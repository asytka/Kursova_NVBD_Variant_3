-- ============================================
-- File: 03_CREATE_FACT_TABLES.sql
-- Description: Creates fact tables for Data Warehouse
-- Author: [Your Name]
-- ============================================

USE ConferenceDW;
GO

PRINT 'Creating fact tables...';
PRINT '';

-- FACT TABLE 1: PRESENTATIONS (Main fact table)
PRINT 'Creating FactPresentations table...';
CREATE TABLE FactPresentations (
    PresentationKey INT PRIMARY KEY IDENTITY(1,1),
    
    -- Foreign Keys (Connections to dimensions)
    TimeKey INT NOT NULL,                    -- When did it happen?
    ConferenceKey INT NOT NULL,              -- Which conference?
    PresenterKey INT NOT NULL,               -- Who presented?
    RoomKey INT NOT NULL,                    -- Where was it?
    SectionKey INT NOT NULL,                 -- What type of session?
    
    -- Degenerate Dimension (if needed)
    PresentationCode VARCHAR(50) NULL,       -- Business code like "P-001"
    
    -- MEASURES (Numbers you can analyze/sum/average)
    DurationMinutes INT NOT NULL,            -- Presentation duration in minutes
    ActualParticipants INT NOT NULL,         -- How many people attended
    RegisteredParticipants INT NOT NULL,     -- How many registered
    AttendanceRate AS (CAST(ActualParticipants AS FLOAT) / 
                      NULLIF(RegisteredParticipants, 0)), -- Calculated measure
    EquipmentCost DECIMAL(10,2) NOT NULL DEFAULT 0.00,    -- Cost of equipment used
    SpeakerFee DECIMAL(10,2) NULL,           -- Fee paid to presenter
    IsKeynote BIT NOT NULL DEFAULT 0,        -- Was this a keynote presentation?
    ParticipantRating DECIMAL(3,2) NULL,     -- Rating 1.00-5.00
    QuestionsAsked INT NULL DEFAULT 0,       -- Number of questions during Q&A
    MaterialsDistributed INT NULL DEFAULT 0, -- Handouts, etc.
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactPresentations_Time 
        FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey),
    CONSTRAINT FK_FactPresentations_Conference 
        FOREIGN KEY (ConferenceKey) REFERENCES DimConference(ConferenceKey),
    CONSTRAINT FK_FactPresentations_Presenter 
        FOREIGN KEY (PresenterKey) REFERENCES DimPresenter(PresenterKey),
    CONSTRAINT FK_FactPresentations_Room 
        FOREIGN KEY (RoomKey) REFERENCES DimRoom(RoomKey),
    CONSTRAINT FK_FactPresentations_Section 
        FOREIGN KEY (SectionKey) REFERENCES DimSection(SectionKey),
    
    -- Check constraints for data quality
    CONSTRAINT CHK_FactPresentations_Duration 
        CHECK (DurationMinutes BETWEEN 15 AND 480),  -- 15min to 8 hours
    CONSTRAINT CHK_FactPresentations_Rating 
        CHECK (ParticipantRating BETWEEN 1.00 AND 5.00 OR ParticipantRating IS NULL),
    CONSTRAINT CHK_FactPresentations_Participants 
        CHECK (ActualParticipants >= 0 AND RegisteredParticipants >= 0)
);
PRINT 'FactPresentations table created.';
PRINT '';

-- FACT TABLE 2: CONFERENCE ATTENDANCE (Aggregate level)
PRINT 'Creating FactConferenceAttendance table...';
CREATE TABLE FactConferenceAttendance (
    AttendanceKey INT PRIMARY KEY IDENTITY(1,1),
    
    -- Foreign Keys
    TimeKey INT NOT NULL,                    -- Day of attendance
    ConferenceKey INT NOT NULL,              -- Which conference
    
    -- MEASURES
    TotalRegistrations INT NOT NULL DEFAULT 0,
    ActualAttendees INT NOT NULL DEFAULT 0,
    VIPCount INT NOT NULL DEFAULT 0,         -- VIP/Keynote attendees
    InternationalAttendees INT NOT NULL DEFAULT 0,
    StudentAttendees INT NOT NULL DEFAULT 0,
    EarlyBirdRegistrations INT NOT NULL DEFAULT 0,
    OnSiteRegistrations INT NOT NULL DEFAULT 0,
    
    -- Financial measures
    RegistrationRevenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    SponsorshipRevenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    OtherRevenue DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    TotalRevenue AS (RegistrationRevenue + SponsorshipRevenue + OtherRevenue),
    
    -- Cost measures
    VenueCost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    SpeakerCost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    MarketingCost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    OtherCost DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    TotalCost AS (VenueCost + SpeakerCost + MarketingCost + OtherCost),
    
    -- Calculated profit
    NetProfit AS ((RegistrationRevenue + SponsorshipRevenue + OtherRevenue) 
                  - (VenueCost + SpeakerCost + MarketingCost + OtherCost)),
    
    -- Satisfaction measures
    AverageRating DECIMAL(3,2) NULL,
    SurveyResponseRate DECIMAL(5,2) NULL,    -- Percentage
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactAttendance_Time 
        FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey),
    CONSTRAINT FK_FactAttendance_Conference 
        FOREIGN KEY (ConferenceKey) REFERENCES DimConference(ConferenceKey),
    
    -- Check constraints
    CONSTRAINT CHK_FactAttendance_Attendees 
        CHECK (ActualAttendees <= TotalRegistrations),
    CONSTRAINT CHK_FactAttendance_Revenue 
        CHECK (RegistrationRevenue >= 0 AND SponsorshipRevenue >= 0)
);
PRINT 'FactConferenceAttendance table created.';
PRINT '';

-- FACT TABLE 3: EQUIPMENT USAGE (Optional - shows complexity)
PRINT 'Creating FactEquipmentUsage table...';
CREATE TABLE FactEquipmentUsage (
    UsageKey INT PRIMARY KEY IDENTITY(1,1),
    
    -- Foreign Keys
    TimeKey INT NOT NULL,
    ConferenceKey INT NOT NULL,
    RoomKey INT NOT NULL,
    EquipmentTypeKey INT NOT NULL,           -- Could be another dimension
    
    -- MEASURES
    UsageHours DECIMAL(5,2) NOT NULL,        -- Hours equipment was used
    SetupTimeMinutes INT NOT NULL,           -- Time to setup
    MaintenanceCost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ElectricityCost DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    IssuesReported INT NOT NULL DEFAULT 0,   -- Number of technical issues
    
    -- Foreign Keys
    CONSTRAINT FK_FactEquipment_Time 
        FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey),
    CONSTRAINT FK_FactEquipment_Conference 
        FOREIGN KEY (ConferenceKey) REFERENCES DimConference(ConferenceKey),
    CONSTRAINT FK_FactEquipment_Room 
        FOREIGN KEY (RoomKey) REFERENCES DimRoom(RoomKey)
);
PRINT 'FactEquipmentUsage table created.';
PRINT '';

PRINT 'All fact tables created successfully!';
PRINT '=========================================';
GO