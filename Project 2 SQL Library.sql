-- Library Management System Project 2

-- Create the tables

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(55),
	contact_no VARCHAR(10)
);

DROP TABLE IF EXISTS books;
CREATE TABLE books(
	isbn VARCHAR(17) PRIMARY KEY,
	book_title VARCHAR(53),
	category VARCHAR(16),
	rental_price FLOAT,
	status VARCHAR(3),
	author VARCHAR(22),
	publisher VARCHAR(25)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees(
	emp_id VARCHAR(4) PRIMARY KEY,
	emp_name VARCHAR(16),
	position VARCHAR(9),
	salary FLOAT,
	branch_id VARCHAR(4) -- FK
);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id VARCHAR(5) PRIMARY KEY,
	issued_member_id VARCHAR(4), -- FK
	issued_book_name VARCHAR(53),
	issued_date DATE,
	issued_book_isbn VARCHAR(17), -- FK
	issued_emp_id VARCHAR(4) -- FK
);

DROP TABLE IF EXISTS members;
CREATE TABLE members(
	member_id VARCHAR(4) PRIMARY KEY,
	member_name VARCHAR(14),
	member_address VARCHAR(13),
	reg_date DATE
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(5) PRIMARY KEY,
	issued_id VARCHAR(5),
	return_book_name VARCHAR(4),
	return_date DATE,
	return_book_isbn VARCHAR(4)
);

-- Foreign key constraints

ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_emp
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_book
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

ALTER TABLE branch
ALTER COLUMN branch_id TYPE VARCHAR(30);

ALTER TABLE branch
ALTER COLUMN manager_id TYPE VARCHAR(30);

ALTER TABLE branch
ALTER COLUMN contact_no TYPE VARCHAR(30);






