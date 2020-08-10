SELECT
    spid,
    RIGHT(CONVERT(VARCHAR, 
        DATEADD(ms, DATEDIFF(ms, last_batch, GETDATE()), '1900-01-01'), 
            121), 12) as batch_duration,
    program_name,
    hostname,
    loginame,
    (
        SELECT
            SUBSTRING(text,
                CASE stmt_start WHEN 0 THEN 1 ELSE stmt_start / 2 END,
                CASE stmt_end
                    WHEN -1
                        THEN DATALENGTH(text)
                    ELSE 
                        stmt_end - CASE stmt_start WHEN 0 THEN 0 ELSE stmt_start END
                    END
                )
        FROM ::fn_get_sql(sql_handle)
    ) sql
FROM master.dbo.sysprocesses procs
WHERE spid > 50
AND status not in ('background', 'sleeping')
AND cmd not in ('AWAITING COMMAND'
               ,'MIRROR HANDLER'
               ,'LAZY WRITER'
               ,'CHECKPOINT SLEEP'
               ,'RA MANAGER')
GROUP BY spid, last_batch, program_name, hostname, loginame, stmt_start, stmt_end, sql_handle
ORDER BY batch_duration DESC