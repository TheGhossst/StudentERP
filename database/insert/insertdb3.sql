-- ============================================================
-- Student ERP System - People Data Expansion (Students + Faculty)
-- File: insertdb3.sql
-- Target: dbschema.sql v3.0
-- Prerequisite: Run dbschema.sql, then insertdb.sql
--
-- Purpose:
--   Increase only core people master data:
--   - users
--   - students
--   - student_profiles
--   - student_academic_history
--   - faculty
--
-- Intentionally excluded:
--   login_attempts, attendance, notifications, events, fees,
--   placements, canteen, and other transactional tables.
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- 1) Expand faculty user accounts (high volume, realistic naming)
-- ------------------------------------------------------------
WITH dept_codes AS (
    SELECT 'Computer Science and Engineering'::TEXT AS dept_name, 'cse'::TEXT AS dept_code, 30::INT AS per_dept
    UNION ALL SELECT 'Electrical and Electronics Engineering', 'eee', 22
    UNION ALL SELECT 'Mechanical Engineering', 'me', 18
    UNION ALL SELECT 'Humanities and Social Sciences', 'hss', 12
),
faculty_seed AS (
    SELECT
        dc.dept_name,
        dc.dept_code,
        gs AS seq,
        ('faculty.' || dc.dept_code || LPAD(gs::TEXT, 3, '0') || '@nitgoa.ac.in')::TEXT AS email,
        CASE WHEN gs % 5 = 0 THEN 'contract' ELSE 'permanent' END AS fac_type
    FROM dept_codes dc
    CROSS JOIN LATERAL generate_series(1, dc.per_dept) gs
),
ins_users AS (
    INSERT INTO users (email, password_hash, base_role, status)
    SELECT
        fs.email,
        crypt('NitGoa@123', gen_salt('bf', 12)),
        'faculty',
        'active'
    FROM faculty_seed fs
    ON CONFLICT (email) DO NOTHING
    RETURNING id, email
)
INSERT INTO faculty (user_id, department_id, type)
SELECT
    u.id,
    d.id,
    fs.fac_type
FROM faculty_seed fs
JOIN users u ON u.email = fs.email
JOIN departments d ON d.name = fs.dept_name
LEFT JOIN faculty f ON f.user_id = u.id
WHERE f.id IS NULL;

-- ------------------------------------------------------------
-- 2) Expand student user accounts + students table
-- ------------------------------------------------------------
WITH class_dim AS (
    SELECT
        c.id AS class_id,
        c.year,
        c.section,
        d.name AS dept_name,
        p.name AS program_name,
        CASE
            WHEN p.name = 'BTech' THEN 'BT'
            WHEN p.name = 'MTech' THEN 'MT'
            ELSE 'PH'
        END AS prog_prefix,
        CASE
            WHEN d.name = 'Computer Science and Engineering' THEN 'CSE'
            WHEN d.name = 'Electrical and Electronics Engineering' THEN 'EEE'
            WHEN d.name = 'Mechanical Engineering' THEN 'ME'
            WHEN d.name = 'Humanities and Social Sciences' THEN 'HSS'
            ELSE 'GEN'
        END AS dept_code,
        CASE
            WHEN p.name = 'BTech' AND c.year = 1 THEN 120
            WHEN p.name = 'BTech' AND c.year = 2 THEN 95
            WHEN p.name = 'BTech' AND c.year = 3 THEN 80
            WHEN p.name = 'MTech' AND c.year = 1 THEN 40
            ELSE 30
        END AS target_per_class
    FROM classes c
    JOIN departments d ON d.id = c.department_id
    JOIN programs p ON p.id = c.program_id
),
student_seed AS (
    SELECT
        cd.class_id,
        cd.year,
        cd.section,
        cd.dept_name,
        cd.program_name,
        cd.prog_prefix,
        cd.dept_code,
        gs AS seq,
        (cd.prog_prefix
            || LPAD((26 - (cd.year - 1))::TEXT, 2, '0')
            || cd.dept_code
            || cd.section
            || LPAD(gs::TEXT, 3, '0'))::TEXT AS roll_number,
        ('student.'
            || LOWER(cd.dept_code)
            || cd.section
            || LPAD((26 - (cd.year - 1))::TEXT, 2, '0')
            || LPAD(gs::TEXT, 3, '0')
            || '@nitgoa.ac.in')::TEXT AS email,
        CASE
            WHEN cd.program_name IN ('BTech', 'MTech') THEN (2 * cd.year - 1)
            ELSE LEAST(2 * cd.year - 1, 14)
        END AS current_sem
    FROM class_dim cd
    CROSS JOIN LATERAL generate_series(1, cd.target_per_class) gs
),
ins_student_users AS (
    INSERT INTO users (email, password_hash, base_role, status)
    SELECT
        ss.email,
        crypt('NitGoa@123', gen_salt('bf', 12)),
        'student',
        'active'
    FROM student_seed ss
    ON CONFLICT (email) DO NOTHING
    RETURNING id, email
)
INSERT INTO students (user_id, roll_number, class_id, current_sem)
SELECT
    u.id,
    ss.roll_number,
    ss.class_id,
    ss.current_sem
FROM student_seed ss
JOIN users u ON u.email = ss.email
LEFT JOIN students s ON s.user_id = u.id OR s.roll_number = ss.roll_number
WHERE s.id IS NULL;

-- ------------------------------------------------------------
-- 3) Add student profiles for newly added students
-- ------------------------------------------------------------
WITH new_students AS (
    SELECT
        s.id,
        s.roll_number,
        s.current_sem,
        u.email,
        c.id AS class_id,
        c.year,
        c.section,
        d.name AS dept_name,
        ROW_NUMBER() OVER (ORDER BY s.roll_number) AS rn
    FROM students s
    JOIN users u ON u.id = s.user_id
    JOIN classes c ON c.id = s.class_id
    JOIN departments d ON d.id = c.department_id
    LEFT JOIN student_profiles sp ON sp.student_id = s.id
    WHERE sp.student_id IS NULL
)
INSERT INTO student_profiles (
    student_id,
    full_name,
    date_of_birth,
    gender,
    phone,
    email,
    address,
    parent_name,
    parent_phone,
    emergency_contact
)
SELECT
    ns.id,
    'Student ' || ns.roll_number AS full_name,
    DATE '2004-01-01' + ((ns.rn % 1400)::INT),
    CASE
        WHEN ns.rn % 3 = 0 THEN 'female'
        WHEN ns.rn % 3 = 1 THEN 'male'
        ELSE 'other'
    END AS gender,
    '98' || LPAD((10000000 + ns.rn)::TEXT, 8, '0') AS phone,
    ns.email,
    CASE
        WHEN ns.dept_name = 'Computer Science and Engineering' THEN 'Panaji, Goa'
        WHEN ns.dept_name = 'Electrical and Electronics Engineering' THEN 'Ponda, Goa'
        WHEN ns.dept_name = 'Mechanical Engineering' THEN 'Margao, Goa'
        ELSE 'Mapusa, Goa'
    END AS address,
    'Parent of ' || ns.roll_number,
    '97' || LPAD((20000000 + ns.rn)::TEXT, 8, '0') AS parent_phone,
    '+91-9' || LPAD((300000000 + ns.rn)::TEXT, 9, '0') AS emergency_contact
FROM new_students ns;

-- ------------------------------------------------------------
-- 4) Add academic history row for 2026-27 Odd semester
-- ------------------------------------------------------------
INSERT INTO student_academic_history (student_id, class_id, semester_id, year)
SELECT
    s.id,
    s.class_id,
    sem.id,
    EXTRACT(YEAR FROM sem.start_date)::INT AS year
FROM students s
JOIN semesters sem ON sem.name = '2026-27 Odd'
LEFT JOIN student_academic_history sah
  ON sah.student_id = s.id
 AND sah.semester_id = sem.id
WHERE sah.id IS NULL;

-- ------------------------------------------------------------
-- 5) Optional: assign additional class advisors from new faculty
-- ------------------------------------------------------------
WITH advisor_pool AS (
    SELECT
        f.id AS faculty_id,
        f.department_id,
        ROW_NUMBER() OVER (PARTITION BY f.department_id ORDER BY u.email) AS rn
    FROM faculty f
    JOIN users u ON u.id = f.user_id
),
class_pool AS (
    SELECT
        c.id AS class_id,
        c.department_id,
        ROW_NUMBER() OVER (PARTITION BY c.department_id ORDER BY c.year, c.section) AS rn
    FROM classes c
)
INSERT INTO class_advisors (class_id, faculty_id)
SELECT
    cp.class_id,
    ap.faculty_id
FROM class_pool cp
JOIN advisor_pool ap
  ON ap.department_id = cp.department_id
 AND ap.rn IN (cp.rn, cp.rn + 1)
ON CONFLICT (class_id, faculty_id) DO NOTHING;

COMMIT;

-- ============================================================
-- Suggested checks:
--   SELECT COUNT(*) FROM users WHERE base_role = 'student';
--   SELECT COUNT(*) FROM users WHERE base_role = 'faculty';
--   SELECT COUNT(*) FROM students;
--   SELECT COUNT(*) FROM faculty;
--   SELECT COUNT(*) FROM student_profiles;
--   SELECT COUNT(*) FROM student_academic_history;
-- ============================================================

