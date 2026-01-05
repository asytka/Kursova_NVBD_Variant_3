USE ConferenceDB;
GO

-- Вимкнути тригери для швидкої генерації
DISABLE TRIGGER ALL ON Conferences;
DISABLE TRIGGER ALL ON Presenters;
DISABLE TRIGGER ALL ON Rooms;
DISABLE TRIGGER ALL ON Equipment;
DISABLE TRIGGER ALL ON Sections;
DISABLE TRIGGER ALL ON Presentations;
DISABLE TRIGGER ALL ON SectionEquipment;
GO

-- Вимкнути обмеження цілісності
ALTER TABLE Sections NOCHECK CONSTRAINT ALL;
ALTER TABLE Presentations NOCHECK CONSTRAINT ALL;
ALTER TABLE SectionEquipment NOCHECK CONSTRAINT ALL;
GO

-- Очистити всі таблиці (якщо потрібно)
/*
DELETE FROM SectionEquipment;
DELETE FROM Presentations;
DELETE FROM Sections;
DELETE FROM Equipment;
DELETE FROM Rooms;
DELETE FROM Presenters;
DELETE FROM Conferences;

DBCC CHECKIDENT ('Conferences', RESEED, 0);
DBCC CHECKIDENT ('Presenters', RESEED, 0);
DBCC CHECKIDENT ('Rooms', RESEED, 0);
DBCC CHECKIDENT ('Equipment', RESEED, 0);
DBCC CHECKIDENT ('Sections', RESEED, 0);
DBCC CHECKIDENT ('Presentations', RESEED, 0);
*/
GO

PRINT ' Envinronment ready for data generation.';
GO