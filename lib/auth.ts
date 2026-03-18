import { SignJWT, jwtVerify, type JWTPayload } from "jose";
import { type NextRequest } from "next/server";

import { dbQuery } from "@/lib/db";

type BaseRole = "student" | "faculty" | "admin";

export type RoleAssignment = {
  name: string;
  scopeType: "class" | "department" | "year" | null;
  scopeId: string | null;
};

export type AuthUser = {
  id: string;
  email: string;
  baseRole: BaseRole;
  status: "active" | "suspended" | "deleted";
  roles: RoleAssignment[];
};

type UserWithPassword = AuthUser & {
  passwordHash: string;
};

type LoginResult = {
  ok: boolean;
  statusCode: number;
  message: string;
  user?: AuthUser;
  token?: string;
};

type SessionPayload = JWTPayload & {
  sub: string;
};

const SESSION_COOKIE_NAME = "studenterp_session";
const SESSION_DURATION_SECONDS = 60 * 60 * 8;

function getJwtSecret(): Uint8Array {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new Error("JWT_SECRET is not set. Add it to your environment variables.");
  }

  return new TextEncoder().encode(secret);
}

function normalizeRoleAssignments(value: unknown): RoleAssignment[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      if (typeof item !== "object" || !item) {
        return null;
      }

      const record = item as Record<string, unknown>;
      const name = typeof record.name === "string" ? record.name : null;

      if (!name) {
        return null;
      }

      const scopeType =
        record.scopeType === "class" ||
        record.scopeType === "department" ||
        record.scopeType === "year"
          ? record.scopeType
          : null;

      const scopeId = typeof record.scopeId === "string" ? record.scopeId : null;

      return {
        name,
        scopeType,
        scopeId,
      };
    })
    .filter((role): role is RoleAssignment => role !== null);
}

type UserRow = {
  id: string;
  email: string;
  password_hash: string;
  base_role: BaseRole;
  status: "active" | "suspended" | "deleted";
  role_assignments: unknown;
};

async function getUserByEmail(email: string): Promise<UserWithPassword | null> {
  const rows = await dbQuery<UserRow>(
    `
      SELECT
        u.id,
        u.email,
        u.password_hash,
        u.base_role,
        u.status,
        COALESCE(
          json_agg(
            json_build_object(
              'name', r.name,
              'scopeType', ur.scope_type,
              'scopeId', ur.scope_id
            )
            ORDER BY r.name
          ) FILTER (WHERE r.id IS NOT NULL),
          '[]'::json
        ) AS role_assignments
      FROM users u
      LEFT JOIN user_roles ur ON ur.user_id = u.id
      LEFT JOIN roles r ON r.id = ur.role_id
      WHERE lower(u.email) = lower($1)
      GROUP BY u.id
    `,
    [email],
  );

  const row = rows[0];

  if (!row) {
    return null;
  }

  return {
    id: row.id,
    email: row.email,
    passwordHash: row.password_hash,
    baseRole: row.base_role,
    status: row.status,
    roles: normalizeRoleAssignments(row.role_assignments),
  };
}

type UserByIdRow = Omit<UserRow, "password_hash">;

async function getUserById(userId: string): Promise<AuthUser | null> {
  const rows = await dbQuery<UserByIdRow>(
    `
      SELECT
        u.id,
        u.email,
        u.base_role,
        u.status,
        COALESCE(
          json_agg(
            json_build_object(
              'name', r.name,
              'scopeType', ur.scope_type,
              'scopeId', ur.scope_id
            )
            ORDER BY r.name
          ) FILTER (WHERE r.id IS NOT NULL),
          '[]'::json
        ) AS role_assignments
      FROM users u
      LEFT JOIN user_roles ur ON ur.user_id = u.id
      LEFT JOIN roles r ON r.id = ur.role_id
      WHERE u.id = $1
      GROUP BY u.id
    `,
    [userId],
  );

  const row = rows[0];

  if (!row) {
    return null;
  }

  return {
    id: row.id,
    email: row.email,
    baseRole: row.base_role,
    status: row.status,
    roles: normalizeRoleAssignments(row.role_assignments),
  };
}

type PasswordCheckRow = {
  is_valid: boolean;
};

async function verifyPassword(password: string, passwordHash: string): Promise<boolean> {
  const rows = await dbQuery<PasswordCheckRow>(
    `
      SELECT crypt($1, $2) = $2 AS is_valid
    `,
    [password, passwordHash],
  );

  return rows[0]?.is_valid === true;
}

async function recordLoginAttempt(params: {
  userId?: string;
  email: string;
  success: boolean;
  ipAddress: string | null;
}) {
  await dbQuery(
    `
      INSERT INTO login_attempts (user_id, email, success, ip_address)
      VALUES ($1, $2, $3, $4)
    `,
    [params.userId ?? null, params.email, params.success, params.ipAddress],
  );
}

export async function createSessionToken(userId: string): Promise<string> {
  const secret = getJwtSecret();

  return await new SignJWT({})
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime(`${SESSION_DURATION_SECONDS}s`)
    .sign(secret);
}

export async function verifySessionToken(token: string): Promise<SessionPayload | null> {
  try {
    const secret = getJwtSecret();
    const result = await jwtVerify<SessionPayload>(token, secret, {
      algorithms: ["HS256"],
    });
    return result.payload;
  } catch {
    return null;
  }
}

export function getSessionCookieName() {
  return SESSION_COOKIE_NAME;
}

export function getSessionDurationSeconds() {
  return SESSION_DURATION_SECONDS;
}

export function getClientIp(request: NextRequest): string | null {
  const forwardedFor = request.headers.get("x-forwarded-for");

  if (forwardedFor) {
    return forwardedFor.split(",")[0]?.trim() ?? null;
  }

  return request.headers.get("x-real-ip");
}

export async function loginWithEmailAndPassword(params: {
  email: string;
  password: string;
  ipAddress: string | null;
}): Promise<LoginResult> {
  const user = await getUserByEmail(params.email);

  if (!user) {
    await recordLoginAttempt({
      email: params.email,
      success: false,
      ipAddress: params.ipAddress,
    });

    return {
      ok: false,
      statusCode: 401,
      message: "Invalid email or password.",
    };
  }

  if (user.status !== "active") {
    await recordLoginAttempt({
      userId: user.id,
      email: user.email,
      success: false,
      ipAddress: params.ipAddress,
    });

    return {
      ok: false,
      statusCode: 403,
      message: "User account is not active.",
    };
  }

  const passwordIsValid = await verifyPassword(params.password, user.passwordHash);

  if (!passwordIsValid) {
    await recordLoginAttempt({
      userId: user.id,
      email: user.email,
      success: false,
      ipAddress: params.ipAddress,
    });

    return {
      ok: false,
      statusCode: 401,
      message: "Invalid email or password.",
    };
  }

  await recordLoginAttempt({
    userId: user.id,
    email: user.email,
    success: true,
    ipAddress: params.ipAddress,
  });

  const token = await createSessionToken(user.id);

  return {
    ok: true,
    statusCode: 200,
    message: "Login successful.",
    token,
    user: {
      id: user.id,
      email: user.email,
      baseRole: user.baseRole,
      status: user.status,
      roles: user.roles,
    },
  };
}

export async function getAuthenticatedUser(request: NextRequest): Promise<AuthUser | null> {
  const token = request.cookies.get(SESSION_COOKIE_NAME)?.value;

  if (!token) {
    return null;
  }

  const payload = await verifySessionToken(token);

  if (!payload?.sub) {
    return null;
  }

  const user = await getUserById(payload.sub);

  if (!user || user.status !== "active") {
    return null;
  }

  return user;
}

export function userHasAnyRole(user: AuthUser, roleNames: string[]): boolean {
  if (roleNames.length === 0) {
    return true;
  }

  const allowed = new Set(roleNames.map((name) => name.toLowerCase()));

  return user.roles.some((role) => allowed.has(role.name.toLowerCase()));
}

export function userHasBaseRole(user: AuthUser, baseRoles: BaseRole[]): boolean {
  if (baseRoles.length === 0) {
    return true;
  }

  return baseRoles.includes(user.baseRole);
}