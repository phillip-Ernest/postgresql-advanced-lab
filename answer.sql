-- STEP 1: Reusable Audit Log

CREATE TABLE audit_log (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  tbl TEXT,
  op TEXT,
  old_row JSONB,
  new_row JSONB,
  changed_by TEXT DEFAULT current_user,
  at TIMESTAMPTZ DEFAULT now()
);

CREATE FUNCTION audit() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log(tbl, op, old_row, new_row)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    CASE
      WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD)
    END,
    CASE
      WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW)
    END
  );

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit
AFTER INSERT OR UPDATE OR DELETE
ON students
FOR EACH ROW
EXECUTE FUNCTION audit();
-- STEP 2: Test Audit Logging

UPDATE students
SET name = 'Kofi M.'
WHERE id = 1;

DELETE FROM students
WHERE id = 3;

SELECT
  tbl,
  op,
  old_row->>'name' AS was,
  new_row->>'name' AS now,
  at
FROM audit_log
ORDER BY at DESC;


-- STEP 3: Hierarchical Categories

CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT,
  parent_id INT REFERENCES categories(id)
);

INSERT INTO categories (name, parent_id) VALUES
  ('Electronics', NULL),
  ('Computers', 1),
  ('Laptops', 2),
  ('Phones', 1);

WITH RECURSIVE tree AS (
  SELECT id, name, parent_id, 0 AS depth
  FROM categories
  WHERE parent_id IS NULL

  UNION ALL

  SELECT c.id, c.name, c.parent_id, t.depth + 1
  FROM categories c
  JOIN tree t ON c.parent_id = t.id
)
SELECT repeat('  ', depth) || name AS tree
FROM tree
ORDER BY depth, name;


-- STEP 5: Least-Privilege Security

CREATE ROLE app_read;
CREATE ROLE app_write;

GRANT CONNECT ON DATABASE bootcamp TO app_read, app_write;

GRANT USAGE ON SCHEMA public TO app_read, app_write;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_read;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA public TO app_write;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA public TO app_write;

CREATE USER api
LOGIN PASSWORD '<REPLACE_WITH_SECURE_PASSWORD>'
IN ROLE app_write;