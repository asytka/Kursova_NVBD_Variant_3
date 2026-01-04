USE ConferenceDB;
SET NOCOUNT ON;

PRINT 'Starting generation of 100,000 presentations...';

DECLARE @start_time DATETIME = GETDATE();
DECLARE @total INT = 100000;
DECLARE @batch INT = 5000;
DECLARE @inserted INT = 0;

-- Presentation titles
DECLARE @presentation_titles TABLE (id INT IDENTITY, title NVARCHAR(300));
INSERT INTO @presentation_titles (title) VALUES
('Advanced Techniques in Machine Learning for Predictive Analytics'),
('Deep Neural Networks: Architecture Optimization and Performance'),
('Natural Language Processing for Multilingual Text Classification'),
('Computer Vision Applications in Autonomous Driving Systems'),
('Reinforcement Learning in Robotics and Game Theory'),
('Generative Adversarial Networks for Synthetic Data Creation'),
('Ethical Considerations in AI Development and Deployment'),
('AI-Powered Diagnostic Tools in Modern Healthcare'),
('Big Data Processing with Apache Spark and Hadoop'),
('Interactive Data Visualization for Business Intelligence'),
('Cloud Security Best Practices for Multi-Tenant Architectures'),
('Network Intrusion Detection Using Machine Learning'),
('Post-Quantum Cryptography: Algorithms and Implementation'),
('Security Challenges in Internet of Things Ecosystems'),
('Blockchain for Supply Chain Transparency and Traceability'),
('Smart Contract Development and Security Auditing'),
('Quantum Machine Learning: Algorithms and Applications'),
('Quantum Error Correction and Fault-Tolerant Computing'),
('DevOps Culture: CI/CD Pipeline Optimization'),
('Microservices Architecture Patterns and Anti-Patterns'),
('Agile Project Management in Distributed Teams'),
('Automated Software Testing Frameworks and Tools'),
('Modern Web Development with React and Node.js'),
('Cross-Platform Mobile Development with Flutter'),
('Game Development Using Unity and Unreal Engine'),
('Augmented Reality in Education and Training'),
('Virtual Reality for Therapeutic Applications'),
('Bioinformatics Tools for Genomic Data Analysis'),
('Computational Models for Protein Structure Prediction'),
('Machine Learning in Drug Discovery and Development'),
('Data Privacy Regulations and Compliance Strategies'),
('Edge Computing for Low-Latency Applications'),
('5G Networks and Their Impact on Mobile Computing'),
('Sustainable Computing: Energy-Efficient Algorithms'),
('Human-Computer Interaction: UX Design Principles'),
('Accessibility in Software Development'),
('Open Source Software: Community and Governance'),
('Digital Transformation in Traditional Industries'),
('Startup Ecosystem: Funding and Growth Strategies'),
('Academic-Industry Collaboration in Tech Research');

WHILE @inserted < @total
BEGIN
    INSERT INTO Presentations (
        section_id,
        presenter_id,
        title,
        abstract,
        start_time,
        duration_minutes,
        equipment_needed,
        presentation_status
    )
    SELECT TOP (@batch)
        s.section_id,
        p.presenter_id,
        pt.title,
        CONCAT(
            'This presentation discusses ',
            LOWER(LEFT(pt.title, CHARINDEX(' ', pt.title + ' ') - 1)),
            ' and its applications in modern technology. ',
            'It covers theory, implementation, case studies, ',
            'and future research directions.'
        ),
        DATEADD(
            MINUTE,
            ABS(CHECKSUM(NEWID())) %
            DATEDIFF(MINUTE, s.start_time, s.end_time),
            s.start_time
        ),
        CASE ABS(CHECKSUM(NEWID())) % 100
            WHEN 0 THEN 45
            WHEN 1 THEN 30
            WHEN 2 THEN 25
            WHEN 3 THEN 20
            ELSE 15
        END,
        CASE WHEN ABS(CHECKSUM(NEWID())) % 100 < 70 THEN 1 ELSE 0 END,
        CASE
            WHEN r < 60 THEN 'Scheduled'
            WHEN r < 95 THEN 'Completed'
            WHEN r < 99 THEN 'Cancelled'
            ELSE 'Postponed'
        END
    FROM Sections s
    CROSS APPLY (SELECT TOP 1 presenter_id FROM Presenters WHERE is_active = 1 ORDER BY NEWID()) p
    CROSS APPLY (SELECT TOP 1 title FROM @presentation_titles ORDER BY NEWID()) pt
    CROSS APPLY (SELECT ABS(CHECKSUM(NEWID())) % 100 AS r) rand
    ORDER BY NEWID();

    SET @inserted += @batch;

    IF @inserted % 20000 = 0
        PRINT CONCAT('Generated ', @inserted, ' presentations...');
END

DECLARE @end_time DATETIME = GETDATE();

PRINT '=========================================';
PRINT 'Presentation generation completed successfully!';
PRINT CONCAT('Total generated: ', @total);
PRINT CONCAT('Execution time: ', DATEDIFF(SECOND, @start_time, @end_time), ' seconds');
PRINT CONCAT(
    'Average speed: ',
    CAST(@total * 1.0 / NULLIF(DATEDIFF(SECOND, @start_time, @end_time), 0) AS DECIMAL(10,2)),
    ' records/sec'
);
PRINT '=========================================';
