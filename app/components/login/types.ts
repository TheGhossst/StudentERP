export interface AuthUser {
  id: string;
  email: string;
  baseRole: "student" | "faculty" | "admin";
  status: "active" | "suspended" | "deleted";
  roles: Array<{
    name: string;
    scopeType: "class" | "department" | "year" | null;
    scopeId: string | null;
  }>;
}

export interface LoginApiResponse {
  message?: string;
  error?: string;
  user?: AuthUser;
}
