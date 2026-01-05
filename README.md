# Conference Management & Analytics System
**Course Work Project**

## Project Overview
This project implements a complete conference management and business intelligence solution using Microsoft SQL Server technologies. It includes an OLTP database, data warehouse, ETL pipelines, OLAP cube, and analytical reports.

The solution demonstrates full-cycle data processing:
OLTP → ETL → Data Warehouse → OLAP Cube → Reports

## Technologies Used
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS)
- SQL Server Reporting Services (SSRS)

---

## Project Structure

### Root
- `.gitignore` – Git ignore rules
- `README.md` – Project documentation

---

## Database

### Database/
Contains scripts for creating and managing the operational database.

- `CREATE_DATABASE.sql` – Creates ConferenceDB
- `CREATE_TABLES.sql` – Creates all database tables
- `CREATE_CONSTRAINTS.sql` – Primary keys, foreign keys, unique constraints
- `CREATE_TRIGGERS.sql` – Business logic triggers
- `CREATE_PROCEDURES.sql` – Stored procedures

### Database/DataGeneration
Scripts for generating realistic test data.

- `SETUP.sql` – Initial setup
- `GENERATE_CONFERENCES.sql` – Conference generation (5-year history)
- `GENERATE_SECTIONS.sql` – Conference sections
- `GENERATE_PRESENTERS.sql` – Presenters
- `GENERATE_PRESENTATIONS.sql` – Presentations
- `GENERATE_ROOMS.sql` – Rooms
- `GENERATE_EQUIPMENT.sql` – Equipment
- `GENERATE_SECTION_EQUIPMENT.sql` – Equipment per section
- `FINISH_SETUP.sql` – Finalization

---

## Data Warehouse

### Database/DataWarehouse
Implements a star-schema data warehouse.

- `CREATE_DATA_WAREHOUSE.sql` – Creates DW database
- `CREATE_DIMENSION_TABLES.sql` – Dimension tables
- `CREATE_FACT_TABLES.sql` – Fact tables
- `POPULATE_TIME_DIMENSION.sql` – Time dimension population
- `CREATE_DW_INDEXES.sql` – Performance indexes

---

## SSIS – ETL Processes

### SSIS_Projects/ConferenceETL
ETL pipelines for loading data from OLTP to DW.

- `Load_DimConference.dtsx`
- `Load_DimPresenter.dtsx`
- `Load_DimRoom.dtsx`
- `Load_DimSection.dtsx`
- `Load_FactPresentations.dtsx`
- `Project.params` – Parameters

---

## SSAS – OLAP Cube

### SSAS_Projects/ConferenceCube
Multidimensional cube for analytics.

- Dimensions: Conference, Section, Presenter, Room, Time
- Measures: Presentation count, duration, equipment usage
- `ConferenceCube.cube` – Cube definition
- `ConferenceCube.database` – SSAS database

---

## SSRS – Reports

### SSRS_Projects/ConferenceReports
Analytical and academic reports.

- `Conference_Schedule.rdl` – Conference schedule report
- `Report1.rdl` – Analytical report
- `AcademicReport.pdf` – Final coursework report

---

## How to Run the Project

1. Execute scripts in `Database/` in order:
   - CREATE_DATABASE.sql
   - CREATE_TABLES.sql
   - CREATE_CONSTRAINTS.sql
   - CREATE_TRIGGERS.sql
   - CREATE_PROCEDURES.sql

2. Generate data using `Database/DataGeneration` scripts.

3. Create and populate the Data Warehouse.

4. Run SSIS ETL packages.

5. Deploy SSAS cube.

6. Deploy and view SSRS reports.

---

## Course Work Outcomes
- Demonstrates relational database design
- Implements ETL and data warehousing
- Enables OLAP analysis
- Produces professional analytical reports

---

**Author:** Bohush N.A.
**Course:** NVDB 
