SELECT
    OBJECT_NAME(i.[object_id]) AS [Table Name]
    ,i.NAME
    ,'DROP INDEX [' + I.NAME + '] ON [' + OBJECT_SCHEMA_NAME(I.OBJECT_ID) + '].[' + OBJECT_NAME(I.OBJECT_ID) + '] '
FROM
    sys.indexes AS i
INNER JOIN sys.objects AS o
    ON i.[object_id] = o.[object_id]
WHERE
    i.index_id NOT IN ( SELECT
    ddius.index_id
FROM
    sys.dm_db_index_usage_stats AS ddius
WHERE
    ddius.[object_id] = i.[object_id]
    AND i.index_id = ddius.index_id
    AND database_id = DB_ID() )
    AND o.[type] = 'U'
ORDER BY
    OBJECT_NAME(i.[object_id]) ASC;