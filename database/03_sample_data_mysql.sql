-- ============================================================
-- PDTS — Optional Local Sample Data | MySQL 8.0+
-- Run after database/01_schema_mysql.sql and database/02_seed_mysql.sql
-- ============================================================

USE pdts_db;

INSERT IGNORE INTO applicant (
    applicant_first_name,
    applicant_middle_name,
    applicant_last_name,
    applicant_sex,
    applicant_civil_status,
    applicant_house_number_street,
    applicant_barangay,
    applicant_city_municipality,
    applicant_province,
    applicant_region,
    applicant_zip_code,
    applicant_birth_date,
    applicant_email_address,
    applicant_contact_number,
    educational_background_category_id,
    applicant_enrollment_status,
    user_id
) VALUES
('Juan', 'Santos', 'Dela Cruz', 1, 1, '123 Mabini Street', 'Barangay 1', 'Manila', 'Metro Manila', 'NCR', '1008', '2003-05-15', 'juan.delacruz@example.com', '09171234567', 'SHS-002', 'continuing', 1),
('Maria', 'Reyes', 'Santos', 2, 1, '45 Bonifacio Avenue', 'Barangay 2', 'Quezon City', 'Metro Manila', 'NCR', '1100', '2002-09-21', 'maria.santos@example.com', '09181234567', 'COL-004', 'continuing', 1);

INSERT IGNORE INTO previous_education (
    applicant_id,
    educational_background_category_id,
    mode_of_learning,
    last_school_name,
    school_address,
    year_graduated,
    track,
    strand
)
SELECT applicant_id, educational_background_category_id, 'Online', 'Sample Senior High School', 'Sample School Address', 2025, 'Academic', 'ICT'
FROM applicant
WHERE applicant_email_address = 'juan.delacruz@example.com';

INSERT IGNORE INTO applicant_emergency_contact (
    applicant_id,
    contact_name,
    relationship,
    contact_number,
    contact_address
)
SELECT applicant_id, 'Ana Dela Cruz', 'Mother', '09170000001', 'Manila, Philippines'
FROM applicant
WHERE applicant_email_address = 'juan.delacruz@example.com';

INSERT IGNORE INTO application (
    applicant_id,
    program_id,
    campus_id,
    application_status_id,
    application_date,
    application_semester,
    application_academic_year,
    application_reference_number
)
SELECT
    applicant_id,
    1,
    2,
    1,
    CURRENT_DATE(),
    'First Semester',
    '2026-2027',
    CONCAT('APP-2026-', LPAD(applicant_id, 4, '0'))
FROM applicant
WHERE applicant_email_address IN ('juan.delacruz@example.com', 'maria.santos@example.com');

INSERT IGNORE INTO requirement (
    application_id,
    requirement_type_id,
    requirement_status_id,
    requirement_tracking_no,
    requirement_file_name,
    requirement_image_path,
    requirement_uploaded_by_user_id
)
SELECT
    a.application_id,
    1,
    1,
    CONCAT('DOC-2026-', LPAD(a.application_id, 4, '0')),
    'birth_certificate.pdf',
    'uploads/birth_certificate.pdf',
    1
FROM application a
WHERE a.application_reference_number LIKE 'APP-2026-%';

INSERT INTO user_activity_log (
    user_activity_log_user_id,
    user_activity_log_action_type,
    user_activity_log_entity_type,
    user_activity_log_description,
    user_activity_log_ip_address
)
VALUES
(1, 'TEST_LOG', 'system', 'Initial local MySQL sample data loaded.', '127.0.0.1');
