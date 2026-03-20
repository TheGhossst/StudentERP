import { dbQuery } from "@/lib/db";
import type { AuthUser } from "@/lib/auth";

export type DashboardStats = {
  totalStudents: number;
  totalFaculty: number;
  totalCourses: number;
  activeSemesterName: string | null;
  pendingLeaveRequests: number;
};

export type NotificationDelivery = {
  channel: "push" | "email" | "sms";
  status: "pending" | "delivered" | "failed";
  deliveredAt: string | null;
};

export type DashboardNotification = {
  id: string;
  title: string;
  message: string;
  createdAt: string;
  isRead: boolean;
  readAt: string | null;
  deliveries: NotificationDelivery[];
};

type DashboardStatsRow = {
  total_students: string;
  total_faculty: string;
  total_courses: string;
  active_semester_name: string | null;
  pending_leave_requests: string;
};

type DashboardNotificationRow = {
  id: string;
  title: string;
  message: string;
  created_at: Date | string;
  is_read: boolean;
  read_at: Date | string | null;
  deliveries: unknown;
};

function toUuidScopeIds(
  user: AuthUser,
  scopeType: "class" | "department",
): string[] {
  return user.roles
    .filter((role) => role.scopeType === scopeType && typeof role.scopeId === "string")
    .map((role) => role.scopeId as string);
}

function normalizeDeliveries(value: unknown): NotificationDelivery[] {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      if (!item || typeof item !== "object") {
        return null;
      }

      const record = item as Record<string, unknown>;
      const channel =
        record.channel === "push" ||
        record.channel === "email" ||
        record.channel === "sms"
          ? record.channel
          : null;

      const status =
        record.status === "pending" ||
        record.status === "delivered" ||
        record.status === "failed"
          ? record.status
          : null;

      if (!channel || !status) {
        return null;
      }

      const deliveredAt =
        typeof record.deliveredAt === "string" ? record.deliveredAt : null;

      return {
        channel,
        status,
        deliveredAt,
      };
    })
    .filter((delivery): delivery is NotificationDelivery => delivery !== null);
}

export async function getDashboardStats(): Promise<DashboardStats> {
  const rows = await dbQuery<DashboardStatsRow>(`
    SELECT
      (SELECT COUNT(*) FROM students WHERE deleted_at IS NULL) AS total_students,
      (SELECT COUNT(*) FROM faculty WHERE deleted_at IS NULL) AS total_faculty,
      (SELECT COUNT(*) FROM courses WHERE deleted_at IS NULL) AS total_courses,
      (SELECT name FROM semesters WHERE is_active = true ORDER BY start_date DESC LIMIT 1) AS active_semester_name,
      (SELECT COUNT(*) FROM leave_requests WHERE status = 'pending') AS pending_leave_requests;
  `);

  const row = rows[0];

  return {
    totalStudents: Number(row?.total_students ?? 0),
    totalFaculty: Number(row?.total_faculty ?? 0),
    totalCourses: Number(row?.total_courses ?? 0),
    activeSemesterName: row?.active_semester_name ?? null,
    pendingLeaveRequests: Number(row?.pending_leave_requests ?? 0),
  };
}

export async function getDashboardNotifications(
  user: AuthUser,
  limit = 20,
): Promise<DashboardNotification[]> {
  const classScopeIds = toUuidScopeIds(user, "class");
  const departmentScopeIds = toUuidScopeIds(user, "department");
  const safeLimit = Math.min(Math.max(limit, 1), 100);

  const rows = await dbQuery<DashboardNotificationRow>(
    `
      WITH candidate_notifications AS (
        SELECT DISTINCT
          n.id,
          n.title,
          n.message,
          n.created_at
        FROM notifications n
        JOIN notification_targets nt ON nt.notification_id = n.id
        WHERE
          (nt.target_type = 'user' AND nt.target_id = $1::uuid)
          OR (nt.target_type = 'class' AND nt.target_id = ANY($2::uuid[]))
          OR (nt.target_type = 'department' AND nt.target_id = ANY($3::uuid[]))
      )
      SELECT
        cn.id,
        cn.title,
        cn.message,
        cn.created_at,
        (nr.read_at IS NOT NULL) AS is_read,
        nr.read_at,
        COALESCE(
          json_agg(
            json_build_object(
              'channel', nd.channel,
              'status', nd.status,
              'deliveredAt', nd.delivered_at
            )
            ORDER BY nd.channel
          ) FILTER (WHERE nd.id IS NOT NULL),
          '[]'::json
        ) AS deliveries
      FROM candidate_notifications cn
      LEFT JOIN notification_reads nr
        ON nr.notification_id = cn.id
       AND nr.user_id = $1::uuid
      LEFT JOIN notification_deliveries nd
        ON nd.notification_id = cn.id
       AND nd.user_id = $1::uuid
      GROUP BY cn.id, cn.title, cn.message, cn.created_at, nr.read_at
      ORDER BY cn.created_at DESC
      LIMIT $4
    `,
    [user.id, classScopeIds, departmentScopeIds, safeLimit],
  );

  return rows.map((row) => ({
    id: row.id,
    title: row.title,
    message: row.message,
    createdAt: new Date(row.created_at).toISOString(),
    isRead: row.is_read,
    readAt: row.read_at ? new Date(row.read_at).toISOString() : null,
    deliveries: normalizeDeliveries(row.deliveries),
  }));
}
