-- ============================================
-- File: 05_CREATE_DW_INDEXES.sql
-- Description: Creates indexes for Data Warehouse performance
-- Author: [Your Name]
-- ============================================

USE ConferenceDW;
GO

PRINT 'Creating indexes for Data Warehouse...';
PRINT '';

-- ============================================
-- DIMENSION TABLE INDEXES
-- ============================================

PRINT 'Creating indexes for dimension tables...';

-- DimTime indexes
CREATE NONCLUSTERED INDEX IX_DimTime_Date 
    ON DimTime(FullDate);
CREATE NONCLUSTERED INDEX IX_DimTime_YearMonth 
    ON DimTime(Year, MonthNumber);
CREATE NONCLUSTERED INDEX IX_DimTime_Quarter 
    ON DimTime(Year, Quarter);
PRINT '  DimTime indexes created.';

-- DimConference indexes
CREATE NONCLUSTERED INDEX IX_DimConference_ID 
    ON DimConference(ConferenceID);
CREATE NONCLUSTERED INDEX IX_DimConference_Date 
    ON DimConference(StartDate, EndDate);
CREATE NONCLUSTERED INDEX IX_DimConference_Location 
    ON DimConference(Location, Topic);
CREATE NONCLUSTERED INDEX IX_DimConference_Current 
    ON DimConference(IsCurrent) WHERE IsCurrent = 1;
PRINT '  DimConference indexes created.';

-- DimPresenter indexes
CREATE NONCLUSTERED INDEX IX_DimPresenter_ID 
    ON DimPresenter(PresenterID);
CREATE NONCLUSTERED INDEX IX_DimPresenter_Name 
    ON DimPresenter(LastName, FirstName);
CREATE NONCLUSTERED INDEX IX_DimPresenter_Degree 
    ON DimPresenter(AcademicDegree, University);
CREATE NONCLUSTERED INDEX IX_DimPresenter_Current 
    ON DimPresenter(IsCurrent) WHERE IsCurrent = 1;
PRINT '  DimPresenter indexes created.';

-- DimRoom indexes
CREATE NONCLUSTERED INDEX IX_DimRoom_ID 
    ON DimRoom(RoomID);
CREATE NONCLUSTERED INDEX IX_DimRoom_Building 
    ON DimRoom(Building, Floor, RoomNumber);
CREATE NONCLUSTERED INDEX IX_DimRoom_Capacity 
    ON DimRoom(Capacity, HasProjector, HasInternet);
PRINT '  DimRoom indexes created.';

-- DimSection indexes
CREATE NONCLUSTERED INDEX IX_DimSection_ID 
    ON DimSection(SectionID);
CREATE NONCLUSTERED INDEX IX_DimSection_Type 
    ON DimSection(SectionType, Topic);
PRINT '  DimSection indexes created.';

PRINT 'Dimension table indexes completed.';
PRINT '';

-- ============================================
-- FACT TABLE INDEXES
-- ============================================

PRINT 'Creating indexes for fact tables...';

-- FactPresentations indexes (most important - this table will be largest)
CREATE NONCLUSTERED INDEX IX_FactPresentations_Time 
    ON FactPresentations(TimeKey);
CREATE NONCLUSTERED INDEX IX_FactPresentations_Conference 
    ON FactPresentations(ConferenceKey);
CREATE NONCLUSTERED INDEX IX_FactPresentations_Presenter 
    ON FactPresentations(PresenterKey);
CREATE NONCLUSTERED INDEX IX_FactPresentations_Room 
    ON FactPresentations(RoomKey);
CREATE NONCLUSTERED INDEX IX_FactPresentations_Section 
    ON FactPresentations(SectionKey);

-- Composite indexes for common query patterns
CREATE NONCLUSTERED INDEX IX_FactPresentations_ConfTime 
    ON FactPresentations(ConferenceKey, TimeKey)
    INCLUDE (DurationMinutes, ActualParticipants);

CREATE NONCLUSTERED INDEX IX_FactPresentations_PresenterTime 
    ON FactPresentations(PresenterKey, TimeKey)
    INCLUDE (DurationMinutes, ParticipantRating);

CREATE NONCLUSTERED INDEX IX_FactPresentations_RoomTime 
    ON FactPresentations(RoomKey, TimeKey)
    INCLUDE (ActualParticipants, EquipmentCost);

-- Index for aggregate queries
CREATE NONCLUSTERED INDEX IX_FactPresentations_Aggregate 
    ON FactPresentations(ConferenceKey, SectionKey, TimeKey)
    INCLUDE (DurationMinutes, ActualParticipants, ParticipantRating);
PRINT '  FactPresentations indexes created.';

-- FactConferenceAttendance indexes
CREATE NONCLUSTERED INDEX IX_FactAttendance_Time 
    ON FactConferenceAttendance(TimeKey);
CREATE NONCLUSTERED INDEX IX_FactAttendance_Conference 
    ON FactConferenceAttendance(ConferenceKey);
CREATE NONCLUSTERED INDEX IX_FactAttendance_Revenue 
    ON FactConferenceAttendance(ConferenceKey, TimeKey)
    INCLUDE (RegistrationRevenue, TotalRevenue, NetProfit);
PRINT '  FactConferenceAttendance indexes created.';

-- FactEquipmentUsage indexes
CREATE NONCLUSTERED INDEX IX_FactEquipment_Time 
    ON FactEquipmentUsage(TimeKey);
CREATE NONCLUSTERED INDEX IX_FactEquipment_ConferenceRoom 
    ON FactEquipmentUsage(ConferenceKey, RoomKey);
PRINT '  FactEquipmentUsage indexes created.';

PRINT 'Fact table indexes completed.';
PRINT '';

-- ============================================
-- STATISTICS FOR QUERY OPTIMIZER
-- ============================================

PRINT 'Creating/updating statistics...';

-- Update statistics on all tables
UPDATE STATISTICS DimTime WITH FULLSCAN;
UPDATE STATISTICS DimConference WITH FULLSCAN;
UPDATE STATISTICS DimPresenter WITH FULLSCAN;
UPDATE STATISTICS DimRoom WITH FULLSCAN;
UPDATE STATISTICS DimSection WITH FULLSCAN;

UPDATE STATISTICS FactPresentations WITH FULLSCAN;
UPDATE STATISTICS FactConferenceAttendance WITH FULLSCAN;
UPDATE STATISTICS FactEquipmentUsage WITH FULLSCAN;

PRINT 'Statistics updated.';
PRINT '';

-- ============================================
-- VERIFICATION
-- ============================================

PRINT 'Verifying indexes...';
PRINT '';

SELECT 
    t.name AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.is_primary_key AS IsPrimaryKey,
    i.fill_factor AS Fill_factor
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
WHERE t.type_desc = 'USER_TABLE'
    AND i.name IS NOT NULL
    AND t.name IN ('DimTime', 'DimConference', 'DimPresenter', 'DimRoom', 'DimSection',
                   'FactPresentations', 'FactConferenceAttendance', 'FactEquipmentUsage')
ORDER BY t.name, i.type_desc, i.name;

PRINT '';
PRINT '=========================================';
PRINT 'Data Warehouse indexes created successfully!';
PRINT 'Total tables indexed: 8';
PRINT 'Total indexes created: ~25';
PRINT 'Data Warehouse is now ready for ETL loading.';
PRINT '=========================================';
GO