SELECT
    DB_NAME() AS DBName
    ,OBJECT_NAME(ps.object_id) AS TableName
    ,i.name AS IndexName
    ,ips.index_type_desc
    ,ps.reserved_page_count*8.0*1024 AS IndexSpaceUsedBytes
    ,ips.avg_fragmentation_in_percent
    ,ips.fragment_count
    ,ips.avg_fragment_size_in_pages
    ,ips.page_count
    FROM sys.dm_db_partition_stats ps
INNER JOIN sys.indexes i
ON ps.object_id = i.object_id
AND ps.index_id = i.index_id
CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), ps.object_id, ps.index_id, null, 'LIMITED') ips
ORDER BY ps.object_id, ps.index_id


DECLARE @FragmentPercent FLOAT
SET @FragmentPercent = 10


SELECT
    *
    , 'ALTER INDEX ' + [IndexName] + ' ON ' + [SchemaName] + '.' + [TableName]
    + ' REBUILD WITH (ONLINE = ON) ' AS RebuildCommand
FROM
    ( SELECT
        DB_NAME() AS DBName
        , OBJECT_SCHEMA_NAME([ps].object_id) AS SchemaName
        , OBJECT_NAME(ps.object_id) AS TableName
        , i.name AS IndexName
        , ips.avg_fragmentation_in_percent 'Fragment %'
        , [ips].fragment_count 'Fragment Count'
        , [ips].avg_fragment_size_in_pages 'Avg Fragment Size In Pages'
        , [ips].page_count 'Page Count'
            , ps.reserved_page_count*8.0*1024 AS 'Index Space Used In Bytes'
    FROM
    sys.dm_db_partition_stats ps
    INNER JOIN sys.indexes i
    ON
    ps.object_id = i.OBJect_id
    AND ps.index_id = i.index_id
    CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), ps.object_id,
    ps.index_id, NULL, 'LIMITED') ips
    WHERE
    ips.avg_fragmentation_in_percent > @FragmentPercent
 ) framgentedIndexes
ORDER BY
    [Fragment %] DESC