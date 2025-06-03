-- Core Entity Tables
CREATE TABLE Role (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) UNIQUE NOT NULL, -- e.g., 'Superadmin', 'HR', 'DML', 'DHS'
    permissions JSON, -- Optional: Store role-specific permissions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Rank (
    rank_id INT PRIMARY KEY AUTO_INCREMENT,
    rank_name VARCHAR(50) UNIQUE NOT NULL, -- e.g., 'Doctor', 'Temporary', 'Casual'
    salary_band DECIMAL(10,2),
    description TEXT
);

CREATE TABLE Department (
    dep_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_id INT NOT NULL,
    facility_id INT NOT NULL,
    dep_name VARCHAR(100) UNIQUE NOT NULL,
    dep_head_staff_id INT, -- FK to Staff
    FOREIGN KEY (dep_head_staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (zone_id) REFERENCES Zone(zone_id),
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
);

CREATE TABLE Zone (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    location VARCHAR(255),
    capacity INT
);

CREATE TABLE Facility (
    facility_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_id INT NOT NULL,
    facility_name VARCHAR(100) UNIQUE NOT NULL,
    dep_id INT NOT NULL,
    facility_manager_staff_id INT, -- FK to Staff
    FOREIGN KEY (dep_id) REFERENCES Department(dep_id),
    FOREIGN KEY (facility_manager_staff_id) REFERENCES Staff(staff_id)
);

CREATE TABLE Transfer (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    from_facility_id  INT NOT NULL,
    to_facility_id  INT NOT NULL,
    transfer_date DATE NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- Association Tables
CREATE TABLE Staff_Rank (
    staff_id INT NOT NULL,
    rank_id INT NOT NULL,
    effective_date DATE NOT NULL,
    PRIMARY KEY (staff_id, rank_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (rank_id) REFERENCES Rank(rank_id)
);
-- Staff and Admins
CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    employment_No VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    passport VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    mobile_No VARCHAR(16) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_employed DATE NOT NULL,
    role_id INT NOT NULL,
    rank_id INT NOT NULL,
    facility_id INT NOT NULL,
    join_date DATE NOT NULL,
    FOREIGN KEY (role_id) REFERENCES Role(role_id),
    FOREIGN KEY (rank_id) REFERENCES Rank(rank_id),
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
);

-- Qualifications
CREATE TABLE QualificationType (
    qualification_type_id INT PRIMARY KEY AUTO_INCREMENT,
    qualification_name VARCHAR(100) UNIQUE NOT NULL, -- MD, RN, etc.
    description TEXT
);

CREATE TABLE StaffQualification (
    staff_id INT NOT NULL,
    qualification_type_id INT NOT NULL,
    date_earned DATE NOT NULL,
    certificate_url VARCHAR(255),
    PRIMARY KEY (staff_id, qualification_type_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (qualification_type_id) REFERENCES QualificationType(qualification_type_id)
);

-- Leave Management
CREATE TABLE LeaveType (
    leave_type_id INT PRIMARY KEY AUTO_INCREMENT,
    leave_name VARCHAR(50) UNIQUE NOT NULL, -- leave of absence, no-pay
    description TEXT
);

CREATE TABLE LeaveRequest (
    leave_req_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    comments TEXT,
    approved_by_admin_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (leave_type_id) REFERENCES LeaveType(leave_type_id),
    FOREIGN KEY (approved_by_admin_id) REFERENCES Admin(admin_id)
);

-- Audit Trails (Optional)
CREATE TABLE Notification (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    notification_type VARCHAR(50) NOT NULL, -- e.g leave_request, retirement, anouncement, facility_request, etc.
    staff_id INT NOT NULL,
    performed_by INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (performed_by) REFERENCES Admin(admin_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);


CREATE TABLE Admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role_id INT NOT NULL,
    last_login TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- Operational Tables
CREATE TABLE Leave_Type (
    leave_type_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL, -- e.g., 'Absent', 'No-Pay'
    description TEXT
);

CREATE TABLE Leave_Request (
    leave_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id INT NOT NULL,
    leave_type_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Approved', 'Pending', 'Rejected') DEFAULT 'Pending',
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id),
    FOREIGN KEY (leave_type_id) REFERENCES Leave_Type(leave_type_id)
);

CREATE TABLE Facility_Request (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    facility_id INT NOT NULL,
    request_type ENUM('Shortage', 'Equipment') NOT NULL,
    description TEXT NOT NULL,
    status ENUM('Pending', 'Approved', 'In-Progress', 'Resolved') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP,
    FOREIGN KEY (facility_id) REFERENCES Facility(facility_id)
);


CREATE INDEX idx_staff_role ON Staff(role_id);
CREATE INDEX idx_staff_facility ON Staff(facility_id);
CREATE INDEX idx_leave_status ON LeaveRequest(status);
CREATE INDEX idx_Notification ON Notification(notification_id, notification_type);
