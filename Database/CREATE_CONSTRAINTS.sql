USE ConferenceDB;
GO

-- Обмеження для таблиці Conferences
ALTER TABLE Conferences
ADD CONSTRAINT CHK_Conference_Dates 
    CHECK (end_date >= start_date),
    CONSTRAINT CHK_Conference_Status 
    CHECK (status IN ('Planned', 'Active', 'Completed', 'Cancelled'));
GO

-- Обмеження для таблиці Presenters
ALTER TABLE Presenters
ADD CONSTRAINT CHK_Presenter_Email 
    CHECK (email LIKE '%@%.%'),
    CONSTRAINT CHK_Academic_Degree 
    CHECK (academic_degree IN ('PhD', 'Professor', 'Associate Professor', 
                              'Assistant Professor', 'Researcher', 'PhD Candidate',
                              'Master', 'Bachelor', 'Student', 'Industry Expert') 
           OR academic_degree IS NULL);
GO

-- Обмеження для таблиці Rooms
ALTER TABLE Rooms
ADD CONSTRAINT CHK_Room_Capacity 
    CHECK (capacity > 0 AND capacity <= 1000),
    CONSTRAINT CHK_Room_Floor 
    CHECK (floor BETWEEN 1 AND 50 OR floor IS NULL);
GO

-- Обмеження для таблиці Equipment
ALTER TABLE Equipment
ADD CONSTRAINT CHK_Equipment_Quantity 
    CHECK (available_quantity >= 0),
    CONSTRAINT CHK_Condition_Status 
    CHECK (condition_status IN ('Excellent', 'Good', 'Fair', 'Poor', 'Broken'));
GO

-- Обмеження для таблиці Sections
ALTER TABLE Sections
ADD CONSTRAINT CHK_Section_Times 
    CHECK (end_time > start_time OR (end_time IS NULL AND start_time IS NULL)),
    CONSTRAINT CHK_Max_Participants 
    CHECK (max_participants > 0 OR max_participants IS NULL);
GO

-- Обмеження для таблиці Presentations
ALTER TABLE Presentations
ADD CONSTRAINT CHK_Presentation_Duration 
    CHECK (duration_minutes BETWEEN 5 AND 120),
    CONSTRAINT CHK_Presentation_Status 
    CHECK (presentation_status IN ('Scheduled', 'In Progress', 'Completed', 
                                  'Cancelled', 'Postponed'));
GO

-- Обмеження для таблиці SectionEquipment
ALTER TABLE SectionEquipment
ADD CONSTRAINT CHK_Quantity_Needed 
    CHECK (quantity_needed > 0),
    CONSTRAINT CHK_Rental_Dates 
    CHECK (return_date >= rental_date OR return_date IS NULL OR rental_date IS NULL);
GO

-- Унікальні обмеження
ALTER TABLE Conferences
ADD CONSTRAINT UQ_Conference_Title_Date 
    UNIQUE (conference_id, start_date);
GO

ALTER TABLE Sections
ADD CONSTRAINT UQ_Section_Conference_Room_Time 
    UNIQUE (conference_id, room_id, section_date, start_time);
GO

PRINT 'Constraints successfuly added.';
GO