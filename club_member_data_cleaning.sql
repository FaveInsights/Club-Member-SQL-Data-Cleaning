--Creating columns and setting up the table structure
CREATE TABLE CLUB_MEMBER (
	FULL_NAME VARCHAR(50),
	AGE INT,
	MARITAL_STATUS VARCHAR(30),
	EMAIL VARCHAR(60),
	PHONE VARCHAR(20),
	FULL_ADDRESS TEXT,
	JOB_TITLE VARCHAR(40),
	MEMBERSHIP_DATE DATE
)
--Copying rows from the CSV file into the table
COPY CLUB_MEMBER
FROM
	'C:\Program Files\PostgreSQL\16\data\data_copy\club_member_info.csv' DELIMITER ',' CSV HEADER;

--checking the full table 
SELECT
	*
FROM
	CLUB_MEMBER;

--Creating a duplicate table so that I can work on the main table
SELECT
	*
FROM
	DUPLICATED_CLUB_MEMBER2 AS
SELECT
	*
FROM
	CLUB_MEMBER;

--	After a thorough inspection, the following were discrepancies observed
--1. Some data in the full_name row contains special characters


SELECT
	ID,
	FULL_NAME,
	AGE
FROM
	CLUB_MEMBER;

--To capitalize the First letter of full_name
UPDATE CLUB_MEMBER
SET
	FULL_NAME = INITCAP(FULL_NAME);

--To remove all special characters in the full_name column, this command would leave a-z, A-Z and space
UPDATE CLUB_MEMBER
SET
	FULL_NAME = REGEXP_REPLACE(FULL_NAME, '[^a-zA-Z ]', '', 'g');

--To remove unwanted spaces in the first_name
UPDATE CLUB_MEMBER
SET
	FULL_NAME = LTRIM(FULL_NAME);

--To add a primary id new column 
ALTER TABLE CLUB_MEMBER
ADD COLUMN ID SERIAL PRIMARY KEY;

--Some of the fields in age column have three figures,, the last one is a mistake so it has to be removed
--Since the data type is an integer, divide by 10
UPDATE CLUB_MEMBER
SET
	AGE = AGE / 10
WHERE
	AGE > 99;

--To check if there is spelling error in marital_status column
SELECT
	ID,
	MARITAL_STATUS
FROM
	CLUB_MEMBER
WHERE
	MARITAL_STATUS NOT IN ('single', 'married', 'separated', 'divorced');

--Some fields were spelt as divored instead of divorced --277 307
UPDATE CLUB_MEMBER
SET
	MARITAL_STATUS = 'divorced'
WHERE
	MARITAL_STATUS = 'divored'
	--To capitalize the marital_status column
UPDATE CLUB_MEMBER
SET
	MARITAL_STATUS = INITCAP(MARITAL_STATUS);

---To check if there are duplicate email addresses
SELECT
	EMAIL,
	COUNT(EMAIL)
FROM
	CLUB_MEMBER
GROUP BY
	EMAIL
HAVING
	COUNT(EMAIL) > 1;

--- There are duplicate values, to delete them run
DELETE FROM CLUB_MEMBER
WHERE
	ID IN (
		SELECT
			ID
		FROM
			(
				SELECT
					ID,
					ROW_NUMBER() OVER (
						PARTITION BY
							EMAIL
						ORDER BY
							ID ASC
					) AS ROW_NUM
				FROM
					CLUB_MEMBER
			) EMAIL
		WHERE
			EMAIL.ROW_NUM > 1
	);

--Next is the phone column, there are 5 entries where the phone length is less than 12,
--This is invalid so we will set it to null
UPDATE CLUB_MEMBER
SET
	PHONE = NULL
WHERE
	LENGTH(PHONE) < 12;

--Next column is the full_address column. It can be seen that the street name_city and state are all together and they should be separated
SELECT
	FULL_ADDRESS
FROM
	CLUB_MEMBER;

CREATE TABLE CLEAN_CLUB_MEMBER AS
SELECT
	*
FROM
	(
		SELECT
			ID,
			FULL_NAME,
			AGE,
			MARITAL_STATUS,
			EMAIL,
			PHONE,
			SPLIT_PART(FULL_ADDRESS, ',', 1) AS "street_address",
			SPLIT_PART(FULL_ADDRESS, ',', 2) AS "city",
			SPLIT_PART(FULL_ADDRESS, ',', 3) AS "state",
			JOB_TITLE,
			MEMBERSHIP_DATE
		FROM
			CLUB_MEMBER
	);

--A new table has been created to update the split_part() function and integrate it with the table
SELECT
	*
FROM
	CLEAN_CLUB_MEMBER;

-- To check the new table
--To check if all the States are correctly spelt
SELECT
	STATE,
	COUNT(STATE)
FROM
	CLEAN_CLUB_MEMBER
GROUP BY
	STATE
ORDER BY
	STATE;

--A few names are mispelt and the should be corrected
--1. Some States are mispelt as Tejas instead of Texas
SELECT
	STATE
FROM
	CLEAN_CLUB_MEMBER
WHERE
	STATE LIKE 'Kali%';

UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'Texas'
WHERE
	STATE LIKE 'Tej%';

--2. Some states are mispelt as Kalifornia instead of California
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'California'
WHERE
	STATE LIKE 'Kali%';

--3. Some States are mispelt Kansus instead of Kansas
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'Kansas'
WHERE
	STATE = 'Kansus';

--4. Some States are mispelt South Dakotaaa instead of South Dakota
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'South Dakota'
WHERE
	STATE LIKE 'South Dakotaa%';

--5.Some States are mispelt Tennesseeee instead of Tennessee
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'Tennessee'
WHERE
	STATE = 'Tennesseeee';

--6. Some States are mispelt Districts of Columbia instead of District of Columbia
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'District of Columbia'
WHERE
	STATE = 'Districts of Columbia';

--7.Some States are mispelt NorthCarolina instead of District of North Carolina
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'North Carolina'
WHERE
	STATE = 'NorthCarolina';

--8. There is an additional space in front of Puerto Rico
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'Puerto Rico'
WHERE
	STATE = ' Puerto Rico';

--9.Some States are mispelt NewYork instead of District of New York
UPDATE CLEAN_CLUB_MEMBER
SET
	STATE = 'New York'
WHERE
	STATE = 'NewYork';

--The job_title column has a quality and reliable row
SELECT
	JOB_TITLE,
	COUNT(JOB_TITLE)
FROM
	CLEAN_CLUB_MEMBER
GROUP BY
	JOB_TITLE
ORDER BY
	JOB_TITLE;

--Membership date column
--Some dates are in 1900s, they are incorrect and should be changed to 2000s
SELECT
	EXTRACT(
		'year'
		FROM
			MEMBERSHIP_DATE
	)
FROM
	CLEAN_CLUB_MEMBER
WHERE
	EXTRACT(
		'year'
		FROM
			MEMBERSHIP_DATE
	) < 2000;

--To replace the 19s with 20s
UPDATE CLEAN_CLUB_MEMBER
SET
	MEMBERSHIP_DATE = REPLACE(MEMBERSHIP_DATE::TEXT, '19', '20')::DATE
WHERE
	EXTRACT(
		'year'
		FROM
			MEMBERSHIP_DATE
	) < 2000;

SELECT
	*
FROM
	CLEAN_CLUB_MEMBER;

--Final output to CSV file
COPY CLEAN_CLUB_MEMBER TO 'C:\Program Files\PostgreSQL\16\data\data_copy\clean_club_member.csv' DELIMITER ',' CSV HEADER;