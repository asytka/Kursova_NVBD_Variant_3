USE ConferenceDB;
GO

-- 1. Процедура для отримання розкладу конференції
CREATE PROCEDURE sp_GetConferenceSchedule
    @conference_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.title as ConferenceTitle,
        s.section_name as SectionName,
        s.section_date as Date,
        s.start_time as StartTime,
        s.end_time as EndTime,
        r.room_number as Room,
        CONCAT(p.first_name, ' ', p.last_name) as Chairperson,
        pr.title as PresentationTitle,
        CONCAT(pr2.first_name, ' ', pr2.last_name) as Presenter,
        pr.start_time as PresentationTime,
        pr.duration_minutes as Duration
    FROM Conferences c
    INNER JOIN Sections s ON c.conference_id = s.conference_id
    LEFT JOIN Rooms r ON s.room_id = r.room_id
    LEFT JOIN Presenters p ON s.chairperson_id = p.presenter_id
    LEFT JOIN Presentations pr ON s.section_id = pr.section_id
    LEFT JOIN Presenters pr2 ON pr.presenter_id = pr2.presenter_id
    WHERE c.conference_id = @conference_id
    ORDER BY s.section_date, s.start_time, pr.start_time;
END
GO

-- 2. Процедура для пошуку виступаючих за країною та ступенем
CREATE PROCEDURE sp_FindPresentersByCriteria
    @country NVARCHAR(50) = NULL,
    @degree VARCHAR(30) = NULL,
    @institution NVARCHAR(150) = NULL,
    @page INT = 1,
    @page_size INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @offset INT = (@page - 1) * @page_size;
    
    SELECT 
        presenter_id,
        CONCAT(first_name, ' ', last_name) as FullName,
        email,
        institution,
        academic_degree,
        country,
        registration_date
    FROM Presenters
    WHERE (@country IS NULL OR country = @country)
        AND (@degree IS NULL OR academic_degree = @degree)
        AND (@institution IS NULL OR institution LIKE '%' + @institution + '%')
        AND is_active = 1
    ORDER BY last_name, first_name
    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
    
    -- Повернути загальну кількість для пагінації
    SELECT COUNT(*) as TotalCount
    FROM Presenters
    WHERE (@country IS NULL OR country = @country)
        AND (@degree IS NULL OR academic_degree = @degree)
        AND (@institution IS NULL OR institution LIKE '%' + @institution + '%')
        AND is_active = 1;
END
GO

-- 3. Процедура для резервування обладнання
CREATE PROCEDURE sp_ReserveEquipment
    @section_id INT,
    @equipment_id INT,
    @quantity INT,
    @rental_date DATE,
    @return_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    BEGIN TRY
        -- Перевірка доступності обладнання
        DECLARE @available INT;
        SELECT @available = available_quantity 
        FROM Equipment 
        WHERE equipment_id = @equipment_id;
        
        IF @available < @quantity
        BEGIN
            RAISERROR('Недостатня кількість обладнання. Доступно: %d', 16, 1, @available);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Додавання резервації
        INSERT INTO SectionEquipment (section_id, equipment_id, quantity_needed, rental_date, return_date)
        VALUES (@section_id, @equipment_id, @quantity, @rental_date, @return_date);
        
        -- Оновлення доступної кількості
        UPDATE Equipment 
        SET available_quantity = available_quantity - @quantity 
        WHERE equipment_id = @equipment_id;
        
        COMMIT TRANSACTION;
        PRINT 'Обладнання успішно зарезервовано.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

-- 4. Процедура для статистики конференції
CREATE PROCEDURE sp_GetConferenceStatistics
    @conference_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        c.title as ConferenceTitle,
        COUNT(DISTINCT s.section_id) as TotalSections,
        COUNT(DISTINCT pr.presentation_id) as TotalPresentations,
        COUNT(DISTINCT p.presenter_id) as TotalPresenters,
        COUNT(DISTINCT r.room_id) as RoomsUsed,
        SUM(pr.duration_minutes) as TotalMinutes,
        AVG(pr.duration_minutes) as AvgDuration,
        MIN(pr.start_time) as EarliestStart,
        MAX(DATEADD(MINUTE, pr.duration_minutes, pr.start_time)) as LatestEnd,
        COUNT(DISTINCT p.country) as CountriesRepresented
    FROM Conferences c
    LEFT JOIN Sections s ON c.conference_id = s.conference_id
    LEFT JOIN Presentations pr ON s.section_id = pr.section_id
    LEFT JOIN Presenters p ON pr.presenter_id = p.presenter_id
    LEFT JOIN Rooms r ON s.room_id = r.room_id
    WHERE c.conference_id = @conference_id
    GROUP BY c.title;
END
GO

-- 5. Функція для розрахунку завантаженості приміщення
CREATE FUNCTION fn_CalculateRoomUtilization
    (
        @room_id INT,
        @start_date DATE,
        @end_date DATE
    )
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_minutes DECIMAL(10,2);
    DECLARE @available_minutes DECIMAL(10,2);
    DECLARE @utilization DECIMAL(5,2);
    
    -- Розрахунок зайнятих хвилин
    SELECT @total_minutes = SUM(DATEDIFF(MINUTE, start_time, end_time))
    FROM Sections
    WHERE room_id = @room_id
        AND section_date BETWEEN @start_date AND @end_date
        AND start_time IS NOT NULL AND end_time IS NOT NULL;
    
    -- Доступні хвилини (9:00-18:00, 9 годин = 540 хвилин на день)
    SET @available_minutes = 540 * (DATEDIFF(DAY, @start_date, @end_date) + 1);
    
    -- Розрахунок утилізації
    IF @available_minutes > 0
        SET @utilization = ROUND((@total_minutes / @available_minutes) * 100, 2);
    ELSE
        SET @utilization = 0;
    
    RETURN @utilization;
END
GO

-- 6. Функція для перевірки доступності виступаючого
CREATE FUNCTION fn_CheckPresenterAvailability
    (
        @presenter_id INT,
        @check_date DATE,
        @start_time TIME,
        @duration_minutes INT
    )
RETURNS BIT
AS
BEGIN
    DECLARE @end_time TIME = DATEADD(MINUTE, @duration_minutes, @start_time);
    DECLARE @is_available BIT = 1;
    
    IF EXISTS (
        SELECT 1
        FROM Presentations p
        INNER JOIN Sections s ON p.section_id = s.section_id
        WHERE p.presenter_id = @presenter_id
            AND s.section_date = @check_date
            AND (
                (@start_time BETWEEN p.start_time AND DATEADD(MINUTE, p.duration_minutes, p.start_time)) OR
                (@end_time BETWEEN p.start_time AND DATEADD(MINUTE, p.duration_minutes, p.start_time)) OR
                (p.start_time BETWEEN @start_time AND @end_time)
            )
    )
    BEGIN
        SET @is_available = 0;
    END
    
    RETURN @is_available;
END
GO

PRINT 'Procedures successfuly created.';
GO