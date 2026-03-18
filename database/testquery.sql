-- ============================================================
-- Student ERP System - Validation Queries
-- File: testquery.sql
-- Usage:
--   1) Run after dbschema.sql and insertdb.sql
--   2) Review rows where status = 'FAIL' or anomaly_count > 0
-- ============================================================

-- ------------------------------------------------------------
-- 1) Basic row-count smoke tests
-- ------------------------------------------------------------

SELECT current_user, session_user;

SELECT COUNT(*) AS users_count FROM users;
SELECT COUNT(*) AS students_count FROM students;
SELECT COUNT(*) AS faculty_count FROM faculty;

select * from users;
SELECT 'users >= 40' AS check_name,
       CASE WHEN COUNT(*) >= 40 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM users;

SELECT 'students >= 30' AS check_name,
       CASE WHEN COUNT(*) >= 30 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM students;

SELECT 'faculty >= 8' AS check_name,
       CASE WHEN COUNT(*) >= 8 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM faculty;

SELECT 'courses >= 12' AS check_name,
       CASE WHEN COUNT(*) >= 12 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM courses;

SELECT 'course_offerings >= 12' AS check_name,
       CASE WHEN COUNT(*) >= 12 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM course_offerings;

SELECT 'enrollments > 0' AS check_name,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM enrollments;

SELECT 'attendance_records > 0' AS check_name,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM attendance_records;

SELECT 'applications >= 20' AS check_name,
       CASE WHEN COUNT(*) >= 20 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM applications;

-- ------------------------------------------------------------
-- 2) Referential integrity anomaly checks (should be zero)
-- ------------------------------------------------------------
SELECT 'students without users' AS check_name,
       COUNT(*) AS anomaly_count
FROM students s
LEFT JOIN users u ON u.id = s.user_id
WHERE u.id IS NULL;

SELECT 'faculty without users' AS check_name,
       COUNT(*) AS anomaly_count
FROM faculty f
LEFT JOIN users u ON u.id = f.user_id
WHERE u.id IS NULL;

SELECT 'enrollments without mapped class eligibility' AS check_name,
       COUNT(*) AS anomaly_count
FROM enrollments e
JOIN students s ON s.id = e.student_id
LEFT JOIN course_offering_classes coc
       ON coc.course_offering_id = e.course_offering_id
      AND coc.class_id = s.class_id
WHERE coc.course_offering_id IS NULL;

SELECT 'attendance records without enrollment' AS check_name,
       COUNT(*) AS anomaly_count
FROM attendance_records ar
JOIN attendance_sessions ass ON ass.id = ar.attendance_session_id
LEFT JOIN enrollments e
       ON e.student_id = ar.student_id
      AND e.course_offering_id = ass.course_offering_id
      AND e.status = 'enrolled'
WHERE e.id IS NULL;

SELECT 'orphan notification_targets target IDs' AS check_name,
       COUNT(*) AS anomaly_count
FROM notification_targets nt
WHERE (nt.target_type = 'user' AND NOT EXISTS (
          SELECT 1 FROM users u WHERE u.id = nt.target_id
      ))
   OR (nt.target_type = 'class' AND NOT EXISTS (
          SELECT 1 FROM classes c WHERE c.id = nt.target_id
      ))
   OR (nt.target_type = 'department' AND NOT EXISTS (
          SELECT 1 FROM departments d WHERE d.id = nt.target_id
      ))
   OR (nt.target_type = 'course_offering' AND NOT EXISTS (
          SELECT 1 FROM course_offerings co WHERE co.id = nt.target_id
      ));

-- ------------------------------------------------------------
-- 3) Trigger-derived consistency checks
-- ------------------------------------------------------------
-- attendance_summary must match attendance_records rollup
WITH recomputed AS (
    SELECT
        ar.student_id,
        ass.course_offering_id,
        COUNT(*)::INT AS total_classes,
        SUM(CASE WHEN ar.status = 'present' THEN 1 ELSE 0 END)::INT AS attended_classes
    FROM attendance_records ar
    JOIN attendance_sessions ass ON ass.id = ar.attendance_session_id
    GROUP BY ar.student_id, ass.course_offering_id
)
SELECT 'attendance_summary mismatch rows' AS check_name,
       COUNT(*) AS anomaly_count
FROM (
    SELECT
        COALESCE(a.student_id, r.student_id) AS student_id,
        COALESCE(a.course_offering_id, r.course_offering_id) AS course_offering_id,
        COALESCE(a.total_classes, 0) AS stored_total,
        COALESCE(r.total_classes, 0) AS recomputed_total,
        COALESCE(a.attended_classes, 0) AS stored_attended,
        COALESCE(r.attended_classes, 0) AS recomputed_attended
    FROM attendance_summary a
    FULL OUTER JOIN recomputed r
      ON a.student_id = r.student_id
     AND a.course_offering_id = r.course_offering_id
) x
WHERE stored_total <> recomputed_total
   OR stored_attended <> recomputed_attended;

-- fees.amount_paid and fees.status must match fee_payments
WITH agg AS (
    SELECT fee_id, COALESCE(SUM(amount_paid), 0) AS total_paid
    FROM fee_payments
    GROUP BY fee_id
)
SELECT 'fees total/status mismatch rows' AS check_name,
       COUNT(*) AS anomaly_count
FROM fees f
LEFT JOIN agg a ON a.fee_id = f.id
WHERE COALESCE(f.amount_paid, 0) <> COALESCE(a.total_paid, 0)
   OR f.status <> CASE
                     WHEN COALESCE(a.total_paid, 0) <= 0 THEN 'pending'
                     WHEN COALESCE(a.total_paid, 0) >= f.amount THEN 'paid'
                     ELSE 'partial'
                  END;

-- orders.total_amount must match sum(quantity * unit_price)
WITH agg AS (
    SELECT order_id, COALESCE(SUM(quantity * unit_price), 0) AS calc_total
    FROM order_items
    GROUP BY order_id
)
SELECT 'orders total mismatch rows' AS check_name,
       COUNT(*) AS anomaly_count
FROM orders o
LEFT JOIN agg a ON a.order_id = o.id
WHERE COALESCE(o.total_amount, 0) <> COALESCE(a.calc_total, 0);

-- ------------------------------------------------------------
-- 4) Business rule checks
-- ------------------------------------------------------------
SELECT 'applications after deadline' AS check_name,
       COUNT(*) AS anomaly_count
FROM applications a
JOIN job_postings jp ON jp.id = a.job_id
WHERE a.applied_at > jp.deadline;

SELECT 'leave_requests invalid date range' AS check_name,
       COUNT(*) AS anomaly_count
FROM leave_requests
WHERE to_date < from_date;

SELECT 'class_sessions invalid status' AS check_name,
       COUNT(*) AS anomaly_count
FROM class_sessions
WHERE status NOT IN ('scheduled', 'cancelled', 'completed', 'rescheduled');

SELECT 'attendance_queue duplicate sequence per session' AS check_name,
       COUNT(*) AS anomaly_count
FROM (
    SELECT attendance_session_id, sequence, COUNT(*) AS c
    FROM attendance_queue
    GROUP BY attendance_session_id, sequence
    HAVING COUNT(*) > 1
) d;

-- ------------------------------------------------------------
-- 5) Materialized view checks
-- ------------------------------------------------------------
REFRESH MATERIALIZED VIEW student_dashboard;
REFRESH MATERIALIZED VIEW student_gpa;

SELECT 'student_dashboard rows > 0' AS check_name,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM student_dashboard;

SELECT 'student_gpa rows > 0' AS check_name,
       CASE WHEN COUNT(*) > 0 THEN 'PASS' ELSE 'FAIL' END AS status,
       COUNT(*) AS actual_count
FROM student_gpa;

SELECT 'student_gpa range check (0..10)' AS check_name,
       COUNT(*) AS anomaly_count
FROM student_gpa
WHERE gpa < 0 OR gpa > 10;

-- ------------------------------------------------------------
-- 6) Quick health snapshots (informational)
-- ------------------------------------------------------------
SELECT status, COUNT(*) AS count_by_status
FROM fees
GROUP BY status
ORDER BY status;

SELECT status, COUNT(*) AS count_by_status
FROM applications
GROUP BY status
ORDER BY status;

SELECT status, COUNT(*) AS count_by_status
FROM orders
GROUP BY status
ORDER BY status;

SELECT type, COUNT(*) AS event_count
FROM events
GROUP BY type
ORDER BY event_count DESC, type;
