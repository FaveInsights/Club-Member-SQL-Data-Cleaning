--Creating columns and setting up the table structure
create table club_member(
full_name varchar(50),
age int,
marital_status varchar(30),
email varchar(60),
phone varchar(20),
full_address text,
job_title varchar(40),
membership_date date
)

--Copying rows from the CSV file into the table
copy club_member from 'C:\Program Files\PostgreSQL\16\data\data_copy\club_member_info.csv' delimiter ',' csv header;

--checking the full table 
select * from club_member;

--Creating a duplicate table so that I can work on the main table
select * from duplicated_club_member2 as select * from club_member;

/*	After a thorough inspection, the following were discrepancies observed
		1. Some data in the full_name row contains special characters

*/

select id,full_name, age from club_member;

--To capitalize the First letter of full_name
update club_member set full_name =initcap(full_name);

--To remove all special characters in the full_name column, this command would leave a-z, A-Z and space
update club_member set full_name = Regexp_replace(full_name, '[^a-zA-Z ]','','g');

--To remove unwanted spaces in the first_name
update club_member set full_name=ltrim(full_name);

--To add a primary id new column 
alter table club_member add column id serial primary key;

--Some of the fields in age column have three figures,, the last one is a mistake so it has to be removed
--Since the data type is an integer, divide by 10
update club_member set age = age/10 where age>99;

--To check if there is spelling error in marital_status column
select id,marital_status from club_member where marital_status not in ('single','married','separated','divorced');

--Some fields were spelt as divored instead of divorced --277 307
update club_member set marital_status='divorced' where marital_status = 'divored'

--To capitalize the marital_status column
update club_member set marital_status =initcap(marital_status);

---To check if there are duplicate email addresses
select email, count(email) from club_member group by email having count(email) > 1;
--- There are duplicate values, to delete them run
delete from club_member where id in (select id from (select id, row_number() over(partition by email order by id asc) as row_num from club_member) email where email.row_num > 1);

--Next is the phone column, there are 5 entries where the phone length is less than 12,
--This is invalid so we will set it to null
update club_member set phone=null where length(phone)<12;

--Next column is the full_address column. It can be seen that the street name_city and state are all together and they should be separated
select full_address from club_member;
create table clean_club_member as select * from (select id, full_name, age, marital_status, email, phone, split_part(full_address, ',', 1) as "street_address", split_part(full_address, ',', 2) as "city", split_part(full_address, ',', 3) as "state",job_title,membership_date from club_member);
--A new table has been created to update the split_part() function and integrate it with the table

select * from clean_club_member; -- To check the new table

--To check if all the States are correctly spelt
select state, count(state) from clean_club_member group by state order by state;

--A few names are mispelt and the should be corrected

--1. Some States are mispelt as Tejas instead of Texas
select state from clean_club_member where state like 'Kali%';
update clean_club_member set state = 'Texas' where state like 'Tej%';
--2. Some states are mispelt as Kalifornia instead of California
update clean_club_member set state = 'California' where state like 'Kali%';
--3. Some States are mispelt Kansus instead of Kansas
update clean_club_member set state = 'Kansas' where state = 'Kansus';
--4. Some States are mispelt South Dakotaaa instead of South Dakota
update clean_club_member set state = 'South Dakota' where state like 'South Dakotaa%';
--5.Some States are mispelt Tennesseeee instead of Tennessee
update clean_club_member set state = 'Tennessee' where state = 'Tennesseeee';
--6. Some States are mispelt Districts of Columbia instead of District of Columbia
update clean_club_member set state = 'District of Columbia' where state = 'Districts of Columbia';
--7.Some States are mispelt NorthCarolina instead of District of North Carolina
update clean_club_member set state = 'North Carolina' where state = 'NorthCarolina';
--8. There is an additional space in front of Puerto Rico
update clean_club_member set state = 'Puerto Rico' where state = ' Puerto Rico';
--9.Some States are mispelt NewYork instead of District of New York
update clean_club_member set state = 'New York' where state = 'NewYork';

--The job_title column has a quality and reliable row
select job_title, count(job_title) from clean_club_member group by job_title order by job_title;

--Membership date column
--Some dates are in 1900s, they are incorrect and should be changed to 2000s
select extract('year' from membership_date) from clean_club_member where extract('year' from membership_date)<2000; 

--To replace the 19s with 20s
update clean_club_member
set membership_date = replace(membership_date::text, '19','20')::date
where extract('year' from membership_date) < 2000;

select * from clean_club_member;

--Final output to CSV file
copy clean_club_member to 'C:\Program Files\PostgreSQL\16\data\data_copy\clean_club_member.csv' delimiter ',' csv header;