USE ConferenceDB;
GO

PRINT 'Завершення налаштування...';
GO

-- Увімкнути тригери
ENABLE TRIGGER ALL ON Conferences;
ENABLE TRIGGER ALL ON Presenters;
ENABLE TRIGGER ALL ON Rooms;
ENABLE TRIGGER ALL ON Equipment;
ENABLE TRIGGER ALL ON Sections;
ENABLE TRIGGER ALL ON Presentations;
ENABLE TRIGGER ALL ON SectionEquipment;
GO

-- Увімкнути обмеження цілісності
ALTER TABLE Sections CHECK CONSTRAINT ALL;
ALTER TABLE Presentations CHECK CONSTRAINT ALL;
ALTER TABLE SectionEquipment CHECK CONSTRAINT ALL;
GO

-- Оновити статистику для оптимізатора запитів
EXEC sp_updatestats;
GO

-- Перевірка цілісності даних
DBCC CHECKDB ('ConferenceDB') WITH NO_INFOMSGS;
GO

-- Перевірка загальних результатів
PRINT '=========================================';
PRINT 'ПІДСУМОК ГЕНЕРАЦІЇ ДАНИХ';
PRINT '=========================================';
PRINT 'Таблиця              | Кількість записів';
PRINT '-----------------------------------------';

DECLARE @conf_count INT, @pres_count INT, @room_count INT, @equip_count INT,
        @sect_count INT, @pres_count2 INT, @se_count INT;

SELECT @conf_count = COUNT(*) FROM Conferences;
SELECT @pres_count = COUNT(*) FROM Presenters;
SELECT @room_count = COUNT(*) FROM Rooms;
SELECT @equip_count = COUNT(*) FROM Equipment;
SELECT @sect_count = COUNT(*) FROM Sections;
SELECT @pres_count2 = COUNT(*) FROM Presentations;
SELECT @se_count = COUNT(*) FROM SectionEquipment;

PRINT 'Conferences          | ' + CAST(@conf_count AS VARCHAR);
PRINT 'Presenters           | ' + CAST(@pres_count AS VARCHAR);
PRINT 'Rooms                | ' + CAST(@room_count AS VARCHAR);
PRINT 'Equipment            | ' + CAST(@equip_count AS VARCHAR);
PRINT 'Sections             | ' + CAST(@sect_count AS VARCHAR);
PRINT 'Presentations        | ' + CAST(@pres_count2 AS VARCHAR);
PRINT 'SectionEquipment     | ' + CAST(@se_count AS VARCHAR);
PRINT '-----------------------------------------';

DECLARE @total INT = @conf_count + @pres_count + @room_count + @equip_count + 
                     @sect_count + @pres_count2 + @se_count;
PRINT 'ЗАГАЛЬНА КІЛЬКІСТЬ   | ' + CAST(@total AS VARCHAR);
PRINT '=========================================';

-- Перевірка foreign key constraints
PRINT 'Перевірка foreign key constraints...';

IF EXISTS (
    SELECT 1 FROM Sections s
    LEFT JOIN Conferences c ON s.conference_id = c.conference_id
    WHERE c.conference_id IS NULL
)
BEGIN
    PRINT '❌ Помилка: Знайдено секції без відповідних конференцій';
END
ELSE
BEGIN
    PRINT 'Секції: всі мають валідні conference_id';
END

IF EXISTS (
    SELECT 1 FROM Presentations p
    LEFT JOIN Sections s ON p.section_id = s.section_id
    WHERE s.section_id IS NULL
)
BEGIN
    PRINT 'Помилка: Знайдено виступи без відповідних секцій';
END
ELSE
BEGIN
    PRINT 'Виступи: всі мають валідні section_id';
END

IF EXISTS (
    SELECT 1 FROM SectionEquipment se
    LEFT JOIN Sections s ON se.section_id = s.section_id
    WHERE s.section_id IS NULL
)
BEGIN
    PRINT 'Помилка: Знайдено зв'язки секція-обладнання без відповідних секцій';
END
ELSE
BEGIN
    PRINT 'SectionEquipment: всі мають валідні section_id';
END

PRINT '=========================================';
PRINT 'Генерація даних успішно завершена!';
PRINT 'База даних готова до використання.';
PRINT '=========================================';
GO