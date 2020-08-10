set transaction isolation level read uncommitted;

WITH ReportItems (ItemID, Name, Path, reportXml) AS
(
    SELECT ItemID
        , Name
        , Path
        , CAST(CAST([Content] AS VARBINARY(MAX)) AS XML) AS reportXml
    FROM Catalog
    WHERE (Type = 2)
),
reports as(
    SELECT ItemID
        , Name
        , Path
        , report.commandText.value('.', 'nvarchar(MAX)') AS commandText
    FROM reportItems
    OUTER APPLY reportXml.nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition"; //CommandText/text()') AS report(commandText)
    UNION ALL
    SELECT ItemID
        , Name
        , Path
        , report.commandText.value('.', 'nvarchar(MAX)') AS commandText
    FROM reportItems
    OUTER APPLY reportXml.nodes(N'declare default element namespace "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition"; //CommandText/text()') AS report(commandText)
)
select * from reports --where commandText like '%%'