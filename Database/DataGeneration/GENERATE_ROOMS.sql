USE ConferenceDB;
GO

PRINT 'Generating 500 rooms (with unique room numbers)...';
GO

-- Check if table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Rooms')
BEGIN
    PRINT '❌ Table Rooms does not exist!';
    RETURN;
END

DECLARE @start_time DATETIME = GETDATE();
DECLARE @target_count INT = 500;
DECLARE @counter INT = 0;
DECLARE @existing_count INT = (SELECT COUNT(*) FROM Rooms);

PRINT 'Table already has ' + CAST(@existing_count AS VARCHAR) + ' records.';

-- If you need to clear the table (uncomment):
-- DELETE FROM Rooms;
-- DBCC CHECKIDENT ('Rooms', RESEED, 0);
-- SET @existing_count = 0;

-- Data arrays for generation
DECLARE @buildings TABLE (id INT IDENTITY, name CHAR(1));
INSERT INTO @buildings (name) VALUES 
('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J');

DECLARE @floors TABLE (id INT IDENTITY, floor INT);
INSERT INTO @floors (floor) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

DECLARE @room_numbers TABLE (id INT IDENTITY, number INT);
INSERT INTO @room_numbers (number) 
SELECT TOP 50 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) 
FROM sys.all_columns;

-- Generate unique room numbers
WHILE @counter < @target_count
BEGIN
    -- Generate unique room number
    DECLARE @room_number VARCHAR(20);
    DECLARE @attempts INT = 0;
    
    WHILE @attempts < 100  -- Protection from infinite loop
    BEGIN
        -- Generate number: Building(1 letter) + Floor(1-10) + Room(01-50)
        SET @room_number = 
            (SELECT TOP 1 name FROM @buildings ORDER BY NEWID()) +
            CAST((SELECT TOP 1 floor FROM @floors ORDER BY NEWID()) AS VARCHAR) +
            RIGHT('0' + CAST((SELECT TOP 1 number FROM @room_numbers ORDER BY NEWID()) AS VARCHAR), 2);
        
        -- Check if this number already exists
        IF NOT EXISTS (SELECT 1 FROM Rooms WHERE room_number = @room_number)
            BREAK;  -- Number is unique, exit loop
        
        SET @attempts = @attempts + 1;
    END
    
    -- If couldn't find unique number, create guaranteed unique
    IF @attempts >= 100
    BEGIN
        SET @room_number = 'RM' + CAST(@counter + 1000 AS VARCHAR);
    END
    
    INSERT INTO Rooms (
        room_number,
        capacity,
        floor,
        has_projector,
        has_sound_system,
        is_available
    )
    VALUES (
        @room_number,
        -- Capacity (20-500)
        CASE 
            WHEN @counter % 10 = 0 THEN 500  -- large hall
            WHEN @counter % 10 = 1 THEN 300  -- medium hall
            WHEN @counter % 10 = 2 THEN 200
            WHEN @counter % 10 = 3 THEN 150
            WHEN @counter % 10 = 4 THEN 100
            WHEN @counter % 10 = 5 THEN 80
            WHEN @counter % 10 = 6 THEN 60
            WHEN @counter % 10 = 7 THEN 40
            WHEN @counter % 10 = 8 THEN 30
            ELSE 20                          -- small room
        END,
        -- Floor (1-10)
        (@counter % 10) + 1,
        -- Has projector (80% have it)
        CASE WHEN @counter % 100 < 80 THEN 1 ELSE 0 END,
        -- Has sound system (60% have it)
        CASE WHEN @counter % 100 < 60 THEN 1 ELSE 0 END,
        -- Is available (85% available)
        CASE WHEN @counter % 100 < 85 THEN 1 ELSE 0 END
    );
    
    SET @counter = @counter + 1;
    
    -- Progress every 100 records
    IF @counter % 100 = 0
    BEGIN
        PRINT 'Generated ' + CAST(@counter AS VARCHAR) + ' rooms...';
    END
END

DECLARE @end_time DATETIME = GETDATE();
DECLARE @duration INT = DATEDIFF(SECOND, @start_time, @end_time);
DECLARE @actual_count INT = (SELECT COUNT(*) FROM Rooms);

PRINT '=========================================';
PRINT 'Room generation completed!';
PRINT 'Total rooms: ' + CAST(@actual_count AS VARCHAR);
PRINT 'Newly added: ' + CAST(@actual_count - @existing_count AS VARCHAR);
PRINT 'Duration: ' + CAST(@duration AS VARCHAR) + ' seconds';
PRINT '=========================================';
GO

-- Check uniqueness and results
SELECT 
    COUNT(*) as TotalRooms,
    COUNT(DISTINCT room_number) as UniqueRoomNumbers,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT room_number) 
        THEN 'All numbers are unique' 
        ELSE 'Duplicates found!' 
    END as UniquenessCheck,
    SUM(CASE WHEN has_projector = 1 THEN 1 ELSE 0 END) as RoomsWithProjector,
    SUM(CASE WHEN has_sound_system = 1 THEN 1 ELSE 0 END) as RoomsWithSound,
    SUM(CASE WHEN is_available = 1 THEN 1 ELSE 0 END) as AvailableRooms,
    AVG(capacity) as AvgCapacity,
    MIN(capacity) as MinCapacity,
    MAX(capacity) as MaxCapacity,
    COUNT(DISTINCT floor) as FloorsUsed
FROM Rooms;
GO