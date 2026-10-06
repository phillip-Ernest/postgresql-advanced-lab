# PostgreSQL Advanced Database Lab

## Overview

This project demonstrates advanced PostgreSQL database concepts, including audit logging, hierarchical data modeling, database migrations, and least-privilege access control.

The project was completed as part of a PostgreSQL advanced database laboratory assignment.

## Technologies Used

* PostgreSQL
* PL/pgSQL
* JSONB
* SQL
* Flyway
* Git and GitHub

## Step 1: Reusable Audit Log

A reusable audit logging system was implemented using a PostgreSQL trigger function.

The `audit_log` table records:

* Table name affected
* Operation performed
* Previous row values
* New row values
* Database user responsible for the change
* Timestamp of the change

The audit trigger supports:

* `INSERT`
* `UPDATE`
* `DELETE`

The audit information is stored using PostgreSQL's `JSONB` data type.

## Step 2: Audit Log Testing

The audit system was tested by performing changes on the `students` table.

An update operation and a delete operation were used to verify that the audit trigger correctly captured database changes.

The audit records can be viewed using:

```sql
SELECT
  tbl,
  op,
  old_row->>'name' AS was,
  new_row->>'name' AS now,
  at
FROM audit_log
ORDER BY at DESC;
```

## Step 3: Hierarchical Data

A self-referencing `categories` table was created to demonstrate hierarchical data.

The table contains:

* `id`
* `name`
* `parent_id`

The `parent_id` column references the `id` column of the same table.

Example hierarchy:

```text
Electronics
  Computers
    Laptops
  Phones
```

A recursive Common Table Expression (CTE) was used to traverse and display the hierarchy.

## Step 4: Flyway Database Migrations

Database changes were organized into versioned Flyway migration files.

The migrations are:

```text
migrations/
├── V1__core_tables.sql
├── V2__audit_log.sql
└── V3__categories.sql
```

### Migration 1

`V1__core_tables.sql`

Creates the core `students` table.

### Migration 2

`V2__audit_log.sql`

Creates the reusable audit logging table, trigger function, and trigger.

### Migration 3

`V3__categories.sql`

Creates the hierarchical categories table and inserts sample category data.

## Step 5: Least-Privilege Security

Separate database roles were created to demonstrate least-privilege access.

### Read Role

The `app_read` role is granted:

* Database connection
* Schema usage
* `SELECT` access on tables

### Write Role

The `app_write` role is granted:

* Database connection
* Schema usage
* `SELECT`
* `INSERT`
* `UPDATE`
* `DELETE`

Sequence privileges are also provided to support inserts into tables using auto-generated IDs.

An API database user was created as a member of the write role.

> **Security Note:** Passwords and other production credentials should never be committed to a public GitHub repository. Any placeholder password in the assignment should be replaced with a secure credential when configuring the database locally.

## Project Structure

```text
postgresql-advanced-lab/
│
├── answer.sql
│
└── migrations/
    ├── V1__core_tables.sql
    ├── V2__audit_log.sql
    └── V3__categories.sql
```

## Conclusion

This project demonstrates several important PostgreSQL concepts:

1. Reusable audit logging with triggers
2. JSONB-based change tracking
3. Hierarchical data modeling
4. Recursive CTEs
5. Version-controlled database migrations
6. Role-based access control
7. Least-privilege database security

The project is maintained using Git and GitHub for version control and submission.
