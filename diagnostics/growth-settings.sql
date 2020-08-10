SELECT
    DB_NAME(mf.database_id) database_name,
    db.recovery_model_desc db_recovery_model,
    mf.name,
    CONVERT(DECIMAL(20,2),(CONVERT(DECIMAL,size)/128)) [file_size_MB],
    CASE mf.is_percent_growth 
        WHEN 1 THEN 'Yes' 
        ELSE 'No' 
    END is_percent_growth,
    CASE mf.is_percent_growth 
        WHEN 1 THEN CONVERT(VARCHAR, mf.growth) + '%'
        WHEN 0 THEN CONVERT(VARCHAR,mf.growth/128) + ' MB'
    END AS [growth_in_increment_of],
    CASE mf.is_percent_growth 
        WHEN 1 THEN CONVERT(DECIMAL(20,2),(((CONVERT(DECIMAL,size)*growth)/100)*8)/1024)
        WHEN 0 THEN CONVERT(DECIMAL(20,2),(CONVERT(DECIMAL, growth)/128))
    END AS [next_auto_growth_size_MB], 
    mf.max_size,
    physical_name 
FROM sys.master_files mf INNER JOIN sys.databases db ON (mf.database_id = db.database_id)
