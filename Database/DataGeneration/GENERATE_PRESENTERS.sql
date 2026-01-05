USE ConferenceDB;
GO

PRINT 'Generating 20,000 presenters...';
GO

-- Check if table exists
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Presenters')
BEGIN
    PRINT '❌ Table Presenters does not exist!';
    RETURN;
END

-- Clear table first
DELETE FROM Presenters;
DBCC CHECKIDENT ('Presenters', RESEED, 0);
GO

DECLARE @start_time DATETIME = GETDATE();
DECLARE @total_rows INT = 20000;
DECLARE @batch_size INT = 5000;  -- Increased batch size for efficiency
DECLARE @batch_num INT = 0;
DECLARE @rows_inserted INT = 0;

-- Data for generation
DECLARE @first_names TABLE (id INT IDENTITY, name NVARCHAR(50));
INSERT INTO @first_names (name) VALUES
('John'), ('Mary'), ('James'), ('Patricia'), ('Robert'), ('Jennifer'),
('Michael'), ('Linda'), ('William'), ('Elizabeth'), ('David'), ('Barbara'),
('Richard'), ('Susan'), ('Joseph'), ('Jessica'), ('Thomas'), ('Sarah'),
('Charles'), ('Karen'), ('Christopher'), ('Nancy'), ('Daniel'), ('Lisa'),
('Matthew'), ('Margaret'), ('Anthony'), ('Betty'), ('Donald'), ('Sandra'),
('Mark'), ('Ashley'), ('Paul'), ('Dorothy'), ('Steven'), ('Kimberly'),
('Andrew'), ('Emily'), ('Kenneth'), ('Donna'), ('Joshua'), ('Michelle'),
('Kevin'), ('Carol'), ('Brian'), ('Amanda'), ('George'), ('Melissa'),
('Edward'), ('Deborah'), ('Ronald'), ('Stephanie'), ('Timothy'), ('Rebecca'),
('Jason'), ('Laura'), ('Jeffrey'), ('Helen'), ('Ryan'), ('Sharon'),
('Jacob'), ('Cynthia'), ('Gary'), ('Kathleen'), ('Nicholas'), ('Amy'),
('Eric'), ('Shirley'), ('Stephen'), ('Angela'), ('Jonathan'), ('Anna'),
('Larry'), ('Ruth'), ('Justin'), ('Brenda'), ('Scott'), ('Pamela'),
('Brandon'), ('Nicole'), ('Frank'), ('Katherine'), ('Benjamin'), ('Samantha'),
('Gregory'), ('Christine'), ('Raymond'), ('Catherine'), ('Samuel'), ('Virginia'),
('Patrick'), ('Debra'), ('Alexander'), ('Rachel'), ('Jack'), ('Janet'),
('Dennis'), ('Emma'), ('Jerry'), ('Carolyn'), ('Tyler'), ('Maria'),
('Aaron'), ('Heather'), ('Henry'), ('Diane'), ('Jose'), ('Julie'),
('Adam'), ('Joyce'), ('Douglas'), ('Victoria'), ('Nathan'), ('Kelly'),
('Peter'), ('Christina'), ('Zachary'), ('Joan'), ('Kyle'), ('Evelyn'),
('Walter'), ('Lauren'), ('Harold'), ('Judith'), ('Jeremy'), ('Olivia'),
('Ethan'), ('Frances'), ('Carl'), ('Martha'), ('Keith'), ('Cheryl'),
('Roger'), ('Megan'), ('Gerald'), ('Andrea'), ('Christian'), ('Hannah'),
('Terry'), ('Jacqueline'), ('Sean'), ('Ann'), ('Arthur'), ('Jean'),
('Austin'), ('Alice'), ('Noah'), ('Kathryn'), ('Lawrence'), ('Gloria'),
('Jesse'), ('Teresa'), ('Joe'), ('Doris'), ('Bryan'), ('Sara'),
('Billy'), ('Janice'), ('Jordan'), ('Marie'), ('Albert'), ('Julia'),
('Dylan'), ('Grace'), ('Bruce'), ('Judy'), ('Willie'), ('Theresa'),
('Gabriel'), ('Madison'), ('Alan'), ('Beverly'), ('Juan'), ('Denise'),
('Logan'), ('Marilyn'), ('Wayne'), ('Amber'), ('Ralph'), ('Danielle'),
('Roy'), ('Rose'), ('Eugene'), ('Brittany'), ('Randy'), ('Diana'),
('Vincent'), ('Abigail'), ('Russell'), ('Natalie'), ('Louis'), ('Jane'),
('Philip'), ('Lori'), ('Bobby'), ('Alexis'), ('Johnny'), ('Tiffany'),
('Bradley'), ('Kayla');

DECLARE @last_names TABLE (id INT IDENTITY, name NVARCHAR(50));
INSERT INTO @last_names (name) VALUES
('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'), ('Garcia'),
('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'), ('Hernandez'), ('Lopez'),
('Gonzalez'), ('Wilson'), ('Anderson'), ('Thomas'), ('Taylor'), ('Moore'),
('Jackson'), ('Martin'), ('Lee'), ('Perez'), ('Thompson'), ('White'),
('Harris'), ('Sanchez'), ('Clark'), ('Ramirez'), ('Lewis'), ('Robinson'),
('Walker'), ('Young'), ('Allen'), ('King'), ('Wright'), ('Scott'),
('Torres'), ('Nguyen'), ('Hill'), ('Flores'), ('Green'), ('Adams'),
('Nelson'), ('Baker'), ('Hall'), ('Rivera'), ('Campbell'), ('Mitchell'),
('Carter'), ('Roberts'), ('Gomez'), ('Phillips'), ('Evans'), ('Turner'),
('Diaz'), ('Parker'), ('Cruz'), ('Edwards'), ('Collins'), ('Reyes'),
('Stewart'), ('Morris'), ('Morales'), ('Murphy'), ('Cook'), ('Rogers'),
('Gutierrez'), ('Ortiz'), ('Morgan'), ('Cooper'), ('Peterson'), ('Bailey'),
('Reed'), ('Kelly'), ('Howard'), ('Ramos'), ('Kim'), ('Cox'),
('Ward'), ('Richardson'), ('Watson'), ('Brooks'), ('Chavez'), ('Wood'),
('James'), ('Bennett'), ('Gray'), ('Mendoza'), ('Ruiz'), ('Hughes'),
('Price'), ('Alvarez'), ('Castillo'), ('Sanders'), ('Patel'), ('Myers'),
('Long'), ('Ross'), ('Foster'), ('Jimenez'), ('Powell'), ('Jenkins'),
('Perry'), ('Russell'), ('Sullivan'), ('Bell'), ('Coleman'), ('Butler'),
('Henderson'), ('Barnes'), ('Gonzales'), ('Fisher'), ('Vasquez'), ('Simmons'),
('Romero'), ('Jordan'), ('Patterson'), ('Alexander'), ('Hamilton'), ('Graham'),
('Reynolds'), ('Griffin'), ('Wallace'), ('Moreno'), ('West'), ('Cole'),
('Hayes'), ('Bryant'), ('Herrera'), ('Gibson'), ('Ellis'), ('Tran'),
('Medina'), ('Aguilar'), ('Stevens'), ('Murray'), ('Ford'), ('Castro'),
('Marshall'), ('Owens'), ('Harrison'), ('Fernandez'), ('McDonald'), ('Woods'),
('Washington'), ('Kennedy'), ('Wells'), ('Vargas'), ('Henry'), ('Chen'),
('Freeman'), ('Webb'), ('Tucker'), ('Guzman'), ('Burns'), ('Crawford'),
('Olson'), ('Simpson'), ('Porter'), ('Hunter'), ('Gordon'), ('Mendez'),
('Silva'), ('Shaw'), ('Snyder'), ('Mason'), ('Dixon'), ('Munoz'),
('Hunt'), ('Hicks'), ('Holmes'), ('Palmer'), ('Wagner'), ('Black'),
('Robertson'), ('Boyd'), ('Rose'), ('Stone'), ('Salazar'), ('Fox'),
('Warren'), ('Mills'), ('Meyer'), ('Rice'), ('Schmidt'), ('Garza'),
('Daniels'), ('Ferguson'), ('Nichols'), ('Stephens'), ('Soto'), ('Weaver'),
('Ryan'), ('Gardner'), ('Payne'), ('Grant'), ('Dunn'), ('Kelley'),
('Spencer'), ('Hawkins'), ('Arnold'), ('Pierce'), ('Vazquez'), ('Hansen'),
('Peters'), ('Santos'), ('Hart'), ('Bradley'), ('Knight'), ('Elliott'),
('Cunningham'), ('Duncan'), ('Armstrong'), ('Hudson'), ('Carroll'), ('Lane'),
('Riley'), ('Andrews'), ('Alvarado'), ('Ray'), ('Delgado'), ('Berry'),
('Perkins'), ('Hoffman'), ('Johnston'), ('Matthews'), ('Pena'), ('Richards'),
('Contreras'), ('Willis'), ('Carpenter'), ('Lawrence'), ('Sandoval'),
('Guerrero'), ('George'), ('Chapman'), ('Rios'), ('Estrada'), ('Ortega'),
('Watkins'), ('Greene'), ('Nunez'), ('Wheeler'), ('Valdez'), ('Harper'),
('Burke'), ('Larson'), ('Santiago'), ('Maldonado'), ('Morrison'), ('Franklin'),
('Carlson'), ('Austin'), ('Dominguez'), ('Carr'), ('Lawson'), ('Jacobs'),
('Obrien'), ('Lynch'), ('Singh'), ('Vega'), ('Bishop'), ('Montgomery'),
('Oliver'), ('Jensen'), ('Harvey'), ('Williamson'), ('Gilbert'), ('Dean'),
('Sims'), ('Espinoza'), ('Howell'), ('Li'), ('Wong'), ('Reid'),
('Hanson'), ('Le'), ('McCoy'), ('Garrett'), ('Burton'), ('Fuller'),
('Wang'), ('Weber'), ('Welch'), ('Rojas'), ('Lucas'), ('Marquez'),
('Fields'), ('Park'), ('Yang'), ('Little'), ('Banks'), ('Padilla'),
('Day'), ('Walsh'), ('Bowman'), ('Schultz'), ('Luna'), ('Fowler'),
('Mejia'), ('Davidson'), ('Acosta'), ('Brewer'), ('May'), ('Holland'),
('Juarez'), ('Newman'), ('Pearson'), ('Curtis'), ('Cortez'), ('Douglas'),
('Schneider'), ('Joseph'), ('Barrett'), ('Navarro'), ('Figueroa'), ('Keller'),
('Avila'), ('Wade'), ('Molina'), ('Stanley'), ('Hopkins'), ('Campos'),
('Barnett'), ('Bates'), ('Chambers'), ('Caldwell'), ('Beck'), ('Lambert'),
('Miranda'), ('Byrd'), ('Craig'), ('Ayala'), ('Lowe'), ('Frazier'),
('Powers'), ('Neal'), ('Leonard'), ('Gregory'), ('Carrillo'), ('Sutton'),
('Fleming'), ('Rhodes'), ('Shelton'), ('Walton'), ('Cohen'), ('Kirk'),
('Mann'), ('Terry'), ('Huff'), ('Burgess'), ('Lawson'), ('Owen'), ('Norris'), ('Dawson'), ('Thornton');

DECLARE @institutions TABLE (id INT IDENTITY, name NVARCHAR(150));
INSERT INTO @institutions (name) VALUES
('Massachusetts Institute of Technology'),
('Stanford University'),
('Harvard University'),
('University of Cambridge'),
('University of Oxford'),
('California Institute of Technology'),
('ETH Zurich'),
('University of Chicago'),
('Imperial College London'),
('University of Pennsylvania'),
('Johns Hopkins University'),
('Yale University'),
('University of California, Berkeley'),
('Princeton University'),
('Columbia University'),
('University of California, Los Angeles'),
('University of Toronto'),
('University of Michigan'),
('University of Washington'),
('Cornell University'),
('University of Edinburgh'),
('University of Melbourne'),
('National University of Singapore'),
('University of Tokyo'),
('Kyoto University'),
('Taras Shevchenko National University of Kyiv'),
('Lviv Polytechnic National University'),
('Kyiv Polytechnic Institute'),
('University of Warsaw'),
('Jagiellonian University'),
('Charles University'),
('University of Vienna'),
('Technical University of Munich'),
('University of Heidelberg'),
('Sorbonne University'),
('University of Paris'),
('University of Barcelona'),
('University of Amsterdam'),
('University of Copenhagen'),
('University of Helsinki'),
('University of Oslo'),
('Stockholm University'),
('University of Zurich'),
('University of Geneva'),
('University of Brussels');

DECLARE @countries TABLE (id INT IDENTITY, name NVARCHAR(50));
INSERT INTO @countries (name) VALUES
('USA'), ('UK'), ('Canada'), ('Australia'), ('Germany'),
('France'), ('Italy'), ('Spain'), ('Netherlands'), ('Sweden'),
('Norway'), ('Denmark'), ('Finland'), ('Switzerland'), ('Austria'),
('Poland'), ('Ukraine'), ('Japan'), ('South Korea'), ('China'),
('India'), ('Singapore'), ('Brazil'), ('Mexico'), ('Argentina'),
('South Africa'), ('Egypt'), ('Israel'), ('Turkey'), ('Russia');

DECLARE @degrees TABLE (id INT IDENTITY, degree VARCHAR(30), weight INT);
INSERT INTO @degrees (degree, weight) VALUES
('PhD', 30),
('Professor', 15),
('Associate Professor', 12),
('Assistant Professor', 10),
('Researcher', 10),
('PhD Candidate', 15),
('Master', 5),
('Bachelor', 2),
('Student', 1);

-- Generate 20,000 records in batches
WHILE @rows_inserted < @total_rows
BEGIN
    -- Calculate how many to insert in this batch
    DECLARE @remaining INT = @total_rows - @rows_inserted;
    DECLARE @current_batch INT = CASE WHEN @remaining < @batch_size THEN @remaining ELSE @batch_size END;
    
    -- Generate sequential numbers for this batch
    ;WITH BatchNumbers AS (
        SELECT TOP (@current_batch) 
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as seq_num,
            NEWID() as random_id
        FROM sys.all_columns a 
        CROSS JOIN sys.all_columns b
    )
    INSERT INTO Presenters (
        first_name,
        last_name,
        email,
        institution,
        academic_degree,
        country,
        registration_date,
        is_active
    )
    SELECT 
        -- First name
        fn.name,
        
        -- Last name
        ln.name,
        
        -- Email (unique based on sequential number)
        LOWER(LEFT(fn.name, 1)) + LOWER(ln.name) + 
        CAST((@rows_inserted + bn.seq_num) AS VARCHAR) + '@' +
        CASE WHEN (@rows_inserted + bn.seq_num) % 5 = 0 THEN 'gmail.com'
             WHEN (@rows_inserted + bn.seq_num) % 5 = 1 THEN 'yahoo.com'
             WHEN (@rows_inserted + bn.seq_num) % 5 = 2 THEN 'outlook.com'
             WHEN (@rows_inserted + bn.seq_num) % 5 = 3 THEN 'university.edu'
             ELSE 'research.org' END,
        
        -- Institution
        i.name,
        
        -- Academic degree (with weights)
        d.degree,
        
        -- Country
        c.name,
        
        -- Registration date (last 3 years)
        DATEADD(DAY, -ABS(CHECKSUM(bn.random_id)) % 1095, GETDATE()),
        
        -- Activity (90% active)
        CASE WHEN ABS(CHECKSUM(bn.random_id)) % 100 < 90 THEN 1 ELSE 0 END
    
    FROM BatchNumbers bn
    CROSS APPLY (
        SELECT name FROM @first_names 
        WHERE id = (ABS(CHECKSUM(bn.random_id)) % 100) + 1
    ) fn
    CROSS APPLY (
        SELECT name FROM @last_names 
        WHERE id = (ABS(CHECKSUM(bn.random_id)) % 100) + 1
    ) ln
    CROSS APPLY (
        SELECT name FROM @institutions 
        WHERE id = (ABS(CHECKSUM(bn.random_id)) % 45) + 1
    ) i
    CROSS APPLY (
        SELECT degree FROM (
            SELECT degree, 
                   SUM(weight) OVER (ORDER BY id) as cumulative_weight
            FROM @degrees
        ) t
        WHERE cumulative_weight >= (ABS(CHECKSUM(bn.random_id)) % 100) + 1
        ORDER BY cumulative_weight
        OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY
    ) d
    CROSS APPLY (
        SELECT name FROM @countries 
        WHERE id = (ABS(CHECKSUM(bn.random_id)) % 30) + 1
    ) c;
    
    -- Update counters
    SET @rows_inserted = @rows_inserted + @current_batch;
    SET @batch_num = @batch_num + 1;
    
    -- Progress every 5,000 records
    IF @rows_inserted % 5000 = 0
    BEGIN
        PRINT 'Generated ' + CAST(@rows_inserted AS VARCHAR) + ' presenters...';
    END
END

DECLARE @end_time DATETIME = GETDATE();
DECLARE @duration INT = DATEDIFF(SECOND, @start_time, @end_time);
DECLARE @actual_count INT = (SELECT COUNT(*) FROM Presenters);

PRINT '=========================================';
PRINT 'Generation finished!';
PRINT 'Target count: ' + CAST(@total_rows AS VARCHAR);
PRINT 'Actual count: ' + CAST(@actual_count AS VARCHAR);
PRINT 'Number of batches: ' + CAST(@batch_num AS VARCHAR);
PRINT 'Duration: ' + CAST(@duration AS VARCHAR) + ' seconds';
IF @duration > 0
    PRINT 'Average speed: ' + CAST(CAST(@actual_count AS FLOAT) / @duration AS DECIMAL(10,2)) + ' records/sec';
PRINT '=========================================';
GO

-- Check results
SELECT 
    COUNT(*) as TotalPresenters,
    COUNT(DISTINCT email) as UniqueEmails,
    COUNT(DISTINCT country) as CountriesRepresented,
    COUNT(DISTINCT institution) as InstitutionsRepresented,
    academic_degree,
    COUNT(*) as CountByDegree,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) as Percentage
FROM Presenters
GROUP BY academic_degree
ORDER BY CountByDegree DESC;
GO