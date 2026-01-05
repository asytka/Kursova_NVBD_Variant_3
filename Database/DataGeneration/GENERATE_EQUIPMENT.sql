-- Генерація 2,000 одиниць обладнання

USE ConferenceDB;
GO

PRINT 'Generating 2,000 equipment entries...';
GO

DECLARE @start_time DATETIME = GETDATE();
DECLARE @counter INT = 0;
DECLARE @batch_size INT = 2000;

-- Масиви даних для генерації
DECLARE @equipment_names TABLE (id INT IDENTITY, type VARCHAR(30), name NVARCHAR(100));
INSERT INTO @equipment_names (type, name) VALUES
('Projector', 'Epson PowerLite 1781W'),
('Projector', 'BenQ MH535'),
('Projector', 'Sony VPL-DW235'),
('Projector', 'Panasonic PT-VMZ50'),
('Projector', 'LG PF50KS'),
('Projector', 'Optoma HD146X'),
('Projector', 'ViewSonic PA503S'),
('Projector', 'NEC NP-ME331W'),
('Sound System', 'Bose L1 Pro8'),
('Sound System', 'JBL EON610'),
('Sound System', 'Yamaha DBR10'),
('Sound System', 'Mackie Thump15A'),
('Sound System', 'QSC K8.2'),
('Sound System', 'Electro-Voice ZLX-12BT'),
('Microphone', 'Shure SM58'),
('Microphone', 'Audio-Technica AT2020'),
('Microphone', 'Rode NT1-A'),
('Microphone', 'Sennheiser e835'),
('Microphone', 'Blue Yeti'),
('Microphone', 'AKG P5S'),
('Laptop', 'Dell XPS 13'),
('Laptop', 'MacBook Pro 16"'),
('Laptop', 'HP Spectre x360'),
('Laptop', 'Lenovo ThinkPad X1'),
('Laptop', 'Microsoft Surface Laptop 4'),
('Monitor', 'Dell UltraSharp U2720Q'),
('Monitor', 'LG 27UN850-W'),
('Monitor', 'Samsung UR55'),
('Monitor', 'ASUS ProArt PA278QV'),
('Monitor', 'HP Z27'),
('Camera', 'Sony Alpha A7 III'),
('Camera', 'Canon EOS R6'),
('Camera', 'Panasonic Lumix GH5'),
('Camera', 'Fujifilm X-T4'),
('Camera', 'Nikon Z6 II'),
('Lighting', 'Godox SL60W'),
('Lighting', 'Aputure 120D II'),
('Lighting', 'Neewer 660 LED'),
('Lighting', 'Falcon Eyes RX-24TD'),
('Printer', 'HP LaserJet Pro M404n'),
('Printer', 'Brother HL-L2350DW'),
('Printer', 'Canon imageCLASS MF644Cdw'),
('Scanner', 'Epson Perfection V600'),
('Scanner', 'Canon CanoScan 9000F'),
('Network Device', 'Cisco SG350-10'),
('Network Device', 'TP-Link TL-SG108'),
('Network Device', 'Netgear GS308'),
('Network Device', 'Ubiquiti UniFi Switch 8');

DECLARE @conditions TABLE (id INT IDENTITY, condition VARCHAR(20), weight INT);
INSERT INTO @conditions (condition, weight) VALUES
('Excellent', 30),
('Good', 50),
('Fair', 15),
('Poor', 4),
('Broken', 1);

WHILE @counter < @batch_size
BEGIN
    INSERT INTO Equipment (
        equipment_name,
        equipment_type,
        available_quantity,
        condition_status,
        purchase_date,
        last_maintenance
    )
    SELECT 
        -- Назва обладнання
        e.name + 
        CASE WHEN e.type = 'Projector' THEN ' Projector'
             WHEN e.type = 'Sound System' THEN ' Sound System'
             ELSE '' END,
        
        -- Тип обладнання
        e.type,
        
        -- Доступна кількість (0-20 для кожного типу)
        CASE 
            WHEN e.type IN ('Projector', 'Sound System') 
                THEN ABS(CHECKSUM(NEWID())) % 10 + 1  -- 1-10
            WHEN e.type IN ('Microphone', 'Laptop') 
                THEN ABS(CHECKSUM(NEWID())) % 20 + 5  -- 5-25
            WHEN e.type IN ('Monitor', 'Camera') 
                THEN ABS(CHECKSUM(NEWID())) % 15 + 3  -- 3-18
            ELSE ABS(CHECKSUM(NEWID())) % 8 + 2       -- 2-10 для решти
        END,
        
        -- Стан обладнання (з вагами)
        c.condition,
        
        -- Дата покупки (останні 5 років)
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 1825, GETDATE()),
        
        -- Останнє технічне обслуговування (останній рік)
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE())
    
    FROM (SELECT * FROM @equipment_names 
          WHERE id = ((@counter % 48) + 1)) e
    CROSS APPLY (
        SELECT condition FROM (
            SELECT condition, 
                   SUM(weight) OVER (ORDER BY id) as cumulative_weight
            FROM @conditions
        ) t
        WHERE cumulative_weight >= (ABS(CHECKSUM(NEWID())) % 100) + 1
        ORDER BY cumulative_weight
        OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
    ) c;
    
    SET @counter = @counter + 1;
    
    -- Прогрес кожні 200 записів
    IF @counter % 200 = 0
    BEGIN
        PRINT 'Generated ' + CAST(@counter AS VARCHAR) + ' equipment entries...';
    END
END

DECLARE @end_time DATETIME = GETDATE();
DECLARE @duration INT = DATEDIFF(SECOND, @start_time, @end_time);

PRINT '=========================================';
PRINT 'Generation finished!';
PRINT 'Total ammount: ' + CAST(@batch_size AS VARCHAR);
PRINT 'Duration: ' + CAST(@duration AS VARCHAR) + ' seconds';
PRINT '=========================================';
GO

-- Перевірка результатів
SELECT 
    COUNT(*) as TotalEquipment,
    equipment_type,
    COUNT(*) as CountByType,
    SUM(available_quantity) as TotalAvailable,
    AVG(available_quantity) as AvgPerType,
    condition_status,
    COUNT(*) as CountByCondition
FROM Equipment
GROUP BY equipment_type, condition_status
ORDER BY equipment_type, CountByCondition DESC;
GO