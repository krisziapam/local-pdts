-- ============================================================
-- PDTS FULL LOCAL MYSQL RESET SETUP
-- MySQL 8.0+ | Run this ONE file in MySQL Workbench
-- WARNING: This drops and recreates pdts_db. It deletes existing local data.
-- Run using Local instance 3306 as root/admin.
-- After this file completes, run the app in VS Code.
-- App DB account created by this file:
--   username: pdts_user
--   password: pdts_local_2026
-- Demo login created by this file:
--   Employee ID: admin001
--   Password: Admin@2025
-- ============================================================

-- ============================================================
-- Included file: database/01_schema_mysql.sql
-- ============================================================

-- ============================================================
-- PDTS — PUPOUS Document Tracking System
-- Local Database Schema | MySQL 8.0+
-- ============================================================
-- Use this script in MySQL Workbench for the local-only repository.
-- It creates the database, tables, keys, indexes, trigger, and public status view.

-- Reset local demo database so setup starts clean.
-- WARNING: this deletes existing local pdts_db data.
DROP DATABASE IF EXISTS pdts_db;

CREATE DATABASE pdts_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Local app database account.
-- Run this script using a MySQL admin/root connection in Workbench.
-- This account is for local demo only. Change it if you reuse this database.
DROP USER IF EXISTS 'pdts_user'@'localhost';
CREATE USER 'pdts_user'@'localhost' IDENTIFIED BY 'pdts_local_2026';
GRANT ALL PRIVILEGES ON pdts_db.* TO 'pdts_user'@'localhost';
FLUSH PRIVILEGES;

USE pdts_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP VIEW IF EXISTS vw_student_status;
DROP TABLE IF EXISTS token_access_log;
DROP TABLE IF EXISTS applicant_access_token;
DROP TABLE IF EXISTS user_activity_log;
DROP TABLE IF EXISTS requirement;
DROP TABLE IF EXISTS archived_record;
DROP TABLE IF EXISTS application;
DROP TABLE IF EXISTS applicant_emergency_contact;
DROP TABLE IF EXISTS previous_education;
DROP TABLE IF EXISTS applicant;
DROP TABLE IF EXISTS tracking_sequences;
DROP TABLE IF EXISTS curriculum_requirement;
DROP TABLE IF EXISTS educational_background_category;
DROP TABLE IF EXISTS deadline;
DROP TABLE IF EXISTS campus;
DROP TABLE IF EXISTS program;
DROP TABLE IF EXISTS rejection_reason;
DROP TABLE IF EXISTS requirement_type;
DROP TABLE IF EXISTS requirement_status;
DROP TABLE IF EXISTS application_status;
DROP TABLE IF EXISTS role_permission;
DROP TABLE IF EXISTS permission;
DROP TABLE IF EXISTS app_user;
DROP TABLE IF EXISTS role;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- LOOKUP TABLES
-- ============================================================

CREATE TABLE educational_background_category (
    category_id          VARCHAR(10)  NOT NULL,
    category_name        VARCHAR(100) NOT NULL,
    category_code        VARCHAR(10)  NOT NULL UNIQUE,
    category_description TEXT,
    category_is_active   TINYINT(1)   NOT NULL DEFAULT 1,
    category_created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ebc PRIMARY KEY (category_id)
) ENGINE=InnoDB;

CREATE TABLE role (
    role_id          INT NOT NULL AUTO_INCREMENT,
    role_name        VARCHAR(50) NOT NULL UNIQUE,
    role_description TEXT,
    CONSTRAINT pk_role PRIMARY KEY (role_id)
) ENGINE=InnoDB;

CREATE TABLE permission (
    permission_id          INT NOT NULL AUTO_INCREMENT,
    permission_name        VARCHAR(100) NOT NULL UNIQUE,
    permission_description TEXT,
    CONSTRAINT pk_permission PRIMARY KEY (permission_id)
) ENGINE=InnoDB;

CREATE TABLE role_permission (
    role_id       INT NOT NULL,
    permission_id INT NOT NULL,
    CONSTRAINT pk_role_permission PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role       FOREIGN KEY (role_id)       REFERENCES role(role_id),
    CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES permission(permission_id)
) ENGINE=InnoDB;

CREATE TABLE application_status (
    application_status_id    INT NOT NULL AUTO_INCREMENT,
    application_status_name  VARCHAR(50) NOT NULL,
    application_status_color VARCHAR(10),
    CONSTRAINT pk_app_status PRIMARY KEY (application_status_id)
) ENGINE=InnoDB;

CREATE TABLE requirement_status (
    status_id                  INT NOT NULL AUTO_INCREMENT,
    requirement_status_name    VARCHAR(50) NOT NULL,
    requirement_status_color   VARCHAR(10),
    requirement_status_desc    TEXT,
    is_final                   TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT pk_req_status PRIMARY KEY (status_id)
) ENGINE=InnoDB;

CREATE TABLE requirement_type (
    type_id               INT NOT NULL AUTO_INCREMENT,
    requirement_type_name VARCHAR(150) NOT NULL,
    type_is_active        TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT pk_req_type PRIMARY KEY (type_id)
) ENGINE=InnoDB;

CREATE TABLE rejection_reason (
    rejection_reason_id          INT NOT NULL AUTO_INCREMENT,
    rejection_reason_name        VARCHAR(100) NOT NULL,
    rejection_reason_description TEXT NOT NULL,
    rejection_reason_is_active   TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT pk_rejection_reason PRIMARY KEY (rejection_reason_id)
) ENGINE=InnoDB;

CREATE TABLE program (
    program_id   INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(200) NOT NULL,
    program_code VARCHAR(20),
    CONSTRAINT pk_program PRIMARY KEY (program_id)
) ENGINE=InnoDB;

CREATE TABLE campus (
    campus_id      INT NOT NULL AUTO_INCREMENT,
    campus_name    VARCHAR(150) NOT NULL,
    campus_address TEXT,
    CONSTRAINT pk_campus PRIMARY KEY (campus_id)
) ENGINE=InnoDB;

CREATE TABLE deadline (
    deadline_id          INT NOT NULL AUTO_INCREMENT,
    requirement_type_id  INT  NOT NULL,
    deadline_date        DATE NOT NULL,
    deadline_description TEXT,
    CONSTRAINT pk_deadline PRIMARY KEY (deadline_id),
    CONSTRAINT fk_deadline_type FOREIGN KEY (requirement_type_id) REFERENCES requirement_type(type_id)
) ENGINE=InnoDB;

CREATE TABLE curriculum_requirement (
    category_id  VARCHAR(10) NOT NULL,
    type_id      INT         NOT NULL,
    is_mandatory TINYINT(1)  NOT NULL DEFAULT 1,
    CONSTRAINT pk_curriculum_req PRIMARY KEY (category_id, type_id),
    CONSTRAINT fk_cr_category FOREIGN KEY (category_id) REFERENCES educational_background_category(category_id),
    CONSTRAINT fk_cr_type     FOREIGN KEY (type_id)     REFERENCES requirement_type(type_id)
) ENGINE=InnoDB;

CREATE TABLE tracking_sequences (
    tracking_sequences_id            INT NOT NULL AUTO_INCREMENT,
    tracking_sequences_entity_type   ENUM('student','document') NOT NULL UNIQUE,
    tracking_sequences_prefix        VARCHAR(5)  NOT NULL,
    tracking_sequences_last_sequence INT         NOT NULL DEFAULT 0,
    tracking_sequences_current_year  INT         NOT NULL,
    tracking_sequences_updated_at    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_tracking PRIMARY KEY (tracking_sequences_id)
) ENGINE=InnoDB;

-- ============================================================
-- CORE ENTITIES
-- ============================================================

CREATE TABLE app_user (
    user_id            INT NOT NULL AUTO_INCREMENT,
    user_last_name     VARCHAR(50)  NOT NULL,
    user_first_name    VARCHAR(50)  NOT NULL,
    user_middle_name   VARCHAR(50),
    user_suffix        VARCHAR(20),
    role_id            INT          NOT NULL,
    user_email_address VARCHAR(100) NOT NULL UNIQUE,
    user_password_hash VARCHAR(255) NOT NULL,
    user_is_active     TINYINT(1)   NOT NULL DEFAULT 1,
    user_created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_last_login    DATETIME,
    user_username      VARCHAR(50)  NOT NULL UNIQUE,
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT fk_user_role FOREIGN KEY (role_id) REFERENCES role(role_id)
) ENGINE=InnoDB;

CREATE TABLE applicant (
    applicant_id                       INT NOT NULL AUTO_INCREMENT,
    applicant_first_name               VARCHAR(50)  NOT NULL,
    applicant_middle_name              VARCHAR(50),
    applicant_last_name                VARCHAR(50)  NOT NULL,
    applicant_suffix                   VARCHAR(20),
    applicant_sex                      TINYINT      NOT NULL,
    applicant_civil_status             TINYINT      NOT NULL,
    applicant_house_number_street      VARCHAR(150),
    applicant_barangay                 VARCHAR(100),
    applicant_city_municipality        VARCHAR(100),
    applicant_province                 VARCHAR(100),
    applicant_region                   VARCHAR(100),
    applicant_zip_code                 VARCHAR(10),
    applicant_birth_date               DATE         NOT NULL,
    applicant_email_address            VARCHAR(100) NOT NULL UNIQUE,
    applicant_contact_number           VARCHAR(20)  NOT NULL,
    educational_background_category_id VARCHAR(10)  NOT NULL,
    applicant_enrollment_status        ENUM('on_leave','continuing') NOT NULL,
    applicant_is_protected             TINYINT(1)   NOT NULL DEFAULT 1,
    applicant_is_deleted               TINYINT(1)   NOT NULL DEFAULT 0,
    applicant_deleted_at               DATETIME,
    applicant_created_at               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    applicant_updated_at               DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    previous_education_id              INT,
    user_id                            INT          NOT NULL,
    CONSTRAINT pk_applicant PRIMARY KEY (applicant_id),
    CONSTRAINT fk_app_ebc  FOREIGN KEY (educational_background_category_id)
        REFERENCES educational_background_category(category_id),
    CONSTRAINT fk_app_user FOREIGN KEY (user_id) REFERENCES app_user(user_id),
    INDEX idx_applicant_last_name (applicant_last_name),
    INDEX idx_applicant_enrollment (applicant_enrollment_status),
    INDEX idx_applicant_deleted (applicant_is_deleted)
) ENGINE=InnoDB;

DELIMITER $$
CREATE TRIGGER trg_protect_applicant
BEFORE DELETE ON applicant
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Applicant records are permanently protected and cannot be physically deleted. Use soft delete instead.';
END$$
DELIMITER ;

CREATE TABLE previous_education (
    previous_education_id              INT NOT NULL AUTO_INCREMENT,
    applicant_id                       INT          NOT NULL,
    educational_background_category_id VARCHAR(10)  NOT NULL,
    mode_of_learning                   ENUM('Online','Face-to-face','Modular','Blended') NOT NULL,
    last_school_name                   VARCHAR(200) NOT NULL,
    school_address                     TEXT,
    year_graduated                     INT,
    track                              VARCHAR(100),
    strand                             VARCHAR(100),
    exam_center                        VARCHAR(200),
    year_passed                        INT,
    units_earned                       DECIMAL(5,1),
    last_course                        VARCHAR(150),
    CONSTRAINT pk_prev_ed PRIMARY KEY (previous_education_id),
    CONSTRAINT fk_pe_applicant FOREIGN KEY (applicant_id) REFERENCES applicant(applicant_id),
    CONSTRAINT fk_pe_ebc FOREIGN KEY (educational_background_category_id)
        REFERENCES educational_background_category(category_id)
) ENGINE=InnoDB;

CREATE TABLE applicant_emergency_contact (
    contact_id      INT NOT NULL AUTO_INCREMENT,
    applicant_id    INT          NOT NULL,
    contact_name    VARCHAR(100) NOT NULL,
    relationship    VARCHAR(50)  NOT NULL,
    contact_number  VARCHAR(20),
    contact_address TEXT,
    CONSTRAINT pk_ec PRIMARY KEY (contact_id),
    CONSTRAINT fk_ec_applicant FOREIGN KEY (applicant_id) REFERENCES applicant(applicant_id)
) ENGINE=InnoDB;

CREATE TABLE application (
    application_id                 INT NOT NULL AUTO_INCREMENT,
    applicant_id                   INT          NOT NULL,
    program_id                     INT          NOT NULL,
    campus_id                      INT          NOT NULL,
    application_status_id          INT          NOT NULL,
    deadline_id                    INT,
    application_date               DATE         NOT NULL,
    application_semester           VARCHAR(20)  NOT NULL,
    application_academic_year      VARCHAR(20)  NOT NULL,
    application_reference_number   VARCHAR(30)  NOT NULL UNIQUE,
    application_last_notified_date DATETIME,
    CONSTRAINT pk_application  PRIMARY KEY (application_id),
    CONSTRAINT fk_appl_applicant FOREIGN KEY (applicant_id)          REFERENCES applicant(applicant_id),
    CONSTRAINT fk_appl_program   FOREIGN KEY (program_id)            REFERENCES program(program_id),
    CONSTRAINT fk_appl_campus    FOREIGN KEY (campus_id)             REFERENCES campus(campus_id),
    CONSTRAINT fk_appl_status    FOREIGN KEY (application_status_id) REFERENCES application_status(application_status_id),
    CONSTRAINT fk_appl_deadline  FOREIGN KEY (deadline_id)           REFERENCES deadline(deadline_id),
    INDEX idx_application_applicant (applicant_id),
    INDEX idx_application_reference (application_reference_number)
) ENGINE=InnoDB;

CREATE TABLE archived_record (
    archived_record_id              BIGINT NOT NULL AUTO_INCREMENT,
    application_id                  INT          NOT NULL,
    applicant_id                    INT          NOT NULL,
    archived_record_at              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archived_record_reason          TEXT,
    requirement_type_id             INT,
    applicant_emergency_contact_id  INT,
    archived_record_type            ENUM('File','Educational Background','Personal Info') NOT NULL,
    archived_record_source          VARCHAR(100),
    archived_record_data_snapshot   JSON,
    archived_record_by_user_id      INT          NOT NULL,
    CONSTRAINT pk_archived PRIMARY KEY (archived_record_id),
    CONSTRAINT fk_ar_application FOREIGN KEY (application_id) REFERENCES application(application_id),
    CONSTRAINT fk_ar_applicant   FOREIGN KEY (applicant_id)   REFERENCES applicant(applicant_id),
    CONSTRAINT fk_ar_user        FOREIGN KEY (archived_record_by_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB;

CREATE TABLE requirement (
    requirement_id                       INT NOT NULL AUTO_INCREMENT,
    application_id                       INT          NOT NULL,
    requirement_type_id                  INT          NOT NULL,
    requirement_status_id                INT          NOT NULL DEFAULT 1,
    requirement_tracking_no              VARCHAR(30)  NOT NULL UNIQUE,
    requirement_file_name                VARCHAR(255) NOT NULL,
    requirement_image_path               TEXT         NOT NULL,
    requirement_upload_date              DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    requirement_uploaded_by_user_id      INT          NOT NULL,
    requirement_date_received            DATETIME,
    requirement_processed_by_user_id     INT,
    requirement_processed_at             DATETIME,
    rejection_reason_id                  INT,
    rejection_reason_rejected_by_user_id INT,
    rejection_reason_rejected_at         DATETIME,
    requirement_remarks                  TEXT,
    requirement_is_email_sent            TINYINT(1)   NOT NULL DEFAULT 0,
    requirement_has_archive_match        TINYINT(1)   NOT NULL DEFAULT 0,
    archive_id                           BIGINT,
    CONSTRAINT pk_requirement  PRIMARY KEY (requirement_id),
    CONSTRAINT fk_req_application FOREIGN KEY (application_id) REFERENCES application(application_id),
    CONSTRAINT fk_req_type        FOREIGN KEY (requirement_type_id) REFERENCES requirement_type(type_id),
    CONSTRAINT fk_req_status      FOREIGN KEY (requirement_status_id) REFERENCES requirement_status(status_id),
    CONSTRAINT fk_req_uploader    FOREIGN KEY (requirement_uploaded_by_user_id) REFERENCES app_user(user_id),
    CONSTRAINT fk_req_processor   FOREIGN KEY (requirement_processed_by_user_id) REFERENCES app_user(user_id),
    CONSTRAINT fk_req_rejection   FOREIGN KEY (rejection_reason_id) REFERENCES rejection_reason(rejection_reason_id),
    CONSTRAINT fk_req_archive     FOREIGN KEY (archive_id) REFERENCES archived_record(archived_record_id),
    INDEX idx_req_status (requirement_status_id),
    INDEX idx_req_application (application_id),
    INDEX idx_req_tracking (requirement_tracking_no)
) ENGINE=InnoDB;

CREATE TABLE user_activity_log (
    user_activity_log_id           BIGINT NOT NULL AUTO_INCREMENT,
    user_activity_log_user_id      INT          NOT NULL,
    user_activity_log_action_type  VARCHAR(100) NOT NULL,
    user_activity_log_entity_type  VARCHAR(50)  NOT NULL,
    archived_record_id             BIGINT,
    user_activity_log_description  TEXT,
    user_activity_log_old_value    TEXT,
    user_activity_log_new_value    TEXT,
    user_activity_log_ip_address   VARCHAR(45),
    user_activity_log_performed_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_ual PRIMARY KEY (user_activity_log_id),
    CONSTRAINT fk_ual_user FOREIGN KEY (user_activity_log_user_id) REFERENCES app_user(user_id),
    INDEX idx_ual_performed_at (user_activity_log_performed_at)
) ENGINE=InnoDB;

-- ============================================================
-- TOKEN TABLES
-- ============================================================

CREATE TABLE applicant_access_token (
    token_id                 BIGINT NOT NULL AUTO_INCREMENT,
    application_id           INT         NOT NULL UNIQUE,
    applicant_id             INT         NOT NULL,
    token_hash               VARCHAR(64) NOT NULL,
    token_prefix             VARCHAR(8)  NOT NULL,
    token_issued_at          DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    token_expires_at         DATETIME    NOT NULL,
    token_is_revoked         TINYINT(1)  NOT NULL DEFAULT 0,
    token_last_used_at       DATETIME,
    token_use_count          INT         NOT NULL DEFAULT 0,
    token_email_sent         TINYINT(1)  NOT NULL DEFAULT 0,
    token_issued_by_user_id  INT         NOT NULL,
    token_revoked_by_user_id INT,
    token_revoked_at         DATETIME,
    CONSTRAINT pk_aat PRIMARY KEY (token_id),
    CONSTRAINT uq_aat_app UNIQUE (application_id),
    CONSTRAINT fk_aat_app       FOREIGN KEY (application_id) REFERENCES application(application_id),
    CONSTRAINT fk_aat_applicant FOREIGN KEY (applicant_id) REFERENCES applicant(applicant_id),
    CONSTRAINT fk_aat_issued    FOREIGN KEY (token_issued_by_user_id) REFERENCES app_user(user_id),
    CONSTRAINT fk_aat_revoked   FOREIGN KEY (token_revoked_by_user_id) REFERENCES app_user(user_id)
) ENGINE=InnoDB;

CREATE TABLE token_access_log (
    access_log_id            BIGINT NOT NULL AUTO_INCREMENT,
    token_id                 BIGINT,
    application_reference_no VARCHAR(30) NOT NULL,
    access_log_ip_address    VARCHAR(45) NOT NULL,
    access_log_user_agent    VARCHAR(500),
    access_log_result        ENUM('SUCCESS','INVALID_TOKEN','EXPIRED_TOKEN','REVOKED_TOKEN','RATE_LIMITED','NOT_FOUND') NOT NULL,
    access_log_performed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_tal PRIMARY KEY (access_log_id),
    CONSTRAINT fk_tal_token FOREIGN KEY (token_id) REFERENCES applicant_access_token(token_id),
    INDEX idx_tal_token_time (token_id, access_log_performed_at),
    INDEX idx_tal_ip (access_log_ip_address)
) ENGINE=InnoDB;

-- ============================================================
-- PUBLIC PORTAL VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_student_status AS
SELECT
    a.application_reference_number,
    CONCAT(ap.applicant_first_name, ' ', COALESCE(ap.applicant_middle_name, ''), ' ', ap.applicant_last_name) AS applicant_full_name,
    p.program_name,
    c.campus_name,
    a.application_semester,
    a.application_academic_year,
    ast.application_status_name,
    r.requirement_tracking_no,
    rt.requirement_type_name,
    rs.requirement_status_name,
    rs.requirement_status_color,
    rr.rejection_reason_description,
    r.requirement_upload_date,
    r.requirement_processed_at,
    CASE WHEN rs.status_id = 5 THEN r.requirement_remarks ELSE NULL END AS resubmission_notes
FROM application a
JOIN applicant ap ON ap.applicant_id = a.applicant_id
JOIN program p ON p.program_id = a.program_id
JOIN campus c ON c.campus_id = a.campus_id
JOIN application_status ast ON ast.application_status_id = a.application_status_id
JOIN requirement r ON r.application_id = a.application_id
JOIN requirement_type rt ON rt.type_id = r.requirement_type_id
JOIN requirement_status rs ON rs.status_id = r.requirement_status_id
LEFT JOIN rejection_reason rr ON rr.rejection_reason_id = r.rejection_reason_id
WHERE COALESCE(ap.applicant_is_deleted, 0) = 0;


-- ============================================================
-- Included file: database/02_seed_mysql.sql
-- ============================================================

-- ============================================================
-- PDTS — Local Seed Data | MySQL 8.0+
-- Run after database/01_schema_mysql.sql
-- ============================================================

USE pdts_db;

-- Curriculum types
INSERT IGNORE INTO educational_background_category
(category_id, category_name, category_code, category_description, category_is_active, category_created_at)
VALUES
('OLD-001', 'Old Curriculum', 'OLD', 'Pre-K12 traditional high school program.', 1, NOW()),
('SHS-002', 'Senior High School', 'SHS', 'K-12 SHS graduate (Grades 11-12).', 1, NOW()),
('ALS-003', 'Alternative Learning System', 'ALS', 'Non-formal ALS / A&E passers.', 1, NOW()),
('COL-004', 'College Undergraduate', 'COL', 'Tertiary-level degree program applicants.', 1, NOW()),
('TVT-005', 'TVET', 'TVET', 'Technical-Vocational Education and Training graduates.', 1, NOW());

-- Roles
INSERT IGNORE INTO role (role_name, role_description) VALUES
('Admission Personnel', 'Can create and update applicant profiles and upload documents.'),
('Admin', 'Can change document statuses and manage rejection reasons.'),
('Head Admission', 'Full system access including user management and logs.');

-- Permissions
INSERT IGNORE INTO permission (permission_name, permission_description) VALUES
('UPLOAD_DOCUMENT', 'Upload scanned document images for applicants.'),
('REJECT_DOCUMENT', 'Reject a submitted document with a reason.'),
('RECEIVE_DOCUMENT', 'Mark a document as Verified/Received.'),
('VIEW_LOGS', 'View the system activity audit trail.'),
('MANAGE_USERS', 'Create, deactivate, and manage staff accounts.'),
('MANAGE_REASONS', 'Add, edit, or deactivate rejection reasons.'),
('REVOKE_TOKEN', 'Revoke or regenerate applicant access tokens.'),
('FILTER_SEARCH', 'Use the advanced filter and search panel.');

-- Role-permission mappings
INSERT IGNORE INTO role_permission VALUES (1,1),(1,8);
INSERT IGNORE INTO role_permission VALUES (2,1),(2,2),(2,3),(2,5),(2,6),(2,7),(2,8);
INSERT IGNORE INTO role_permission VALUES (3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8);

-- Application statuses
INSERT IGNORE INTO application_status (application_status_name, application_status_color) VALUES
('Pending', '#FFA500'),
('Under Review', '#2E75B6'),
('Approved', '#28A745'),
('Rejected', '#DC3545');

-- Document processing statuses
INSERT IGNORE INTO requirement_status
(requirement_status_name, requirement_status_color, requirement_status_desc, is_final)
VALUES
('Pending', '#FFA500', 'Document uploaded; awaiting Registrar initial action.', 0),
('Under Review', '#2E75B6', 'Registrar is actively reviewing the document.', 0),
('Verified/Received', '#28A745', 'Document fully verified and accepted into the official record.', 1),
('Rejected', '#DC3545', 'Document denied; rejection reason recorded and emailed.', 1),
('For Resubmission', '#C8A951', 'Flagged for corrected resubmission; guidance notes attached.', 0);

-- Document/requirement types
INSERT IGNORE INTO requirement_type (requirement_type_name) VALUES
('PSA Birth Certificate'),
('Form 137 / Form 138'),
('Transcript of Records (TOR)'),
('Diploma (Certified Copy)'),
('2x2 ID Pictures (4 pcs)'),
('X-Ray Result (within 6 months)'),
('Certificate of Good Moral Character'),
('NBI / Police Clearance'),
('Letter of Endorsement'),
('ALS Certificate of Rating'),
('TVET National Certificate (NC II/III)'),
('PSA Marriage Certificate'),
('Certificate of Employment');

-- Rejection reasons
INSERT IGNORE INTO rejection_reason (rejection_reason_name, rejection_reason_description) VALUES
('Document Blurry', 'The uploaded document image is too blurry to be legible. Please resubmit a clear, high-resolution scan.'),
('Expired Certificate', 'The submitted certificate or clearance has expired. Please provide a document issued within the last 6 months.'),
('Wrong Document Type', 'The uploaded file does not match the required document type. Please upload the correct document.'),
('Incomplete Document', 'The submitted document appears to be incomplete or is missing pages. Please resubmit the complete document.'),
('Photo Background Invalid', 'The ID photo background must be plain white. Colored or patterned backgrounds are not accepted.'),
('Unreadable File Format', 'The file format is not supported or is corrupted. Please resubmit as a clear JPEG or PDF.');

-- Programs
INSERT IGNORE INTO program (program_name, program_code) VALUES
('Bachelor of Science in Information Technology', 'BSIT'),
('Bachelor of Science in Business Administration', 'BSBA'),
('Bachelor of Science in Criminology', 'BSCrim'),
('Bachelor of Science in Nursing', 'BSN'),
('Bachelor of Technology and Livelihood Education', 'BTLE'),
('NC II — Computer Hardware Servicing', 'NC2-CHS'),
('NC II — Bread and Pastry Production', 'NC2-BPP');

-- Campuses
INSERT IGNORE INTO campus (campus_name, campus_address) VALUES
('PUP Main Campus — Sta. Mesa, Manila', 'Anonas St., Sta. Mesa, Manila, 1008'),
('PUP Open University System', 'Anonas St., Sta. Mesa, Manila, 1008'),
('PUP Paranaque Campus', 'Dr. A. Santos Ave., Sucat, Paranaque City'),
('PUP Lopez, Quezon', 'Quezon Province Campus'),
('PUP San Juan Campus', 'San Juan, Metro Manila');

-- Tracking sequences
INSERT IGNORE INTO tracking_sequences
(tracking_sequences_entity_type, tracking_sequences_prefix, tracking_sequences_last_sequence, tracking_sequences_current_year)
VALUES
('student', 'STU', 0, YEAR(CURRENT_DATE())),
('document', 'DOC', 0, YEAR(CURRENT_DATE()));

-- Curriculum requirements
INSERT IGNORE INTO curriculum_requirement VALUES
('OLD-001',1,1),('OLD-001',2,1),('OLD-001',5,1),('OLD-001',6,1),('OLD-001',7,1),('OLD-001',8,1);

INSERT IGNORE INTO curriculum_requirement VALUES
('SHS-002',1,1),('SHS-002',2,1),('SHS-002',4,1),('SHS-002',5,1),('SHS-002',6,1),('SHS-002',7,1),('SHS-002',8,1);

INSERT IGNORE INTO curriculum_requirement VALUES
('ALS-003',1,1),('ALS-003',5,1),('ALS-003',10,1),('ALS-003',8,1);

INSERT IGNORE INTO curriculum_requirement VALUES
('COL-004',1,1),('COL-004',3,1),('COL-004',4,1),('COL-004',5,1),('COL-004',6,1),('COL-004',7,1),('COL-004',8,1),('COL-004',9,1),('COL-004',13,0);

INSERT IGNORE INTO curriculum_requirement VALUES
('TVT-005',1,1),('TVT-005',5,1),('TVT-005',11,1),('TVT-005',8,1),('TVT-005',7,1);

-- Local demo staff account.
-- Sample only. Change the password before real deployment.
-- username: admin001
-- password: Admin@2025
INSERT INTO app_user
(user_last_name, user_first_name, role_id, user_email_address, user_password_hash, user_username, user_is_active)
VALUES
('Administrator', 'System', 3, 'admin@example.edu', '{noop}Admin@2025', 'admin001', 1)
ON DUPLICATE KEY UPDATE
    role_id = VALUES(role_id),
    user_email_address = VALUES(user_email_address),
    user_password_hash = VALUES(user_password_hash),
    user_is_active = 1;


-- ============================================================
-- Included file: database/03_sample_data_mysql.sql
-- ============================================================

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

