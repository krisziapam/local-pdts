-- ============================================================
-- PDTS — SQL Query Demonstration | MySQL 8.0+
-- 3 simple, 4 moderate, and 3 difficult queries for IM report/demo
-- ============================================================

USE pdts_db;

-- ============================================================
-- SIMPLE QUERIES
-- ============================================================

-- 1. Show all active applicants.
SELECT
    applicant_id,
    applicant_first_name,
    applicant_last_name,
    applicant_email_address,
    applicant_contact_number
FROM applicant
WHERE COALESCE(applicant_is_deleted, 0) = 0
ORDER BY applicant_created_at DESC;

-- 2. Show all requirement/document types.
SELECT
    type_id,
    requirement_type_name
FROM requirement_type
WHERE type_is_active = 1
ORDER BY requirement_type_name;

-- 3. Show all document statuses.
SELECT
    status_id,
    requirement_status_name,
    requirement_status_color
FROM requirement_status
ORDER BY status_id;

-- ============================================================
-- MODERATE QUERIES
-- ============================================================

-- 4. Show applicants with their application reference numbers and programs.
SELECT
    ap.applicant_id,
    CONCAT(ap.applicant_first_name, ' ', ap.applicant_last_name) AS applicant_name,
    a.application_reference_number,
    p.program_code,
    p.program_name,
    ast.application_status_name
FROM applicant ap
JOIN application a ON a.applicant_id = ap.applicant_id
JOIN program p ON p.program_id = a.program_id
JOIN application_status ast ON ast.application_status_id = a.application_status_id
WHERE COALESCE(ap.applicant_is_deleted, 0) = 0
ORDER BY a.application_date DESC;

-- 5. Show uploaded requirements with applicant and status details.
SELECT
    r.requirement_tracking_no,
    CONCAT(ap.applicant_first_name, ' ', ap.applicant_last_name) AS applicant_name,
    rt.requirement_type_name,
    rs.requirement_status_name,
    r.requirement_upload_date
FROM requirement r
JOIN application a ON a.application_id = r.application_id
JOIN applicant ap ON ap.applicant_id = a.applicant_id
JOIN requirement_type rt ON rt.type_id = r.requirement_type_id
JOIN requirement_status rs ON rs.status_id = r.requirement_status_id
WHERE COALESCE(ap.applicant_is_deleted, 0) = 0
ORDER BY r.requirement_upload_date DESC;

-- 6. Count applicants per educational background category.
SELECT
    ebc.category_name,
    COUNT(ap.applicant_id) AS total_applicants
FROM educational_background_category ebc
LEFT JOIN applicant ap
    ON ap.educational_background_category_id = ebc.category_id
   AND COALESCE(ap.applicant_is_deleted, 0) = 0
GROUP BY ebc.category_id, ebc.category_name
ORDER BY total_applicants DESC, ebc.category_name;

-- 7. Show staff users and their roles.
SELECT
    u.user_id,
    u.user_username,
    CONCAT(u.user_first_name, ' ', u.user_last_name) AS staff_name,
    u.user_email_address,
    r.role_name,
    CASE WHEN u.user_is_active = 1 THEN 'Active' ELSE 'Inactive' END AS account_status
FROM app_user u
JOIN role r ON r.role_id = u.role_id
ORDER BY u.user_id;

-- ============================================================
-- DIFFICULT QUERIES
-- ============================================================

-- 8. Summarize document status counts per applicant.
SELECT
    ap.applicant_id,
    CONCAT(ap.applicant_first_name, ' ', ap.applicant_last_name) AS applicant_name,
    COUNT(r.requirement_id) AS total_requirements,
    SUM(CASE WHEN rs.requirement_status_name = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN rs.requirement_status_name = 'Under Review' THEN 1 ELSE 0 END) AS under_review_count,
    SUM(CASE WHEN rs.requirement_status_name = 'Verified/Received' THEN 1 ELSE 0 END) AS verified_count,
    SUM(CASE WHEN rs.requirement_status_name = 'Rejected' THEN 1 ELSE 0 END) AS rejected_count,
    SUM(CASE WHEN rs.requirement_status_name = 'For Resubmission' THEN 1 ELSE 0 END) AS resubmission_count
FROM applicant ap
JOIN application a ON a.applicant_id = ap.applicant_id
LEFT JOIN requirement r ON r.application_id = a.application_id
LEFT JOIN requirement_status rs ON rs.status_id = r.requirement_status_id
WHERE COALESCE(ap.applicant_is_deleted, 0) = 0
GROUP BY ap.applicant_id, applicant_name
ORDER BY ap.applicant_id;

-- 9. Find applicants whose latest application still has pending/incomplete requirements.
SELECT
    ap.applicant_id,
    CONCAT(ap.applicant_first_name, ' ', ap.applicant_last_name) AS applicant_name,
    latest_app.application_reference_number,
    COUNT(r.requirement_id) AS incomplete_requirement_count
FROM applicant ap
JOIN (
    SELECT ranked.*
    FROM (
        SELECT
            a.*,
            ROW_NUMBER() OVER (
                PARTITION BY a.applicant_id
                ORDER BY a.application_date DESC, a.application_id DESC
            ) AS rn
        FROM application a
    ) ranked
    WHERE ranked.rn = 1
) latest_app ON latest_app.applicant_id = ap.applicant_id
JOIN requirement r ON r.application_id = latest_app.application_id
JOIN requirement_status rs ON rs.status_id = r.requirement_status_id
WHERE COALESCE(ap.applicant_is_deleted, 0) = 0
  AND rs.requirement_status_name <> 'Verified/Received'
GROUP BY ap.applicant_id, applicant_name, latest_app.application_reference_number
ORDER BY incomplete_requirement_count DESC, applicant_name;

-- 10. Audit trail report for staff actions with readable staff names.
SELECT
    l.user_activity_log_id,
    l.user_activity_log_performed_at,
    CONCAT(u.user_first_name, ' ', u.user_last_name) AS performed_by,
    r.role_name,
    l.user_activity_log_action_type,
    l.user_activity_log_entity_type,
    l.user_activity_log_description,
    l.user_activity_log_ip_address
FROM user_activity_log l
JOIN app_user u ON u.user_id = l.user_activity_log_user_id
JOIN role r ON r.role_id = u.role_id
ORDER BY l.user_activity_log_performed_at DESC
LIMIT 100;
