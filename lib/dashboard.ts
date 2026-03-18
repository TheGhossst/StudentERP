import { dbQuery } from "@/lib/db";

export type DashboardStats = {
  totalStudents: number;
  totalFaculty: number;
  totalCourses: number;
  activeSemesterName: string | null;
  pendingLeaveRequests: number;
};

type DashboardStatsRow = {
  total_students: string;
  total_faculty: string;
  total_courses: string;
  active_semester_name: string | null;
  pending_leave_requests: string;
};

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
