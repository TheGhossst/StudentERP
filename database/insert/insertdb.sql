-- ============================================================
-- Student ERP System - Seed Data Script (100+ rows)
-- Target: dbschema.sql v3.0
-- Notes:
--   1) Run this AFTER creating schema objects from dbschema.sql.
--   2) This script uses realistic, constraint-safe values.
--   3) Deadlines are set in the future relative to 2026-03-18.
-- ============================================================

ROLLBACK;

BEGIN;

INSERT INTO roles (name) VALUES
('CR'),
('advisor'),
('HoD'),
('placement_coordinator');

INSERT INTO role_constraints (role_id, scope_type, max_per_scope, gender_required)
SELECT id, 'class', 1, 'any' FROM roles WHERE name = 'CR'
UNION ALL
SELECT id, 'class', 1, 'any' FROM roles WHERE name = 'advisor'
UNION ALL
SELECT id, 'department', 1, 'any' FROM roles WHERE name = 'HoD'
UNION ALL
SELECT id, 'department', 2, 'any' FROM roles WHERE name = 'placement_coordinator';

INSERT INTO programs (name) VALUES
('BTech'),
('MTech'),
('PhD');

INSERT INTO departments (name) VALUES
('Computer Science and Engineering'),
('Electrical and Electronics Engineering'),
('Mechanical Engineering'),
('Humanities and Social Sciences');

INSERT INTO semesters (name, start_date, end_date, is_active) VALUES
('2025-26 Odd',  DATE '2025-07-15', DATE '2025-12-05', FALSE),
('2025-26 Even', DATE '2026-01-05', DATE '2026-05-15', TRUE),
('2026-27 Odd',  DATE '2026-07-15', DATE '2026-12-05', FALSE);

INSERT INTO time_slots (start_time, end_time) VALUES
(TIME '08:00', TIME '08:50'),
(TIME '09:00', TIME '09:50'),
(TIME '10:00', TIME '10:50'),
(TIME '11:00', TIME '11:50'),
(TIME '13:00', TIME '13:50'),
(TIME '14:00', TIME '14:50');

INSERT INTO feature_flags (name, enabled, description) VALUES
('attendance.face_recognition', TRUE,  'Enable face recognition for attendance queue optimization'),
('placements.ai_resume_score', TRUE,   'Enable AI assisted resume scoring for placement office'),
('fees.auto_reminder', TRUE,           'Send automatic due-date reminders for pending fees'),
('canteen.qr_payment', TRUE,           'Enable QR-based payment options at canteen counters'),
('leave.esign_approval', FALSE,        'Digital e-sign workflow for leave approvals'),
('notifications.sms_fallback', TRUE,   'Fallback to SMS for failed push deliveries');


INSERT INTO users (email, password_hash, base_role, status) VALUES
('admin.erp@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'admin',   'active'),
('registrar.office@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'admin', 'active'),

('ananya.sharma@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('rahul.verma@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('meera.nair@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('arvind.iyer@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('kavita.reddy@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('suresh.patil@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('priya.menon@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),
('deepak.gupta@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'faculty', 'active'),

('aisha.khan24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('rohan.mishra24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('neha.joseph24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('vikram.singh24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('pooja.naidu24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('aditya.rao24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('shruti.das24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('karan.jain24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('nisha.gupta24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('manav.bose24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('ishita.paul23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('varun.bhat23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('riya.sethi23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('harsh.vora23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('tanvi.kale23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('yash.pandey23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('fatima.sheikh23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('nikhil.kulkarni23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('aman.tyagi22@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('saloni.arora22@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('parth.desai22@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('bhavya.naik24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('girish.kumar24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('lavanya.murthy24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('vivek.chauhan24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('sana.pervez23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('abhishek.nandi23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('heena.ali23@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),

('omkar.joshi24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active'),
('diya.kapoor24@nitgoa.ac.in', crypt('NitGoa@123', gen_salt('bf', 12)), 'student', 'active');

-- ------------------------------------------------------------
-- 3) ACADEMIC STRUCTURE
-- ------------------------------------------------------------

INSERT INTO classes (department_id, program_id, year, section)
SELECT d.id, p.id, x.year, x.section
FROM (
    VALUES
    ('Computer Science and Engineering', 'BTech', 1, 'A'),
    ('Computer Science and Engineering', 'BTech', 1, 'B'),
    ('Computer Science and Engineering', 'BTech', 2, 'A'),
    ('Computer Science and Engineering', 'BTech', 2, 'B'),
    ('Computer Science and Engineering', 'BTech', 3, 'A'),
    ('Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('Electrical and Electronics Engineering', 'BTech', 2, 'A'),
    ('Mechanical Engineering', 'BTech', 1, 'A'),
    ('Computer Science and Engineering', 'MTech', 1, 'A')
) AS x(dept_name, program_name, year, section)
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.program_name;

INSERT INTO faculty (user_id, department_id, type)
SELECT u.id, d.id, x.fac_type
FROM (
    VALUES
    ('ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering', 'permanent'),
    ('rahul.verma@nitgoa.ac.in', 'Computer Science and Engineering', 'permanent'),
    ('meera.nair@nitgoa.ac.in', 'Electrical and Electronics Engineering', 'permanent'),
    ('arvind.iyer@nitgoa.ac.in', 'Humanities and Social Sciences', 'contract'),
    ('kavita.reddy@nitgoa.ac.in', 'Mechanical Engineering', 'permanent'),
    ('suresh.patil@nitgoa.ac.in', 'Computer Science and Engineering', 'contract'),
    ('priya.menon@nitgoa.ac.in', 'Computer Science and Engineering', 'permanent'),
    ('deepak.gupta@nitgoa.ac.in', 'Electrical and Electronics Engineering', 'contract')
) AS x(email, dept_name, fac_type)
JOIN users u ON u.email = x.email
JOIN departments d ON d.name = x.dept_name;

INSERT INTO students (user_id, roll_number, class_id, current_sem)
SELECT u.id, x.roll_number, c.id, x.current_sem
FROM (
    VALUES
    ('aisha.khan24@nitgoa.ac.in',       'BT24CSE001', 'Computer Science and Engineering', 'BTech', 1, 'A', 2),
    ('rohan.mishra24@nitgoa.ac.in',     'BT24CSE002', 'Computer Science and Engineering', 'BTech', 1, 'A', 2),
    ('neha.joseph24@nitgoa.ac.in',      'BT24CSE003', 'Computer Science and Engineering', 'BTech', 1, 'A', 2),
    ('vikram.singh24@nitgoa.ac.in',     'BT24CSE004', 'Computer Science and Engineering', 'BTech', 1, 'A', 2),
    ('pooja.naidu24@nitgoa.ac.in',      'BT24CSE005', 'Computer Science and Engineering', 'BTech', 1, 'A', 2),

    ('aditya.rao24@nitgoa.ac.in',       'BT24CSE051', 'Computer Science and Engineering', 'BTech', 1, 'B', 2),
    ('shruti.das24@nitgoa.ac.in',       'BT24CSE052', 'Computer Science and Engineering', 'BTech', 1, 'B', 2),
    ('karan.jain24@nitgoa.ac.in',       'BT24CSE053', 'Computer Science and Engineering', 'BTech', 1, 'B', 2),
    ('nisha.gupta24@nitgoa.ac.in',      'BT24CSE054', 'Computer Science and Engineering', 'BTech', 1, 'B', 2),
    ('manav.bose24@nitgoa.ac.in',       'BT24CSE055', 'Computer Science and Engineering', 'BTech', 1, 'B', 2),

    ('ishita.paul23@nitgoa.ac.in',      'BT23CSE101', 'Computer Science and Engineering', 'BTech', 2, 'A', 4),
    ('varun.bhat23@nitgoa.ac.in',       'BT23CSE102', 'Computer Science and Engineering', 'BTech', 2, 'A', 4),
    ('riya.sethi23@nitgoa.ac.in',       'BT23CSE103', 'Computer Science and Engineering', 'BTech', 2, 'A', 4),
    ('harsh.vora23@nitgoa.ac.in',       'BT23CSE104', 'Computer Science and Engineering', 'BTech', 2, 'A', 4),

    ('tanvi.kale23@nitgoa.ac.in',       'BT23CSE151', 'Computer Science and Engineering', 'BTech', 2, 'B', 4),
    ('yash.pandey23@nitgoa.ac.in',      'BT23CSE152', 'Computer Science and Engineering', 'BTech', 2, 'B', 4),
    ('fatima.sheikh23@nitgoa.ac.in',    'BT23CSE153', 'Computer Science and Engineering', 'BTech', 2, 'B', 4),
    ('nikhil.kulkarni23@nitgoa.ac.in',  'BT23CSE154', 'Computer Science and Engineering', 'BTech', 2, 'B', 4),

    ('aman.tyagi22@nitgoa.ac.in',       'BT22CSE201', 'Computer Science and Engineering', 'BTech', 3, 'A', 6),
    ('saloni.arora22@nitgoa.ac.in',     'BT22CSE202', 'Computer Science and Engineering', 'BTech', 3, 'A', 6),
    ('parth.desai22@nitgoa.ac.in',      'BT22CSE203', 'Computer Science and Engineering', 'BTech', 3, 'A', 6),

    ('bhavya.naik24@nitgoa.ac.in',      'BT24EEE001', 'Electrical and Electronics Engineering', 'BTech', 1, 'A', 2),
    ('girish.kumar24@nitgoa.ac.in',     'BT24EEE002', 'Electrical and Electronics Engineering', 'BTech', 1, 'A', 2),
    ('lavanya.murthy24@nitgoa.ac.in',   'BT24EEE003', 'Electrical and Electronics Engineering', 'BTech', 1, 'A', 2),
    ('vivek.chauhan24@nitgoa.ac.in',    'BT24EEE004', 'Electrical and Electronics Engineering', 'BTech', 1, 'A', 2),

    ('sana.pervez23@nitgoa.ac.in',      'BT23EEE101', 'Electrical and Electronics Engineering', 'BTech', 2, 'A', 4),
    ('abhishek.nandi23@nitgoa.ac.in',   'BT23EEE102', 'Electrical and Electronics Engineering', 'BTech', 2, 'A', 4),
    ('heena.ali23@nitgoa.ac.in',        'BT23EEE103', 'Electrical and Electronics Engineering', 'BTech', 2, 'A', 4),

    ('omkar.joshi24@nitgoa.ac.in',      'BT24ME001',  'Mechanical Engineering', 'BTech', 1, 'A', 2),
    ('diya.kapoor24@nitgoa.ac.in',      'BT24ME002',  'Mechanical Engineering', 'BTech', 1, 'A', 2)
) AS x(email, roll_number, dept_name, program_name, year, section, current_sem)
JOIN users u ON u.email = x.email
JOIN classes c ON c.year = x.year AND c.section = x.section
JOIN departments d ON d.id = c.department_id AND d.name = x.dept_name
JOIN programs p ON p.id = c.program_id AND p.name = x.program_name;

INSERT INTO student_profiles (
    student_id, full_name, date_of_birth, gender, phone, email,
    address, parent_name, parent_phone, emergency_contact
)
SELECT s.id, x.full_name, x.dob, x.gender, x.phone, x.email,
       x.address, x.parent_name, x.parent_phone, x.emergency_contact
FROM (
    VALUES
    ('BT24CSE001','Aisha Khan',      DATE '2006-02-18','female','9876501001','aisha.khan24@nitgoa.ac.in','Bhopal, Madhya Pradesh','Imran Khan','9876509001','+91-9000001001'),
    ('BT24CSE002','Rohan Mishra',    DATE '2005-11-02','male','9876501002','rohan.mishra24@nitgoa.ac.in','Prayagraj, Uttar Pradesh','Sanjay Mishra','9876509002','+91-9000001002'),
    ('BT24CSE003','Neha Joseph',     DATE '2006-03-25','female','9876501003','neha.joseph24@nitgoa.ac.in','Kochi, Kerala','Thomas Joseph','9876509003','+91-9000001003'),
    ('BT24CSE004','Vikram Singh',    DATE '2005-09-09','male','9876501004','vikram.singh24@nitgoa.ac.in','Jaipur, Rajasthan','Raghav Singh','9876509004','+91-9000001004'),
    ('BT24CSE005','Pooja Naidu',     DATE '2006-01-31','female','9876501005','pooja.naidu24@nitgoa.ac.in','Visakhapatnam, Andhra Pradesh','Madhavi Naidu','9876509005','+91-9000001005'),

    ('BT24CSE051','Aditya Rao',      DATE '2006-07-16','male','9876501051','aditya.rao24@nitgoa.ac.in','Mysuru, Karnataka','Sridhar Rao','9876509051','+91-9000001051'),
    ('BT24CSE052','Shruti Das',      DATE '2005-12-12','female','9876501052','shruti.das24@nitgoa.ac.in','Kolkata, West Bengal','Subhash Das','9876509052','+91-9000001052'),
    ('BT24CSE053','Karan Jain',      DATE '2006-04-28','male','9876501053','karan.jain24@nitgoa.ac.in','Indore, Madhya Pradesh','Rakesh Jain','9876509053','+91-9000001053'),
    ('BT24CSE054','Nisha Gupta',     DATE '2006-06-03','female','9876501054','nisha.gupta24@nitgoa.ac.in','Lucknow, Uttar Pradesh','Amit Gupta','9876509054','+91-9000001054'),
    ('BT24CSE055','Manav Bose',      DATE '2006-08-20','male','9876501055','manav.bose24@nitgoa.ac.in','Durgapur, West Bengal','Prabir Bose','9876509055','+91-9000001055'),

    ('BT23CSE101','Ishita Paul',     DATE '2005-05-13','female','9876501101','ishita.paul23@nitgoa.ac.in','Pune, Maharashtra','Ajay Paul','9876509101','+91-9000001101'),
    ('BT23CSE102','Varun Bhat',      DATE '2004-10-19','male','9876501102','varun.bhat23@nitgoa.ac.in','Mangaluru, Karnataka','Mohan Bhat','9876509102','+91-9000001102'),
    ('BT23CSE103','Riya Sethi',      DATE '2005-02-04','female','9876501103','riya.sethi23@nitgoa.ac.in','Delhi','Anil Sethi','9876509103','+91-9000001103'),
    ('BT23CSE104','Harsh Vora',      DATE '2004-08-26','male','9876501104','harsh.vora23@nitgoa.ac.in','Ahmedabad, Gujarat','Nitin Vora','9876509104','+91-9000001104'),

    ('BT23CSE151','Tanvi Kale',      DATE '2004-12-08','female','9876501151','tanvi.kale23@nitgoa.ac.in','Nashik, Maharashtra','Rohit Kale','9876509151','+91-9000001151'),
    ('BT23CSE152','Yash Pandey',     DATE '2004-09-15','male','9876501152','yash.pandey23@nitgoa.ac.in','Kanpur, Uttar Pradesh','Deepak Pandey','9876509152','+91-9000001152'),
    ('BT23CSE153','Fatima Sheikh',   DATE '2005-01-22','female','9876501153','fatima.sheikh23@nitgoa.ac.in','Hyderabad, Telangana','Rashid Sheikh','9876509153','+91-9000001153'),
    ('BT23CSE154','Nikhil Kulkarni', DATE '2004-11-30','male','9876501154','nikhil.kulkarni23@nitgoa.ac.in','Nagpur, Maharashtra','Prakash Kulkarni','9876509154','+91-9000001154'),

    ('BT22CSE201','Aman Tyagi',      DATE '2003-07-11','male','9876501201','aman.tyagi22@nitgoa.ac.in','Noida, Uttar Pradesh','Rajeev Tyagi','9876509201','+91-9000001201'),
    ('BT22CSE202','Saloni Arora',    DATE '2003-06-09','female','9876501202','saloni.arora22@nitgoa.ac.in','Chandigarh','Kunal Arora','9876509202','+91-9000001202'),
    ('BT22CSE203','Parth Desai',     DATE '2003-03-17','male','9876501203','parth.desai22@nitgoa.ac.in','Surat, Gujarat','Hemant Desai','9876509203','+91-9000001203'),

    ('BT24EEE001','Bhavya Naik',     DATE '2006-02-27','female','9876501301','bhavya.naik24@nitgoa.ac.in','Udupi, Karnataka','Ravi Naik','9876509301','+91-9000001301'),
    ('BT24EEE002','Girish Kumar',    DATE '2006-05-07','male','9876501302','girish.kumar24@nitgoa.ac.in','Patna, Bihar','Mahesh Kumar','9876509302','+91-9000001302'),
    ('BT24EEE003','Lavanya Murthy',  DATE '2005-10-01','female','9876501303','lavanya.murthy24@nitgoa.ac.in','Bengaluru, Karnataka','S. Murthy','9876509303','+91-9000001303'),
    ('BT24EEE004','Vivek Chauhan',   DATE '2006-03-14','male','9876501304','vivek.chauhan24@nitgoa.ac.in','Dehradun, Uttarakhand','V. K. Chauhan','9876509304','+91-9000001304'),

    ('BT23EEE101','Sana Pervez',     DATE '2005-04-30','female','9876501351','sana.pervez23@nitgoa.ac.in','Aligarh, Uttar Pradesh','Aamir Pervez','9876509351','+91-9000001351'),
    ('BT23EEE102','Abhishek Nandi',  DATE '2004-06-21','male','9876501352','abhishek.nandi23@nitgoa.ac.in','Howrah, West Bengal','Arup Nandi','9876509352','+91-9000001352'),
    ('BT23EEE103','Heena Ali',       DATE '2004-12-19','female','9876501353','heena.ali23@nitgoa.ac.in','Bhopal, Madhya Pradesh','Javed Ali','9876509353','+91-9000001353'),

    ('BT24ME001','Omkar Joshi',      DATE '2005-09-03','male','9876501401','omkar.joshi24@nitgoa.ac.in','Navi Mumbai, Maharashtra','Sanjay Joshi','9876509401','+91-9000001401'),
    ('BT24ME002','Diya Kapoor',      DATE '2006-01-10','female','9876501402','diya.kapoor24@nitgoa.ac.in','Ludhiana, Punjab','Ashok Kapoor','9876509402','+91-9000001402')
) AS x(roll_number, full_name, dob, gender, phone, email, address, parent_name, parent_phone, emergency_contact)
JOIN students s ON s.roll_number = x.roll_number;

INSERT INTO student_academic_history (student_id, class_id, semester_id, year)
SELECT s.id, s.class_id, sem.id, EXTRACT(YEAR FROM sem.start_date)::INT
FROM students s
CROSS JOIN (
    SELECT id, start_date
    FROM semesters
    WHERE name = '2025-26 Even'
) sem;

INSERT INTO class_advisors (class_id, faculty_id)
SELECT c.id, f.id
FROM (
    VALUES
    ('Computer Science and Engineering', 'BTech', 1, 'A', 'ananya.sharma@nitgoa.ac.in'),
    ('Computer Science and Engineering', 'BTech', 1, 'B', 'rahul.verma@nitgoa.ac.in'),
    ('Computer Science and Engineering', 'BTech', 2, 'A', 'suresh.patil@nitgoa.ac.in'),
    ('Computer Science and Engineering', 'BTech', 2, 'B', 'priya.menon@nitgoa.ac.in'),
    ('Computer Science and Engineering', 'BTech', 3, 'A', 'ananya.sharma@nitgoa.ac.in'),
    ('Electrical and Electronics Engineering', 'BTech', 1, 'A', 'meera.nair@nitgoa.ac.in'),
    ('Electrical and Electronics Engineering', 'BTech', 2, 'A', 'deepak.gupta@nitgoa.ac.in'),
    ('Mechanical Engineering', 'BTech', 1, 'A', 'kavita.reddy@nitgoa.ac.in')
) AS x(dept_name, prog_name, year, section, faculty_email)
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.prog_name
JOIN classes c ON c.department_id = d.id AND c.program_id = p.id AND c.year = x.year AND c.section = x.section
JOIN users u ON u.email = x.faculty_email
JOIN faculty f ON f.user_id = u.id;

-- Scoped role assignments (CR, advisor, HoD, placement coordinator)
INSERT INTO user_roles (user_id, role_id, scope_type, scope_id)
SELECT u.id, r.id, 'class', c.id
FROM (
    VALUES
    ('aisha.khan24@nitgoa.ac.in',      'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('aditya.rao24@nitgoa.ac.in',      'Computer Science and Engineering', 'BTech', 1, 'B'),
    ('ishita.paul23@nitgoa.ac.in',     'Computer Science and Engineering', 'BTech', 2, 'A'),
    ('tanvi.kale23@nitgoa.ac.in',      'Computer Science and Engineering', 'BTech', 2, 'B'),
    ('aman.tyagi22@nitgoa.ac.in',      'Computer Science and Engineering', 'BTech', 3, 'A'),
    ('bhavya.naik24@nitgoa.ac.in',     'Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('sana.pervez23@nitgoa.ac.in',     'Electrical and Electronics Engineering', 'BTech', 2, 'A'),
    ('omkar.joshi24@nitgoa.ac.in',     'Mechanical Engineering', 'BTech', 1, 'A')
) AS x(email, dept_name, prog_name, year, section)
JOIN users u ON u.email = x.email
JOIN roles r ON r.name = 'CR'
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.prog_name
JOIN classes c ON c.department_id = d.id AND c.program_id = p.id AND c.year = x.year AND c.section = x.section;

INSERT INTO user_roles (user_id, role_id, scope_type, scope_id)
SELECT u.id, r.id, 'class', c.id
FROM (
    VALUES
    ('ananya.sharma@nitgoa.ac.in',     'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('rahul.verma@nitgoa.ac.in',       'Computer Science and Engineering', 'BTech', 1, 'B'),
    ('suresh.patil@nitgoa.ac.in',      'Computer Science and Engineering', 'BTech', 2, 'A'),
    ('priya.menon@nitgoa.ac.in',       'Computer Science and Engineering', 'BTech', 2, 'B'),
    ('ananya.sharma@nitgoa.ac.in',     'Computer Science and Engineering', 'BTech', 3, 'A'),
    ('meera.nair@nitgoa.ac.in',        'Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('deepak.gupta@nitgoa.ac.in',      'Electrical and Electronics Engineering', 'BTech', 2, 'A'),
    ('kavita.reddy@nitgoa.ac.in',      'Mechanical Engineering', 'BTech', 1, 'A')
) AS x(email, dept_name, prog_name, year, section)
JOIN users u ON u.email = x.email
JOIN roles r ON r.name = 'advisor'
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.prog_name
JOIN classes c ON c.department_id = d.id AND c.program_id = p.id AND c.year = x.year AND c.section = x.section;

INSERT INTO user_roles (user_id, role_id, scope_type, scope_id)
SELECT u.id, r.id, 'department', d.id
FROM (
    VALUES
    ('ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering'),
    ('meera.nair@nitgoa.ac.in', 'Electrical and Electronics Engineering'),
    ('kavita.reddy@nitgoa.ac.in', 'Mechanical Engineering')
) AS x(email, dept_name)
JOIN users u ON u.email = x.email
JOIN roles r ON r.name = 'HoD'
JOIN departments d ON d.name = x.dept_name;

INSERT INTO user_roles (user_id, role_id, scope_type, scope_id)
SELECT u.id, r.id, 'department', d.id
FROM (
    VALUES
    ('priya.menon@nitgoa.ac.in', 'Computer Science and Engineering'),
    ('deepak.gupta@nitgoa.ac.in', 'Electrical and Electronics Engineering')
) AS x(email, dept_name)
JOIN users u ON u.email = x.email
JOIN roles r ON r.name = 'placement_coordinator'
JOIN departments d ON d.name = x.dept_name;

INSERT INTO login_attempts (user_id, email, success, ip_address, attempted_at)
SELECT u.id, x.email, x.success, x.ip_address, x.attempted_at
FROM (
    VALUES
    ('aisha.khan24@nitgoa.ac.in', FALSE, '10.10.1.11', TIMESTAMP '2026-03-01 08:05:00'),
    ('aisha.khan24@nitgoa.ac.in', TRUE,  '10.10.1.11', TIMESTAMP '2026-03-01 08:08:00'),
    ('rohan.mishra24@nitgoa.ac.in', TRUE, '10.10.1.12', TIMESTAMP '2026-03-01 08:20:00'),
    ('neha.joseph24@nitgoa.ac.in', TRUE, '10.10.1.13', TIMESTAMP '2026-03-01 08:35:00'),
    ('vikram.singh24@nitgoa.ac.in', FALSE, '10.10.1.14', TIMESTAMP '2026-03-01 08:42:00'),
    ('ananya.sharma@nitgoa.ac.in', TRUE, '10.10.1.21', TIMESTAMP '2026-03-01 09:00:00'),
    ('rahul.verma@nitgoa.ac.in', TRUE, '10.10.1.22', TIMESTAMP '2026-03-01 09:10:00'),
    ('admin.erp@nitgoa.ac.in', TRUE, '10.10.1.2', TIMESTAMP '2026-03-01 09:30:00'),
    ('registrar.office@nitgoa.ac.in', TRUE, '10.10.1.3', TIMESTAMP '2026-03-01 09:35:00'),
    ('tanvi.kale23@nitgoa.ac.in', TRUE, '10.10.1.31', TIMESTAMP '2026-03-01 10:02:00'),
    ('aman.tyagi22@nitgoa.ac.in', TRUE, '10.10.1.32', TIMESTAMP '2026-03-01 10:14:00'),
    ('bhavya.naik24@nitgoa.ac.in', FALSE, '10.10.1.33', TIMESTAMP '2026-03-01 10:20:00'),
    ('bhavya.naik24@nitgoa.ac.in', TRUE, '10.10.1.33', TIMESTAMP '2026-03-01 10:24:00'),
    ('omkar.joshi24@nitgoa.ac.in', TRUE, '10.10.1.34', TIMESTAMP '2026-03-01 10:31:00'),
    ('priya.menon@nitgoa.ac.in', TRUE, '10.10.1.23', TIMESTAMP '2026-03-01 10:50:00'),
    ('meera.nair@nitgoa.ac.in', TRUE, '10.10.1.24', TIMESTAMP '2026-03-01 11:05:00'),
    ('kavita.reddy@nitgoa.ac.in', TRUE, '10.10.1.25', TIMESTAMP '2026-03-01 11:16:00'),
    ('deepak.gupta@nitgoa.ac.in', FALSE, '10.10.1.26', TIMESTAMP '2026-03-01 11:25:00'),
    ('fatima.sheikh23@nitgoa.ac.in', TRUE, '10.10.1.35', TIMESTAMP '2026-03-01 11:40:00'),
    ('diya.kapoor24@nitgoa.ac.in', TRUE, '10.10.1.36', TIMESTAMP '2026-03-01 12:02:00')
) AS x(email, success, ip_address, attempted_at)
JOIN users u ON u.email = x.email;

-- ------------------------------------------------------------
-- 4) COURSES, OFFERINGS, ENROLLMENTS
-- ------------------------------------------------------------

INSERT INTO courses (code, name, credits, type) VALUES
('CS101', 'Programming Fundamentals', 4, 'theory'),
('CS102', 'Data Structures', 4, 'theory'),
('MA101', 'Engineering Mathematics I', 3, 'theory'),
('EE101', 'Basic Electrical Engineering', 3, 'theory'),
('ME101', 'Engineering Mechanics', 3, 'theory'),
('HS101', 'Technical Communication', 2, 'theory'),
('CS201', 'Database Management Systems', 4, 'theory'),
('CS202', 'Object Oriented Programming', 4, 'theory'),
('CS203L', 'DBMS Lab', 2, 'lab'),
('CS301', 'Operating Systems', 4, 'theory'),
('CS302', 'Computer Networks', 4, 'theory'),
('EC201', 'Signals and Systems', 4, 'theory');

INSERT INTO course_prerequisites (course_id, prerequisite_course_id)
SELECT c2.id, c1.id
FROM (
    VALUES
    ('CS102','CS101'),
    ('CS201','CS102'),
    ('CS202','CS101'),
    ('CS203L','CS201'),
    ('CS301','CS202'),
    ('CS302','CS201')
) AS x(course_code, prereq_code)
JOIN courses c2 ON c2.code = x.course_code
JOIN courses c1 ON c1.code = x.prereq_code;

INSERT INTO course_offerings (course_id, faculty_id, semester_id)
SELECT c.id, f.id, s.id
FROM (
    VALUES
    ('CS101',  'ananya.sharma@nitgoa.ac.in', '2025-26 Even'),
    ('CS102',  'rahul.verma@nitgoa.ac.in',   '2025-26 Even'),
    ('MA101',  'arvind.iyer@nitgoa.ac.in',   '2025-26 Even'),
    ('EE101',  'meera.nair@nitgoa.ac.in',    '2025-26 Even'),
    ('ME101',  'kavita.reddy@nitgoa.ac.in',  '2025-26 Even'),
    ('HS101',  'arvind.iyer@nitgoa.ac.in',   '2025-26 Even'),
    ('CS201',  'priya.menon@nitgoa.ac.in',   '2025-26 Even'),
    ('CS202',  'ananya.sharma@nitgoa.ac.in', '2025-26 Even'),
    ('CS301',  'rahul.verma@nitgoa.ac.in',   '2025-26 Even'),
    ('CS302',  'suresh.patil@nitgoa.ac.in',  '2025-26 Even'),
    ('EC201',  'deepak.gupta@nitgoa.ac.in',  '2025-26 Even'),
    ('CS203L', 'priya.menon@nitgoa.ac.in',   '2025-26 Even')
) AS x(course_code, faculty_email, sem_name)
JOIN courses c ON c.code = x.course_code
JOIN users u ON u.email = x.faculty_email
JOIN faculty f ON f.user_id = u.id
JOIN semesters s ON s.name = x.sem_name;

INSERT INTO course_offering_classes (course_offering_id, class_id)
SELECT co.id, cl.id
FROM (
    VALUES
    ('CS101',  'ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('CS101',  'ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering', 'BTech', 1, 'B'),
    ('CS102',  'rahul.verma@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('CS102',  'rahul.verma@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 1, 'B'),
    ('MA101',  'arvind.iyer@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('MA101',  'arvind.iyer@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 1, 'B'),
    ('MA101',  'arvind.iyer@nitgoa.ac.in',   'Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('EE101',  'meera.nair@nitgoa.ac.in',    'Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('ME101',  'kavita.reddy@nitgoa.ac.in',  'Mechanical Engineering', 'BTech', 1, 'A'),
    ('HS101',  'arvind.iyer@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 1, 'A'),
    ('HS101',  'arvind.iyer@nitgoa.ac.in',   'Electrical and Electronics Engineering', 'BTech', 1, 'A'),
    ('CS201',  'priya.menon@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 2, 'A'),
    ('CS201',  'priya.menon@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 2, 'B'),
    ('CS202',  'ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering', 'BTech', 2, 'A'),
    ('CS202',  'ananya.sharma@nitgoa.ac.in', 'Computer Science and Engineering', 'BTech', 2, 'B'),
    ('CS203L', 'priya.menon@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 2, 'A'),
    ('CS203L', 'priya.menon@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 2, 'B'),
    ('CS301',  'rahul.verma@nitgoa.ac.in',   'Computer Science and Engineering', 'BTech', 3, 'A'),
    ('CS302',  'suresh.patil@nitgoa.ac.in',  'Computer Science and Engineering', 'BTech', 3, 'A'),
    ('EC201',  'deepak.gupta@nitgoa.ac.in',  'Electrical and Electronics Engineering', 'BTech', 2, 'A')
) AS x(course_code, faculty_email, dept_name, prog_name, year, section)
JOIN courses c ON c.code = x.course_code
JOIN users u ON u.email = x.faculty_email
JOIN faculty f ON f.user_id = u.id
JOIN semesters sem ON sem.name = '2025-26 Even'
JOIN course_offerings co ON co.course_id = c.id AND co.faculty_id = f.id AND co.semester_id = sem.id
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.prog_name
JOIN classes cl ON cl.department_id = d.id AND cl.program_id = p.id AND cl.year = x.year AND cl.section = x.section;

-- Enroll each student to all offerings mapped to their class
INSERT INTO enrollments (student_id, course_offering_id, status)
SELECT s.id, coc.course_offering_id, 'enrolled'
FROM students s
JOIN course_offering_classes coc ON coc.class_id = s.class_id;

INSERT INTO backlogs (student_id, course_id, status, created_at)
SELECT s.id, c.id, x.status, x.created_at
FROM (
    VALUES
    ('BT23CSE103', 'CS101', 'pending',  TIMESTAMP '2026-01-15 10:00:00'),
    ('BT23CSE154', 'CS102', 'pending',  TIMESTAMP '2026-01-20 11:30:00'),
    ('BT22CSE201', 'CS201', 'pending',  TIMESTAMP '2026-02-01 09:15:00'),
    ('BT23EEE102', 'EE101', 'pending',  TIMESTAMP '2026-01-18 14:10:00'),
    ('BT24ME001',  'ME101', 'pending',  TIMESTAMP '2026-02-05 16:00:00'),
    ('BT23CSE104', 'CS101', 'cleared',  TIMESTAMP '2025-08-10 10:00:00'),
    ('BT23CSE152', 'MA101', 'cleared',  TIMESTAMP '2025-08-12 12:00:00'),
    ('BT23CSE153', 'CS102', 'pending',  TIMESTAMP '2026-02-09 10:45:00'),
    ('BT23EEE101', 'MA101', 'pending',  TIMESTAMP '2026-02-11 11:20:00'),
    ('BT22CSE203', 'CS202', 'pending',  TIMESTAMP '2026-02-14 15:35:00')
) AS x(roll_number, course_code, status, created_at)
JOIN students s ON s.roll_number = x.roll_number
JOIN courses c ON c.code = x.course_code;

-- ------------------------------------------------------------
-- 5) TIMETABLE, SESSIONS, ATTENDANCE
-- ------------------------------------------------------------

INSERT INTO timetable (class_id, course_offering_id, faculty_id, day_of_week, time_slot_id, room)
SELECT cl.id, co.id, f.id, x.day_of_week, ts.id, x.room
FROM (
    VALUES
    ('Computer Science and Engineering', 'BTech', 1, 'A', 'CS101',  'ananya.sharma@nitgoa.ac.in', 1, '09:00', 'B1-201'),
    ('Computer Science and Engineering', 'BTech', 1, 'B', 'CS101',  'ananya.sharma@nitgoa.ac.in', 3, '09:00', 'B1-202'),
    ('Computer Science and Engineering', 'BTech', 1, 'A', 'CS102',  'rahul.verma@nitgoa.ac.in',   2, '10:00', 'B1-203'),
    ('Computer Science and Engineering', 'BTech', 1, 'B', 'CS102',  'rahul.verma@nitgoa.ac.in',   4, '10:00', 'B1-204'),
    ('Computer Science and Engineering', 'BTech', 1, 'A', 'MA101',  'arvind.iyer@nitgoa.ac.in',   5, '08:00', 'A2-110'),
    ('Electrical and Electronics Engineering', 'BTech', 1, 'A', 'MA101', 'arvind.iyer@nitgoa.ac.in', 2, '08:00', 'A2-111'),
    ('Electrical and Electronics Engineering', 'BTech', 1, 'A', 'EE101', 'meera.nair@nitgoa.ac.in', 1, '11:00', 'E1-305'),
    ('Mechanical Engineering', 'BTech', 1, 'A', 'ME101', 'kavita.reddy@nitgoa.ac.in', 3, '11:00', 'M1-101'),
    ('Computer Science and Engineering', 'BTech', 2, 'A', 'CS201',  'priya.menon@nitgoa.ac.in',   1, '13:00', 'C2-401'),
    ('Computer Science and Engineering', 'BTech', 2, 'B', 'CS201',  'priya.menon@nitgoa.ac.in',   3, '13:00', 'C2-402'),
    ('Computer Science and Engineering', 'BTech', 2, 'A', 'CS202',  'ananya.sharma@nitgoa.ac.in', 2, '14:00', 'C2-410'),
    ('Computer Science and Engineering', 'BTech', 2, 'B', 'CS202',  'ananya.sharma@nitgoa.ac.in', 4, '14:00', 'C2-411'),
    ('Computer Science and Engineering', 'BTech', 3, 'A', 'CS301',  'rahul.verma@nitgoa.ac.in',   2, '11:00', 'C3-501'),
    ('Computer Science and Engineering', 'BTech', 3, 'A', 'CS302',  'suresh.patil@nitgoa.ac.in',  4, '11:00', 'C3-502'),
    ('Electrical and Electronics Engineering', 'BTech', 2, 'A', 'EC201', 'deepak.gupta@nitgoa.ac.in', 5, '13:00', 'E2-210'),
    ('Computer Science and Engineering', 'BTech', 2, 'A', 'CS203L', 'priya.menon@nitgoa.ac.in',   5, '14:00', 'LAB-C2-7'),
    ('Computer Science and Engineering', 'BTech', 2, 'B', 'CS203L', 'priya.menon@nitgoa.ac.in',   2, '13:00', 'LAB-C2-8')
) AS x(dept_name, prog_name, year, section, course_code, faculty_email, day_of_week, start_time, room)
JOIN departments d ON d.name = x.dept_name
JOIN programs p ON p.name = x.prog_name
JOIN classes cl ON cl.department_id = d.id AND cl.program_id = p.id AND cl.year = x.year AND cl.section = x.section
JOIN courses c ON c.code = x.course_code
JOIN users u ON u.email = x.faculty_email
JOIN faculty f ON f.user_id = u.id
JOIN semesters sem ON sem.name = '2025-26 Even'
JOIN course_offerings co ON co.course_id = c.id AND co.faculty_id = f.id AND co.semester_id = sem.id
JOIN time_slots ts ON ts.start_time = x.start_time::TIME;

INSERT INTO class_sessions (timetable_id, class_id, course_offering_id, date, status)
SELECT t.id, t.class_id, t.course_offering_id,
    DATE '2026-03-09' + ((ROW_NUMBER() OVER (ORDER BY t.id) - 1)::INT),
       CASE WHEN ROW_NUMBER() OVER (ORDER BY t.id) % 7 = 0 THEN 'rescheduled' ELSE 'completed' END
FROM timetable t;

INSERT INTO class_changes (class_session_id, type, new_date, new_time_slot_id, reason, created_by)
SELECT cs.id,
       CASE WHEN cs.status = 'rescheduled' THEN 'reschedule' ELSE 'cancel' END,
       cs.date + 1,
       ts.id,
       CASE WHEN cs.status = 'rescheduled' THEN 'Faculty attending senate meeting' ELSE 'Campus maintenance block closure' END,
       u.id
FROM class_sessions cs
JOIN time_slots ts ON ts.start_time = TIME '14:00'
JOIN users u ON u.email = 'admin.erp@nitgoa.ac.in'
WHERE cs.status IN ('rescheduled')
LIMIT 3;

INSERT INTO attendance_sessions (class_session_id, course_offering_id, started_at, ended_at)
SELECT cs.id, cs.course_offering_id,
       (cs.date::timestamp + TIME '09:00'),
       (cs.date::timestamp + TIME '09:20')
FROM class_sessions cs
ORDER BY cs.date
LIMIT 14;

INSERT INTO attendance_queue (attendance_session_id, student_id, sequence, status)
SELECT z.attendance_session_id, z.student_id, z.seq,
       CASE WHEN z.seq % 9 = 0 THEN 'pending' ELSE 'done' END
FROM (
    SELECT asess.id AS attendance_session_id,
           e.student_id,
           ROW_NUMBER() OVER (PARTITION BY asess.id ORDER BY s.roll_number) AS seq
    FROM attendance_sessions asess
    JOIN enrollments e ON e.course_offering_id = asess.course_offering_id AND e.status = 'enrolled'
    JOIN students s ON s.id = e.student_id
) z;

INSERT INTO attendance_records (attendance_session_id, student_id, status, recorded_at)
SELECT z.attendance_session_id, z.student_id,
       CASE WHEN z.seq % 6 = 0 THEN 'absent' ELSE 'present' END,
       TIMESTAMP '2026-03-10 09:05:00' + (z.seq || ' minutes')::INTERVAL
FROM (
    SELECT asess.id AS attendance_session_id,
           e.student_id,
           ROW_NUMBER() OVER (PARTITION BY asess.id ORDER BY s.roll_number) AS seq
    FROM attendance_sessions asess
    JOIN enrollments e ON e.course_offering_id = asess.course_offering_id AND e.status = 'enrolled'
    JOIN students s ON s.id = e.student_id
) z;

-- ------------------------------------------------------------
-- 6) EXAMS, MARKS, GRADES
-- ------------------------------------------------------------

INSERT INTO exams (course_offering_id, type, date, max_marks, is_published)
SELECT co.id, 'midsem', DATE '2026-03-25', 30, TRUE
FROM course_offerings co
JOIN semesters s ON s.id = co.semester_id
WHERE s.name = '2025-26 Even'
UNION ALL
SELECT co.id, 'endsem', DATE '2026-05-05', 70, FALSE
FROM course_offerings co
JOIN semesters s ON s.id = co.semester_id
WHERE s.name = '2025-26 Even';

INSERT INTO marks (student_id, exam_id, marks_obtained)
SELECT e.student_id,
       ex.id,
       CASE
           WHEN ex.type = 'midsem' THEN
               CASE WHEN rn % 7 = 0 THEN 14 WHEN rn % 5 = 0 THEN 18 WHEN rn % 3 = 0 THEN 22 ELSE 26 END
           ELSE
               CASE WHEN rn % 7 = 0 THEN 38 WHEN rn % 5 = 0 THEN 45 WHEN rn % 3 = 0 THEN 55 ELSE 63 END
       END::FLOAT
FROM (
    SELECT ex.id AS exam_id,
           ex.type,
           en.student_id,
           ROW_NUMBER() OVER (PARTITION BY ex.id ORDER BY s.roll_number) AS rn
    FROM exams ex
    JOIN enrollments en ON en.course_offering_id = ex.course_offering_id
    JOIN students s ON s.id = en.student_id
) t
JOIN exams ex ON ex.id = t.exam_id
JOIN enrollments e ON e.student_id = t.student_id AND e.course_offering_id = ex.course_offering_id;

INSERT INTO grades (student_id, course_offering_id, grade, grade_points, is_final, published_at)
SELECT en.student_id,
       en.course_offering_id,
       CASE
           WHEN rn % 11 = 0 THEN 'F'
           WHEN rn % 7 = 0 THEN 'C'
           WHEN rn % 5 = 0 THEN 'B'
           WHEN rn % 3 = 0 THEN 'A'
           ELSE 'A+'
       END AS grade,
       CASE
           WHEN rn % 11 = 0 THEN 0
           WHEN rn % 7 = 0 THEN 6
           WHEN rn % 5 = 0 THEN 8
           WHEN rn % 3 = 0 THEN 9
           ELSE 10
       END::FLOAT AS grade_points,
       TRUE,
       TIMESTAMP '2026-05-20 10:00:00'
FROM (
    SELECT en.student_id,
           en.course_offering_id,
           ROW_NUMBER() OVER (PARTITION BY en.course_offering_id ORDER BY s.roll_number) AS rn
    FROM enrollments en
    JOIN students s ON s.id = en.student_id
    WHERE en.status = 'enrolled'
) en;

-- ------------------------------------------------------------
-- 7) LEAVE WORKFLOW
-- ------------------------------------------------------------

INSERT INTO leave_requests (student_id, from_date, to_date, reason, status, current_step, version, created_at)
SELECT s.id, x.from_date, x.to_date, x.reason, 'pending', 1, 1, x.created_at
FROM (
    VALUES
    ('BT24CSE003', DATE '2026-03-21', DATE '2026-03-22', 'Medical consultation and rest advised by physician', TIMESTAMP '2026-03-18 09:30:00'),
    ('BT24CSE055', DATE '2026-03-25', DATE '2026-03-27', 'Family wedding travel', TIMESTAMP '2026-03-19 11:10:00'),
    ('BT23CSE102', DATE '2026-03-28', DATE '2026-03-29', 'Participation in inter-college hackathon finals', TIMESTAMP '2026-03-20 16:05:00'),
    ('BT23CSE153', DATE '2026-04-01', DATE '2026-04-03', 'Minor surgery follow-up visits', TIMESTAMP '2026-03-21 10:15:00'),
    ('BT24EEE002', DATE '2026-03-24', DATE '2026-03-24', 'Bank document verification with parent', TIMESTAMP '2026-03-18 15:40:00'),
    ('BT24ME002',  DATE '2026-03-30', DATE '2026-04-01', 'NCC camp attendance', TIMESTAMP '2026-03-22 08:45:00')
) AS x(roll_number, from_date, to_date, reason, created_at)
JOIN students s ON s.roll_number = x.roll_number;

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 1, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'CR';

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 2, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'advisor';

INSERT INTO leave_approval_steps (leave_request_id, step_order, role_required_id, status)
SELECT lr.id, 3, r.id, 'pending'
FROM leave_requests lr
JOIN roles r ON r.name = 'HoD';

INSERT INTO leave_documents (leave_request_id, file_url)
SELECT lr.id, x.file_url
FROM (
    VALUES
    ('BT24CSE003', 'https://docs.campus.edu/leave/medcert_bt24cse003.pdf'),
    ('BT23CSE153', 'https://docs.campus.edu/leave/discharge_bt23cse153.pdf'),
    ('BT23CSE102', 'https://docs.campus.edu/leave/hackathon_invite_bt23cse102.pdf'),
    ('BT24ME002',  'https://docs.campus.edu/leave/ncc_order_bt24me002.pdf')
) AS x(roll_number, file_url)
JOIN students s ON s.roll_number = x.roll_number
JOIN leave_requests lr ON lr.student_id = s.id;

-- ------------------------------------------------------------
-- 8) NOTIFICATIONS
-- ------------------------------------------------------------

INSERT INTO notifications (title, message, created_by, created_at)
SELECT x.title, x.message, u.id, x.created_at
FROM (
    VALUES
    ('Mid-Sem Timetable Published', 'Mid-sem examination timetable is now available in the exam portal.', 'admin.erp@nitgoa.ac.in', TIMESTAMP '2026-03-18 09:00:00'),
    ('Fee Reminder', 'Tuition fee due date is approaching. Please clear dues by April 30.', 'registrar.office@nitgoa.ac.in', TIMESTAMP '2026-03-19 10:15:00'),
    ('Placement Drive: Infrabyte', 'Infrabyte software engineer role opened for CSE and EEE students.', 'priya.menon@nitgoa.ac.in', TIMESTAMP '2026-03-20 14:20:00'),
    ('Library Maintenance', 'Central library will remain closed on Sunday due to server migration.', 'admin.erp@nitgoa.ac.in', TIMESTAMP '2026-03-21 17:30:00'),
    ('Canteen Menu Update', 'High-protein combo is available this week at discounted price.', 'admin.erp@nitgoa.ac.in', TIMESTAMP '2026-03-22 11:00:00')
) AS x(title, message, created_by_email, created_at)
JOIN users u ON u.email = x.created_by_email;

INSERT INTO notification_targets (notification_id, target_type, target_id)
SELECT n.id, 'class', c.id
FROM notifications n
JOIN classes c ON c.year = 1 AND c.section = 'A'
JOIN departments d ON d.id = c.department_id AND d.name = 'Computer Science and Engineering'
WHERE n.title = 'Mid-Sem Timetable Published'
UNION ALL
SELECT n.id, 'user', u.id
FROM notifications n
JOIN users u ON u.email = 'aisha.khan24@nitgoa.ac.in'
WHERE n.title = 'Fee Reminder'
UNION ALL
SELECT n.id, 'department', d.id
FROM notifications n
JOIN departments d ON d.name = 'Computer Science and Engineering'
WHERE n.title = 'Placement Drive: Infrabyte'
UNION ALL
SELECT n.id, 'department', d.id
FROM notifications n
JOIN departments d ON d.name = 'Electrical and Electronics Engineering'
WHERE n.title = 'Placement Drive: Infrabyte'
UNION ALL
SELECT n.id, 'course_offering', co.id
FROM notifications n
JOIN course_offerings co ON co.id = (
    SELECT co2.id
    FROM course_offerings co2
    JOIN courses c ON c.id = co2.course_id
    WHERE c.code = 'CS201'
    LIMIT 1
)
WHERE n.title = 'Library Maintenance';

INSERT INTO notification_reads (notification_id, user_id, read_at)
SELECT n.id, u.id, TIMESTAMP '2026-03-23 09:00:00' + (rn || ' minutes')::INTERVAL
FROM notifications n
JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY email) AS rn
    FROM users
    WHERE base_role IN ('student', 'faculty')
    LIMIT 25
) u ON TRUE
WHERE n.title IN ('Mid-Sem Timetable Published', 'Fee Reminder')
  AND (u.rn % 2 = 0 OR n.title = 'Mid-Sem Timetable Published');

INSERT INTO notification_deliveries (notification_id, user_id, channel, status, delivered_at)
SELECT n.id, u.id, ch.channel,
       CASE WHEN u.rn % 9 = 0 THEN 'failed' ELSE 'delivered' END,
       CASE WHEN u.rn % 9 = 0 THEN NULL ELSE TIMESTAMP '2026-03-23 09:10:00' + (u.rn || ' minutes')::INTERVAL END
FROM notifications n
JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY email) AS rn
    FROM users
    WHERE base_role IN ('student', 'faculty')
    LIMIT 20
) u ON TRUE
JOIN (
    VALUES ('push'), ('email')
) AS ch(channel) ON TRUE
WHERE n.title IN ('Mid-Sem Timetable Published', 'Placement Drive: Infrabyte');

-- ------------------------------------------------------------
-- 9) PLACEMENTS
-- ------------------------------------------------------------

INSERT INTO companies (name, website, created_at) VALUES
('Infrabyte Systems', 'https://www.infrabyte.example', TIMESTAMP '2026-03-10 09:00:00'),
('Nordic Analytics', 'https://www.nordic-analytics.example', TIMESTAMP '2026-03-11 10:00:00'),
('Aster Mobility', 'https://www.astermobility.example', TIMESTAMP '2026-03-12 11:00:00'),
('BluePeak Networks', 'https://www.bluepeak.example', TIMESTAMP '2026-03-12 11:30:00'),
('Quantum Forge Labs', 'https://www.quantumforge.example', TIMESTAMP '2026-03-13 12:15:00');

INSERT INTO job_postings (company_id, role, description, deadline, created_at)
SELECT c.id, x.role, x.description, x.deadline, x.created_at
FROM (
    VALUES
    ('Infrabyte Systems', 'Software Engineer Trainee', 'Backend-focused role for Java/Python development and API testing.', TIMESTAMP '2026-05-30 23:59:00', TIMESTAMP '2026-03-20 10:00:00'),
    ('Infrabyte Systems', 'Data Analyst Intern', 'SQL and BI internship with production dashboards.', TIMESTAMP '2026-05-28 23:59:00', TIMESTAMP '2026-03-20 10:30:00'),
    ('Nordic Analytics', 'ML Engineering Intern', 'Model training pipelines and MLOps monitoring.', TIMESTAMP '2026-06-05 23:59:00', TIMESTAMP '2026-03-21 09:30:00'),
    ('Aster Mobility', 'Embedded Systems Graduate Engineer', 'Firmware validation and CAN bus diagnostics.', TIMESTAMP '2026-05-25 23:59:00', TIMESTAMP '2026-03-21 15:45:00'),
    ('BluePeak Networks', 'Network Operations Trainee', 'L2 NOC operations and incident response.', TIMESTAMP '2026-05-22 23:59:00', TIMESTAMP '2026-03-22 11:10:00'),
    ('Quantum Forge Labs', 'Research Assistant - Applied AI', 'Prototype research assistantship with publication support.', TIMESTAMP '2026-06-15 23:59:00', TIMESTAMP '2026-03-22 16:40:00')
) AS x(company_name, role, description, deadline, created_at)
JOIN companies c ON c.name = x.company_name;

INSERT INTO placement_criteria (job_id, min_cgpa, min_attendance, max_backlogs)
SELECT jp.id, x.min_cgpa, x.min_attendance, x.max_backlogs
FROM (
    VALUES
    ('Software Engineer Trainee', 7.0, 75.0, 1),
    ('Data Analyst Intern', 6.5, 70.0, 2),
    ('ML Engineering Intern', 8.0, 80.0, 0),
    ('Embedded Systems Graduate Engineer', 6.8, 70.0, 2),
    ('Network Operations Trainee', 6.2, 68.0, 2),
    ('Research Assistant - Applied AI', 8.2, 80.0, 0)
) AS x(role, min_cgpa, min_attendance, max_backlogs)
JOIN job_postings jp ON jp.role = x.role;

INSERT INTO placement_allowed_departments (job_id, department_id)
SELECT jp.id, d.id
FROM (
    VALUES
    ('Software Engineer Trainee', 'Computer Science and Engineering'),
    ('Software Engineer Trainee', 'Electrical and Electronics Engineering'),
    ('Data Analyst Intern', 'Computer Science and Engineering'),
    ('Data Analyst Intern', 'Electrical and Electronics Engineering'),
    ('ML Engineering Intern', 'Computer Science and Engineering'),
    ('Embedded Systems Graduate Engineer', 'Electrical and Electronics Engineering'),
    ('Embedded Systems Graduate Engineer', 'Mechanical Engineering'),
    ('Network Operations Trainee', 'Electrical and Electronics Engineering'),
    ('Research Assistant - Applied AI', 'Computer Science and Engineering')
) AS x(role, dept_name)
JOIN job_postings jp ON jp.role = x.role
JOIN departments d ON d.name = x.dept_name;

INSERT INTO placement_allowed_programs (job_id, program_id)
SELECT jp.id, p.id
FROM (
    VALUES
    ('Software Engineer Trainee', 'BTech'),
    ('Data Analyst Intern', 'BTech'),
    ('ML Engineering Intern', 'BTech'),
    ('ML Engineering Intern', 'MTech'),
    ('Embedded Systems Graduate Engineer', 'BTech'),
    ('Network Operations Trainee', 'BTech'),
    ('Research Assistant - Applied AI', 'BTech'),
    ('Research Assistant - Applied AI', 'MTech')
) AS x(role, program_name)
JOIN job_postings jp ON jp.role = x.role
JOIN programs p ON p.name = x.program_name;

INSERT INTO applications (student_id, job_id, status, applied_at)
SELECT s.id, jp.id, x.status, x.applied_at
FROM (
    VALUES
    ('BT22CSE201', 'Software Engineer Trainee', 'applied',     TIMESTAMP '2026-03-24 09:20:00'),
    ('BT22CSE202', 'Software Engineer Trainee', 'shortlisted', TIMESTAMP '2026-03-24 09:25:00'),
    ('BT22CSE203', 'Data Analyst Intern',       'applied',     TIMESTAMP '2026-03-24 09:31:00'),
    ('BT23CSE101', 'Data Analyst Intern',       'applied',     TIMESTAMP '2026-03-25 10:05:00'),
    ('BT23CSE102', 'ML Engineering Intern',     'applied',     TIMESTAMP '2026-03-25 10:20:00'),
    ('BT23CSE103', 'Software Engineer Trainee', 'rejected',    TIMESTAMP '2026-03-25 10:55:00'),
    ('BT23CSE104', 'Software Engineer Trainee', 'applied',     TIMESTAMP '2026-03-25 11:10:00'),
    ('BT23CSE151', 'ML Engineering Intern',     'shortlisted', TIMESTAMP '2026-03-25 11:35:00'),
    ('BT23CSE152', 'Research Assistant - Applied AI', 'applied', TIMESTAMP '2026-03-26 09:40:00'),
    ('BT23CSE153', 'Data Analyst Intern',       'applied',     TIMESTAMP '2026-03-26 10:05:00'),
    ('BT23CSE154', 'Software Engineer Trainee', 'applied',     TIMESTAMP '2026-03-26 10:30:00'),
    ('BT24EEE001', 'Embedded Systems Graduate Engineer', 'applied', TIMESTAMP '2026-03-26 11:00:00'),
    ('BT24EEE002', 'Network Operations Trainee', 'applied',    TIMESTAMP '2026-03-26 11:20:00'),
    ('BT24EEE003', 'Embedded Systems Graduate Engineer', 'applied', TIMESTAMP '2026-03-26 11:42:00'),
    ('BT24EEE004', 'Network Operations Trainee', 'shortlisted', TIMESTAMP '2026-03-26 12:03:00'),
    ('BT23EEE101', 'Embedded Systems Graduate Engineer', 'applied', TIMESTAMP '2026-03-27 09:05:00'),
    ('BT23EEE102', 'Network Operations Trainee', 'applied',    TIMESTAMP '2026-03-27 09:30:00'),
    ('BT23EEE103', 'Data Analyst Intern',       'applied',     TIMESTAMP '2026-03-27 09:55:00'),
    ('BT24ME001',  'Embedded Systems Graduate Engineer', 'applied', TIMESTAMP '2026-03-27 10:15:00'),
    ('BT24ME002',  'Network Operations Trainee', 'applied',    TIMESTAMP '2026-03-27 10:40:00')
) AS x(roll_number, role, status, applied_at)
JOIN students s ON s.roll_number = x.roll_number
JOIN job_postings jp ON jp.role = x.role;

-- ------------------------------------------------------------
-- 10) FEES
-- ------------------------------------------------------------

INSERT INTO fees (student_id, amount, due_date, type, semester_id, status, version, created_at)
SELECT s.id,
       CASE
           WHEN c.year = 1 THEN 85000
           WHEN c.year = 2 THEN 90000
           ELSE 95000
       END::FLOAT,
       DATE '2026-04-30',
       'tuition',
       sem.id,
       'pending',
       1,
       TIMESTAMP '2026-03-15 09:00:00'
FROM students s
JOIN classes c ON c.id = s.class_id
JOIN semesters sem ON sem.name = '2025-26 Even';

INSERT INTO fee_payments (fee_id, amount_paid, payment_method, transaction_id, paid_at)
SELECT f.id,
       CASE WHEN rn % 4 = 0 THEN (f.amount * 1.0) ELSE (f.amount * 0.5) END,
       CASE WHEN rn % 3 = 0 THEN 'netbanking' WHEN rn % 2 = 0 THEN 'card' ELSE 'upi' END,
       'TXN-FEE-' || LPAD(rn::TEXT, 5, '0'),
       TIMESTAMP '2026-03-28 10:00:00' + (rn || ' minutes')::INTERVAL
FROM (
    SELECT id, amount, ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM fees
    ORDER BY id
    LIMIT 20
) f;

-- ------------------------------------------------------------
-- 11) CANTEEN + PAYMENTS
-- ------------------------------------------------------------

INSERT INTO canteen_items (name, price, available) VALUES
('Masala Dosa', 55, TRUE),
('Veg Sandwich', 45, TRUE),
('Paneer Wrap', 70, TRUE),
('Lemon Rice', 50, TRUE),
('Rajma Chawal', 65, TRUE),
('Chicken Roll', 85, TRUE),
('Idli Sambar', 40, TRUE),
('Poha', 30, TRUE),
('Cold Coffee', 60, TRUE),
('Filter Coffee', 25, TRUE),
('Tea', 15, TRUE),
('Banana Smoothie', 75, TRUE),
('Fruit Bowl', 80, TRUE),
('Veg Thali', 90, TRUE),
('Mineral Water 1L', 20, TRUE);

INSERT INTO orders (student_id, status, type, total_amount, version, created_at)
SELECT s.id,
       CASE WHEN rn % 6 = 0 THEN 'ready' WHEN rn % 4 = 0 THEN 'preparing' ELSE 'completed' END,
       CASE WHEN rn % 3 = 0 THEN 'dine-in' ELSE 'takeaway' END,
       0,
       1,
       TIMESTAMP '2026-03-23 12:00:00' + (rn || ' minutes')::INTERVAL
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY roll_number) AS rn
    FROM students
    LIMIT 20
) s;

INSERT INTO order_items (order_id, canteen_item_id, quantity, unit_price)
SELECT o.id,
       ci.id,
       CASE WHEN x.seq % 4 = 0 THEN 2 ELSE 1 END,
       ci.price
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY created_at) AS rn
    FROM orders
) o
JOIN LATERAL (
    VALUES
    (1, (o.rn % 15) + 1),
    (2, ((o.rn + 4) % 15) + 1)
) AS x(seq, item_no) ON TRUE
JOIN (
    SELECT id, ROW_NUMBER() OVER (ORDER BY name) AS item_no, price
    FROM canteen_items
) ci ON ci.item_no = x.item_no;

INSERT INTO payments (order_id, amount, payment_method, status, paid_at)
SELECT o.id,
       o.total_amount,
       CASE WHEN rn % 3 = 0 THEN 'wallet' WHEN rn % 2 = 0 THEN 'card' ELSE 'upi' END,
       CASE WHEN rn % 7 = 0 THEN 'pending' ELSE 'paid' END,
       CASE WHEN rn % 7 = 0 THEN NULL ELSE (o.created_at + INTERVAL '20 minutes') END
FROM (
    SELECT id, created_at, total_amount, ROW_NUMBER() OVER (ORDER BY created_at) AS rn
    FROM orders
) o;

-- ------------------------------------------------------------
-- 12) AUDIT + EVENT BUS
-- ------------------------------------------------------------

INSERT INTO audit_logs (user_id, action, entity_type, entity_id, metadata, timestamp)
SELECT u.id,
       x.action,
       x.entity_type,
    x.entity_id::UUID,
       x.metadata::jsonb,
       x.ts
FROM (
    VALUES
    ('admin.erp@nitgoa.ac.in', 'CREATE', 'notification', NULL, '{"module":"notifications","source":"admin_panel"}', TIMESTAMP '2026-03-22 11:00:00'),
    ('registrar.office@nitgoa.ac.in', 'UPDATE', 'fee', NULL, '{"module":"fees","reason":"bulk reminder"}', TIMESTAMP '2026-03-22 12:05:00'),
    ('ananya.sharma@nitgoa.ac.in', 'UPDATE', 'marks', NULL, '{"module":"exams","exam_type":"midsem"}', TIMESTAMP '2026-03-25 17:30:00'),
    ('priya.menon@nitgoa.ac.in', 'CREATE', 'job_posting', NULL, '{"module":"placements","company":"Infrabyte Systems"}', TIMESTAMP '2026-03-20 10:00:00'),
    ('meera.nair@nitgoa.ac.in', 'UPDATE', 'attendance_record', NULL, '{"module":"attendance","batch":"EEE1A"}', TIMESTAMP '2026-03-14 09:45:00'),
    ('aisha.khan24@nitgoa.ac.in', 'READ', 'notification', NULL, '{"module":"notifications","channel":"push"}', TIMESTAMP '2026-03-23 09:22:00'),
    ('tanvi.kale23@nitgoa.ac.in', 'CREATE', 'leave_request', NULL, '{"module":"leave","days":2}', TIMESTAMP '2026-03-19 11:10:00'),
    ('aman.tyagi22@nitgoa.ac.in', 'CREATE', 'application', NULL, '{"module":"placements","role":"Software Engineer Trainee"}', TIMESTAMP '2026-03-24 09:20:00'),
    ('bhavya.naik24@nitgoa.ac.in', 'CREATE', 'order', NULL, '{"module":"canteen","type":"takeaway"}', TIMESTAMP '2026-03-23 12:35:00'),
    ('omkar.joshi24@nitgoa.ac.in', 'CREATE', 'payment', NULL, '{"module":"canteen","method":"upi"}', TIMESTAMP '2026-03-23 13:05:00'),
    ('admin.erp@nitgoa.ac.in', 'LOGIN', 'user', NULL, '{"module":"auth","ip":"10.10.1.1"}', TIMESTAMP '2026-03-01 08:00:00'),
    ('registrar.office@nitgoa.ac.in', 'LOGIN', 'user', NULL, '{"module":"auth","ip":"10.10.1.2"}', TIMESTAMP '2026-03-01 09:00:00')
) AS x(email, action, entity_type, entity_id, metadata, ts)
JOIN users u ON u.email = x.email;

INSERT INTO events (type, payload, created_at) VALUES
('attendance.session.started', '{"class":"CSE1A","course":"CS101"}', TIMESTAMP '2026-03-10 09:00:00'),
('attendance.session.closed', '{"class":"CSE1A","present":4,"absent":1}', TIMESTAMP '2026-03-10 09:25:00'),
('exam.marks.published', '{"course":"CS201","exam":"midsem"}', TIMESTAMP '2026-03-25 18:00:00'),
('fees.reminder.sent', '{"count":30,"channel":"email"}', TIMESTAMP '2026-03-22 12:10:00'),
('placement.job.opened', '{"company":"Infrabyte Systems","role":"Software Engineer Trainee"}', TIMESTAMP '2026-03-20 10:02:00'),
('placement.application.received', '{"student":"BT22CSE201","job":"Software Engineer Trainee"}', TIMESTAMP '2026-03-24 09:20:00'),
('leave.request.created', '{"student":"BT24CSE003","days":2}', TIMESTAMP '2026-03-18 09:30:00'),
('notification.dispatched', '{"title":"Mid-Sem Timetable Published","audience":"class"}', TIMESTAMP '2026-03-18 09:01:00'),
('canteen.order.created', '{"order_type":"takeaway"}', TIMESTAMP '2026-03-23 12:00:00'),
('canteen.payment.captured', '{"method":"upi","status":"paid"}', TIMESTAMP '2026-03-23 12:25:00');

COMMIT;

-- ============================================================
-- Optional sanity checks (run manually after insert):
--   SELECT COUNT(*) FROM users;
--   SELECT COUNT(*) FROM students;
--   SELECT COUNT(*) FROM enrollments;
--   SELECT COUNT(*) FROM attendance_records;
--   SELECT COUNT(*) FROM applications;
-- ============================================================

