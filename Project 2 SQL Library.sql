SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

-- Task 1. Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(
	isbn,
	book_title,
	category,
	rental_price,
	status,
	author,
	publisher
)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121'
SELECT * FROM issued_status

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    issued_emp_id,
    COUNT(issued_id) AS nr_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1;

-- Alt

SELECT
	issued_emp_id,
	COUNT(*) AS nr_books
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status AS ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;

SELECT * FROM book_cnts
-- Task 7. Retrieve All Books in a Specific Category:

CREATE TABLE book_category_table
AS
SELECT
	book_title,
	category
FROM books
GROUP BY 1, 2

SELECT 
	book_title
FROM book_category_table
WHERE category = 'Fiction'

-- Alt 
SELECT * FROM books
WHERE category = 'Fiction'

-- Task 8: Find Total Rental Income by Category:

SELECT
	b.category,
	SUM(b.rental_price),
	count(*) AS count_var,
	count(b.isbn) AS count_books,
	count(ist.issued_book_isbn) AS count_issued
FROM 
(
books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
)
GROUP BY 1

-- Task 9 List Members Who Registered in the Last 180 Days:

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C001', 'san', 'Sergels Torg', '2026-02-02')


SELECT
	*
FROM members
WHERE reg_date >= CURRENT_DATE - Interval '180 days';

-- Task 10 List Employess with their branch manager's
-- name and their branch details

select * from employees
select * from branch

SELECT 
	emp.*,
	emp_2.emp_name AS manager_name,
	br.manager_id,
	br.branch_id
FROM
(

employees AS emp
JOIN
branch AS br
ON br.branch_id = emp.branch_id

JOIN 
employees as emp_2
ON emp_2.emp_id = br.manager_id
)

-- Create a table of books with rental price above a certain threshold
SELECT * FROM books

DROP TABLE IF EXISTS book_table;

CREATE TABLE book_table
AS
SELECT
	*
FROM books
WHERE rental_price > 7;


SELECT * FROM book_table;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM return_status
SELECT * FROM issued_status
SELECT * FROM books

SELECT 
	*
	--DISTINCT ist.issued_book_name
FROM 
issued_status AS ist
LEFT JOIN
return_status AS rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have 
-- overdue books (assume a 30-day return period). '
-- Display the member's_id, member's name, book title,
-- issue date, and days overdue.

select * from issued_status
select * from return_status
select * from members

-- historical late returns
SELECT 
	mem.member_id,
	mem.member_name,
	ist.issued_book_name,
	ist.issued_date,
	CURRENT_DATE - ist.issued_date AS days_overdue
FROM 
issued_status AS ist
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN
members AS mem
ON mem.member_id = ist.issued_member_id
WHERE CURRENT_DATE > ist.issued_date + INTERVAL '30 days'
AND rs.return_date IS NULL

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books 
-- in the books table to "Yes" when they are returned
-- (based on entries in the return_status table).

select * from books;
select * from return_status;
select * from issued_status;

ALTER TABLE return_status
ADD  COLUMN book_quality VARCHAR(20);
UPDATE return_status
SET book_quality = 'Good';

SELECT * FROM return_status;

UPDATE return_status
SET book_quality = 'Damaged'
WHERE return_id IN('RS116', 'RS117', 'RS118');

-- Issued book
SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-553-29698-2'; 

-- The book
SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

-- Change book status, not available since issued atm
UPDATE books
SET status = 'no'
WHERE isbn = '978-0-553-29698-2'

-- Check if returned
SELECT * FROM return_status
WHERE issued_id = 'IS130';
-- not returned

-- Add a return on the IS130 issued_id
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');

SELECT * FROM return_status
WHERE issued_id = 'IS130';

UPDATE books
SET status = 'Yes'
WHERE isbn = '978-0-553-29698-2';

-- create a return, get the issued_id from return_status,
-- join the issued_id with the issued_status table,
-- get the isbn and join it with the books table,
-- change the status in the books table

-- Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(50);
	v_book_name VARCHAR(50);
	
BEGIN
	-- All logic and code
	
	-- 1. Inserting into return table based on user input
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES
	(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
	
	-- 2. Get isbn
	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn, v_book_name
	FROM issued_status
	WHERE issued_id = p_issued_id;

	-- 3. Update books based on isbn
	
	UPDATE books
	SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$

CALL add_return_records()

/*
SELECT * FROM issued_status
WHERE issued_id = 'IS135'
<isbn = 978-0-307-58837-1
*/

-- Testing Function
CALL add_return_records('R139', 'IS135', 'Good');

-- Checking result

-- Book returned
SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

-- Issued status
SELECT * FROM return_status;
WHERE issued_id = 'IS135';

CALL add_return_records('RS138', 'IS135', 'Good')

-- Task 15: Branch Performance Report
-- Create a query that generates a performance 
-- report for each branch, showing the number of 
-- books issued, the number of books returned, 
-- and the total revenue generated from book rentals.


CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id

LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id

JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create 
-- a new table active_members containing members who 
-- have issued at least one book in the last 2 months.

DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members
AS
SELECT
    m.member_id
FROM members m

JOIN issued_status ist
ON m.member_id = ist.issued_member_id

GROUP BY m.member_id

HAVING MAX(ist.issued_date) >= CURRENT_DATE - INTERVAL '6 months';

SELECT * FROM active_members;

DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN
(SELECT
	DISTINCT issued_member_id
FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL '2 month');
SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have 
-- processed the most book issues. Display the 
-- employee name, number of books processed, 
-- and their branch.

SELECT
    COUNT(ist.issued_id) AS nr_issues,
    e.emp_id,
    e.emp_name,
    b.branch_id,
    b.manager_id
FROM issued_status AS ist
JOIN employees AS e
    ON ist.issued_emp_id = e.emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY e.emp_id, e.emp_name, b.branch_id, b.manager_id
ORDER BY nr_issues DESC;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued
-- books more than twice with the status "damaged" 
-- in the books table. Display the member name, 
-- book title, and the number of times they've 
-- issued damaged books.

SELECT * FROM issued_status;
SELECT * FROM return_status;

CREATE TABLE dmg_count_table AS
SELECT
    ist.*,
    COUNT(r.book_quality) AS dmg_count
FROM issued_status AS ist
LEFT JOIN return_status AS r
    ON ist.issued_id = r.issued_id
    AND r.book_quality = 'Damaged'
GROUP BY ist.issued_id;

SELECT * FROM dmg_count_table

SELECT 
	issued_emp_id,
	SUM(dmg_count) AS nr_dmg
FROM dmg_count_table
GROUP BY 1
HAVING SUM(dmg_count) > 2;

-- Task 19: Stored Procedure Objective: 
-- Create a stored procedure to manage the status 
-- of books in a library system. 
-- Description: Write a stored procedure that 
-- updates the status of a book in the library based 
-- on its issuance. The procedure should function as 
-- follows: The stored procedure should take the 
-- book_id as an input parameter. 
-- The procedure should first check if the book is 
-- available (status = 'yes'). 
-- If the book is available, it should be issued, 
-- and the status in the books table should be 
-- updated to 'no'. If the book is not available 
-- (status = 'no'), the procedure should return an 
-- error message indicating that the book is 
-- currently not available.

SELECT * FROM issued_status;

CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

SELECT * FROM books
WHERE isbn = '978-0-553-29698-2';

SELECT * FROM issued_status;


issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))

CALL issue_book('IS155', 'C108', '978-0-375-41398-8', 'E104');
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');

-- Task 20: Create Table As Select (CTAS) Objective: 
-- Create a CTAS (Create Table As Select) query to 
-- identify overdue books and calculate fines.
-- Description: Write a CTAS query to create a new 
-- table that lists each member and the books they 
-- have issued but not returned within 30 days. 
-- The table should include: The number of overdue 
-- books. The total fines, with each day's fine 
-- calculated at $0.50. The number of books issued 
-- by each member. The resulting table should show: 
-- Member ID Number of overdue books Total fines

SELECT *  FROM books;
SELECT * FROM issued_status;
SELECT * FROM return_status;

SELECT
	i.issued_member_id AS Member_ID,
	COUNT(*) AS Nr_overdue_books,
	SUM((CURRENT_DATE - (i.issued_date + 30))) * 0.5 AS fine
FROM issued_status i

LEFT JOIN return_status r
ON i.issued_id = r.issued_id

WHERE r.return_date IS NULL
AND i.issued_date <= CURRENT_DATE - INTERVAL '30 days'

GROUP BY 1;

