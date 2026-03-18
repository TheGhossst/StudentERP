-- ============================================================
--  Student ERP System — PostgreSQL Schema  v3.0
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";


CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    password_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    base_role     TEXT NOT NULL CONSTRAINT chk_base_role CHECK (base_role IN ('student', 'faculty', 'admin')),
    status        TEXT NOT NULL DEFAULT 'active' CONSTRAINT chk_user_status CHECK (status IN ('active','suspended','deleted')), -- [FIX #10]
    deleted_at    TIMESTAMP,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL  -- 'CR', 'advisor', 'HoD', 'placement_coordinator'
);

CREATE TABLE user_roles (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id     UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    scope_type  TEXT CONSTRAINT chk_ur_scope CHECK (scope_type IN ('class', 'department', 'year')),
    scope_id    UUID,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, role_id, scope_type, scope_id)
);

CREATE TABLE role_constraints (
    role_id         UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    scope_type      TEXT NOT NULL,
    max_per_scope   INT,
    gender_required TEXT DEFAULT 'any' CONSTRAINT chk_rc_gender CHECK (gender_required IN ('male', 'female', 'any')),
    PRIMARY KEY (role_id, scope_type)
);

CREATE UNIQUE INDEX idx_cr_one_per_scope
    ON user_roles (role_id, scope_id)
    WHERE scope_type = 'class';

CREATE TABLE login_attempts (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID REFERENCES users(id) ON DELETE SET NULL,
    email        TEXT,
    success      BOOLEAN NOT NULL,
    ip_address   TEXT,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE semesters (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL,
    is_active  BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_sem_dates CHECK (end_date > start_date)
);

CREATE TABLE programs (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL CONSTRAINT chk_prog_name CHECK (name IN ('BTech', 'MTech', 'PhD'))
);

CREATE TABLE departments (
    id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE classes (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    program_id    UUID NOT NULL REFERENCES programs(id)    ON DELETE RESTRICT,
    year          INT  NOT NULL CONSTRAINT chk_class_year CHECK (year BETWEEN 1 AND 7), -- Expanded for PhD/Integrated
    section       TEXT NOT NULL,
    UNIQUE (department_id, program_id, year, section)
);



CREATE TABLE students (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    roll_number TEXT UNIQUE NOT NULL,
    class_id    UUID NOT NULL REFERENCES classes(id) ON DELETE RESTRICT,
    current_sem INT  NOT NULL CONSTRAINT chk_stu_sem CHECK (current_sem BETWEEN 1 AND 14), -- Expanded for PhD max sems
    deleted_at  TIMESTAMP
);

CREATE TABLE student_academic_history (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id  UUID NOT NULL REFERENCES students(id)  ON DELETE CASCADE,
    class_id    UUID NOT NULL REFERENCES classes(id)   ON DELETE RESTRICT,
    semester_id UUID NOT NULL REFERENCES semesters(id) ON DELETE RESTRICT,
    year        INT  NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, semester_id)
);

CREATE TABLE student_profiles (
    student_id        UUID PRIMARY KEY REFERENCES students(id) ON DELETE CASCADE,
    full_name         TEXT NOT NULL,
    date_of_birth     DATE,
    gender            TEXT CONSTRAINT chk_stu_gender CHECK (gender IN ('male', 'female', 'other')),
    phone             TEXT,
    email             TEXT,
    address           TEXT,
    parent_name       TEXT,
    parent_phone      TEXT,
    emergency_contact TEXT,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE faculty (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
    type          TEXT NOT NULL CONSTRAINT chk_fac_type CHECK (type IN ('permanent', 'contract')),
    deleted_at    TIMESTAMP
);

CREATE TABLE class_advisors (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id    UUID NOT NULL REFERENCES classes(id)  ON DELETE CASCADE,
    faculty_id  UUID NOT NULL REFERENCES faculty(id)  ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (class_id, faculty_id)
);



CREATE TABLE courses (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code       TEXT UNIQUE NOT NULL,
    name       TEXT NOT NULL,
    credits    INT  NOT NULL CONSTRAINT chk_crs_creds CHECK (credits > 0),
    type       TEXT NOT NULL CONSTRAINT chk_crs_type CHECK (type IN ('theory', 'lab')),
    deleted_at TIMESTAMP
);

CREATE TABLE course_prerequisites (
    course_id              UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    prerequisite_course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    PRIMARY KEY (course_id, prerequisite_course_id)
);

CREATE TABLE course_offerings (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_id   UUID NOT NULL REFERENCES courses(id)   ON DELETE RESTRICT,
    faculty_id  UUID NOT NULL REFERENCES faculty(id)   ON DELETE RESTRICT,
    semester_id UUID NOT NULL REFERENCES semesters(id) ON DELETE RESTRICT
);


CREATE TABLE course_offering_classes (
    course_offering_id UUID REFERENCES course_offerings(id) ON DELETE CASCADE,
    class_id           UUID REFERENCES classes(id)          ON DELETE CASCADE,
    PRIMARY KEY (course_offering_id, class_id)
);


CREATE TABLE backlogs (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id  UUID NOT NULL REFERENCES courses(id)  ON DELETE CASCADE,
    status     TEXT NOT NULL DEFAULT 'pending' CONSTRAINT chk_backlog_status CHECK (status IN ('pending', 'cleared')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cleared_at TIMESTAMP,
    UNIQUE (student_id, course_id)
);

CREATE TABLE enrollments (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id         UUID NOT NULL REFERENCES students(id)         ON DELETE CASCADE,
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    status             TEXT NOT NULL DEFAULT 'enrolled'
                            CONSTRAINT chk_enr_status CHECK (status IN ('enrolled', 'dropped', 'completed')),
    enrolled_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, course_offering_id)
);

CREATE TABLE time_slots (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    start_time TIME NOT NULL,
    end_time   TIME NOT NULL,
    CONSTRAINT chk_time_slot CHECK (end_time > start_time),
    UNIQUE (start_time, end_time)
);


CREATE TABLE timetable (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id           UUID REFERENCES classes(id)                   ON DELETE CASCADE, 
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    faculty_id         UUID NOT NULL REFERENCES faculty(id)          ON DELETE CASCADE,
    day_of_week        INT  NOT NULL CONSTRAINT chk_tt_day CHECK (day_of_week BETWEEN 1 AND 7), -- 1=Monday
    time_slot_id       UUID NOT NULL REFERENCES time_slots(id)       ON DELETE RESTRICT,
    room               TEXT,
    UNIQUE (course_offering_id, day_of_week, time_slot_id),
    UNIQUE (faculty_id, day_of_week, time_slot_id)
);

CREATE TABLE class_sessions (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    timetable_id       UUID REFERENCES timetable(id) ON DELETE SET NULL,
    class_id           UUID NOT NULL REFERENCES classes(id)          ON DELETE CASCADE,
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    date               DATE NOT NULL,
    status             TEXT NOT NULL DEFAULT 'scheduled'
                            CONSTRAINT chk_cs_status CHECK (status IN ('scheduled', 'cancelled', 'completed', 'rescheduled')),
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE class_changes (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_session_id UUID NOT NULL REFERENCES class_sessions(id) ON DELETE CASCADE,
    type             TEXT NOT NULL CONSTRAINT chk_cc_type CHECK (type IN ('cancel', 'reschedule')),
    new_date         DATE,
    new_time_slot_id UUID REFERENCES time_slots(id),
    reason           TEXT,
    created_by       UUID NOT NULL REFERENCES users(id),
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE attendance_sessions (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_session_id   UUID UNIQUE NOT NULL REFERENCES class_sessions(id)   ON DELETE CASCADE,
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    started_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at           TIMESTAMP,
    CONSTRAINT chk_ended_after_started CHECK (ended_at IS NULL OR ended_at > started_at)
);

CREATE TABLE attendance_queue (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_session_id UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    student_id            UUID NOT NULL REFERENCES students(id)            ON DELETE CASCADE,
    sequence              INT  NOT NULL,
    status                TEXT NOT NULL DEFAULT 'pending'
                               CONSTRAINT chk_aq_status CHECK (status IN ('pending', 'done')),
    UNIQUE (attendance_session_id, student_id),
    UNIQUE (attendance_session_id, sequence)
);

CREATE TABLE attendance_records (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_session_id UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    student_id            UUID NOT NULL REFERENCES students(id)            ON DELETE CASCADE,
    status                TEXT NOT NULL CONSTRAINT chk_ar_status CHECK (status IN ('present', 'absent')),
    recorded_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (attendance_session_id, student_id)
);

CREATE TABLE attendance_summary (
    student_id          UUID NOT NULL REFERENCES students(id)          ON DELETE CASCADE,
    course_offering_id  UUID NOT NULL REFERENCES course_offerings(id)  ON DELETE CASCADE,
    total_classes       INT  NOT NULL DEFAULT 0 CONSTRAINT chk_att_tot_cl CHECK (total_classes >= 0),
    attended_classes    INT  NOT NULL DEFAULT 0 CONSTRAINT chk_att_att_cl CHECK (attended_classes >= 0),
    PRIMARY KEY (student_id, course_offering_id),
    CONSTRAINT chk_attended_lte_total CHECK (attended_classes <= total_classes)
);


CREATE TABLE exams (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id) ON DELETE CASCADE,
    type               TEXT NOT NULL CONSTRAINT chk_ex_type CHECK (type IN ('midsem', 'endsem', 'quiz', 'assignment')),
    date               DATE,
    max_marks          FLOAT NOT NULL CONSTRAINT chk_ex_max CHECK (max_marks > 0),
    is_published       BOOLEAN DEFAULT FALSE,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE marks (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id     UUID  NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    exam_id        UUID  NOT NULL REFERENCES exams(id)    ON DELETE CASCADE,
    marks_obtained FLOAT NOT NULL CONSTRAINT chk_mk_obt CHECK (marks_obtained >= 0),
    recorded_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, exam_id)
);


CREATE TABLE grades (
    student_id         UUID NOT NULL REFERENCES students(id)          ON DELETE CASCADE,
    course_offering_id UUID NOT NULL REFERENCES course_offerings(id)  ON DELETE CASCADE,
    grade              TEXT NOT NULL,
    grade_points       FLOAT CONSTRAINT chk_gr_pts CHECK (grade_points BETWEEN 0 AND 10),
    is_final           BOOLEAN DEFAULT FALSE,
    published_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_offering_id)
);


CREATE TABLE leave_requests (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id   UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    from_date    DATE NOT NULL,
    to_date      DATE NOT NULL,
    reason       TEXT NOT NULL,
    status       TEXT NOT NULL DEFAULT 'pending'
                      CONSTRAINT chk_lr_status CHECK (status IN ('pending', 'approved', 'rejected')),
    current_step INT  NOT NULL DEFAULT 1,
    version      INT  NOT NULL DEFAULT 1,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_date_range CHECK (to_date >= from_date)
);

CREATE TABLE leave_approval_steps (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leave_request_id UUID NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    step_order       INT  NOT NULL,
    role_required_id UUID NOT NULL REFERENCES roles(id),
    status           TEXT NOT NULL DEFAULT 'pending'
                          CONSTRAINT chk_las_status CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_by      UUID REFERENCES users(id),
    remarks          TEXT,
    acted_at         TIMESTAMP,
    UNIQUE (leave_request_id, step_order)
);

CREATE TABLE leave_documents (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    leave_request_id UUID NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    file_url         TEXT NOT NULL,
    uploaded_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE notifications (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title      TEXT NOT NULL,
    message    TEXT NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notification_targets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    target_type     TEXT NOT NULL CONSTRAINT chk_nt_tgt_type CHECK (target_type IN ('user', 'class', 'department', 'course_offering')),
    target_id       UUID NOT NULL
);

CREATE TABLE notification_reads (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    read_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (notification_id, user_id)
);

CREATE TABLE notification_deliveries (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users(id)         ON DELETE CASCADE,
    channel         TEXT NOT NULL CONSTRAINT chk_nd_ch CHECK (channel IN ('push', 'email', 'sms')),
    status          TEXT NOT NULL DEFAULT 'pending'
                         CONSTRAINT chk_nd_status CHECK (status IN ('pending', 'delivered', 'failed')),
    delivered_at    TIMESTAMP,
    UNIQUE (notification_id, user_id, channel)
);


CREATE TABLE companies (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name       TEXT UNIQUE NOT NULL,
    website    TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE job_postings (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id  UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    role        TEXT NOT NULL,
    description TEXT,
    deadline    TIMESTAMP NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE placement_criteria (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id         UUID NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    min_cgpa       FLOAT CONSTRAINT chk_pc_cgpa CHECK (min_cgpa BETWEEN 0.0 AND 10.0),
    min_attendance FLOAT CONSTRAINT chk_pc_att CHECK (min_attendance BETWEEN 0.0 AND 100.0),
    max_backlogs   INT DEFAULT 0 CONSTRAINT chk_pc_bklg CHECK (max_backlogs >= 0),
    UNIQUE (job_id)
);

CREATE TABLE placement_allowed_departments (
    job_id        UUID NOT NULL REFERENCES job_postings(id)  ON DELETE CASCADE,
    department_id UUID NOT NULL REFERENCES departments(id)   ON DELETE CASCADE,
    PRIMARY KEY (job_id, department_id)
);

CREATE TABLE placement_allowed_programs (
    job_id     UUID NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    program_id UUID NOT NULL REFERENCES programs(id)    ON DELETE CASCADE,
    PRIMARY KEY (job_id, program_id)
);

CREATE TABLE applications (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES students(id)     ON DELETE CASCADE,
    job_id     UUID NOT NULL REFERENCES job_postings(id) ON DELETE CASCADE,
    status     TEXT NOT NULL DEFAULT 'applied'
                    CONSTRAINT chk_app_status CHECK (status IN ('applied', 'shortlisted', 'rejected', 'selected')),
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, job_id)
);


CREATE TABLE fees (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id  UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    amount      FLOAT NOT NULL CONSTRAINT chk_fee_amt CHECK (amount > 0),
    amount_paid FLOAT NOT NULL DEFAULT 0 CONSTRAINT chk_fee_paid CHECK (amount_paid >= 0),
    due_date    DATE  NOT NULL,
    type        TEXT  NOT NULL CONSTRAINT chk_fee_type CHECK (type IN ('tuition', 'hostel', 'exam', 'library', 'other')),
    semester_id UUID REFERENCES semesters(id) ON DELETE SET NULL, -- Adapted to semester relation
    status      TEXT  NOT NULL DEFAULT 'pending'
                      CONSTRAINT chk_fee_status CHECK (status IN ('pending', 'partial', 'paid', 'waived')), -- Added partial
    version     INT   NOT NULL DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fee_payments (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fee_id         UUID  NOT NULL REFERENCES fees(id) ON DELETE CASCADE,
    amount_paid    FLOAT NOT NULL CONSTRAINT chk_fp_amt CHECK (amount_paid > 0),
    payment_method TEXT  CONSTRAINT chk_fp_method CHECK (payment_method IN ('upi', 'card', 'netbanking', 'cash')),
    transaction_id TEXT,
    paid_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE canteen_items (
    id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name      TEXT NOT NULL,
    price     FLOAT NOT NULL CONSTRAINT chk_ci_price CHECK (price >= 0),
    available BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id   UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    status       TEXT NOT NULL DEFAULT 'placed'
                      CONSTRAINT chk_ord_status CHECK (status IN ('placed', 'preparing', 'ready', 'completed')),
    type         TEXT NOT NULL CONSTRAINT chk_ord_type CHECK (type IN ('dine-in', 'takeaway')),
    total_amount FLOAT NOT NULL DEFAULT 0 CONSTRAINT chk_ord_tot CHECK (total_amount >= 0),
    version      INT  NOT NULL DEFAULT 1,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id        UUID NOT NULL REFERENCES orders(id)        ON DELETE CASCADE,
    canteen_item_id UUID NOT NULL REFERENCES canteen_items(id) ON DELETE RESTRICT,
    quantity        INT  NOT NULL CONSTRAINT chk_oi_qty CHECK (quantity > 0),
    unit_price      FLOAT NOT NULL CONSTRAINT chk_oi_price CHECK (unit_price >= 0)
);

CREATE TABLE payments (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id       UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    amount         FLOAT NOT NULL CONSTRAINT chk_pay_amt CHECK (amount > 0),
    payment_method TEXT  CONSTRAINT chk_pay_meth CHECK (payment_method IN ('upi', 'card', 'cash', 'wallet')),
    status         TEXT NOT NULL DEFAULT 'pending'
                        CONSTRAINT chk_pay_status CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
    paid_at        TIMESTAMP
);


CREATE TABLE audit_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
    action      TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id   UUID,
    metadata    JSONB,
    timestamp   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE events (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type       TEXT NOT NULL,
    payload    JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE feature_flags (
    name        TEXT PRIMARY KEY,
    enabled     BOOLEAN NOT NULL DEFAULT FALSE,
    description TEXT,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

CREATE POLICY students_own_data_select ON students
FOR SELECT
USING (
    user_id = current_setting('app.user_id', true)::UUID
);

CREATE POLICY students_own_data_update ON students
FOR UPDATE
USING (
    user_id = current_setting('app.user_id', true)::UUID
)
WITH CHECK (
    user_id = current_setting('app.user_id', true)::UUID
);

CREATE MATERIALIZED VIEW student_dashboard AS
SELECT
    s.id AS student_id,
    u.email,
    s.roll_number,
    COUNT(e.id) AS enrolled_courses,
    COALESCE(SUM(c.credits) FILTER (WHERE g.grade NOT IN ('F', 'Ab')), 0) AS total_credits_earned
FROM students s
JOIN users u ON s.user_id = u.id
LEFT JOIN enrollments e ON e.student_id = s.id AND e.status = 'enrolled'
LEFT JOIN grades g ON g.student_id = s.id
LEFT JOIN course_offerings co ON g.course_offering_id = co.id
LEFT JOIN courses c ON co.course_id = c.id
GROUP BY s.id, u.email, s.roll_number;


CREATE OR REPLACE FUNCTION check_student_enrollment()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM enrollments e
        JOIN attendance_sessions s ON s.course_offering_id = e.course_offering_id
        WHERE e.student_id = NEW.student_id
          AND s.id = NEW.attendance_session_id
          AND e.status = 'enrolled'
    ) THEN
        RAISE EXCEPTION 'Student is not enrolled in this course offering';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_attendance_summary()
RETURNS TRIGGER AS $$
DECLARE
    v_course_offering_id UUID;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT course_offering_id
        INTO v_course_offering_id
        FROM attendance_sessions
        WHERE id = NEW.attendance_session_id;

        INSERT INTO attendance_summary (student_id, course_offering_id, total_classes, attended_classes)
        VALUES (
            NEW.student_id,
            v_course_offering_id,
            1,
            CASE WHEN NEW.status = 'present' THEN 1 ELSE 0 END
        )
        ON CONFLICT (student_id, course_offering_id)
        DO UPDATE SET
            total_classes = attendance_summary.total_classes + 1,
            attended_classes = attendance_summary.attended_classes +
                CASE WHEN NEW.status = 'present' THEN 1 ELSE 0 END;

        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        SELECT course_offering_id
        INTO v_course_offering_id
        FROM attendance_sessions
        WHERE id = OLD.attendance_session_id;

        UPDATE attendance_summary
        SET
            total_classes = GREATEST(total_classes - 1, 0),
            attended_classes = GREATEST(attended_classes - CASE WHEN OLD.status = 'present' THEN 1 ELSE 0 END, 0)
        WHERE student_id = OLD.student_id
          AND course_offering_id = v_course_offering_id;

        SELECT course_offering_id
        INTO v_course_offering_id
        FROM attendance_sessions
        WHERE id = NEW.attendance_session_id;

        INSERT INTO attendance_summary (student_id, course_offering_id, total_classes, attended_classes)
        VALUES (
            NEW.student_id,
            v_course_offering_id,
            1,
            CASE WHEN NEW.status = 'present' THEN 1 ELSE 0 END
        )
        ON CONFLICT (student_id, course_offering_id)
        DO UPDATE SET
            total_classes = attendance_summary.total_classes + 1,
            attended_classes = attendance_summary.attended_classes +
                CASE WHEN NEW.status = 'present' THEN 1 ELSE 0 END;

        RETURN NEW;
    ELSE
        SELECT course_offering_id
        INTO v_course_offering_id
        FROM attendance_sessions
        WHERE id = OLD.attendance_session_id;

        UPDATE attendance_summary
        SET
            total_classes = GREATEST(total_classes - 1, 0),
            attended_classes = GREATEST(attended_classes - CASE WHEN OLD.status = 'present' THEN 1 ELSE 0 END, 0)
        WHERE student_id = OLD.student_id
          AND course_offering_id = v_course_offering_id;

        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_enrollment
BEFORE INSERT OR UPDATE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION check_student_enrollment();

CREATE TRIGGER trg_update_attendance_summary
AFTER INSERT OR UPDATE OR DELETE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION update_attendance_summary();

CREATE OR REPLACE FUNCTION validate_enrollment_class_scope()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM students s
        JOIN course_offering_classes coc ON coc.class_id = s.class_id
        WHERE s.id = NEW.student_id
          AND coc.course_offering_id = NEW.course_offering_id
    ) THEN
        RAISE EXCEPTION 'Student class is not eligible for this course offering';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_enrollment_class_scope
BEFORE INSERT OR UPDATE ON enrollments
FOR EACH ROW EXECUTE FUNCTION validate_enrollment_class_scope();

CREATE OR REPLACE FUNCTION enforce_leave_workflow()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'pending' AND NEW.status != 'pending' THEN
        IF NEW.step_order != (SELECT current_step FROM leave_requests WHERE id = NEW.leave_request_id) THEN
            RAISE EXCEPTION 'Cannot act on this step; it is not the active step.';
        END IF;

        IF NEW.status = 'approved' THEN
            IF NEW.step_order = (
                SELECT MAX(step_order)
                FROM leave_approval_steps
                WHERE leave_request_id = NEW.leave_request_id
            ) THEN
                UPDATE leave_requests
                SET status = 'approved', version = version + 1
                WHERE id = NEW.leave_request_id;
            ELSE
                UPDATE leave_requests
                SET current_step = current_step + 1, version = version + 1
                WHERE id = NEW.leave_request_id;
            END IF;
        ELSIF NEW.status = 'rejected' THEN
            UPDATE leave_requests
            SET status = 'rejected', version = version + 1
            WHERE id = NEW.leave_request_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_leave_workflow
BEFORE UPDATE ON leave_approval_steps
FOR EACH ROW EXECUTE FUNCTION enforce_leave_workflow();

CREATE OR REPLACE FUNCTION check_application_deadline()
RETURNS TRIGGER AS $$
BEGIN
    IF NOW() > (SELECT deadline FROM job_postings WHERE id = NEW.job_id) THEN
        RAISE EXCEPTION 'Application deadline has passed.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_deadline
BEFORE INSERT ON applications
FOR EACH ROW EXECUTE FUNCTION check_application_deadline();

CREATE OR REPLACE FUNCTION update_fee_totals()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE fees f
    SET
        amount_paid = agg.total_paid,
        status = CASE
            WHEN agg.total_paid <= 0 THEN 'pending'
            WHEN agg.total_paid >= f.amount THEN 'paid'
            ELSE 'partial'
        END,
        version = f.version + 1
    FROM (
        SELECT fee_id, COALESCE(SUM(amount_paid), 0) AS total_paid
        FROM fee_payments
        WHERE fee_id = NEW.fee_id
        GROUP BY fee_id
    ) agg
    WHERE f.id = agg.fee_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_fee_totals
AFTER INSERT ON fee_payments
FOR EACH ROW EXECUTE FUNCTION update_fee_totals();

CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
DECLARE
    v_order_id UUID;
BEGIN
    v_order_id := COALESCE(NEW.order_id, OLD.order_id);

    UPDATE orders o
    SET
        total_amount = totals.new_total,
        version = o.version + 1
    FROM (
        SELECT oi.order_id, COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS new_total
        FROM order_items oi
        WHERE oi.order_id = v_order_id
        GROUP BY oi.order_id
    ) totals
    WHERE o.id = totals.order_id;

    IF NOT FOUND THEN
        UPDATE orders
        SET total_amount = 0,
            version = version + 1
        WHERE id = v_order_id;
    END IF;

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_order_total();


CREATE INDEX idx_user_roles_user          ON user_roles(user_id);
CREATE INDEX idx_user_roles_scope         ON user_roles(scope_type, scope_id);
CREATE INDEX idx_login_attempts_user      ON login_attempts(user_id);
CREATE INDEX idx_login_attempts_time      ON login_attempts(attempted_at);

CREATE INDEX idx_students_class           ON students(class_id);
CREATE INDEX idx_students_roll            ON students(roll_number);
CREATE INDEX idx_students_deleted         ON students(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_faculty_dept             ON faculty(department_id);

CREATE INDEX idx_enrollments_student      ON enrollments(student_id);
CREATE INDEX idx_enrollments_offering     ON enrollments(course_offering_id);
CREATE INDEX idx_enrollments_status       ON enrollments(status);
CREATE INDEX idx_co_classes_offering      ON course_offering_classes(course_offering_id);

CREATE INDEX idx_timetable_class          ON timetable(class_id);
CREATE INDEX idx_timetable_offering       ON timetable(course_offering_id);
CREATE INDEX idx_class_sessions_date      ON class_sessions(date);
CREATE INDEX idx_class_sessions_status    ON class_sessions(status);
CREATE INDEX idx_class_sessions_offering  ON class_sessions(course_offering_id);

CREATE INDEX idx_att_sessions_offering    ON attendance_sessions(course_offering_id);
CREATE INDEX idx_att_queue_session        ON attendance_queue(attendance_session_id);
CREATE INDEX idx_att_queue_status         ON attendance_queue(status);
CREATE INDEX idx_att_records_student      ON attendance_records(student_id);
CREATE INDEX idx_att_records_session      ON attendance_records(attendance_session_id);
CREATE INDEX idx_att_summary_student      ON attendance_summary(student_id);

CREATE INDEX idx_exams_offering           ON exams(course_offering_id);
CREATE INDEX idx_marks_student            ON marks(student_id);
CREATE INDEX idx_marks_exam               ON marks(exam_id);
CREATE INDEX idx_grades_student           ON grades(student_id);
CREATE INDEX idx_grades_offering          ON grades(course_offering_id);

CREATE INDEX idx_leave_student            ON leave_requests(student_id);
CREATE INDEX idx_leave_status             ON leave_requests(status);
CREATE INDEX idx_leave_steps_request      ON leave_approval_steps(leave_request_id);

CREATE INDEX idx_notif_targets_notif      ON notification_targets(notification_id);
CREATE INDEX idx_notif_targets_target     ON notification_targets(target_type, target_id);
CREATE INDEX idx_notif_reads_user         ON notification_reads(user_id);
CREATE INDEX idx_notif_deliveries_user    ON notification_deliveries(user_id);
CREATE INDEX idx_notif_deliveries_status  ON notification_deliveries(status);
CREATE INDEX idx_notifications_message_gin ON notifications USING gin(to_tsvector('simple', message));

CREATE INDEX idx_place_dept_job           ON placement_allowed_departments(job_id);
CREATE INDEX idx_place_prog_job           ON placement_allowed_programs(job_id);
CREATE INDEX idx_applications_student     ON applications(student_id);
CREATE INDEX idx_applications_job         ON applications(job_id);
CREATE INDEX idx_job_postings_deadline    ON job_postings(deadline);

CREATE INDEX idx_fees_student             ON fees(student_id);
CREATE INDEX idx_fees_status              ON fees(status);
CREATE INDEX idx_fees_due_date            ON fees(due_date);
CREATE INDEX idx_fee_payments_fee         ON fee_payments(fee_id);

CREATE INDEX idx_orders_student           ON orders(student_id);
CREATE INDEX idx_orders_status            ON orders(status);
CREATE INDEX idx_payments_order           ON payments(order_id);
CREATE INDEX idx_payments_status          ON payments(status);

CREATE INDEX idx_audit_user               ON audit_logs(user_id);
CREATE INDEX idx_audit_entity             ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_timestamp          ON audit_logs(timestamp);
CREATE INDEX idx_events_type              ON events(type);
CREATE INDEX idx_events_created           ON events(created_at);

CREATE INDEX idx_audit_metadata_gin       ON audit_logs USING gin(metadata);

CREATE MATERIALIZED VIEW student_gpa AS
SELECT
    g.student_id,
    co.semester_id,
    ROUND(
        (
            (
                SUM(g.grade_points * c.credits)
                FILTER (WHERE g.grade_points IS NOT NULL)
            )
            /
            NULLIF(
                SUM(c.credits)
                FILTER (WHERE g.grade_points IS NOT NULL),
                0
            )
        )::numeric,
        2
    ) AS gpa
FROM grades g
JOIN course_offerings co ON co.id = g.course_offering_id
JOIN courses c ON c.id = co.course_id
GROUP BY g.student_id, co.semester_id;