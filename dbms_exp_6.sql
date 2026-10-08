-- ============================================
-- DBMS EXPERIMENT: STORED PROCEDURE & TRIGGERS
-- ============================================

-- ============================================
-- 1. CREATE TABLES
-- ============================================

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    gender CHAR(1),
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);


-- ============================================
-- 2. INSERT DEPARTMENT DATA
-- ============================================

INSERT INTO Department (dept_id, dept_name, location)
VALUES
(1, 'IT', 'Delhi'),
(2, 'HR', 'Mumbai'),
(3, 'Finance', 'Bangalore'),
(4, 'Marketing', 'Pune'),
(5, 'Research', 'Hyderabad');


-- ============================================
-- 3. INSERT EMPLOYEE DATA
-- ============================================

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(101, 'Aarav Sharma', 'M', 75000, '2021-01-15', 1),
(102, 'Ananya Singh', 'F', 68000, '2022-03-10', 1),
(103, 'Rohan Verma', 'M', 82000, '2020-07-20', 1),
(104, 'Priya Gupta', 'F', 72000, '2021-11-05', 1),
(105, 'Karan Mehta', 'M', 95000, '2019-06-18', 1),
(106, 'Sneha Kapoor', 'F', 64000, '2023-01-12', 1),

(107, 'Rahul Kumar', 'M', 55000, '2022-05-15', 2),
(108, 'Neha Sharma', 'F', 62000, '2021-09-22', 2),
(109, 'Amit Jain', 'M', 58000, '2020-04-11', 2),
(110, 'Pooja Verma', 'F', 67000, '2023-02-19', 2),
(111, 'Vikas Singh', 'M', 60000, '2022-08-01', 2),
(112, 'Riya Agarwal', 'F', 71000, '2019-12-10', 2),

(113, 'Arjun Patel', 'M', 88000, '2020-01-25', 3),
(114, 'Meera Shah', 'F', 92000, '2019-08-14', 3),
(115, 'Suresh Rao', 'M', 76000, '2021-06-30', 3),
(116, 'Kavya Iyer', 'F', 85000, '2022-10-17', 3),
(117, 'Manish Gupta', 'M', 73000, '2023-03-21', 3),
(118, 'Nisha Reddy', 'F', 90000, '2020-11-09', 3),

(119, 'Aditya Joshi', 'M', 70000, '2021-02-28', 4),
(120, 'Simran Kaur', 'F', 66000, '2022-04-15', 4),
(121, 'Mohit Bansal', 'M', 74000, '2020-09-12', 4),
(122, 'Isha Malhotra', 'F', 81000, '2019-07-07', 4),
(123, 'Nikhil Sethi', 'M', 69000, '2023-01-05', 4),
(124, 'Tanya Arora', 'F', 77000, '2021-12-18', 4),

(125, 'Dev Malhotra', 'M', 98000, '2018-05-20', 5),
(126, 'Aditi Mishra', 'F', 91000, '2020-03-16', 5),
(127, 'Varun Nair', 'M', 87000, '2021-10-08', 5),
(128, 'Shreya Das', 'F', 93000, '2019-11-25', 5),
(129, 'Yash Thakur', 'M', 79000, '2022-07-14', 5),
(130, 'Diya Kapoor', 'F', 96000, '2023-02-02', 5);


-- ============================================
-- 4. STORED PROCEDURE: transfer_employee
-- ============================================

DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_employee_count INT DEFAULT 0;
    DECLARE v_department_count INT DEFAULT 0;
    DECLARE v_current_dept INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    -- Check whether employee exists
    SELECT COUNT(*)
    INTO v_employee_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_employee_count = 0 THEN

        ROLLBACK;
        SELECT 'Error: Employee does not exist.' AS message;

    ELSE

        -- Check whether department exists
        SELECT COUNT(*)
        INTO v_department_count
        FROM Department
        WHERE dept_id = p_new_dept_id;

        IF v_department_count = 0 THEN

            ROLLBACK;
            SELECT 'Error: Department does not exist.' AS message;

        ELSE

            -- Get current department
            SELECT dept_id
            INTO v_current_dept
            FROM Employee
            WHERE emp_id = p_emp_id;

            -- Check if employee is already in department
            IF v_current_dept = p_new_dept_id THEN

                ROLLBACK;
                SELECT 'Error: Employee is already in this department.'
                AS message;

            ELSE

                -- Transfer employee
                UPDATE Employee
                SET dept_id = p_new_dept_id
                WHERE emp_id = p_emp_id;

                COMMIT;

                SELECT 'Employee transferred successfully.'
                AS message;

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;


-- ============================================
-- 5. TEST STORED PROCEDURE
-- ============================================

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;


CALL transfer_employee(101, 3);


SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;


-- ============================================
-- 6. EDGE CASE: EMPLOYEE DOES NOT EXIST
-- ============================================

CALL transfer_employee(999, 3);


-- ============================================
-- 7. EDGE CASE: DEPARTMENT DOES NOT EXIST
-- ============================================

CALL transfer_employee(101, 99);


-- ============================================
-- 8. EDGE CASE: SAME DEPARTMENT
-- ============================================

CALL transfer_employee(101, 3);


-- ============================================
-- 9. SALARY VALIDATION TRIGGER
-- Salary must be >= 15000
-- ============================================

DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be at least 15000';
    END IF;
END //

DELIMITER ;


-- ============================================
-- 10. TEST INVALID SALARY
-- ============================================

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(131, 'Test Employee', 'M', 10000, '2026-09-25', 1);


-- ============================================
-- 11. TEST VALID SALARY
-- ============================================

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(131, 'Test Employee', 'M', 30000, '2026-09-25', 1);

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id = 131;


-- ============================================
-- 12. SALARY VALIDATION FOR UPDATE
-- ============================================

DELIMITER //

CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be at least 15000';
    END IF;
END //

DELIMITER ;


-- ============================================
-- 13. TEST INVALID SALARY UPDATE
-- ============================================

UPDATE Employee
SET salary = 5000
WHERE emp_id = 131;

SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id = 131;


-- ============================================
-- 14. CREATE AUDIT TABLE
-- ============================================

CREATE TABLE Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30)
);


-- ============================================
-- 15. AUDIT LOGGING TRIGGER
-- ============================================

DELIMITER //

CREATE TRIGGER salary_audit_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN

    IF OLD.salary <> NEW.salary THEN

        INSERT INTO Salary_Audit
        (
            emp_id,
            old_salary,
            new_salary,
            action
        )
        VALUES
        (
            NEW.emp_id,
            OLD.salary,
            NEW.salary,
            'SALARY UPDATED'
        );

    END IF;

END //

DELIMITER ;


-- ============================================
-- 16. TEST AUDIT TRIGGER
-- ============================================

UPDATE Employee
SET salary = 35000
WHERE emp_id = 131;

SELECT *
FROM Salary_Audit;


-- ============================================
-- 17. TEST MULTIPLE SALARY CHANGES
-- ============================================

UPDATE Employee
SET salary = 40000
WHERE emp_id = 131;

UPDATE Employee
SET salary = 45000
WHERE emp_id = 131;

SELECT
    audit_id,
    emp_id,
    old_salary,
    new_salary,
    action
FROM Salary_Audit
WHERE emp_id = 131;


-- ============================================
-- 18. EDGE CASE: SALARY UNCHANGED
-- ============================================

UPDATE Employee
SET salary = 45000
WHERE emp_id = 131;


-- ============================================
-- 19. NULL SALARY VALIDATION
-- ============================================

DROP TRIGGER validate_employee_salary;

DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;


-- ============================================
-- 20. TEST NULL SALARY
-- ============================================

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(132, 'Null Salary', 'F', NULL, '2026-09-25', 1);


-- ============================================
-- 21. CHECK ALL TRIGGERS
-- ============================================

SHOW TRIGGERS;


-- ============================================
-- 22. CHECK STORED PROCEDURE
-- ============================================

SHOW PROCEDURE STATUS
WHERE Db = 'sandbox_db';