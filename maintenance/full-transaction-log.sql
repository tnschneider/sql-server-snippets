USE [<db-name>]
ALTER DATABASE [<db-name>] SET RECOVERY FULL

BACKUP DATABASE [<db-name>]
TO DISK = 'nul:' WITH STATS = 10
 
BACKUP LOG [<db-name>]
TO DISK = 'nul:' WITH STATS = 10
 
DBCC SHRINKFILE ([<log-file-name>], 1)