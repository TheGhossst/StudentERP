DROP DATABASE test WITH (FORCE);
CREATE DATABASE test;

DROP DATABASE NITGOAERP WITH (FORCE);
CREATE DATABASE NITGOAERP;

SELECT datname FROM pg_database;
SELECT current_database() AS db, current_schema() AS schema, current_user AS usr;

SELECT 'roles' AS table_name, COUNT(*) FROM roles
UNION ALL
SELECT 'users_visible', COUNT(*) FROM users
UNION ALL
SELECT 'students_visible', COUNT(*) FROM students
UNION ALL
SELECT 'faculty', COUNT(*) FROM faculty
UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments;

ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE students DISABLE ROW LEVEL SECURITY;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

SELECT current_database(), current_schema();

select * from faculty;
select count(distinct(password_hash)) from users ;

SELECT COUNT(*) FROM login_attempts;

SELECT * FROM notifications;
SELECT * FROM notification_targets;
