-- ============================================
-- Спрощений скрипт створення бази даних
-- Використовує стандартні шляхи SQL Server
-- ============================================

USE master;
GO

-- Перевірка існування БД та її видалення
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'ConferenceDB')
BEGIN
    -- Відключаємо всі підключення до БД
    ALTER DATABASE ConferenceDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ConferenceDB;
    PRINT 'Existing database deleted';
END
GO

-- Створення нової БД з стандартними шляхами
CREATE DATABASE ConferenceDB;
GO

-- Налаштування БД
USE ConferenceDB;
GO

ALTER DATABASE ConferenceDB SET RECOVERY SIMPLE;
ALTER DATABASE ConferenceDB SET AUTO_CREATE_STATISTICS ON;
ALTER DATABASE ConferenceDB SET AUTO_UPDATE_STATISTICS ON;
GO

PRINT 'ConferenceDB created successfuly';
GO