-- ============================================
-- File: 02_CREATE_DIMENSION_TABLES.sql
-- Description: Creates all dimension tables for star schema
-- Author: [Your Name]
-- ============================================

USE ConferenceDW;
GO

PRINT 'Creating dimension tables...';
PRINT '';

-- 1. TIME DIMENSION (Most Important!)
PRINT 'Creating DimTime table...';
CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY IDENTITY(1,1),
    FullDate DATE NOT NULL,
    DayNumber INT NOT NULL,           -- Day of month (1-31)
    DayName VARCHAR(20) NOT NULL,     -- Monday, Tuesday, etc.
    WeekNumber INT NOT NULL,          -- Week of year (1-52)
    MonthNumber INT NOT NULL,         -- Month (1-12)
    MonthName VARCHAR(20) NOT NULL,   -- January, February, etc.
    Quarter INT NOT NULL,             -- Quarter (1-4)
    Year INT NOT NULL,                -- Year (2020, 2021, etc.)
    IsWeekend BIT NOT NULL,           -- 1 if Saturday/Sunday
    IsHoliday BIT NOT NULL DEFAULT 0, -- 1 if holiday
    FiscalYear INT NULL,              -- Fiscal year (if different)
    Season VARCHAR(20) NULL,          -- Spring, Summer, Fall, Winter
    
    -- Surrogate key pattern for data warehousing
    CONSTRAINT AK_DimTime_Date UNIQUE (FullDate)
);
PRINT 'DimTime table created.';
PRINT '';

-- 2. CONFERENCE DIMENSION
PRINT 'Creating DimConference table...';
CREATE TABLE DimConference (
    ConferenceKey INT PRIMARY KEY IDENTITY(1,1),
    ConferenceID INT NOT NULL,               -- Business key from source
    ConferenceName VARCHAR(200) NOT NULL,
    ConferenceCode VARCHAR(50) NULL,         -- Short code like "AI-2024"
    Topic VARCHAR(100) NOT NULL,             -- Main topic
    Location VARCHAR(200) NOT NULL,          -- City, Country
    Venue VARCHAR(150) NULL,                 -- Specific venue name
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DurationDays INT NOT NULL,               -- Calculated field
    IsInternational BIT NOT NULL DEFAULT 0,  -- International conference?
    RegistrationFee DECIMAL(10,2) NULL,      -- Fee amount
    Organizer VARCHAR(200) NULL,             -- Organizing institution
    
    -- Slowly Changing Dimension (SCD) Type 2 columns
    IsCurrent BIT NOT NULL DEFAULT 1,        -- 1 for current record
    StartDateSCD DATETIME NOT NULL DEFAULT GETDATE(),  -- When this version started
    EndDateSCD DATETIME NULL,                -- When this version ended
    LoadDate DATETIME NOT NULL DEFAULT GETDATE(),      -- When loaded to DW
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT AK_DimConference_Business UNIQUE (ConferenceID, StartDateSCD)
);
PRINT 'DimConference table created.';
PRINT '';

-- 3. PRESENTER DIMENSION
PRINT 'Creating DimPresenter table...';
CREATE TABLE DimPresenter (
    PresenterKey INT PRIMARY KEY IDENTITY(1,1),
    PresenterID INT NOT NULL,                -- Business key from source
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    FullName AS (FirstName + ' ' + LastName), -- Computed column
    Email VARCHAR(150) NULL,
    Phone VARCHAR(50) NULL,
    AcademicDegree VARCHAR(50) NOT NULL,     -- PhD, MSc, Professor, etc.
    Position VARCHAR(100) NULL,              -- Job title
    University VARCHAR(200) NULL,
    Department VARCHAR(150) NULL,
    Country VARCHAR(100) NULL,
    City VARCHAR(100) NULL,
    ExperienceYears INT NULL,                -- Years of experience
    PublicationsCount INT NULL DEFAULT 0,    -- Number of publications
    HIndex INT NULL DEFAULT 0,               -- Academic H-index
    
    -- SCD Type 2 for presenter changes (if they change university, etc.)
    IsCurrent BIT NOT NULL DEFAULT 1,
    StartDateSCD DATETIME NOT NULL DEFAULT GETDATE(),
    EndDateSCD DATETIME NULL,
    LoadDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT AK_DimPresenter_Business UNIQUE (PresenterID, StartDateSCD)
);
PRINT 'DimPresenter table created.';
PRINT '';

-- 4. ROOM DIMENSION
PRINT 'Creating DimRoom table...';
CREATE TABLE DimRoom (
    RoomKey INT PRIMARY KEY IDENTITY(1,1),
    RoomID INT NOT NULL,                     -- Business key from source
    RoomName VARCHAR(100) NOT NULL,
    RoomNumber VARCHAR(20) NULL,
    Building VARCHAR(100) NOT NULL,
    Floor INT NULL,
    Capacity INT NOT NULL,
    RoomType VARCHAR(50) NULL,               -- Auditorium, Classroom, Lab, etc.
    HasProjector BIT NOT NULL DEFAULT 0,
    HasWhiteboard BIT NOT NULL DEFAULT 0,
    HasInternet BIT NOT NULL DEFAULT 1,
    HasMicrophone BIT NOT NULL DEFAULT 0,
    HasVideoConference BIT NOT NULL DEFAULT 0,
    IsAccessible BIT NOT NULL DEFAULT 1,     -- Wheelchair accessible
    HourlyRate DECIMAL(10,2) NULL,           -- Cost per hour if applicable
    
    LoadDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT AK_DimRoom_Business UNIQUE (RoomID)
);
PRINT 'DimRoom table created.';
PRINT '';

-- 5. SECTION DIMENSION
PRINT 'Creating DimSection table...';
CREATE TABLE DimSection (
    SectionKey INT PRIMARY KEY IDENTITY(1,1),
    SectionID INT NOT NULL,                  -- Business key from source
    SectionType VARCHAR(50) NOT NULL,        -- Plenary, Workshop, etc.
    Topic VARCHAR(100) NOT NULL,
    MaxParticipants INT NOT NULL,
    DifficultyLevel VARCHAR(20) NULL,        -- Beginner, Intermediate, Advanced
    Language VARCHAR(50) NULL DEFAULT 'English',
    IsInteractive BIT NOT NULL DEFAULT 0,    -- Workshop with exercises?
    RequiresRegistration BIT NOT NULL DEFAULT 1,
    
    LoadDate DATETIME NOT NULL DEFAULT GETDATE(),
    UpdateDate DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT AK_DimSection_Business UNIQUE (SectionID)
);
PRINT 'DimSection table created.';
PRINT '';

PRINT 'All dimension tables created successfully!';
PRINT '=========================================';
GO