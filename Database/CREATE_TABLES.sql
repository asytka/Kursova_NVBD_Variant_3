USE ConferenceDB;
GO

-- Таблиця Конференції
CREATE TABLE Conferences (
    conference_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location NVARCHAR(150) NOT NULL,
    theme NVARCHAR(100),
    status VARCHAR(20) NOT NULL DEFAULT 'Planned',
    created_date DATETIME DEFAULT GETDATE(),
    last_updated DATETIME DEFAULT GETDATE()
);
GO

-- Таблиця Виступаючі
CREATE TABLE Presenters (
    presenter_id INT IDENTITY(1,1) PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    institution NVARCHAR(150) NOT NULL,
    academic_degree VARCHAR(30),
    country NVARCHAR(50),
    registration_date DATE DEFAULT GETDATE(),
    is_active BIT DEFAULT 1
);
GO

-- Таблиця Приміщення
CREATE TABLE Rooms (
    room_id INT IDENTITY(1,1) PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    capacity INT NOT NULL,
    floor INT,
    has_projector BIT DEFAULT 0,
    has_sound_system BIT DEFAULT 0,
    is_available BIT DEFAULT 1
);
GO

-- Таблиця Обладнання
CREATE TABLE Equipment (
    equipment_id INT IDENTITY(1,1) PRIMARY KEY,
    equipment_name NVARCHAR(100) NOT NULL,
    equipment_type VARCHAR(30) NOT NULL,
    available_quantity INT NOT NULL DEFAULT 0,
    condition_status VARCHAR(20) DEFAULT 'Good',
    purchase_date DATE,
    last_maintenance DATE
);
GO

-- Таблиця Секції
CREATE TABLE Sections (
    section_id INT IDENTITY(1,1) PRIMARY KEY,
    conference_id INT NOT NULL,
    section_name NVARCHAR(150) NOT NULL,
    chairperson_id INT,
    room_id INT,
    max_participants INT,
    start_time TIME,
    end_time TIME,
    section_date DATE,
    
    CONSTRAINT FK_Sections_Conferences 
        FOREIGN KEY (conference_id) REFERENCES Conferences(conference_id),
    CONSTRAINT FK_Sections_Presenters 
        FOREIGN KEY (chairperson_id) REFERENCES Presenters(presenter_id),
    CONSTRAINT FK_Sections_Rooms 
        FOREIGN KEY (room_id) REFERENCES Rooms(room_id)
);
GO

-- Таблиця Виступи
CREATE TABLE Presentations (
    presentation_id INT IDENTITY(1,1) PRIMARY KEY,
    section_id INT NOT NULL,
    presenter_id INT NOT NULL,
    title NVARCHAR(300) NOT NULL,
    abstract NVARCHAR(MAX),
    start_time TIME NOT NULL,
    duration_minutes INT NOT NULL,
    equipment_needed BIT DEFAULT 0,
    presentation_status VARCHAR(15) DEFAULT 'Scheduled',
    
    CONSTRAINT FK_Presentations_Sections 
        FOREIGN KEY (section_id) REFERENCES Sections(section_id),
    CONSTRAINT FK_Presentations_Presenters 
        FOREIGN KEY (presenter_id) REFERENCES Presenters(presenter_id)
);
GO

-- Таблиця ОбладнанняСекції
CREATE TABLE SectionEquipment (
    section_id INT NOT NULL,
    equipment_id INT NOT NULL,
    quantity_needed INT NOT NULL DEFAULT 1,
    rental_date DATE,
    return_date DATE,
    
    CONSTRAINT PK_SectionEquipment 
        PRIMARY KEY (section_id, equipment_id),
    CONSTRAINT FK_SectionEquipment_Sections 
        FOREIGN KEY (section_id) REFERENCES Sections(section_id),
    CONSTRAINT FK_SectionEquipment_Equipment 
        FOREIGN KEY (equipment_id) REFERENCES Equipment(equipment_id)
);
GO

PRINT 'OLTP таблиці успішно створені.';
GO