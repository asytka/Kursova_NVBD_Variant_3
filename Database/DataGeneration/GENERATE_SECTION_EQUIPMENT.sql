-- ============================================
-- Generate 10,000 links between sections and equipment
-- ============================================

USE ConferenceDB;
GO

PRINT 'Starting generation of 10,000 section-equipment links...';
GO

DECLARE @start_time DATETIME = GETDATE();
DECLARE @counter INT = 0;
DECLARE @target_count INT = 10000;
DECLARE @existing_count INT = (SELECT COUNT(*) FROM SectionEquipment);

PRINT 'Table already has ' + CAST(@existing_count AS VARCHAR) + ' existing links.';

-- If you need to clear the table (uncomment):
-- DELETE FROM SectionEquipment;
-- SET @existing_count = 0;

-- Get available sections and equipment
DECLARE @sections TABLE (section_id INT PRIMARY KEY, section_date DATE);
DECLARE @equipment TABLE (equipment_id INT PRIMARY KEY, equipment_type VARCHAR(30), available_quantity INT);

INSERT INTO @sections (section_id, section_date)
SELECT section_id, section_date FROM Sections;

INSERT INTO @equipment (equipment_id, equipment_type, available_quantity)
SELECT equipment_id, equipment_type, available_quantity FROM Equipment WHERE available_quantity > 0;

-- Check if we have enough data
DECLARE @section_count INT = (SELECT COUNT(*) FROM @sections);
DECLARE @equipment_count INT = (SELECT COUNT(*) FROM @equipment);

PRINT 'Available sections: ' + CAST(@section_count AS VARCHAR);
PRINT 'Available equipment: ' + CAST(@equipment_count AS VARCHAR);

IF @section_count = 0 OR @equipment_count = 0
BEGIN
    PRINT '❌ ERROR: Not enough data to generate links!';
    PRINT '   Make sure Sections and Equipment tables have data.';
    RETURN;
END

-- Generate unique pairs (section, equipment)
DECLARE @generated_pairs TABLE (
    pair_id INT IDENTITY(1,1) PRIMARY KEY,
    section_id INT,
    equipment_id INT,
    UNIQUE (section_id, equipment_id)
);

PRINT 'Generating unique section-equipment pairs...';

-- Generate 10,000 unique pairs
WHILE @counter < @target_count AND @counter < (@section_count * @equipment_count)
BEGIN
    DECLARE @section_id INT, @equipment_id INT;
    
    -- Get random section
    SELECT TOP 1 @section_id = section_id 
    FROM @sections 
    ORDER BY NEWID();
    
    -- Get random equipment
    SELECT TOP 1 @equipment_id = equipment_id 
    FROM @equipment 
    ORDER BY NEWID();
    
    -- Try to insert unique pair
    IF NOT EXISTS (SELECT 1 FROM @generated_pairs 
                   WHERE section_id = @section_id AND equipment_id = @equipment_id)
    BEGIN
        INSERT INTO @generated_pairs (section_id, equipment_id)
        VALUES (@section_id, @equipment_id);
        
        SET @counter = @counter + 1;
        
        -- Progress every 2,000 records
        IF @counter % 2000 = 0
        BEGIN
            PRINT 'Generated ' + CAST(@counter AS VARCHAR) + ' unique pairs...';
        END
    END
END

PRINT 'Inserting data into SectionEquipment table...';

-- Insert data into main table
INSERT INTO SectionEquipment (
    section_id,
    equipment_id,
    quantity_needed,
    rental_date,
    return_date
)
SELECT 
    gp.section_id,
    gp.equipment_id,
    
    -- Quantity needed (1-3 units)
    CASE 
        WHEN e.equipment_type IN ('Projector', 'Sound System', 'Laptop') THEN 1
        WHEN e.equipment_type = 'Microphone' THEN ABS(CHECKSUM(NEWID())) % 3 + 1  -- 1-3
        WHEN e.equipment_type = 'Monitor' THEN ABS(CHECKSUM(NEWID())) % 2 + 1    -- 1-2
        ELSE 1
    END,
    
    -- Rental date (section date - 1 day)
    DATEADD(DAY, -1, s.section_date),
    
    -- Return date (section date + 1 day)
    DATEADD(DAY, 1, s.section_date)

FROM @generated_pairs gp
INNER JOIN @sections s ON gp.section_id = s.section_id
INNER JOIN @equipment e ON gp.equipment_id = e.equipment_id;

-- Update available equipment quantity
UPDATE Equipment
SET available_quantity = available_quantity - se.quantity_needed
FROM Equipment e
INNER JOIN SectionEquipment se ON e.equipment_id = se.equipment_id
INNER JOIN @generated_pairs gp ON se.section_id = gp.section_id AND se.equipment_id = gp.equipment_id;

DECLARE @end_time DATETIME = GETDATE();
DECLARE @duration INT = DATEDIFF(SECOND, @start_time, @end_time);
DECLARE @actual_count INT = (SELECT COUNT(*) FROM SectionEquipment) - @existing_count;
DECLARE @total_count INT = (SELECT COUNT(*) FROM SectionEquipment);

PRINT '=========================================';
PRINT 'Section-Equipment links generation completed!';
PRINT '=========================================';
PRINT 'Target links: ' + CAST(@target_count AS VARCHAR);
PRINT 'New links created: ' + CAST(@actual_count AS VARCHAR);
PRINT 'Total links in table: ' + CAST(@total_count AS VARCHAR);
PRINT 'Duration: ' + CAST(@duration AS VARCHAR) + ' seconds';
PRINT '=========================================';
GO

-- Check results
SELECT 
    COUNT(*) as TotalRelations,
    COUNT(DISTINCT section_id) as SectionsWithEquipment,
    COUNT(DISTINCT equipment_id) as EquipmentTypesUsed,
    AVG(quantity_needed) as AvgQuantityPerRelation,
    SUM(quantity_needed) as TotalEquipmentReserved,
    MIN(rental_date) as EarliestRental,
    MAX(return_date) as LatestReturn
FROM SectionEquipment;
GO