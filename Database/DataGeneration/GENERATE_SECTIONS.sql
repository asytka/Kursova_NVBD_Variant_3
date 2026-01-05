USE ConferenceDB;
SET NOCOUNT ON;

PRINT 'Starting generation of 5,000 sections...';

DECLARE @start_time DATETIME = GETDATE();
DECLARE @total INT = 5000;
DECLARE @batch INT = 500;
DECLARE @inserted INT = 0;

-- Lookup tables
DECLARE @section_types TABLE (id INT IDENTITY, type VARCHAR(50));
INSERT INTO @section_types VALUES
('Plenary Session'), ('Parallel Session'), ('Workshop'),
('Tutorial'), ('Panel Discussion'), ('Poster Session'),
('Round Table'), ('Keynote Speech'), ('Technical Session'),
('Special Session');

DECLARE @topics TABLE (id INT IDENTITY, topic VARCHAR(100));
INSERT INTO @topics VALUES
('Machine Learning Applications'), ('Deep Learning Architectures'),
('Natural Language Processing'), ('Computer Vision'),
('Reinforcement Learning'), ('Generative AI'),
('Ethics in AI'), ('AI in Healthcare'),
('Big Data Analytics'), ('Data Visualization'),
('Cloud Security'), ('Network Security'),
('Cryptography'), ('IoT Security'),
('Blockchain Applications'), ('Smart Contracts'),
('Quantum Algorithms'), ('Quantum Machine Learning'),
('DevOps Practices'), ('Microservices Architecture'),
('Agile Methodology'), ('Software Testing'),
('Web Development Trends'), ('Mobile App Development'),
('Game Development'), ('AR/VR Technologies'),
('Bioinformatics Tools'), ('Computational Biology');

WHILE @inserted < @total
BEGIN
    INSERT INTO Sections (
        conference_id,
        section_name,
        chairperson_id,
        room_id,
        max_participants,
        start_time,
        end_time,
        section_date
    )
    SELECT TOP (@batch)
        c.conference_id,
        st.type + ' on ' + t.topic,
        p.presenter_id,
        r.room_id,
        CASE st.type
            WHEN 'Plenary Session' THEN 300
            WHEN 'Keynote Speech' THEN 250
            WHEN 'Workshop' THEN 50
            WHEN 'Tutorial' THEN 40
            WHEN 'Panel Discussion' THEN 100
            ELSE 80
        END,
        dt.start_dt,
        DATEADD(MINUTE, dt.duration, dt.start_dt),
        DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 3, c.start_date)
    FROM Conferences c
    CROSS APPLY (SELECT TOP 1 presenter_id FROM Presenters WHERE is_active = 1 ORDER BY NEWID()) p
    CROSS APPLY (SELECT TOP 1 room_id FROM Rooms WHERE is_available = 1 ORDER BY NEWID()) r
    CROSS APPLY (SELECT TOP 1 type FROM @section_types ORDER BY NEWID()) st
    CROSS APPLY (SELECT TOP 1 topic FROM @topics ORDER BY NEWID()) t
    CROSS APPLY (
        SELECT
            DATEADD(
                MINUTE,
                540 + ABS(CHECKSUM(NEWID())) % 480, -- 09:00–17:00
                CAST(c.start_date AS DATETIME)
            ) AS start_dt,
            60 + ABS(CHECKSUM(NEWID())) % 120 AS duration
    ) dt
    ORDER BY NEWID();

    SET @inserted += @batch;

    IF @inserted % 1000 = 0
        PRINT CONCAT('Generated ', @inserted, ' sections...');
END

DECLARE @end_time DATETIME = GETDATE();

PRINT '=========================================';
PRINT 'Section generation completed successfully!';
PRINT CONCAT('Total sections generated: ', @total);
PRINT CONCAT('Execution time: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');
PRINT '=========================================';
