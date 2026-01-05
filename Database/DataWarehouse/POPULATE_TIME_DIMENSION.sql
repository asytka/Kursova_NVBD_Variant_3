-- ============================================
-- File: 04_POPULATE_TIME_DIMENSION.sql
-- Description: Populates Time dimension with dates
-- SIMPLE VERSION - No GO statements inside
-- Author: [Your Name]
-- ============================================

USE ConferenceDW;
GO

PRINT 'Populating Time dimension...';
PRINT '';

-- Clear existing data
DELETE FROM DimTime;
PRINT 'Cleared existing time data.';

-- Get date range from ConferenceDB (with buffer)
DECLARE @MinDate DATE, @MaxDate DATE;
DECLARE @DateCounter DATE;
DECLARE @RowsInserted INT = 0;
DECLARE @StartDate DATE, @EndDate DATE;

-- Get the actual range from your data
SELECT 
    @MinDate = DATEADD(YEAR, -2, MIN(section_date)),
    @MaxDate = DATEADD(YEAR, 2, MAX(section_date))
FROM ConferenceDB.dbo.Sections;

-- Set bounds
IF @MinDate < '2020-01-01' SET @MinDate = '2020-01-01';
IF @MaxDate > '2030-12-31' SET @MaxDate = '2030-12-31';

SET @StartDate = @MinDate;
SET @EndDate = @MaxDate;
SET @DateCounter = @StartDate;

PRINT 'Date range: ' + CONVERT(VARCHAR, @StartDate) + ' to ' + CONVERT(VARCHAR, @EndDate);
PRINT 'Total days to insert: ' + CAST(DATEDIFF(DAY, @StartDate, @EndDate) + 1 AS VARCHAR);
PRINT '';

-- Loop through each day
WHILE @DateCounter <= @EndDate
BEGIN
    INSERT INTO DimTime (
        FullDate,
        DayNumber,
        DayName,
        WeekNumber,
        MonthNumber,
        MonthName,
        Quarter,
        Year,
        IsWeekend,
        IsHoliday,
        FiscalYear,
        Season
    )
    VALUES (
        @DateCounter,
        DAY(@DateCounter),
        DATENAME(WEEKDAY, @DateCounter),
        DATEPART(WEEK, @DateCounter),
        MONTH(@DateCounter),
        DATENAME(MONTH, @DateCounter),
        DATEPART(QUARTER, @DateCounter),
        YEAR(@DateCounter),
        CASE WHEN DATENAME(WEEKDAY, @DateCounter) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
        CASE 
            WHEN MONTH(@DateCounter) = 1 AND DAY(@DateCounter) = 1 THEN 1
            WHEN MONTH(@DateCounter) = 12 AND DAY(@DateCounter) = 25 THEN 1
            WHEN MONTH(@DateCounter) = 12 AND DAY(@DateCounter) = 31 THEN 1
            ELSE 0 
        END,
        CASE WHEN MONTH(@DateCounter) >= 4 THEN YEAR(@DateCounter) ELSE YEAR(@DateCounter) - 1 END,
        CASE 
            WHEN MONTH(@DateCounter) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(@DateCounter) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(@DateCounter) IN (6, 7, 8) THEN 'Summer'
            ELSE 'Autumn'
        END
    );
    
    SET @RowsInserted = @RowsInserted + 1;
    SET @DateCounter = DATEADD(DAY, 1, @DateCounter);
    
    -- Show progress every 500 rows
    IF @RowsInserted % 500 = 0
        PRINT '  Inserted ' + CAST(@RowsInserted AS VARCHAR) + ' dates...';
END;

PRINT '';
PRINT '=========================================';
PRINT 'SUCCESS: Time dimension populated!';
PRINT 'Total dates inserted: ' + CAST(@RowsInserted AS VARCHAR);
PRINT 'Date range: ' + CONVERT(VARCHAR, @StartDate) + ' to ' + CONVERT(VARCHAR, @EndDate);
PRINT '=========================================';
GO

-- Verify
SELECT 
    COUNT(*) as TotalDates,
    MIN(FullDate) as FirstDate,
    MAX(FullDate) as LastDate,
    SUM(CASE WHEN IsWeekend = 1 THEN 1 ELSE 0 END) as WeekendDays
FROM DimTime;
GO