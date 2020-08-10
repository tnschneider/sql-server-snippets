SELECT TOP 10
    query_stats.query_hash AS "Query Hash"
    , SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time"
    , MIN(query_stats.statement_text) AS "Statement Text"
    , MAX([query_stats].last_execution_time) AS "Max Execution Time"
FROM
    ( SELECT
        QS.*
        , SUBSTRING(ST.text, ( QS.statement_start_offset / 2 ) + 1,
        ( ( CASE statement_end_offset
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE QS.statement_end_offset
        END - QS.statement_start_offset ) / 2 ) + 1) AS statement_text
        FROM
        sys.dm_exec_query_stats AS QS
        CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) AS ST
    ) AS query_stats
GROUP BY
    query_stats.query_hash
ORDER BY
    2 DESC;
