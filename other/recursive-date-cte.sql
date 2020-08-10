DECLARE @start DATE = '2000-01-01';
DECLARE @end DATE = '2000-12-31';

WITH dates AS
(
        SELECT @start AS Date
        UNION ALL
        SELECT DATEADD(DAY, 1, Date) AS Date
        FROM [dates]
        WHERE DATEADD(DAY, 1, Date) <= @end
)

SELECT * FROM [dates]