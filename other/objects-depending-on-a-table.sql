DECLARE @cat VARCHAR(MAX);
DECLARE @sch VARCHAR(MAX);
DECLARE @obj VARCHAR(MAX);

SET @cat = '';
SET @sch = '';
SET @obj = '';

WITH cte (cat, sch, obj, child_catalog, child_schema, child_name, level) AS (
    SELECT view_catalog, view_schema, view_name, table_catalog, table_schema, table_name, 0 
    FROM information_schema.view_table_usage 
    WHERE table_catalog = @cat AND table_schema = @sch AND table_name = @obj
    UNION ALL 
    SELECT vtu.view_catalog, vtu.view_schema, vtu.view_name, vtu.table_catalog, vtu.table_schema, vtu.table_name, cte.level + 1 
    FROM information_schema.view_table_usage vtu 
        INNER JOIN cte ON
            vtu.table_name = cte.obj
            AND vtu.table_schema = cte.sch
            AND vtu.table_catalog = cte.cat
)
SELECT DISTINCT cat, sch, obj, t.table_type as type, MIN(level) as level
FROM cte 
INNER JOIN information_schema.tables t ON 
    cte.cat = t.table_catalog 
    AND cte.sch = t.table_schema
    AND cte.obj = t.table_name
GROUP BY cat, sch, obj, t.table_type
ORDER BY cat, sch, obj
OPTION(MAXRECURSION 0)



--WITH COLUMN
DECLARE @cat VARCHAR(MAX);
DECLARE @sch VARCHAR(MAX);
DECLARE @obj VARCHAR(MAX);
DECLARE @col VARCHAR(MAX);

SET @cat = '';
SET @sch = '';
SET @obj = '';
SET @col = '';

WITH cte (cat, sch, obj, child_catalog, child_schema, child_name, level) AS (
    SELECT view_catalog, view_schema, view_name, table_catalog, table_schema, table_name, 0 
    FROM information_schema.view_column_usage 
    WHERE table_catalog = @cat AND table_schema = @sch AND table_name = @obj AND column_name = @col
    UNION ALL 
    SELECT vtu.view_catalog, vtu.view_schema, vtu.view_name, vtu.table_catalog, vtu.table_schema, vtu.table_name, cte.level + 1 
    FROM information_schema.view_table_usage vtu 
        INNER JOIN cte ON
            vtu.table_name = cte.obj
            AND vtu.table_schema = cte.sch
            AND vtu.table_catalog = cte.cat
)
SELECT DISTINCT cat, sch, obj, t.table_type as type, MIN(level) as level
FROM cte 
INNER JOIN information_schema.tables t ON 
    cte.cat = t.table_catalog 
    AND cte.sch = t.table_schema
    AND cte.obj = t.table_name
GROUP BY cat, sch, obj, t.table_type
ORDER BY cat, sch, obj
OPTION(MAXRECURSION 0)