CREATE DATABASE employee_Client;
USE employee_Client;
CREATE TABLE employee (
  emp_id INT PRIMARY KEY,
  first_name VARCHAR(40),
  last_name VARCHAR(40),
  birth_day DATE,
  sex VARCHAR(1),
  salary INT,
  super_id INT,
  branch_id INT
);

CREATE TABLE branch (
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(40),
  mgr_id INT,
  mgr_start_date DATE,
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name VARCHAR(40),
  branch_id INT,
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);


CREATE TABLE works_with (
  emp_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY(emp_id, client_id),
  FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
  FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier (
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(40),
  PRIMARY KEY(branch_id, supplier_name),
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

-- Corporate
INSERT INTO employee VALUES(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL);

INSERT INTO branch VALUES(1, 'Corporate', 100, '2006-02-09');

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

INSERT INTO employee VALUES(101, 'Jan', 'Levinson', '1961-05-11', 'F', 110000, 100, 1);

-- Scranton
INSERT INTO employee VALUES(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, 100, NULL);

INSERT INTO branch VALUES(2, 'Scranton', 102, '1992-04-06');

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

INSERT INTO employee VALUES(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, 102, 2);
INSERT INTO employee VALUES(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, 102, 2);
INSERT INTO employee VALUES(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, 102, 2);

-- Stamford
INSERT INTO employee VALUES(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, 100, NULL);

INSERT INTO branch VALUES(3, 'Stamford', 106, '1998-02-13');

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

INSERT INTO employee VALUES(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, 106, 3);
INSERT INTO employee VALUES(108, 'Jim', 'Halpert', '1978-10-01', 'M', 71000, 106, 3);


-- BRANCH SUPPLIER
INSERT INTO branch_supplier VALUES(2, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Patriot Paper', 'Paper');
INSERT INTO branch_supplier VALUES(2, 'J.T. Forms & Labels', 'Custom Forms');
INSERT INTO branch_supplier VALUES(3, 'Uni-ball', 'Writing Utensils');
INSERT INTO branch_supplier VALUES(3, 'Hammer Mill', 'Paper');
INSERT INTO branch_supplier VALUES(3, 'Stamford Lables', 'Custom Forms');

-- CLIENT
INSERT INTO client VALUES(400, 'Dunmore Highschool', 2);
INSERT INTO client VALUES(401, 'Lackawana Country', 2);
INSERT INTO client VALUES(402, 'FedEx', 3);
INSERT INTO client VALUES(403, 'John Daly Law, LLC', 3);
INSERT INTO client VALUES(404, 'Scranton Whitepages', 2);
INSERT INTO client VALUES(405, 'Times Newspaper', 3);
INSERT INTO client VALUES(406, 'FedEx', 2);

-- WORKS_WITH
INSERT INTO works_with VALUES(105, 400, 55000);
INSERT INTO works_with VALUES(102, 401, 267000);
INSERT INTO works_with VALUES(108, 402, 22500);
INSERT INTO works_with VALUES(107, 403, 5000);
INSERT INTO works_with VALUES(108, 403, 12000);
INSERT INTO works_with VALUES(105, 404, 33000);
INSERT INTO works_with VALUES(107, 405, 26000);
INSERT INTO works_with VALUES(102, 406, 15000);
INSERT INTO works_with VALUES(105, 406, 130000);

-- Find all employees ordered by salary
SELECT *
FROM employee
ORDER BY salary;

-- Find all employees ordered by sex then name
SELECT *
FROM employee
ORDER BY sex, first_name;

-- Find the first 5 employees in the table
SELECT *
FROM employee
LIMIT 5;

-- Find the 3rd highest salary
SELECT *
FROM ( SELECT * 
       FROM employee
       ORDER BY salary DESC
       LIMIT 3 ) x
ORDER BY salary
LIMIT 1;       

-- Find out all the different genders
SELECT DISTINCT sex
FROM employee;

-- 	find all employee's id's and names who were born after 1969
SELECT emp_id,	concat(	first_name,' ',last_name) 
FROM   employee
WHERE 	birth_day >= 1970-01-01;

-- Find all employees who are female & born after 1969 or make over 80K
SELECT *
FROM employee
WHERE sex = 'F' 
AND ( birth_day >= 1970-01-01  OR salary > 80000 );
			
-- Find all employees named Jim, Michael, Johnny or David
SELECT * 
FROM employee
WHERE first_name IN ('jim','Michael', 'Johnny', 'David');

-- Find how many males and females work in the company
SELECT sex,COUNT(sex)
FROM employee 
GROUP BY sex;

-- Find the total sales of each salesman
SELECT emp_id,SUM(total_sales)
FROM Works_With
GROUP BY emp_id;

-- Find the total amount of money spent by each client
SELECT client_id,SUM(total_sales)
FROM Works_With
GROUP BY client_id;

-- Find clients who are an LLC
SELECT *
FROM Client 
WHERE client_name LIKE '%LLC';

-- Find a list of employee and branch names/ Must have same number of columns & data Type
SELECT first_name
FROM employee
UNION
SELECT branch_name
FROM
Branch;

INSERT INTO branch 
VALUES(4, 'Buffalo', NULL, NULL);

--  Find all branches and names of their managers
SELECT 	e.emp_id, e.first_name, e.last_name, b.branch_name
FROM employee e
INNER JOIN Branch b
ON e.emp_id = b.mgr_id;

-- Find names of all employees who sold over 50,000
SELECT 	first_name, last_name
FROM Employee 
WHERE emp_id IN (
		SELECT emp_id 
                FROM (
		      SELECT emp_id, SUM(total_sales) S
		      FROM Works_With 
		      GROUP BY emp_id
                      HAVING S >= 50000 ) X
                );
		
-- Find all clients who are handeled by the barnch Michael Scott manages, aqssume you know Michael Scott ID              

SELECT c.client_id,c.client_name
FROM Client c
WHERE c.branch_id = ( SELECT B.Branch_id
                      FROM Branch b
                      WHERE B.Branch_id = ( SELECT E.Branch_id
					     FROM Employee e
                                             WHERE emp_id = 102) );
 -- Find all clients who are handeled by the barnch Michael Scott manages, aqssume you don't know Michael Scott ID                        

SELECT c.client_id,c.client_name
FROM Client c
WHERE c.branch_id = ( SELECT B.Branch_id
                      FROM Branch b
                      WHERE B.Branch_id = ( SELECT E.Branch_id
					     FROM Employee e
                                             WHERE e.first_name = 'Michael' AND e.last_name = 'Scott') );
		
-- Find the names of employees who work with clients handeled by the scranton branch
SELECT e.first_name, e.last_name
FROM employee e
WHERE e.branch_id IN ( SELECT b.branch_id
		       FROM Branch b
                       WHERE b.branch_name = 'Scranton' );

-- Find the names of all clients who have spent more than 100,000 dollars
SELECT c.client_name
FROM Client c
WHERE c.client_id IN ( SELECT client_id 
                       FROM ( 
				SELECT w.client_id, SUM(w.total_sales) s
				FROM Works_With w
				GROUP BY w.client_id
				HAVING s >= 100000 ) X );
		
