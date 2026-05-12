# PDTS — Local MySQL Clean Version

This repository is the clean local MySQL version of the PUPOUS Document Tracking System. For the easiest setup, open and run:

```text
database/00_FULL_RESET_SETUP_MYSQL.sql
```

in MySQL Workbench, then run the Spring Boot app from VS Code. See `START_HERE_LOCAL_MYSQL.md` for the step-by-step guide.

---

# PDTS — PUPOUS Document Tracking System Local MySQL Version

**Polytechnic University of the Philippines — Open University System**  
Office of the University Registrar | Information Management Prototype

PDTS, or the **PUPOUS Document Tracking System**, is a Spring Boot web application for encoding and tracking incoming applicant documents from a manual school form. This repository version is prepared for **local development with MySQL**, **MySQL Workbench**, **Visual Studio Code**, **Java JDK 21**, and **Maven**.

> This is the local MySQL version for classroom development and Information Management documentation.

---

## Main Features

- Staff login and role-based access using Spring Security.
- Dashboard summaries for applicants, applications, documents, and activity.
- Applicant profile creation, editing, searching, and soft deletion.
- Application record creation with generated application reference numbers.
- Requirement/document tracking with upload, review, receive, reject, and resubmission status workflows.
- Public applicant status portal using reference number and access token.
- Email notification support through Resend API when configured.
- Staff user management with activate/deactivate controls.
- Rejection reason management.
- Audit log viewer for staff actions.
- Reports and tracking lookup pages.

---

## Local Technology Stack

| Layer | Technology |
|---|---|
| Backend | Java 21, Spring Boot 3.5.14 |
| Web/UI | Thymeleaf, HTML5, CSS3, Vanilla JavaScript |
| Security | Spring Security, BCrypt/noop demo password support |
| Database | MySQL 8.0+ / MySQL Community Server |
| Database Tool | MySQL Workbench |
| Persistence | Spring Data JPA, Hibernate, JdbcTemplate |
| Build Tool | Maven |
| IDE | Visual Studio Code |

---

## Recommended Local Tools

Install these before running the project:

1. **Java JDK 21**
2. **Maven 3.9+**
3. **MySQL Community Server 8.0+**
4. **MySQL Workbench**
5. **Visual Studio Code**
6. **Git**

Recommended VS Code extensions are included in:

```text
.vscode/extensions.json
```

---

## Project Structure

```text
pdts-IM-local-mysql/
├── database/
│   ├── 01_schema_mysql.sql             # MySQL database tables, keys, indexes, trigger, and view
│   ├── 02_seed_mysql.sql               # Required lookup data and local sample admin
│   ├── 03_sample_data_mysql.sql        # Optional local test data
│   └── 04_queries_mysql.sql            # 3 simple, 4 moderate, 3 difficult SQL queries
├── src/
│   └── main/
│       ├── java/com/pdts/              # Spring Boot source code
│       └── resources/
│           ├── application.properties  # Local MySQL app configuration
│           └── templates/              # Thymeleaf pages
├── uploads/                            # Local uploaded files folder
├── pom.xml                             # Maven dependencies and build configuration
└── README.md
```

---

## Database Processing Flow for Defense

Use this process when explaining how the database was built:

```text
Manual incoming document form
    ↓
Identify data fields
    ↓
Normalize the data: UNF → 1NF → 2NF → 3NF
    ↓
Create ERD and data dictionary
    ↓
Run MySQL CREATE TABLE script
    ↓
Run seed data script
    ↓
Run optional sample data script
    ↓
Use SELECT/JOIN/GROUP BY queries for reports
    ↓
Run the Java Spring Boot prototype locally
```

---

## Database Scripts

Run these files in **MySQL Workbench** in this order:

```text
database/01_schema_mysql.sql
database/02_seed_mysql.sql
database/03_sample_data_mysql.sql   optional
database/04_queries_mysql.sql       for SQL demo/report only
```

The first script creates the database named:

```text
pdts_db
```

The second script inserts required lookup records such as roles, permissions, requirement statuses, requirement types, programs, campuses, and the local demo staff account.

---

## Local Demo Login

After running `02_seed_mysql.sql`, use the sample-only account:

```text
Username: admin001
Password: Admin@2025
```

This is for local classroom testing only. Change the password before using the system outside a controlled demo environment.

---

## Configure the Local App

The default local configuration is already in:

```text
src/main/resources/application.properties
```

Default connection:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/pdts_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Manila
spring.datasource.username=root
spring.datasource.password=
```

If your MySQL root account has a password, set it in your terminal before running the app.

### macOS/Linux

```bash
export DATABASE_USERNAME="root"
export DATABASE_PASSWORD="your_mysql_password"
export PORT="8080"
```

### Windows PowerShell

```powershell
$env:DATABASE_USERNAME="root"
$env:DATABASE_PASSWORD="your_mysql_password"
$env:PORT="8080"
```

---

## Run the Application

From the project root folder:

```bash
mvn spring-boot:run
```

Then open:

```text
http://localhost:8080/login
```

---

## Important Local URLs

| URL | Purpose |
|---|---|
| `/login` | Staff login page |
| `/dashboard` | Main staff dashboard |
| `/applicants` | Applicant management |
| `/requirements` | Requirement/document tracking |
| `/users` | Staff user management |
| `/logs` | Activity log viewer |
| `/email-notifications` | Manual email page |
| `/tracking-lookup` | Tracking lookup utility |
| `/reports` | Reports page |
| `/` | Public applicant tracking landing page |

---

## Main Database Tables

```text
educational_background_category
role
permission
role_permission
application_status
requirement_status
requirement_type
rejection_reason
program
campus
deadline
curriculum_requirement
tracking_sequences
app_user
applicant
previous_education
applicant_emergency_contact
application
archived_record
requirement
user_activity_log
applicant_access_token
token_access_log
vw_student_status
```

---

## Notes for Information Management / MySQL Report

This repository includes MySQL-ready materials for your Information Management requirements:

- **Normalization:** use the PDTS entities from the manual incoming-document process.
- **ERD:** generate the diagram from MySQL Workbench using the `pdts_db` schema.
- **Data Dictionary:** base it on `database/01_schema_mysql.sql`.
- **SQL Code:** use `database/04_queries_mysql.sql` for simple, moderate, and difficult SQL examples.
- **Prototype Screenshots:** run the local app and take screenshots from the browser.

Correct defense wording:

> The local repository uses MySQL to match the Information Management subject requirements. The database was processed from the manual form, normalized up to 3NF, converted into MySQL tables with primary keys and foreign keys, then connected to the Java Spring Boot prototype.

---

## Common Issues and Fixes

| Problem | Likely Cause | Fix |
|---|---|---|
| `mvn` is not recognized | Maven is not installed or not in PATH | Install Maven and restart the terminal. |
| Cannot connect to MySQL | MySQL Server is not running | Start MySQL Server from System Settings, Services, or MySQL Workbench. |
| Access denied for user `root` | Wrong MySQL password | Set `DATABASE_PASSWORD` correctly or update `application.properties`. |
| Unknown database `pdts_db` | Schema script was not run | Run `database/01_schema_mysql.sql` first. |
| Login fails | Seed script was not run | Run `database/02_seed_mysql.sql`. |
| Port already in use | Another app uses port 8080 | Set `PORT=8081` or stop the other app. |
| Email fails locally | Resend API key is blank | Configure `RESEND_API_KEY` or ignore email during database-only testing. |

---

## Before Pushing as a New GitHub Repository

Recommended commands:

```bash
git init
git add .
git commit -m "Create local MySQL version of PDTS"
git branch -M main
git remote add origin <your-new-repository-url>
git push -u origin main
```

Do not commit real API keys, real database passwords, `.env` files, real applicant data, or private school records.

---

## Academic Use Notice

This project is a school/demo implementation. Review security, storage, logging, backups, and deployment settings before using it in a real production environment.
