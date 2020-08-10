/* Reto Egeter, fullparam.wordpress.com */
DECLARE @SearchStrColumnName nvarchar(100), @SearchStrColumnValue nvarchar(100), @SearchStrInXML bit
SET @SearchStrColumnValue = '%' /* use LIKE syntax */
SET @SearchStrColumnName = NULL /* NULL for all, use LIKE syntax */
SET @SearchStrInXML = 0 /* Searching XML data may be slow */

IF OBJECT_ID('tempdb..#Results') IS NOT NULL DROP TABLE #Results
CREATE TABLE #Results (TableName nvarchar(128), ColumnName nvarchar(128), ColumnValue nvarchar(max),ColumnType nvarchar(20))

SET NOCOUNT ON

DECLARE @TableName nvarchar(256) = '',@ColumnName nvarchar(128),@ColumnType nvarchar(20), @QuotedSearchStrColumnValue nvarchar(110), @QuotedSearchStrColumnName nvarchar(110)
SET @QuotedSearchStrColumnValue = QUOTENAME(@SearchStrColumnValue,'''')
DECLARE @ColumnNameTable TABLE (COLUMN_NAME nvarchar(128),DATA_TYPE nvarchar(20))

WHILE @TableName IS NOT NULL
BEGIN
SET @TableName =
(
SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
AND QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
AND OBJECTPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)), 'IsMSShipped') = 0
)

IF @TableName IS NOT NULL
BEGIN
DECLARE @sql VARCHAR(MAX)
SET @sql = 'SELECT QUOTENAME(COLUMN_NAME),DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(''' + @TableName + ''', 2)
AND TABLE_NAME = PARSENAME(''' + @TableName + ''', 1)
AND DATA_TYPE IN (' + CASE WHEN ISNUMERIC(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@SearchStrColumnValue,'%',''),'_',''),'[',''),']',''),'-','')) = 1 THEN '''tinyint'',''int'',''bigint'',' ELSE '' END + '''char'',''varchar'',''nchar'',''nvarchar''' + CASE @SearchStrInXML WHEN 1 THEN ',''xml''' ELSE '' END + ')
AND COLUMN_NAME LIKE COALESCE(' + CASE WHEN @SearchStrColumnName IS NULL THEN 'NULL' ELSE '''' + @SearchStrColumnName + '''' END  + ',COLUMN_NAME)'
INSERT INTO @ColumnNameTable
EXEC (@sql)
WHILE EXISTS (SELECT TOP 1 COLUMN_NAME FROM @ColumnNameTable)
BEGIN
SELECT TOP 1 @ColumnName = COLUMN_NAME,@ColumnType = DATA_TYPE FROM @ColumnNameTable
SET @sql = 'SELECT ''' + @TableName + ''',''' + @ColumnName + ''',' + CASE @SearchStrInXML WHEN 1 THEN 'LEFT(CAST(' + @ColumnName + ' AS nvarchar(MAX)), 4096),''' ELSE 'LEFT(' + @ColumnName + ', 4096),''' END + @ColumnType + '''
FROM ' + @TableName + ' (NOLOCK) ' +
' WHERE ' + CASE @SearchStrInXML WHEN 1 THEN 'CAST(' + @ColumnName + ' AS nvarchar(MAX))' ELSE @ColumnName END + ' LIKE ' + @QuotedSearchStrColumnValue
INSERT INTO #Results
EXEC(@sql)
DELETE FROM @ColumnNameTable WHERE COLUMN_NAME = @ColumnName
END 
END
END
SET NOCOUNT OFF

SELECT TableName, ColumnName, ColumnValue, ColumnType, COUNT(*) AS Count FROM #Results
GROUP BY TableName, ColumnName, ColumnValue, ColumnType