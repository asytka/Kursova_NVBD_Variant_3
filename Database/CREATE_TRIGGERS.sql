USE ConferenceDB;
GO

-- Тригер для автоматичного оновлення last_updated в Conferences
CREATE TRIGGER TR_Conferences_UpdateDate
ON Conferences
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE c
    SET last_updated = GETDATE()
    FROM Conferences c
    INNER JOIN inserted i ON c.conference_id = i.conference_id;
END
GO

-- Тригер для перевірки доступності обладнання
CREATE TRIGGER TR_SectionEquipment_CheckAvailability
ON SectionEquipment
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Перевірка чи є достатня кількість обладнання
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Equipment e ON i.equipment_id = e.equipment_id
        WHERE i.quantity_needed > e.available_quantity
    )
    BEGIN
        RAISERROR('Error', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Оновлення доступної кількості обладнання
    UPDATE e
    SET available_quantity = e.available_quantity - i.quantity_needed
    FROM Equipment e
    INNER JOIN inserted i ON e.equipment_id = i.equipment_id
    WHERE NOT EXISTS (
        SELECT 1 FROM deleted d 
        WHERE d.equipment_id = e.equipment_id 
        AND d.section_id = i.section_id
    );
    
    -- Відновлення кількості при видаленні запису
    UPDATE e
    SET available_quantity = e.available_quantity + d.quantity_needed
    FROM Equipment e
    INNER JOIN deleted d ON e.equipment_id = d.equipment_id
    WHERE NOT EXISTS (
        SELECT 1 FROM inserted i 
        WHERE i.equipment_id = e.equipment_id 
        AND i.section_id = d.section_id
    ) AND d.quantity_needed IS NOT NULL;
END
GO

-- Тригер для перевірки конфліктів розкладу в приміщенні
CREATE TRIGGER TR_Sections_CheckScheduleConflict
ON Sections
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Sections s ON i.room_id = s.room_id 
            AND i.section_date = s.section_date
            AND i.section_id != s.section_id
        WHERE (
            (i.start_time BETWEEN s.start_time AND s.end_time) OR
            (i.end_time BETWEEN s.start_time AND s.end_time) OR
            (s.start_time BETWEEN i.start_time AND i.end_time)
        ) AND i.room_id IS NOT NULL
    )
    BEGIN
        RAISERROR('Error', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- Тригер для автоматичного оновлення кількості учасників
CREATE TRIGGER TR_Presentations_UpdateParticipantCount
ON Presentations
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Оновлення для вставлених записів
    UPDATE s
    SET max_participants = ISNULL(s.max_participants, 0) + 
        (SELECT COUNT(*) FROM inserted i WHERE i.section_id = s.section_id)
    FROM Sections s
    WHERE s.section_id IN (SELECT section_id FROM inserted);
    
    -- Оновлення для видалених записів
    UPDATE s
    SET max_participants = ISNULL(s.max_participants, 0) - 
        (SELECT COUNT(*) FROM deleted d WHERE d.section_id = s.section_id)
    FROM Sections s
    WHERE s.section_id IN (SELECT section_id FROM deleted);
END
GO

-- Тригер для ведення історії змін
CREATE TRIGGER TR_Conferences_Audit
ON Conferences
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO ConferenceAudit (
        conference_id, old_status, new_status, 
        change_date, changed_by
    )
    SELECT 
        i.conference_id,
        d.status as old_status,
        i.status as new_status,
        GETDATE(),
        SYSTEM_USER
    FROM inserted i
    INNER JOIN deleted d ON i.conference_id = d.conference_id
    WHERE i.status != d.status;
END
GO

-- Створення таблиці для аудиту (якщо ще не існує)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ConferenceAudit')
BEGIN
    CREATE TABLE ConferenceAudit (
        audit_id INT IDENTITY(1,1) PRIMARY KEY,
        conference_id INT NOT NULL,
        old_status VARCHAR(20),
        new_status VARCHAR(20),
        change_date DATETIME DEFAULT GETDATE(),
        changed_by VARCHAR(100)
    );
END
GO

PRINT 'Triggers successfuly created.';
GO