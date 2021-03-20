/* DATA ANALYSIS, MODIFICATIONS AND IMPUTATIONS*/

dm 'clear log'; dm 'clear output';

libname project1 "C:\Users\mxs190046\Desktop\Predictive_SAS_Directory\SAS_Project";
title;
/* Reading the csv*//* 539759 rows and 25 variables */
proc import out = work.vehicles1
		datafile = "C:\Users\mxs190046\Desktop\Predictive_SAS_Directory\vehicles.csv"
		dbms=csv replace;
		getnames = yes;
		datarow = 2;
run;

/* INITIAL EXPLORATORY ANALYSIS*/

proc contents data = work.vehicles1 varnum;
run;



/* Dropping the non important variables*/
 
data vehicles1(DROP = url region_url lat long description county image_url); 
set vehicles1;
run;
/* 539759 observations and 18 variables */

proc print data=work.vehicles1(obs=10);
run;

/* REPORTING MISSING VALUES FOR EACH VARIABLE */

proc sql;
   select count(distinct(model)) as unique_model
   from work.vehicles1;
quit;
/* 32980 unique car models in this dataset */

proc freq data=vehicles1;
	tables model / nocum missing;
	run;
/* 1.48% missing values */

proc sql;
   select count(distinct(region)) as unique_region
   from work.vehicles1;
quit;
/* Listing from 388 unique regions*/
%let TopN = 10;
proc freq data=vehicles1 ORDER=FREQ; /* ordering by highest frequncy */
  tables region / nocum missing maxlevels=&TopN Plots=FreqPlot;
run;
/* Listing distinct Manufactureres*/

proc sql;
   select count(distinct(manufacturer)) as unique_manufacturer
   from work.vehicles1;
quit;
/* Listing from 43 unique manufacturer */

proc freq data=vehicles1 ORDER = freq;
	tables manufacturer / nocum maxlevels=&TopN Plots=freqplot;
	run;
/* 4.37% missing values */
/* Listing different values of cylinders*/

proc sql;
   select count(distinct(cylinders)) as unique_cylinders
   from work.vehicles1;
quit;
/* 8 type of cylinder configurations in these vehicles listing */

proc freq data=vehicles1;
	tables cylinders / nocum missing;
	run;
/* 40.48% missing values in cylinders */

/*Listing consitions*/
proc sql;
   select count(distinct(condition)) as unique_conditon
   from work.vehicles1;
quit;
/* 6 type of vehicle conditions */

proc freq data=vehicles1;
	tables condition / nocum missing;
	run;
/* 43.73% missing values, 26.42% excellent, 1.65% fair, 22.22% good, 5.54% like new, 0.3% new, 0.14% salvage */


proc freq data=vehicles1;
	tables fuel / nocum missing; 
	run;
/* 0.63% missing values, 8.2% diesel, 0.2% electrical, 86.91% gas, 0.79% hybrid, 3.28% other */


proc freq data=vehicles1;
	tables title_status / nocum missing;
	run;
/* 0.54% missing values, 95.21% clean, 0.6% lien, 0.13% missing, 0.04% parts only, 2.41% rebuilt, 1.07% salvage */


proc freq data=vehicles1;
	tables transmission / nocum missing; 
	run;
/* 0.74% missing values, 88.18% automatic, 6.48% manual. 4.61% other */


proc freq data=vehicles1;
	tables size / nocum missing;
	run;
/* 68.77% missing values, 4.63% compact, 17.15% full-size, 8.71% mid size, 0.73% sub-compact */


proc freq data=vehicles1;
	tables drive / nocum missing;
	run;
/* 28.86% missing values, 33.09% 4wd, 24.67% fwd, 13.39 rwd */


proc freq data=vehicles1;
	tables type / nocum missing;
	run;
/* 13 types of vehciles */
/* 27.32% missing values, 18.29% sedan, 18.11% SUV, 9.72% pickup, 9.72% truck */
/* might drop */

proc freq data=vehicles1;
	tables paint_color / nocum missing;
	run;
/* 12 different types of paint color on vehicles */
/* 32.28% missing values, 17.70% white followed by 13.71% black */


proc freq data=vehicles1 order= freq;
	tables state / nocum missing maxlevels=&TopN plots=freqplot;
	run;
/* Checking the count of null values in id, vin, odometer, price */
proc sql;
	select count(*) as id_null from work.vehicles1 where id IS NULL;
	quit;
/* no missing values */

proc sql;
	select count(*) as vin_null from work.vehicles1 where vin IS NULL;
	quit;
/* 224371 missing values */

proc sql;
	select count(*) as odometer_null from work.vehicles1 where odometer IS NULL;
	quit;
/* 98976 missing values */

proc sql;
	select count(*) as price_null from work.vehicles1 where price = 0;
	quit;
/* 44689 rows where price is zero */

/***********************************************************************************************************************/
/*IMPUTATION STARTS*/

/* IMPUTING VALUES FOR FIELDS WHERE NUMBER OF CYLINDERS IS MISSING - FULL DETAILS MENTIONED IN REPORT */



proc sql;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' 
	and model in('silverado','silverado 1', 'f-250','silverado 2','tahoe','f-350')
	and id > 7065764796 and id  <= 7093536715 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' 
	and model in('explorer','grand carav', 'wrangler un','edge')
	and id > 7065764796 and id  <= 7093536715 ;
	update work.vehicles1 set cylinders = '4 cylinders' where cylinders=' ' 
	and model in('civic','focus', 'corolla','cruze')
	and id > 7065764796 and id  <= 7093536715 ;
	quit;

/* Half and Half */
proc sql;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' and model in('charger','2500','mustang','f-150') 
	and id > 7065764796 and id  < 7079650756;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in('charger','2500','mustang','f-150') 
	and id > 7079650756 and id  < 7093536715 ;
	quit;

/* 1/3rd and 2/3rd */
proc sql;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model ='1500' and id > 7065764796 and id  < 7075022102 ;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' and model ='1500' and id > 7075022102 and id  < 7093536715 ;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' and model in ('grand chero','tacoma','3500') and id > 7065764796 and id  < 7075022102 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in ('grand chero','tacoma','3500') and id > 7075022102 and id  < 7093536715 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in ('sierra','escape','accord','malibu','equinox') and id > 7065764796 and id  < 7075022102 ;
	update work.vehicles1 set cylinders = '4 cylinders' where cylinders=' ' and model in ('sierra','escape','accord','malibu','equinox','fusion') and id > 7075022102 and id  < 7093536715 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in ('fusion') and id > 7065764796 and id  < 7075022102 ;
    quit;

/* 1/10th */
proc sql;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in ('sierra 1500','expedition') and id > 7065764796 and id  < 7068541988 ;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' and model in ('sierra 1500','expedition') and id > 7068541988 and id  < 7093536715 ;
	quit;

proc sql;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' ' and model in ('impala','wrangler') and id > 7065764796 and id  < 7068541988 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in ('impala','wrangler') and id > 7068541988 and id  < 7093536715 ;
	quit;

proc sql;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' ' and model in('altima','camry') and id > 7065764796 and id  < 7068541988 ;
	update work.vehicles1 set cylinders = '4 cylinders' where cylinders=' ' and model in('altima','camry') and id > 7068541988 and id  < 7093536715 ;
	quit;
proc freq data=work.vehicles1;
	tables cylinders / nocum missing;
	run;
proc sql;
	update work.vehicles1 set cylinders = '8 cylinders' where cylinders=' '  and id > 7065764796 and id  < 7075022102 ;
	update work.vehicles1 set cylinders = '6 cylinders' where cylinders=' '  and id > 7075022102 and id  < 7084279408 ;
    update work.vehicles1 set cylinders = '4 cylinders' where cylinders=' '  and id > 7084279408 and id  < 7093536715; 
	quit;
/************************************************************************************************************************/
/* IMPUTING VALUES FOR MODEL, MANUFACTURER */
proc sql;
	update work.vehicles1 set model = 'Chevrolet' where lower(model) like '%chevrolet%'; 
	update work.vehicles1 set model = 'Corolla' where lower(model) like '%corolla%';
	update work.vehicles1 set model = 'Maserati' where lower(model) like '%maserati%';
	update work.vehicles1 set model = 'F-150' where model like '%F-150%';
	update work.vehicles1 set model = 'Escalade' where lower(model) like '%escalade%';
	update work.vehicles1 set model = 'Buick' where lower(model) like '%buick%';
	update work.vehicles1 set model = 'Odyssey' where lower(model) like '%odyssey%';
	update work.vehicles1 set model = 'CR-V' where UPPER(model) like '%CR-V%';
	update work.vehicles1 set model = 'Forester' where lower(model) like '%forester%';
	update work.vehicles1 set model = 'Impala' where lower(model) like '%impala%';
	update work.vehicles1 set model = 'Pilot' where lower(model) like '%pilot%';
	update work.vehicles1 set model = 'Outlander' where lower(model) like '%outlander%';
	update work.vehicles1 set model = 'Passat' where lower(model) like '%passat%';
	update work.vehicles1 set model = 'Roadster' where lower(model) like '%roadster%';
	update work.vehicles1 set model = 'Silverado' where lower(model) like '%silverado%';
	update work.vehicles1 set model = 'Yaris' where lower(model) like '%yaris%';
	update work.vehicles1 set manufacturer = 'suzuki' where model like '%ZUK%';
	quit;
/* 53136 rows were updated */


proc sql;
	delete from work.vehicles1 where model in('0','000','0000','00000','000000000','0000000000'); 
	quit;
/* 6 rows deleted */ 

proc sql;
	update work.vehicles1 set model= substr(model,4) where substr(model,1,2) like('0_');
	quit;
/* 48 rows updated */

proc freq data=work.vehicles1;
	tables model / nocum missing;
	run;
/************************************************************************************************************************/

proc sql;
	select count(*) from work.vehicles1 where manufacturer IS NULL; /*23584 missing values */
	quit; /* now reduced to 14366 missing values  */

proc sql;
	select manufacturer, model from work.vehicles1 where manufacturer is null;
	quit;

/* Correcting spelling for porsche */

proc sql;
	update work.vehicles1 set manufacturer = 'porsche' where manufacturer like '%porche%';
	quit;
/* 13 rows updated */

/* Updating manufacturer as per model, by searching on google for which model belongs to which manufacturer */

proc sql;
	update work.vehicles1 set manufacturer = 'infiniti' where lower(model) like '%infiniti%';
	update work.vehicles1 set manufacturer = 'isuzu' where lower(model) like '%isuzu%';
	update work.vehicles1 set manufacturer = 'maserati' where lower(model) like '%maserati%';
	update work.vehicles1 set manufacturer = 'chevrolet' where lower(model) like '%camaro%' or lower(model) like '%corvette%'
	or lower(model) like '%impala%' or lower(model) like '%mali%' or lower(model) like '%traverse%' 
	or lower(model) like '%camino%' or lower(model) like '%suburban%' or lower(model) like '%tahoe%' 
	or lower(model) like '%sonic%' or lower(model) like '%carlo%' or lower(model) like '%avalanche%'
	or lower(model) like '%cruz%';
	update work.vehicles1 set manufacturer = 'smart' where lower(model) like '%smart%';
	update work.vehicles1 set manufacturer = 'maserati' where lower(model) like '%maserati%';
	update work.vehicles1 set manufacturer = 'gmc' where lower(model) like '%silverado%';	
	update work.vehicles1 set manufacturer = 'gmc' where lower(model) like '%hummer%';
	update work.vehicles1 set manufacturer = 'gmc' where lower(model) like '%ierra%';
	update work.vehicles1 set manufacturer = 'porsche' where lower(model) like '%porsche%';
	update work.vehicles1 set manufacturer = 'hyundai' where lower(model) like '%genesis%' or lower(model) like '%elantra%'
	lower(model) like '%sonata%' or lower(model) like '%accent%' or lower(model) like '%tucson%';
	update work.vehicles1 set manufacturer = 'hyundai' where lower(model) like '%santa%';
	quit;
/* 50267 rows were updated */

/* DELETED THESE ROWS BECAUSE ON RESEARCHING WE FOUND THAT IS NO SUCH MODEL. IT IS ONE OF THE PARTS OF A CAR*/

proc sql;
	delete from work.vehicles1 where model = 'olet Silver';
	quit;
/* 195 model with olet silver deleted */

/* IMPUTING MANUFACTURERS BASED ON MADELS*/

proc sql;
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%f-250%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%mustang%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%f-150%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%f-350%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%expedition%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%escape%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%explorer%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%excursion%';
	update work.vehicles1 set manufacturer = 'ford' where lower(model) like '%focus%' or lower(model) like '%fusion%';
quit;
/* 23205 rows were updated */

proc sql;
	update work.vehicles1 set manufacturer = 'chrysler' where lower(model) like '%ram%';
	update work.vehicles1 set manufacturer = 'chrysler' where lower(model) like '%caravan%';
	update work.vehicles1 set manufacturer = 'chrysler' where lower(model) like '%cherokee%' 
	or lower(model) like '%wrangler%';
	update work.vehicles1 set manufacturer = 'chrysler' where lower(model) like '%compass%';
	update work.vehicles1 set manufacturer = 'honda' where lower(model) like '%crv%';
	update work.vehicles1 set manufacturer = 'honda' where lower(model) like '%accord%' or lower(model) like '%odyssey%';
	update work.vehicles1 set manufacturer = 'honda' where lower(model) like '%civic%' or lower(model) like '%pilot%';
	update work.vehicles1 set manufacturer = 'volkswagen' where lower(model) like '%bentley%';
	update work.vehicles1 set manufacturer = 'volkswagen' where lower(model) like '%jetta%';
	update work.vehicles1 set manufacturer = 'volkswagen' where lower(model) like '%passat%';
	update work.vehicles1 set manufacturer = 'subaru' where lower(model) like '%forester%' or lower(model) like '%subaru%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%corolla%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%4runner%' or lower(model) like '%tacoma%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%prius%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%scion%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%camry%';
	update work.vehicles1 set manufacturer = 'toyota' where lower(model) like '%highlander%';
	update work.vehicles1 set manufacturer = 'nissan' where lower(model) like '%sentra%';
	update work.vehicles1 set manufacturer = 'nissan' where lower(model) like '%armada%';
	update work.vehicles1 set manufacturer = 'nissan' where lower(model) like '%versa%' or lower(model) like '%maxima%';
	update work.vehicles1 set manufacturer = 'volvo' where lower(model) like '%volvo%';
	update work.vehicles1 set manufacturer = 'mercedes-benz' where lower(model) like '%merc%' or lower(model) like '%benz%';
	update work.vehicles1 set manufacturer = 'kia' where lower(model) like '%soul%' or lower(model) like '%sorento%'
	or lower(model) like '%forte%';
	update work.vehicles1 set manufacturer = 'cadillac' where lower(model) like '%escalade%';
	quit;
/* 115900 rows were updated */

proc sql;
	update work.vehicles1 set manufacturer = 'audi' where lower(model) like '%audi%';
	update work.vehicles1 set manufacturer = 'bmw' where lower(model) like '%bmw%';
	quit;
/* 70 rows were updated */

proc sql;
	update work.vehicles1 set manufacturer = 'dodge' where lower(model) like '%dodge%' or lower(model) like '%challenger%'
	or lower(model) like '%charger%' or lower(model) like '%durango%' or lower(model) like '%dart%'
	or lower(model) like '%avenger%' or lower(model) like '%journey%';
	quit;
/* 10917 rows updated */
proc sql;	
	update work.vehicles1 set manufacturer = 'suzuki' where model like '%ZUK%';
	update work.vehicles1 set manufacturer = 'ram' where model like '%RAM%';
	update work.vehicles1 set manufacturer = 'suzuki' where model like '%Suz%';
	update work.vehicles1 set manufacturer = 'mazda' where model like '%Mazda%';
	update work.vehicles1 set manufacturer = 'rolls royce' where model like '%Rolls-Royce%';
	update work.vehicles1 set manufacturer = 'lamborghini' where model like '%Lamborghini%';
	quit;
/* 517 rows were updated*/	
proc freq data=vehicles1;
	tables manufacturer / nocum missing;
	run;

/* We tried to generalise the most common values for reducing the missing number of observations */
/************************************************************************************************************************/

/* RESTRICT PRICE maybe 60-70k, check after creating histogram*/
/* Check which cares are more than 60-70k */
/* Assume 2lakh upper price is erroneous, include less than 2lakh, remove rows more than 2 laKh, plot ahistogram of this data,
this tells us that 60k cars are there, 60k to 2lakh are luxurious and less in number, include only till 60k */

proc sql;
	select count(*) from work.vehicles1 where price > 200000;
	quit;
/* 162 cars have price more than $200000, which can either belong to highly luxurious segment or are erroneous */

proc sql;
	select * from work.vehicles1 where price > 200000;
	quit;
/* Creating a histogram to check the distribution of price variable */

proc univariate data = vehicles1;
	var price;
	histogram;
	run;
/* Deleting observations with price > 200000 beacuse the data looks bad and faulty*/

proc sql;
	delete from work.vehicles1 where price > 200000;
	quit;

/* Plotting a histogram of this price upto 200000 to get a better idea about the distribution*/
proc univariate data = vehicles1;
	var price;
	histogram;
	run;
/* We can see from this distribution that there are a very few cars having price more than 60,000 till 200,000 */

proc sql;
	select count(*) from work.vehicles1 where price > 60000;
	quit;
/* 2570 cars have price more than 60k, upto 200k */

/* This is from luxurious category and very less in number so not including for our analysis */

proc sql;
	select * from work.vehicles1 where price > 60000;
	quit;
proc sql;
	delete from work.vehicles1 where price > 60000;
	run;
/* 2570 entries were deleted */

/* Now creating a distribution of price upto 60k to get a better idea about distribution . 
   We can see that distribution has improved a lot*/

proc univariate data=vehicles1;
   var price;
   histogram  / midpoints = 0 to 60000 by 1000;
run;

/***********************************************************************************************************************/
/* RESTRICTING YEAR BETWEEN 1900 AND 2020 */

proc sql;
	delete from work.vehicles1 where year IS NULL;
	quit;
/* Deleted those 942 values */

proc sql;
	select count(*) from work.vehicles1 where year > 2020;
	quit;
/* 100 entries having year greater than 2020. Deleting those rows */

proc sql;
	delete from work.vehicles1 where year > 2020;
	delete from work.vehicles1 where year < 1900;
	quit;
/* 101 rows deleted */

/* IMPUTING ODOMETER  BASED ON GROUPING BY YEAR- MORE DETAILS IN REPORT*/
proc sql;
	select year,mean(odometer) from work.vehicles1 group by year;
	run;

proc sql;
  create table Odom1 as (Select odometer,year from work.vehicles1);
  run;

 proc sql;
  insert into Odom1(odometer,year)select odometer,year from work.vehicles1;
  run;

 proc sql;
	update work.vehicles1 v1 set odometer= (select mean(odometer) from Odom1 v2 where v2.year=v1.year) where odometer is null;
	run;
/* 98403 rows updated */

/************************************************************************************************************************/
/* DROPPING SIZE AND CONDITION AND VIN BECAUSE OF A HIGH PERCENTAGE OF NULL VALUES */

data vehicles1(DROP =  size condition vin); 
	set vehicles1;
	run;
/* Dropping vin because all values are not unique for vin and it also has a high number of misisng values .
	vin should ideally be unique for all and imputing the values for vin will not make sense*/

proc contents data = work.vehicles1 varnum;
run;
/* 535978 observations and 15 variables */

/* DELETING ALL ROWS WITH NULL VALUES */ 

data work.vehicles1; 
	set work.vehicles1; 
	if nmiss(of _numeric_) + cmiss(of _character_) > 0 then delete; 
	run;
/* 271663 values and 15 variables */


proc contents data = work.vehicles1 varnum;
run;

/* CHECKING ALL UNIQUE VALUES, MAX, MIN, FREQUENCY DISTRIBUTION OF THE REMAINING VARIABLES
   AND SEE IF WE FURTHERR NEED TO DROP ANY VALUES */

proc sql;
   select count(distinct(model)) as unique_model
   from work.vehicles1;
quit;
/* 12744, very high number of unique values */

proc freq data=vehicles1;
	tables model / nocum missing;
	run;


%let TopN = 10;

proc freq data=vehicles1 ORDER=FREQ; /* ordering by highest frequncy */
  tables region / nocum missing maxlevels=&TopN Plots=FreqPlot;
run;
/* Display top 10 regions */


proc sql;
	select count(distinct(manufacturer)) as unique_manufacturer
	from work.vehicles1;
quit;

/* Show a distribution of manufacturer */
proc freq data=vehicles1 order = freq;
	tables manufacturer / nocum missing maxlevels = &TopN plots = freqplot;
	run;
/* Distribution of cylinders*/

proc freq data=vehicles1 order=freq;
	tables cylinders / nocum missing plots = freqplot;
	run;

/* Distribution of fuel*/

proc freq data=vehicles1 ORDER=FREQ;
	tables fuel / nocum missing plots = freqplot; 
	run;
/* Distribution of title_status */


proc freq data=vehicles1 order=freq;
	tables title_status / nocum missing plots = freqplot;
	run;
/* Distribution of transmission*/


proc freq data=vehicles1;
	tables transmission / nocum missing plots = freqplot; 
	run;
/* Distribution of drive */


proc freq data=vehicles1;
	tables drive / nocum missing plots = freqplot;
	run;
/* Distribution of type */


proc freq data=vehicles1 order = freq;
	tables type / nocum missing plots = freqplot;
	run;
/* Paint coolor*/


proc freq data=vehicles1 order=freq;
	tables paint_color / nocum missing plots = freqplot;
	run;
/* 12 different types of paint color on vehicles */

/* CONVERTING PRICE AND ODOMETER TO CATEGORICAL VARIABLES*/
/* ADDING TWO NEW CATEGORICAL VARIABLES 'Odom' and 'Price_Categ' for Odometer and Price respectively*/

proc sql; 
     ALTER TABLE work.vehicles1
     ADD odo_cat varchar(20);
quit;
/*  Based on research on google, it was found that very few vehicles actually have travelled more than 350,000 miles
    and then this distribution was decided */
 
proc sql;
    update work.vehicles1 set odo_cat='0-50000' where odometer<=50000;
	update work.vehicles1 set odo_cat='50001-100000' where odometer<=100000 and odometer>50000;
	update work.vehicles1 set odo_cat='100001-150000' where odometer<=150000 and odometer>100000;
	update work.vehicles1 set odo_cat='150001-200000' where odometer<=200000 and odometer>150000;
    update work.vehicles1 set odo_cat='200001-250000' where odometer<=250000 and odometer>200000;
    update work.vehicles1 set odo_cat='>250000' where odometer>250000;
quit;

proc sql; 
    ALTER TABLE work.vehicles1
     ADD price_cat varchar(20);
quit;


/* After checking the percentiles for price, we decided to divide price into following 4 categories */   

proc means data=work.vehicles1 noprint;
 var Price;
 output out=abc P25= P50= P75= / autoname;
run; 
proc sql;
    update work.vehicles1 set price_cat='L1' where price<6000;
	update work.vehicles1 set price_cat='L2' where price>6000 and price<12000;
	update work.vehicles1 set price_cat='L3' where price>12000 and price<20000;
	update work.vehicles1 set price_cat='L4' where price>20000 and price<=60000;
quit;

/* We will also create one more variable price_cat1, dividing price into binary categories for running different models.*/
proc sql; 
    ALTER TABLE work.vehicles1
     ADD price_cat1 varchar(20);
quit;    
proc sql;
    update work.vehicles1 set price_cat1='reasonable' where price<20000;
	update work.vehicles1 set price_cat1='expensive' where price>20000;
quit;
/*We are trying conversions on Price to improve the distribution*/

data work.vehicles1;
set work.vehicles1;
logprice=log(price);
run;
data work.vehicles1;
set work.vehicles1;
priceReciprocal=1/price;
run;
proc means skewness;
var logprice;
run;
proc means skewness;
var price;
run;
proc means skewness;
var priceReciprocal;
run;
/*  We can see that if e convert data into log or 1/price, the skewness is increasing. 
     So we will not be doing these transformations*/

/* After checking these distributions we decided to drop rows where price = 0. Also, reasoning behind why 
   we converted price to a categorical variable and not log or reciprocal. */ 
proc sql;
	delete from work.vehicles1 where price = 0;
	quit;


/************************************************************************************************************************/
/* CREATE A NEW DATASET OR CSV HERE TO USE FOR MODELING */
proc export data=work.vehicles1
	outfile = 'C:\Users\mxs190046\Desktop\Predictive_SAS_Directory\vehicles_update2.csv'
	dbms=csv;
	run;
proc contents data=work.vehicles1;
run;
/* 251135 observations and 17 variables */
/***********************************************************************************************************************/ 














