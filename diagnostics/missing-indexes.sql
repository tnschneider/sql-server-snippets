SELECT
    *
FROM
    ( 
    SELECT
        ROUND(( user_seeks + user_scans ) * avg_total_user_cost * ( avg_user_impact * 0.01 ),2) AS [index_advantage]
                ,'CREATE INDEX [IDX_TO_DO] ON ' + dbmid.[statement] 
                + '(' + COALESCE([equality_columns], '') 
                + CASE WHEN [equality_columns] IS NOT NULL AND [inequality_columns] IS NOT NULL THEN ','
        ELSE ''
        END + COALESCE([inequality_columns],'') + ') '
        + CASE WHEN [included_columns] IS NULL THEN ''
        ELSE ' INCLUDE (' + [included_columns] + ')'
        END AS SqlStatment
        ,dbmigs.last_user_seek last_user_seek
        ,dbmid.[statement] AS [Database.Schema.Table]
        ,dbmid.equality_columns equality_columns
        ,dbmid.inequality_columns inequality_columns
        ,dbmid.included_columns included_columns
        ,dbmigs.unique_compiles unique_compiles
        ,dbmigs.user_seeks user_seeks
        ,dbmigs.user_scans user_scans
        ,ROUND(dbmigs.avg_total_user_cost,2) avg_total_user_cost
        ,dbmigs.avg_user_impact avg_user_impact
        ,dbmigs.avg_system_impact avg_system_impact
    FROM
        sys.dm_db_missing_index_group_stats AS dbmigs WITH ( NOLOCK )
    INNER JOIN sys.dm_db_missing_index_groups AS dbmig WITH ( NOLOCK )
        ON dbmigs.group_handle = dbmig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS dbmid WITH ( NOLOCK )
        ON dbmig.index_handle = dbmid.index_handle
    WHERE
        dbmid.[database_id] = DB_ID()
    ) idxs
WHERE 1 = 1 
    AND [idxs].[Database.Schema.Table] LIKE '%%' --REPLACE WITH YOUR SCHEMA OR OTHER SEARCH 
ORDER BY
    [index_advantage] DESC
    [unique_compiles] DESC 
    [avg_user_impact] DESC