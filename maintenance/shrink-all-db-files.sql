DECLARE @sql VARCHAR(MAX) = '';

SELECT @sql = @sql + 
	'USE [' + d.[name] +  ']; DBCC SHRINKFILE (N''' + f.name + ''' , 0, TRUNCATEONLY); '
FROM sys.master_files f
JOIN sys.[databases] d
ON [d].[database_id] = [f].[database_id]
ORDER BY size DESC

SELECT @sql
EXEC (@sql)
