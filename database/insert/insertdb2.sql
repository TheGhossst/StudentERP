-- ============================================================
-- Student ERP System - Bulk Real-World Expansion Seed Data
-- File: insertdb2.sql
-- Target: dbschema.sql v3.0
-- Prerequisite: Run insertdb.sql first
--
-- Goal:
--   Add high-volume realistic data for analytics, dashboards,
--   pagination, and performance testing.
--
-- Notes:
--   1) This script is designed to be safe with existing constraints.
--   2) Uses ON CONFLICT where uniqueness can collide.
--   3) Dates are aligned with the 2025-26 Even / 2026-27 Odd timeline.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 0) Optional feature toggles update (realistic operations)
-- ------------------------------------------------------------
UPDATE feature_flags
SET updated_at = CURRENT_TIMESTAMP,
    enabled = CASE
        WHEN name = 'leave.esign_approval' THEN TRUE
        ELSE enabled
    END
WHERE name IN (
    'attendance.face_recognition',
    'placements.ai_resume_score',
    'fees.auto_reminder',
    'canteen.qr_payment',
    'leave.esign_approval',
    'notifications.sms_fallback'
);

-- ------------------------------------------------------------
-- 1) Large login activity simulation
-- ------------------------------------------------------------
INSERT INTO login_attempts (user_id, email, success, ip_address, attempted_at)
SELECT
    u.id,
    u.email,
    CASE
        WHEN (g.attempt_no % 11 = 0) THEN FALSE
        WHEN (u.base_role = 'admin' AND g.attempt_no % 17 = 0) THEN FALSE
        ELSE TRUE
    END AS success,
    '10.20.' || ((ROW_NUMBER() OVER (ORDER BY u.email) % 40) + 1)::TEXT || '.' || ((g.attempt_no % 240) + 10)::TEXT,
    TIMESTAMP '2026-03-02 07:00:00'
        + ((ROW_NUMBER() OVER (ORDER BY u.email) - 1) * INTERVAL '3 minutes')
        + (g.attempt_no * INTERVAL '9 hours')
FROM users u
CROSS JOIN generate_series(1, 28) AS g(attempt_no);

-- ------------------------------------------------------------
-- 2) Timetable-driven class sessions for upcoming weeks
-- ------------------------------------------------------------
INSERT INTO class_sessions (timetable_id, class_id, course_offering_id, date, status)
SELECT
    t.id,
    t.class_id,
    t.course_offering_id,
    d.class_date,
    CASE
        WHEN (EXTRACT(DAY FROM d.class_date)::INT % 19 = 0) THEN 'rescheduled'
        WHEN (EXTRACT(DAY FROM d.class_date)::INT % 23 = 0) THEN 'cancelled'
        ELSE 'completed'
    END AS status
FROM timetable t
CROSS JOIN LATERAL (
    SELECT gs::DATE AS class_date
    FROM generate_series(DATE '2026-03-23', DATE '2026-07-10', INTERVAL '1 day') gs
    WHERE EXTRACT(ISODOW FROM gs)::INT = t.day_of_week
) d;

INSERT INTO class_changes (class_session_id, type, new_date, new_time_slot_id, reason, created_by)
SELECT
    cs.id,
    CASE WHEN cs.status = 'rescheduled' THEN 'reschedule' ELSE 'cancel' END,
    cs.date + 1,
    ts.id,
    CASE
        WHEN cs.status = 'rescheduled' THEN 'Institute event overlap / faculty committee meeting'
        ELSE 'Room unavailable due to infrastructure maintenance'
    END,
    admin_user.id
FROM class_sessions cs
JOIN users admin_user ON admin_user.email = 'admin.erp@nitgoa.ac.in'
JOIN time_slots ts ON ts.start_time = TIME '14:00'
WHERE cs.date BETWEEN DATE '2026-03-23' AND DATE '2026-07-10'
  AND cs.status IN ('rescheduled', 'cancelled')
  AND NOT EXISTS (
      SELECT 1
      FROM class_changes cc
      WHERE cc.class_session_id = cs.id
  );

-- ------------------------------------------------------------
-- 3) Attendance sessions + queue + records at scale
-- ------------------------------------------------------------
INSERT INTO attendance_sessions (class_session_id, course_offering_id, started_at, ended_at)
SELECT
    cs.id,
    cs.course_offering_id,
    (cs.date::TIMESTAMP + ts.start_time),
    (cs.date::TIMESTAMP + ts.start_time + INTERVAL '24 minutes')
FROM class_sessions cs
JOIN timetable t ON t.id = cs.timetable_id
JOIN time_slots ts ON ts.id = t.time_slot_id
LEFT JOIN attendance_sessions a ON a.class_session_id = cs.id
WHERE cs.status IN ('completed', 'rescheduled')
  AND a.id IS NULL;

INSERT INTO attendance_queue (attendance_session_id, student_id, sequence, status)
SELECT
    asess.id,
    en.student_id,
    ROW_NUMBER() OVER (PARTITION BY asess.id ORDER BY s.roll_number) AS sequence,
    CASE
        WHEN ROW_NUMBER() OVER (PARTITION BY asess.id ORDER BY s.roll_number) % 13 = 0 THEN 'pending'
        ELSE 'done'
    END AS status
FROM attendance_sessions asess
JOIN enrollments en
  ON en.course_offering_id = asess.course_offering_id
 AND en.status = 'enrolled'
JOIN students s ON s.id = en.student_id
ON CONFLICT (attendance_session_id, student_id) DO NOTHING;

INSERT INTO attendance_records (attendance_session_id, student_id, status, recorded_at)
SELECT
    aq.attendance_session_id,
    aq.student_id,
    CASE
        WHEN aq.sequence % 10 = 0 THEN 'absent'
        WHEN aq.sequence % 27 = 0 THEN 'absent'
        ELSE 'present'
    END AS status,
    asess.started_at + (aq.sequence || ' minutes')::INTERVAL
FROM attendance_queue aq
JOIN attendance_sessions asess ON asess.id = aq.attendance_session_id
LEFT JOIN attendance_records ar
  ON ar.attendance_session_id = aq.attendance_session_id
 AND ar.student_id = aq.student_id
WHERE ar.id IS NULL;

-- ------------------------------------------------------------
-- 4) Additional internal assessments (quiz + assignment)
-- ------------------------------------------------------------
INSERT INTO exams (course_offering_id, type, date, max_marks, is_published)
SELECT
    co.id,
    x.exam_type,
    x.exam_date,
    x.max_marks,
    TRUE
FROM course_offerings co
JOIN semesters sem ON sem.id = co.semester_id
JOIN LATERAL (
    VALUES
        ('quiz',       DATE '2026-04-08', 20.0::FLOAT),
        ('quiz',       DATE '2026-04-22', 20.0::FLOAT),
        ('assignment', DATE '2026-04-29', 25.0::FLOAT),
        ('assignment', DATE '2026-05-10', 25.0::FLOAT)
) AS x(exam_type, exam_date, max_marks) ON TRUE
WHERE sem.name = '2025-26 Even';

INSERT INTO marks (student_id, exam_id, marks_obtained)
SELECT
    en.student_id,
    ex.id,
    CASE
        WHEN ex.type = 'quiz' THEN
            CASE
                WHEN z.rn % 13 = 0 THEN 8
                WHEN z.rn % 9 = 0 THEN 11
                WHEN z.rn % 5 = 0 THEN 14
                WHEN z.rn % 3 = 0 THEN 16
                ELSE 18
            END
        ELSE
            CASE
                WHEN z.rn % 13 = 0 THEN 10
                WHEN z.rn % 9 = 0 THEN 14
                WHEN z.rn % 5 = 0 THEN 17
                WHEN z.rn % 3 = 0 THEN 20
                ELSE 23
            END
    END::FLOAT AS marks_obtained
FROM (
    SELECT
        ex.id AS exam_id,
        ex.type,
        en.student_id,
        ROW_NUMBER() OVER (PARTITION BY ex.id ORDER BY s.roll_number) AS rn
    FROM exams ex
    JOIN course_offerings co ON co.id = ex.course_offering_id
    JOIN semesters sem ON sem.id = co.semester_id
    JOIN enrollments en ON en.course_offering_id = ex.course_offering_id
    JOIN students s ON s.id = en.student_id
    WHERE sem.name = '2025-26 Even'
      AND ex.type IN ('quiz', 'assignment')
      AND en.status = 'enrolled'
) z
JOIN exams ex ON ex.id = z.exam_id
JOIN enrollments en ON en.student_id = z.student_id AND en.course_offering_id = ex.course_offering_id
ON CONFLICT (student_id, exam_id) DO NOTHING;

-- ------------------------------------------------------------
-- 5) Bulk notifications for operations, academics, placements
-- ------------------------------------------------------------
WITH creator_pool AS (
    SELECT id, email,
           ROW_NUMBER() OVER (ORDER BY email) AS rn
    FROM users
    WHERE base_role IN ('admin', 'faculty')
),
notif_seed AS (
    SELECT
        gs,
        CASE
            WHEN gs % 6 = 0 THEN 'Placement Update #' || LPAD(gs::TEXT, 3, '0')
            WHEN gs % 5 = 0 THEN 'Exam Circular #' || LPAD(gs::TEXT, 3, '0')
            WHEN gs % 4 = 0 THEN 'Attendance Advisory #' || LPAD(gs::TEXT, 3, '0')
            WHEN gs % 3 = 0 THEN 'Fee Reminder Batch #' || LPAD(gs::TEXT, 3, '0')
            WHEN gs % 2 = 0 THEN 'Library and Lab Notice #' || LPAD(gs::TEXT, 3, '0')
            ELSE 'Campus Operations Bulletin #' || LPAD(gs::TEXT, 3, '0')
        END AS title,
        CASE
            WHEN gs % 6 = 0 THEN 'New shortlist timelines published. Check placement portal for role-level test and interview windows.'
            WHEN gs % 5 = 0 THEN 'Internal exam schedule and seating details updated. Verify room, slot, and reporting time.'
            WHEN gs % 4 = 0 THEN 'Attendance review cycle initiated. Students below threshold should meet advisors this week.'
            WHEN gs % 3 = 0 THEN 'Pending fee accounts have been flagged for reminder workflow. Pay before deadline to avoid holds.'
            WHEN gs % 2 = 0 THEN 'Library network maintenance window announced; digital services may be intermittently unavailable.'
            ELSE 'General administrative update posted by ERP operations team for all active users.'
        END AS message,
        TIMESTAMP '2026-03-24 08:00:00' + (gs * INTERVAL '2 hours') AS created_at
    FROM generate_series(1, 180) gs
),
created AS (
    INSERT INTO notifications (title, message, created_by, created_at)
    SELECT
        n.title,
        n.message,
        cp.id,
        n.created_at
    FROM notif_seed n
    JOIN creator_pool cp ON cp.rn = ((n.gs - 1) % (SELECT COUNT(*) FROM creator_pool)) + 1
    RETURNING id, title
)
INSERT INTO notification_targets (notification_id, target_type, target_id)
SELECT
    c.id,
    t.target_type,
    t.target_id
FROM created c
JOIN LATERAL (
    SELECT 'department'::TEXT AS target_type, d.id AS target_id
    FROM departments d
    WHERE (ABS(hashtext(c.title || d.name)) % 2) = 0
    UNION ALL
    SELECT 'class'::TEXT, cl.id
    FROM classes cl
    WHERE (ABS(hashtext(c.title || cl.section || cl.year::TEXT)) % 5) = 0
) t ON TRUE;

INSERT INTO notification_reads (notification_id, user_id, read_at)
SELECT
    n.id,
    u.id,
    n.created_at + ((ROW_NUMBER() OVER (PARTITION BY n.id ORDER BY u.email) + 5) || ' minutes')::INTERVAL
FROM notifications n
JOIN users u ON u.base_role IN ('student', 'faculty')
WHERE n.created_at >= TIMESTAMP '2026-03-24 08:00:00'
  AND (ABS(hashtext(n.id::TEXT || u.id::TEXT)) % 3) <> 0
ON CONFLICT (notification_id, user_id) DO NOTHING;

INSERT INTO notification_deliveries (notification_id, user_id, channel, status, delivered_at)
SELECT
    n.id,
    u.id,
    ch.channel,
    CASE
        WHEN ABS(hashtext(n.id::TEXT || u.id::TEXT || ch.channel)) % 17 = 0 THEN 'failed'
        ELSE 'delivered'
    END AS status,
    CASE
        WHEN ABS(hashtext(n.id::TEXT || u.id::TEXT || ch.channel)) % 17 = 0 THEN NULL
        ELSE n.created_at + ((ABS(hashtext(u.id::TEXT || ch.channel)) % 50 + 2)::TEXT || ' minutes')::INTERVAL
    END AS delivered_at
FROM notifications n
JOIN users u ON u.base_role IN ('student', 'faculty')
JOIN (VALUES ('push'::TEXT), ('email'::TEXT), ('sms'::TEXT)) ch(channel) ON TRUE
WHERE n.created_at >= TIMESTAMP '2026-03-24 08:00:00'
ON CONFLICT (notification_id, user_id, channel) DO NOTHING;

-- ------------------------------------------------------------
-- 6) Placements expansion: companies, jobs, criteria, applications
-- ------------------------------------------------------------
WITH new_companies AS (
    INSERT INTO companies (name, website, created_at)
    SELECT
        'Campus Recruiter ' || LPAD(gs::TEXT, 3, '0') AS name,
        'https://recruiter' || LPAD(gs::TEXT, 3, '0') || '.example.com' AS website,
        TIMESTAMP '2026-03-20 09:00:00' + (gs * INTERVAL '35 minutes')
    FROM generate_series(1, 120) gs
    ON CONFLICT (name) DO NOTHING
    RETURNING id, name
)
INSERT INTO job_postings (company_id, role, description, deadline, created_at)
SELECT
    c.id,
    r.role,
    r.description,
    r.deadline,
    r.created_at
FROM (
    SELECT id, name FROM companies WHERE name LIKE 'Campus Recruiter %'
) c
JOIN LATERAL (
    VALUES
        ('Software Engineer Graduate Trainee', 'Backend/API development with SQL optimization and integration testing.', TIMESTAMP '2026-06-20 23:59:00', TIMESTAMP '2026-03-25 10:00:00'),
        ('Data and BI Analyst Intern', 'Reporting, ETL sanity checks, dashboards, and stakeholder analytics communication.', TIMESTAMP '2026-06-22 23:59:00', TIMESTAMP '2026-03-25 10:20:00'),
        ('QA Automation Intern', 'Regression suite maintenance, test data strategy, and release signoff checks.', TIMESTAMP '2026-06-24 23:59:00', TIMESTAMP '2026-03-25 10:40:00')
) r(role, description, deadline, created_at) ON TRUE;

INSERT INTO placement_criteria (job_id, min_cgpa, min_attendance, max_backlogs)
SELECT
    jp.id,
    CASE
        WHEN jp.role LIKE '%Software%' THEN 7.0
        WHEN jp.role LIKE '%Data%' THEN 6.8
        ELSE 6.5
    END AS min_cgpa,
    CASE
        WHEN jp.role LIKE '%Software%' THEN 75.0
        WHEN jp.role LIKE '%Data%' THEN 72.0
        ELSE 70.0
    END AS min_attendance,
    CASE
        WHEN jp.role LIKE '%Software%' THEN 1
        WHEN jp.role LIKE '%Data%' THEN 2
        ELSE 2
    END AS max_backlogs
FROM job_postings jp
LEFT JOIN placement_criteria pc ON pc.job_id = jp.id
WHERE pc.job_id IS NULL;

INSERT INTO placement_allowed_departments (job_id, department_id)
SELECT jp.id, d.id
FROM job_postings jp
JOIN departments d ON (
       (jp.role LIKE '%Software%' AND d.name IN ('Computer Science and Engineering', 'Electrical and Electronics Engineering'))
    OR (jp.role LIKE '%Data%' AND d.name IN ('Computer Science and Engineering', 'Electrical and Electronics Engineering', 'Mechanical Engineering'))
    OR (jp.role LIKE '%QA%' AND d.name IN ('Computer Science and Engineering', 'Electrical and Electronics Engineering', 'Mechanical Engineering'))
)
ON CONFLICT (job_id, department_id) DO NOTHING;

INSERT INTO placement_allowed_programs (job_id, program_id)
SELECT jp.id, p.id
FROM job_postings jp
JOIN programs p ON p.name IN ('BTech', 'MTech')
ON CONFLICT (job_id, program_id) DO NOTHING;

INSERT INTO applications (student_id, job_id, status, applied_at)
SELECT
    s.id,
    jp.id,
    CASE
        WHEN ABS(hashtext(s.roll_number || jp.id::TEXT)) % 17 = 0 THEN 'shortlisted'
        WHEN ABS(hashtext(s.roll_number || jp.id::TEXT)) % 29 = 0 THEN 'rejected'
        ELSE 'applied'
    END AS status,
    TIMESTAMP '2026-03-28 09:00:00'
      + ((ABS(hashtext(s.id::TEXT || jp.id::TEXT)) % 900)::TEXT || ' minutes')::INTERVAL
FROM students s
JOIN classes cl ON cl.id = s.class_id
JOIN departments d ON d.id = cl.department_id
JOIN programs p ON p.id = cl.program_id
JOIN job_postings jp ON jp.created_at >= TIMESTAMP '2026-03-25 10:00:00'
JOIN placement_allowed_departments pad
  ON pad.job_id = jp.id
 AND pad.department_id = d.id
JOIN placement_allowed_programs pap
  ON pap.job_id = jp.id
 AND pap.program_id = p.id
WHERE ABS(hashtext(s.roll_number || jp.id::TEXT)) % 4 <> 0
ON CONFLICT (student_id, job_id) DO NOTHING;

-- ------------------------------------------------------------
-- 7) Additional fee cycles and payments
-- ------------------------------------------------------------
INSERT INTO fees (student_id, amount, due_date, type, semester_id, status, version, created_at)
SELECT
    s.id,
    CASE
        WHEN c.year = 1 THEN 38000
        WHEN c.year = 2 THEN 42000
        ELSE 46000
    END::FLOAT AS amount,
    DATE '2026-08-25',
    'hostel',
    sem.id,
    'pending',
    1,
    TIMESTAMP '2026-06-15 10:00:00'
FROM students s
JOIN classes c ON c.id = s.class_id
JOIN semesters sem ON sem.name = '2026-27 Odd';

INSERT INTO fees (student_id, amount, due_date, type, semester_id, status, version, created_at)
SELECT
    s.id,
    4500::FLOAT,
    DATE '2026-07-30',
    'library',
    sem.id,
    'pending',
    1,
    TIMESTAMP '2026-06-18 11:00:00'
FROM students s
JOIN semesters sem ON sem.name = '2026-27 Odd';

INSERT INTO fee_payments (fee_id, amount_paid, payment_method, transaction_id, paid_at)
SELECT
    f.id,
    CASE
        WHEN f.type = 'hostel' THEN ROUND((f.amount * CASE WHEN seq.n % 3 = 0 THEN 1.0 ELSE 0.55 END)::numeric, 2)::FLOAT
        ELSE ROUND((f.amount * CASE WHEN seq.n % 4 = 0 THEN 1.0 ELSE 0.60 END)::numeric, 2)::FLOAT
    END AS amount_paid,
    CASE
        WHEN seq.n % 3 = 0 THEN 'netbanking'
        WHEN seq.n % 2 = 0 THEN 'card'
        ELSE 'upi'
    END AS payment_method,
    'TXN-BULK-' || LPAD(seq.n::TEXT, 7, '0') || '-' || SUBSTRING(f.id::TEXT, 1, 8),
    TIMESTAMP '2026-07-01 09:00:00' + (seq.n * INTERVAL '7 minutes')
FROM (
    SELECT id, amount, type,
           ROW_NUMBER() OVER (ORDER BY created_at, id) AS n
    FROM fees
    WHERE created_at >= TIMESTAMP '2026-06-15 00:00:00'
) f
JOIN LATERAL (
    SELECT f.n AS n
) seq ON TRUE;

-- ------------------------------------------------------------
-- 8) Canteen demand surge: more items, orders, order_items, payments
-- ------------------------------------------------------------
INSERT INTO canteen_items (name, price, available)
SELECT
    x.name,
    x.price,
    TRUE
FROM (
    VALUES
    ('Veg Puff', 22.0),
    ('Egg Puff', 28.0),
    ('Samosa Plate', 30.0),
    ('Chole Bhature', 75.0),
    ('Pav Bhaji', 68.0),
    ('Veg Noodles', 72.0),
    ('Chicken Noodles', 95.0),
    ('Curd Rice', 48.0),
    ('Aloo Paratha', 52.0),
    ('Paneer Paratha', 64.0),
    ('Mini Meal', 110.0),
    ('Brownie', 45.0),
    ('Muffin', 35.0),
    ('Lassi', 40.0),
    ('Buttermilk', 20.0),
    ('Orange Juice', 55.0),
    ('Protein Shake', 95.0),
    ('Boiled Eggs', 30.0),
    ('Sprouts Bowl', 50.0),
    ('Veg Cutlet', 38.0)
) AS x(name, price)
WHERE NOT EXISTS (
    SELECT 1
    FROM canteen_items ci
    WHERE ci.name = x.name
);

INSERT INTO orders (student_id, status, type, total_amount, version, created_at)
SELECT
    s.id,
    CASE
        WHEN g.seq % 9 = 0 THEN 'ready'
        WHEN g.seq % 5 = 0 THEN 'preparing'
        ELSE 'completed'
    END AS status,
    CASE WHEN g.seq % 4 = 0 THEN 'dine-in' ELSE 'takeaway' END AS type,
    0,
    1,
    TIMESTAMP '2026-03-24 08:00:00'
      + (((ROW_NUMBER() OVER (ORDER BY s.roll_number) - 1) * 60 + g.seq * 8)::TEXT || ' minutes')::INTERVAL
FROM students s
CROSS JOIN generate_series(1, 32) AS g(seq);

INSERT INTO order_items (order_id, canteen_item_id, quantity, unit_price)
SELECT
    o.id,
    ci.id,
    CASE WHEN pick.line_no = 3 THEN 2 ELSE 1 END AS quantity,
    ci.price
FROM (
    SELECT id,
           ROW_NUMBER() OVER (ORDER BY created_at, id) AS order_no
    FROM orders
    WHERE created_at >= TIMESTAMP '2026-03-24 08:00:00'
) o
JOIN LATERAL (
    VALUES
        (1, (o.order_no % 35) + 1),
        (2, ((o.order_no + 7) % 35) + 1),
        (3, ((o.order_no + 15) % 35) + 1)
) AS pick(line_no, item_no) ON TRUE
JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY name, id) AS item_no, price
    FROM canteen_items
) ci ON ci.item_no = pick.item_no;

INSERT INTO payments (order_id, amount, payment_method, status, paid_at)
SELECT
    o.id,
    o.total_amount,
    CASE
        WHEN o.rn % 4 = 0 THEN 'wallet'
        WHEN o.rn % 3 = 0 THEN 'card'
        WHEN o.rn % 2 = 0 THEN 'cash'
        ELSE 'upi'
    END AS payment_method,
    CASE
        WHEN o.rn % 14 = 0 THEN 'pending'
        WHEN o.rn % 29 = 0 THEN 'failed'
        ELSE 'paid'
    END AS status,
    CASE
        WHEN o.rn % 14 = 0 OR o.rn % 29 = 0 THEN NULL
        ELSE o.created_at + INTERVAL '18 minutes'
    END AS paid_at
FROM (
    SELECT id, created_at, total_amount,
           ROW_NUMBER() OVER (ORDER BY created_at, id) AS rn
    FROM orders
    WHERE created_at >= TIMESTAMP '2026-03-24 08:00:00'
) o;

-- ------------------------------------------------------------
-- 9) Leave requests at scale with documents and workflow steps
-- ------------------------------------------------------------
INSERT INTO leave_requests (student_id, from_date, to_date, reason, status, current_step, version, created_at)
SELECT
    s.id,
    DATE '2026-04-05' + (g.seq % 55),
    DATE '2026-04-05' + (g.seq % 55) + (g.seq % 3),
    CASE
        WHEN g.seq % 5 = 0 THEN 'Medical follow-up and doctor advised rest'
        WHEN g.seq % 4 = 0 THEN 'Family function travel and return logistics'
        WHEN g.seq % 3 = 0 THEN 'Technical competition participation with institute team'
        WHEN g.seq % 2 = 0 THEN 'Personal emergency and travel'
        ELSE 'Official student activity participation'
    END AS reason,
    'pending',
    1,
    1,
    TIMESTAMP '2026-03-26 09:00:00' + ((g.seq + ROW_NUMBER() OVER (ORDER BY s.roll_number)) * INTERVAL '6 minutes')
FROM students s
CROSS JOIN generate_series(1, 3) AS g(seq)
WHERE s.current_sem >= 2;

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 1, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'CR'
LEFT JOIN leave_approval_steps las
  ON las.leave_request_id = lr.id
 AND las.step_order = 1
WHERE las.id IS NULL;

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 2, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'advisor'
LEFT JOIN leave_approval_steps las
  ON las.leave_request_id = lr.id
 AND las.step_order = 2
WHERE las.id IS NULL;

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 3, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'HoD'
LEFT JOIN leave_approval_steps las
  ON las.leave_request_id = lr.id
 AND las.step_order = 3
WHERE las.id IS NULL;

INSERT INTO leave_documents (leave_request_id, file_url)
SELECT
    lr.id,
    'https://docs.campus.edu/leave/bulk/' || REPLACE(s.roll_number, ' ', '') || '_' || SUBSTRING(lr.id::TEXT, 1, 8) || '.pdf'
FROM leave_requests lr
JOIN students s ON s.id = lr.student_id
WHERE lr.created_at >= TIMESTAMP '2026-03-26 09:00:00'
  AND ABS(hashtext(lr.id::TEXT)) % 3 = 0
  AND NOT EXISTS (
      SELECT 1
      FROM leave_documents ld
      WHERE ld.leave_request_id = lr.id
  );

-- ------------------------------------------------------------
-- 10) High-volume audit logs
-- ------------------------------------------------------------
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, metadata, timestamp)
SELECT
    u.id,
    x.action,
    x.entity_type,
    NULL,
    x.metadata,
    x.ts
FROM (
    SELECT
        userset.id AS user_id,
        CASE
            WHEN g.seq % 7 = 0 THEN 'UPDATE'
            WHEN g.seq % 5 = 0 THEN 'CREATE'
            WHEN g.seq % 3 = 0 THEN 'READ'
            ELSE 'LOGIN'
        END AS action,
        CASE
            WHEN g.seq % 11 = 0 THEN 'attendance_record'
            WHEN g.seq % 9 = 0 THEN 'application'
            WHEN g.seq % 7 = 0 THEN 'fee'
            WHEN g.seq % 5 = 0 THEN 'notification'
            WHEN g.seq % 3 = 0 THEN 'order'
            ELSE 'user'
        END AS entity_type,
        jsonb_build_object(
            'module', CASE
                WHEN g.seq % 11 = 0 THEN 'attendance'
                WHEN g.seq % 9 = 0 THEN 'placements'
                WHEN g.seq % 7 = 0 THEN 'fees'
                WHEN g.seq % 5 = 0 THEN 'notifications'
                WHEN g.seq % 3 = 0 THEN 'canteen'
                ELSE 'auth'
            END,
            'trace_seq', g.seq,
            'source', 'bulk_seed_v2'
        ) AS metadata,
        TIMESTAMP '2026-03-01 06:00:00'
          + (((ROW_NUMBER() OVER (ORDER BY userset.email) - 1) * 5 + g.seq * 13)::TEXT || ' minutes')::INTERVAL AS ts
    FROM (
        SELECT id, email
        FROM users
    ) userset
    CROSS JOIN generate_series(1, 45) g(seq)
) x
JOIN users u ON u.id = x.user_id;

-- ------------------------------------------------------------
-- 11) Event bus expansion for stream processing tests
-- ------------------------------------------------------------
INSERT INTO events (type, payload, created_at)
SELECT
    CASE
        WHEN gs % 10 = 0 THEN 'attendance.session.started'
        WHEN gs % 9 = 0 THEN 'attendance.session.closed'
        WHEN gs % 8 = 0 THEN 'exam.marks.published'
        WHEN gs % 7 = 0 THEN 'fees.reminder.sent'
        WHEN gs % 6 = 0 THEN 'placement.job.opened'
        WHEN gs % 5 = 0 THEN 'placement.application.received'
        WHEN gs % 4 = 0 THEN 'leave.request.created'
        WHEN gs % 3 = 0 THEN 'notification.dispatched'
        WHEN gs % 2 = 0 THEN 'canteen.order.created'
        ELSE 'canteen.payment.captured'
    END AS type,
    jsonb_build_object(
        'batch', 'insertdb2',
        'event_no', gs,
        'priority', CASE WHEN gs % 12 = 0 THEN 'high' WHEN gs % 4 = 0 THEN 'medium' ELSE 'normal' END,
        'trace', md5(gs::TEXT)
    ) AS payload,
    TIMESTAMP '2026-03-20 00:00:00' + (gs * INTERVAL '5 minutes')
FROM generate_series(1, 6000) gs;

COMMIT;

-- ============================================================
-- Optional sanity checks after running this script:
--   SELECT COUNT(*) FROM login_attempts;
--   SELECT COUNT(*) FROM class_sessions;
--   SELECT COUNT(*) FROM attendance_sessions;
--   SELECT COUNT(*) FROM attendance_records;
--   SELECT COUNT(*) FROM exams WHERE type IN ('quiz','assignment');
--   SELECT COUNT(*) FROM marks;
--   SELECT COUNT(*) FROM notifications;
--   SELECT COUNT(*) FROM notification_deliveries;
--   SELECT COUNT(*) FROM companies;
--   SELECT COUNT(*) FROM job_postings;
--   SELECT COUNT(*) FROM applications;
--   SELECT COUNT(*) FROM fees;
--   SELECT COUNT(*) FROM orders;
--   SELECT COUNT(*) FROM order_items;
--   SELECT COUNT(*) FROM payments;
--   SELECT COUNT(*) FROM leave_requests;
--   SELECT COUNT(*) FROM audit_logs;
--   SELECT COUNT(*) FROM events;
-- ============================================================