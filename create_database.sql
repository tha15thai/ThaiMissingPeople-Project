-- ========================================
-- Missing Person System Database
-- ระบบบันทึกข้อมูลผู้สูญหาย (รายการสถานีประชาชน)
-- Database: MSSQL
-- ========================================

-- Create Database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'MissingPersonDB')
BEGIN
    CREATE DATABASE MissingPersonDB;
END
GO

USE MissingPersonDB;
GO

-- ========================================
-- Drop Tables (for clean setup)
-- ========================================
IF OBJECT_ID('ReportedTips', 'U') IS NOT NULL DROP TABLE ReportedTips;
IF OBJECT_ID('Reporter_Phone', 'U') IS NOT NULL DROP TABLE Reporter_Phone;
IF OBJECT_ID('CaseOwner_Phone', 'U') IS NOT NULL DROP TABLE CaseOwner_Phone;
IF OBJECT_ID('Missingperson_Character_Log', 'U') IS NOT NULL DROP TABLE Missingperson_Character_Log;
IF OBJECT_ID('Last_Seen_Log', 'U') IS NOT NULL DROP TABLE Last_Seen_Log;
IF OBJECT_ID('StatusLog', 'U') IS NOT NULL DROP TABLE StatusLog;
IF OBJECT_ID('Reporter', 'U') IS NOT NULL DROP TABLE Reporter;
IF OBJECT_ID('MissingCase', 'U') IS NOT NULL DROP TABLE MissingCase;
IF OBJECT_ID('IdentityDocument', 'U') IS NOT NULL DROP TABLE IdentityDocument;
IF OBJECT_ID('MissingPerson', 'U') IS NOT NULL DROP TABLE MissingPerson;
IF OBJECT_ID('CaseOwner', 'U') IS NOT NULL DROP TABLE CaseOwner;
IF OBJECT_ID('PoliceStation', 'U') IS NOT NULL DROP TABLE PoliceStation;
IF OBJECT_ID('Staff', 'U') IS NOT NULL DROP TABLE Staff;
GO

-- ========================================
-- Table 1: Staff (เจ้าหน้าที่)
-- ========================================
CREATE TABLE Staff (
    staff_id INT PRIMARY KEY IDENTITY(1,1),
    staff_name NVARCHAR(100) NOT NULL,
    staff_position NVARCHAR(50),
    created_date DATETIME DEFAULT GETDATE()
);
GO

-- ========================================
-- Table 2: CaseOwner (ผู้แจ้งคดีคนแรก)
-- ========================================
CREATE TABLE CaseOwner (
    owner_id INT PRIMARY KEY IDENTITY(1,1),
    owner_title NVARCHAR(50) NOT NULL,
    owner_name NVARCHAR(50) NOT NULL
);
GO

-- ========================================
-- Table 3: MissingPerson (ข้อมูลบุคคลสูญหาย)
-- ========================================
CREATE TABLE MissingPerson (
    missingperson_id INT PRIMARY KEY IDENTITY(1,1),
    missing_title NVARCHAR(50) NOT NULL,
    missing_name NVARCHAR(50) NOT NULL,
    gender NVARCHAR(50) NOT NULL,
    birthday DATE NULL,
    age INT NOT NULL,
    race NVARCHAR(50) NOT NULL
);
GO

-- ========================================
-- Table 4: IdentityDocument (ข้อมูลบัตรประจำตัว)
-- ========================================
CREATE TABLE IdentityDocument (
    id_number NVARCHAR(20) PRIMARY KEY,
    id_type NVARCHAR(50) NOT NULL,
    missingperson_id INT NOT NULL,
    FOREIGN KEY (missingperson_id) REFERENCES MissingPerson(missingperson_id)
);
GO

-- ========================================
-- Table 5: PoliceStation (ข้อมูลสถานีตำรวจ)
-- ========================================
CREATE TABLE PoliceStation (
    police_station_id INT PRIMARY KEY IDENTITY(1,1),
    police_station_name NVARCHAR(50) NOT NULL,
    police_station_province NVARCHAR(50) NOT NULL,
    police_station_phone NVARCHAR(50) NOT NULL
);
GO

-- ========================================
-- Table 6: MissingCase (ข้อมูลคดีผู้สูญหาย)
-- ========================================
CREATE TABLE MissingCase (
    case_id INT PRIMARY KEY IDENTITY(1,1),
    priority NVARCHAR(30) NOT NULL,
    latest_status NVARCHAR(50) NOT NULL,
    missing_reason NVARCHAR(50) NOT NULL,
    received_date DATETIME NOT NULL DEFAULT GETDATE(),
    staff_id INT NOT NULL,
    latest_last_seen_at NVARCHAR(MAX) NOT NULL, -- JSON field
    first_last_seen_at NVARCHAR(MAX) NOT NULL, -- JSON field
    latest_characteristics NVARCHAR(MAX) NOT NULL, -- JSON field
    relation_to_missing NVARCHAR(15) NOT NULL,
    inform_channels NVARCHAR(30) NOT NULL,
    notice NVARCHAR(500) NOT NULL,
    owner_id INT NOT NULL,
    missingperson_id INT NOT NULL,
    police_station_id INT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (owner_id) REFERENCES CaseOwner(owner_id),
    FOREIGN KEY (missingperson_id) REFERENCES MissingPerson(missingperson_id),
    FOREIGN KEY (police_station_id) REFERENCES PoliceStation(police_station_id)
);
GO

-- ========================================
-- Table 7: Reporter (ข้อมูลผู้แจ้งเบาะแส)
-- ========================================
CREATE TABLE Reporter (
    reporter_id INT PRIMARY KEY IDENTITY(1,1),
    reporter_title NVARCHAR(50) NOT NULL,
    reporter_name NVARCHAR(50) NOT NULL
);
GO

-- ========================================
-- Table 8: StatusLog (ข้อมูลสถานะเคส Log)
-- ========================================
CREATE TABLE StatusLog (
    log_id INT PRIMARY KEY IDENTITY(1,1),
    case_id INT NOT NULL,
    description NVARCHAR(50) NOT NULL,
    case_status NVARCHAR(50) NOT NULL,
    logged_by NVARCHAR(50) NOT NULL,
    logged_date DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (case_id) REFERENCES MissingCase(case_id)
);
GO

-- ========================================
-- Table 9: Last_Seen_Log (สถานที่ที่พบเห็นล่าสุด)
-- ========================================
CREATE TABLE Last_Seen_Log (
    log_id INT PRIMARY KEY,
    missing_date DATE NOT NULL,
    missing_time TIME NOT NULL,
    missing_place NVARCHAR(50) NOT NULL,
    subdistrict NVARCHAR(50) NOT NULL,
    district NVARCHAR(50) NOT NULL,
    province NVARCHAR(50) NOT NULL,
    FOREIGN KEY (log_id) REFERENCES StatusLog(log_id)
);
GO

-- ========================================
-- Table 10: Missingperson_Character_Log (ลักษณะบุคคล)
-- ========================================
CREATE TABLE Missingperson_Character_Log (
    log_id INT PRIMARY KEY,
    image_url NVARCHAR(500) NOT NULL,
    skin_color NVARCHAR(50) NOT NULL,
    body_shape NVARCHAR(50) NOT NULL,
    hair_styles NVARCHAR(50) NOT NULL,
    hair_color NVARCHAR(50) NOT NULL,
    height_cm INT NOT NULL,
    FOREIGN KEY (log_id) REFERENCES StatusLog(log_id)
);
GO

-- ========================================
-- Table 11: CaseOwner_Phone (เบอร์โทรศัพท์ผู้แจ้งคดี)
-- ========================================
CREATE TABLE CaseOwner_Phone (
    owner_id INT NOT NULL,
    owner_phone NVARCHAR(10) NOT NULL,
    PRIMARY KEY (owner_id, owner_phone),
    FOREIGN KEY (owner_id) REFERENCES CaseOwner(owner_id)
);
GO

-- ========================================
-- Table 12: Reporter_Phone (เบอร์โทรศัพท์ผู้แจ้งเบาะแส)
-- ========================================
CREATE TABLE Reporter_Phone (
    reporter_id INT NOT NULL,
    reporter_phone NVARCHAR(10) NOT NULL,
    PRIMARY KEY (reporter_id, reporter_phone),
    FOREIGN KEY (reporter_id) REFERENCES Reporter(reporter_id)
);
GO

-- ========================================
-- Table 13: ReportedTips (ข้อมูลที่ผู้แจ้งเบาะแส)
-- ========================================
CREATE TABLE ReportedTips (
    reporter_id INT NOT NULL,
    case_id INT NOT NULL,
    log_id INT NOT NULL,
    PRIMARY KEY (reporter_id, case_id),
    FOREIGN KEY (reporter_id) REFERENCES Reporter(reporter_id),
    FOREIGN KEY (case_id) REFERENCES MissingCase(case_id),
    FOREIGN KEY (log_id) REFERENCES StatusLog(log_id)
);
GO

PRINT 'Database and tables created successfully!';
GO
