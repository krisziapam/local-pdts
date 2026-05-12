# MySQL Conversion Notes

This repository was converted for a local MySQL setup using MySQL Workbench, Visual Studio Code, Java JDK 21, and Maven.

## Main conversion changes

- Replaced the PostgreSQL JDBC dependency with `mysql-connector-j` in `pom.xml`.
- Updated `src/main/resources/application.properties` to connect to local MySQL:
  - database: `pdts_db`
  - default username: `root`
  - default port: `8080`
- Removed deployment-only files that are not needed for a local MySQL repository.
- Added MySQL scripts:
  - `database/01_schema_mysql.sql`
  - `database/02_seed_mysql.sql`
  - `database/03_sample_data_mysql.sql`
  - `database/04_queries_mysql.sql`
- Updated native SQL used by the Java controllers:
  - PostgreSQL `RETURNING` → MySQL `LAST_INSERT_ID()`
  - PostgreSQL string concatenation `||` → MySQL `CONCAT()`
  - PostgreSQL `split_part(... )::int` → MySQL `SUBSTRING_INDEX(...)` and `CAST(... AS UNSIGNED)`
  - PostgreSQL `DELETE ... USING` → MySQL `DELETE r FROM ... JOIN ...`
  - PostgreSQL `LATERAL` latest-record lookup → MySQL 8 `ROW_NUMBER()` window query
- Changed the database driver and Hibernate dialect to MySQL.
- Added VS Code extension recommendations and a sample Java launch configuration.

## Important note

The local MySQL version keeps the same database logic: applicants, applications, requirements, statuses, users, roles, tokens, and logs. The difference is the database syntax and local connection setup.

## Recommended database processing demonstration

1. Run `01_schema_mysql.sql` to create the database structure.
2. Run `02_seed_mysql.sql` to insert lookup data and the sample staff account.
3. Run `03_sample_data_mysql.sql` to add demo applicants and documents.
4. Run `04_queries_mysql.sql` to demonstrate simple, moderate, and difficult SQL queries.
5. Run the Spring Boot app with `mvn spring-boot:run`.
