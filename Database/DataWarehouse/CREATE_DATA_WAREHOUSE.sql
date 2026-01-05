PRINT 'Creating Data Warehouse database...';
GO

-- Check if database exists and drop it
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ConferenceDW')
BEGIN
    PRINT 'Dropping existing ConferenceDW database...';
    
    -- Set database to single user mode to kick out other connections
    ALTER DATABASE ConferenceDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Drop the database
    DROP DATABASE ConferenceDW;
    
    PRINT 'Existing database dropped.';
END
ELSE
BEGIN
    PRINT 'ConferenceDW database does not exist. Creating new...';
END
GO

-- SIMPLIFIED: Create database without specifying file paths
-- SQL Server will use its default locations
CREATE DATABASE ConferenceDW;
GO

PRINT 'Data Warehouse database created successfully.';
GO

USE ConferenceDW;
GO

-- Now we can show where files were created
SELECT 
    name AS [FileName],
    type_desc AS [FileType],
    physical_name AS [Location],
    size/128.0 AS [SizeMB],
    growth AS [GrowthKB]
FROM sys.database_files;

PRINT '';
PRINT 'ConferenceDW is ready for dimension and fact tables.';
GO