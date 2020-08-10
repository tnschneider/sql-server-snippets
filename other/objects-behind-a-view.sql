DECLARE @cat VARCHAR(MAX);
DECLARE @sch VARCHAR(MAX);
DECLARE @obj VARCHAR(MAX);

SET @cat = '';
SET @sch = '';
SET @obj = '';

WITH cte (parent_catalog, parent_schema, parent_name, cat, sch, obj, level) AS (
    SELECT view_catalog, view_schema, view_name, table_catalog, table_schema, table_name, 0 
    FROM information_schema.view_table_usage 
    WHERE view_catalog = @cat AND view_schema = @sch AND view_name = @obj
    UNION ALL 
    SELECT vtu.view_catalog, vtu.view_schema, vtu.view_name, vtu.table_catalog, vtu.table_schema, vtu.table_name, cte.level + 1 
    FROM information_schema.view_table_usage vtu 
        INNER JOIN cte ON
            vtu.view_name = cte.obj 
            AND vtu.view_schema = cte.sch
            AND vtu.view_catalog = cte.cat
    )
SELECT DISTINCT parent_catalog, parent_schema, parent_name, cat, sch, obj, t.table_type as type, MIN(level) as level
FROM cte 
INNER JOIN information_schema.tables t ON
    cte.cat = t.table_catalog
    AND cte.sch = t.table_schema
    AND cte.obj = t.table_name
GROUP BY parent_catalog, parent_schema, parent_name, cat, sch, obj, t.table_type
ORDER BY parent_catalog, parent_schema, parent_name, cat, sch, obj
OPTION(MAXRECURSION 0)