#MYSQL Assignment by Sachin Katiyar - DS Cohort 10

#Dropping schema named assignment if already exists.
drop schema if exists `assignment`;
#Creating schema named "Assignment"
create schema `assignment`;

#Using assignment schema
use `assignment`;

#Removing strict mode from mysql
SET SESSION sql_mode = "";

#Creating table bajaj_auto with columns and its data types same as provided in csv files
create table `bajaj_auto` (
	`Date` 					varchar(20),
	`Open_Price`			DECIMAL(10,2) default NULL,
	`High_Price`			DECIMAL(10,2) default NULL,
	`Low_Price`				DECIMAL(10,2) default NULL,
	`Close_Price`			DECIMAL(10,2) default NULL,
	`WAP`					DECIMAL(10,2) default NULL,
	`No_of_Shares`			INTEGER(10) default NULL,
	`No_of_Trades`			INTEGER(10) default NULL,
	`Total_Turnover`		BIGINT(10) default NULL,
	`Deliverable_Quantity`	INTEGER(10) default NULL,
	`Percentage_Deli_Qty_to_Traded_Qty`	DECIMAL(10,2) default NULL,
	`Spread_High_Low`		DECIMAL(10,2) default NULL,
	`Spread_Close_Open`		DECIMAL(10,2) default NULL,
	PRIMARY KEY (`Date`));

# Since structure of all csv provided are same thus table structure will also be same therefore creating tables named eicher_motors, 
# hero_motocorp, infosys, tcs and tvs_motors using existing structure of bajaj_auto table
create table `eicher_motors` like `bajaj_auto`;
create table `hero_motocorp` like `bajaj_auto`;
create table `infosys` like `bajaj_auto`;
create table `tcs` like `bajaj_auto`;
create table `tvs_motors` like `bajaj_auto`;

#-------------------------------------------------------------------------------------------------------------------------------------------

#Loading data into bajaj_auto from given Bajaj Auto.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/Bajaj Auto.csv' 
INTO TABLE bajaj_auto 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Loading data into eicher_motors from given Eicher Motors.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/Eicher Motors.csv' 
INTO TABLE eicher_motors 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Loading data into hero_motocorp from given Hero Motocorp.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/Hero Motocorp.csv' 
INTO TABLE hero_motocorp 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Loading data into infosys from given Infosys.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/Infosys.csv' 
INTO TABLE infosys 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Loading data into tcs from given TCS.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/TCS.csv' 
INTO TABLE tcs 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#Loading data into tvs_motors from given TVS Motors.csv file ignoring header
LOAD DATA  INFILE 'D:/Assignment/TVS Motors.csv' 
INTO TABLE tvs_motors 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#-------------------------------------------------------------------------------------------------------------------------------------------

#setting SQL_SAFE_UPDATES to 0 to avoid error of "absense of where clause" while updating table
set SQL_SAFE_UPDATES = 0;

# LPAD 0 in date if day no in date is of one character, then take first three letters of month with day and concat it with year. 
# Finally convert this string into date format. Doing this for all stocks table.

update bajaj_auto set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update bajaj_auto set `date` = concat(substring(`date`,1,6),right(`date`,5));
update bajaj_auto set `date` = str_to_date(`date`, '%d-%M-%Y');

update eicher_motors set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update eicher_motors set `date` = concat(substring(`date`,1,6),right(`date`,5));
update eicher_motors set `date` = str_to_date(`date`, '%d-%M-%Y');

update hero_motocorp set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update hero_motocorp set `date` = concat(substring(`date`,1,6),right(`date`,5));
update hero_motocorp set `date` = str_to_date(`date`, '%d-%M-%Y');

update infosys set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update infosys set `date` = concat(substring(`date`,1,6),right(`date`,5));
update infosys set `date` = str_to_date(`date`, '%d-%M-%Y');

update tcs set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update tcs set `date` = concat(substring(`date`,1,6),right(`date`,5));
update tcs set `date` = str_to_date(`date`, '%d-%M-%Y');

update tvs_motors set `date` = if(length(substring_index(`date`,"-",1))=1,LPAD(`date`,length(`date`)+1,'0'),`date`);
update tvs_motors set `date` = concat(substring(`date`,1,6),right(`date`,5));
update tvs_motors set `date` = str_to_date(`date`, '%d-%M-%Y');

#-------------------------------------------------------------------------------------------------------------------------------------------

#Creating a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA.
create table bajaj1 
	select 
		`date`,
        Close_Price,
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
	from bajaj_auto
    window w as (order by `date`);

select * from bajaj1;

#Creating a new table named 'tcs1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA. 
create table tcs1
	select 
		`date`, 
        Close_Price,
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
	from tcs
    window w as (order by `date`);

select * from tcs1;

#Creating a new table named 'tvs1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA.
create table tvs1
	select 
		`date`, 
        Close_Price, 
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
	from tvs_motors
    window w as (order by `date`);

select * from tvs1;

#Creating a new table named 'infosys1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA.
create table infosys1
	select 
		`date`, 
        Close_Price, 
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
	from infosys
    window w as (order by `date`);

select * from infosys1;

#Creating a new table named 'eicher1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA.
create table eicher1 
	select 
		`date`,
        Close_Price,
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
	from eicher_motors
    window w as (order by `date`);

select * from eicher1;

#Creating a new table named 'hero1' containing the date, close price, 20 Day MA and 50 Day MA. 20 Day MA and 50 Day MA will have NULL values if enough preceding rows
# are not present before current row i.e. 20 for 20 Day MA and 50 for 50 Day MA.
create table hero1 
	select
		`date`,
        Close_Price, 
        (
			case 
				when ROW_NUMBER() over w >= 20 then avg(Close_Price) over (order by `date` rows 19 preceding) 
				else NULL 
			end 
		)as `20_Day_MA`,
        (
			case 
				when ROW_NUMBER() over w >= 50 then avg(Close_Price) over (order by `date` rows 49 preceding) 
				else NULL 
			end 
		)as `50_Day_MA`
    from hero_motocorp
    window w as (order by `date`);

select * from hero1;
#-------------------------------------------------------------------------------------------------------------------------------------------

#Creating master table that contains the date and close price of all the six stocks
create table master_table(
`date` date,
Bajaj DECIMAL(10,2),
TCS DECIMAL(10,2),
TVS DECIMAL(10,2),
Infosys DECIMAL(10,2),
Eicher DECIMAL(10,2),
Hero DECIMAL(10,2));

#inserting data for bajaj with date while update data for all other stocks by checking date i.e. closing price must be updated with respect to right date column
insert into master_table (`date`,Bajaj) select `Date`, Close_Price from bajaj_auto;
update master_table set TCS = (select Close_Price from tcs where `date` = master_table.`date`);
update master_table set TVS = (select Close_Price from tvs_motors where `date` = master_table.`date`);
update master_table set Infosys = (select Close_Price from infosys where `date` = master_table.`date`);
update master_table set Eicher = (select Close_Price from eicher_motors where `date` = master_table.`date`);
update master_table set Hero = (select Close_Price from hero_motocorp where `date` = master_table.`date`);
commit;

select * from master_table;
#-------------------------------------------------------------------------------------------------------------------------------------------

# Creating two table for temporary use named temp and temp2.
# temp contains columns named row_num, date, Close_Price, 20_Day_MA, 50_Day_MA and check. 
# check column will have value NULL if any of 20_Day_MA or 50_Day_MA value is NULL, 1 if 20_Day_MA is greater than 50_Day_MA, 0 if 20_Day_MA is smaller than 50_Day_MA
# and previous check value if 20_Day_MA is equal to 50_Day_MA. This covers all the boundary line conditions.
# temp2 contains columns named row_num, date, Close_Price, check and old_check. old_check will contain row-value of column check before current row (i.e. previous cell value of check column) order by date.
# Create table with stockname append by number 2 (e.g. bajaj2, tcs2 etc.) that contains column named date, Close_Price and Signal. 
# Signal will be set as Buy when check is not equal to old_check and value of check is 1. It means shorter-term moving average (i.e. 20_Day_MA) crosses above the longer-term moving average (i.e. 50_Day_MA). 
# Signal will be set as Sell when check is not equal to old_check and value of check is 0. It means shorter-term moving average (i.e. 20_Day_MA) crosses below the longer-term moving average (i.e. 50_Day_MA). For all other case, check will be set as Hold.
# Note that check will be NULL for all rows having row_num < 50 this is because longer-term moving average (i.e. 50_Day_MA) will only be correctly calculated after 49 rows order by date in ascending order.

#-------------------------------------------------------bajaj2------------------------------------------------------------------------------
drop table if exists temp;
drop table if exists temp2;

create table temp 
	select 
		 ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
        `Close_Price`,
        `20_Day_MA`,
        `50_Day_MA`,
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check`
	from bajaj1
    window w as (order by `date`);
    
create table temp2 
	select
		`row_num`,
		`date`,
		`Close_Price`,
		`check`, 
		lag(`check`,1) over w as old_check
    from temp
    window w as (order by `date`);

create table bajaj2 
	select 
		`date`, 
		`Close_Price`,
		( 
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
				else 'Hold'
			end
		) as `Signal`
	from temp2;

select * from bajaj2;
#-------------------------------------------------------tcs2------------------------------------------------------------------------------
                    
drop table if exists temp;
drop table if exists temp2;

create table temp 
	select 
		ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
		Close_Price,
        `20_Day_MA`, 
        `50_Day_MA`,
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check` 
	from tcs1
    window w as (order by `date`);
    
create table temp2
	select 
		`row_num`,
		`date`,
        Close_Price, 
        `check`, 
        lag(`check`,1) over w as old_check 
	from temp
    window w as (order by `date`);
    
create table tcs2 
	select 
		`date`,
        Close_Price,
		(
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
                else 'Hold'
			end
		) as `Signal`
	from temp2;

select * from tcs2;
#-------------------------------------------------------tvs2------------------------------------------------------------------------------   
                 
drop table if exists temp;
drop table if exists temp2;

create table temp 
	select 
		ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
        Close_Price,
        `20_Day_MA`,
        `50_Day_MA`,
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check`
	from tvs1
    window w as (order by `date`);
    
create table temp2
	select
		`row_num`,
		`date`,
        Close_Price,
        `check`, 
        lag(`check`,1) over w as old_check 
	from temp
    window w as (order by `date`);
    
create table tvs2 
	select
		`date`, 
        Close_Price, 
		( 
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
                else 'Hold'
			end
		) as `Signal`
	from temp2;  

select * from tvs2;
#-------------------------------------------------------infosys2------------------------------------------------------------------------------

drop table if exists temp;
drop table if exists temp2;

create table temp 
	select 
		ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
        Close_Price,
        `20_Day_MA`,
        `50_Day_MA`, 
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check`
	from infosys1
    window w as (order by `date`);
    
create table temp2
	select
		`row_num`,
		`date` ,
        Close_Price, 
        `check`, 
        lag(`check`,1) over w as old_check 
	from temp
    window w as (order by `date`);
    
create table infosys2 
	select
		`date`,
        Close_Price, 
		( 
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
                else 'Hold'
			end
		) as `Signal`
	from temp2;

select * from infosys2;
#-------------------------------------------------------eicher2------------------------------------------------------------------------------

drop table if exists temp;
drop table if exists temp2;

create table temp 
	select
		ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
        Close_Price,
        `20_Day_MA`,
        `50_Day_MA`,
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check`
	from eicher1
    window w as (order by `date`);
    
create table temp2 
	select
		`row_num`,
		`date`,
        Close_Price,
        `check`,
        lag(`check`,1) over w as old_check 
	from temp
    window w as (order by `date`);
    
create table eicher2 
	select 
		`date`, 
        Close_Price, 
		( 
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
                else 'Hold'
			end
		) as `Signal`
	from temp2;

select * from eicher2;
#-------------------------------------------------------hero2------------------------------------------------------------------------------

drop table if exists temp;
drop table if exists temp2;

create table temp 
	select
		ROW_NUMBER() OVER(w) as `row_num`,
		`date`,
        Close_Price, 
        `20_Day_MA`, 
        `50_Day_MA`,
        if(`20_Day_MA` is NULL or `50_Day_MA`is NULL,NULL,if(`20_Day_MA` > `50_Day_MA`,1,if(`20_Day_MA` < `50_Day_MA`,0,if(lag(`50_Day_MA`,1) over w is NULL,NULL,if(lag(`20_Day_MA`,1) over w > lag(`50_Day_MA`,1) over w,1,0))))) as `check`
	from hero1
    window w as (order by `date`);
    
create table temp2
	select
		`row_num`,
		`date`,
        Close_Price, 
        `check`, 
        lag(`check`,1) over w as old_check
	from temp
    window w as (order by `date`);
    
create table hero2 
	select 
		`date`,
        Close_Price, 
		( 
			case 
				when (`row_num` <50) then Null
				when (`check`<>`old_check` and `check`=1) then 'Buy'
				when (`check`<>`old_check` and `check`=0) then 'Sell'
                else 'Hold'
			end
		) as `Signal`
	from temp2;

select * from hero2;
#------------------------------------------------------------------------------------------------------------------------------------------

# Creating a User defined function, that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.                    
create function `get_signal` 
(
	d varchar(10)
)
returns char(5) deterministic
return 
(
	select `Signal` 
    from bajaj2 
    where `date`=str_to_date(d, '%d-%m-%Y')
);

# Calling user defined function named get_signal and passing date to find SIGNAL value for bajaj stock
select get_signal('18-05-2015') as `SIGNAL`;
#--------------------------------------------------------------------END-------------------------------------------------------------------