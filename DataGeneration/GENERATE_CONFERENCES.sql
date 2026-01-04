USE ConferenceDB;
SET NOCOUNT ON;

PRINT 'Starting generation of 1,000 conferences (5-year history)...';

DECLARE @start_time DATETIME = GETDATE();
DECLARE @counter INT = 0;
DECLARE @total INT = 1000;

-- 5-year window: 4 years past + current year + 1 year future
DECLARE @start_range DATE = DATEADD(YEAR, -4, CAST(GETDATE() AS DATE));
DECLARE @day_step INT = (365 * 5) / @total; -- evenly spread

-- Themes
DECLARE @themes TABLE (id INT IDENTITY, theme NVARCHAR(100));
INSERT INTO @themes VALUES
('Artificial Intelligence'), ('Machine Learning'), ('Deep Learning'),
('Data Science'), ('Big Data Analytics'), ('Cybersecurity'),
('Blockchain'), ('Internet of Things'), ('Cloud Computing'),
('Quantum Computing'), ('Software Engineering'), ('DevOps'),
('Web Development'), ('Mobile Development'), ('Game Development'),
('Computer Vision'), ('Natural Language Processing'), ('Robotics'),
('Bioinformatics'), ('Health Informatics');

-- Locations
DECLARE @locations TABLE (id INT IDENTITY, location NVARCHAR(150));
INSERT INTO @locations VALUES
('Kyiv, Ukraine'), ('Warsaw, Poland'), ('Berlin, Germany'),
('Paris, France'), ('London, UK'),
('New York, USA'), ('San Francisco, USA'),
('Toronto, Canada'), ('Tokyo, Japan'),
('Sydney, Australia'), ('Singapore'),
('Dubai, UAE'), ('Online Conference'), ('Virtual Event');

WHILE @counter < @total
BEGIN
    DECLARE @conf_start DATE = DATEADD(DAY, @counter * @day_step, @start_range);
    DECLARE @conf_end   DATE = DATEADD(DAY, 2 + (@counter % 3), @conf_start);

    INSERT INTO Conferences (
        title,
        start_date,
        end_date,
        location,
        theme,
        status,
        created_date,
        last_updated
    )
    SELECT
        CONCAT(
    CASE @counter % 4
        WHEN 0 THEN 'International Conference on '
        WHEN 1 THEN 'World Summit on '
        WHEN 2 THEN 'Global Forum on '
        ELSE 'Annual Meeting on '
    END,
    t.theme,
    ' ',
    YEAR(@conf_start),
    ' #',
    FORMAT(@counter + 1, '0000')
),
        @conf_start,
        @conf_end,
        l.location,
        t.theme,
        CASE
            WHEN @conf_end < CAST(GETDATE() AS DATE) THEN 'Completed'
            WHEN @conf_start > CAST(GETDATE() AS DATE) THEN 'Planned'
            ELSE 'Active'
        END,
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 60, @conf_start),
        GETDATE()
    FROM @themes t
    CROSS APPLY (
        SELECT location
        FROM @locations
        WHERE id = (ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM @locations)) + 1
    ) l
    WHERE t.id = (ABS(CHECKSUM(NEWID())) % (SELECT COUNT(*) FROM @themes)) + 1;

    SET @counter += 1;

    IF @counter % 100 = 0
        PRINT CONCAT('Generated ', @counter, ' conferences...');
END

DECLARE @end_time DATETIME = GETDATE();

PRINT '=========================================';
PRINT 'Conference generation completed successfully!';
PRINT CONCAT('Total generated: ', @total);
PRINT CONCAT('Execution time: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');
PRINT CONCAT(
    'Average speed: ',
    CAST(@total * 1.0 / NULLIF(DATEDIFF(SECOND, @start_time, @end_time), 0) AS DECIMAL(10,2)),
    ' records/sec'
);
PRINT '=========================================';
