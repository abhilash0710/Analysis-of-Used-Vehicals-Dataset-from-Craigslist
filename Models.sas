dm 'clear log'; dm 'clear output';

libname project2 "C:\Users\mxs190046\Desktop\Predictive_SAS_Directory";
title;
/* READING THE FILE CREATED FOR MODELING*/

proc import out = work.vehicles2
		datafile = "C:\Users\mxs190046\Desktop\Predictive_SAS_Directory\vehicles_update2.csv"
		dbms=csv replace;
		getnames = yes;
		datarow = 2;
run;

proc contents data=work.vehicles2;
run;
/* 251135 observations and 17 variables */

proc print data=work.vehicles2(obs=10);
run;

/* Checking association of categorical variables  with price_cat1(Binary).
   All the associations are mentioned in report*/

proc freq data=work.vehicles2;
	tables cylinders*price_cat1 drive*price_cat1 fuel*price_cat1 manufacturer*price_cat1 odo_cat*price_cat1
	region*price_cat1 state*price_cat1 title_status*price_cat1 transmission*price_cat1 type*price_cat1 /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;


/* Association between state and region */	

proc freq data=work.vehicles2;
	tables region*state /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;


/* Model and manufacturer */

proc freq data=work.vehicles2;
	tables model*manufacturer /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;

/* State and manufacturer */

proc freq data=work.vehicles2;
	tables state*manufacturer /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;

/* Drive and type */

proc freq data=work.vehicles2;
	tables drive*type /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;


/* Drive and transmission */

proc freq data=work.vehicles2;
	tables type*transmission /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;
/* ******************************************************************************************** */
/* Checking association of categorical variables  with price_cat(4 categories).
   All the associations are mentioned in report*/

proc freq data=work.vehicles2;
	tables cylinders*price_cat drive*price_cat fuel*price_cat manufacturer*price_cat odo_cat*price_cat
	region*price_cat state*price_cat title_status*price_cat transmission*price_cat type*price_cat /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;


/* NOW STUDY ASSOCIATION BETWEEN VARIOUS PREDICTOR VARIABLES */

/*Cylinders and Drive*/

proc freq data=work.vehicles2;
	tables cylinders*drive /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;
/*Cylinders and fuel*/

proc freq data=work.vehicles2;
	tables cylinders*fuel /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;
/*Manufacturer and Type*/

proc freq data=work.vehicles2;
	tables manufacturer*type /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;
/*Manufacturer and Drive*/

proc freq data=work.vehicles2;
	tables manufacturer*drive /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;
/*Manufacturer and Cylinders*/

proc freq data=work.vehicles2;
	tables manufacturer*cylinders /
		/*plots(only)=freqplot(scale=percent)*/ chisq relrisk norow nocol nopercent;
run;


/**********************************************************************************************************************/
/* MODEL 1 - WITH BINARY PRICE - STEPWISE SELECTION, WITH MANUFACTURER DRIVE TYPE AND ODO_CAT */


proc logistic data=work.vehicles2(obs=80000) 
              plots(only)=(effect (clband x=(manufacturer drive type odo_cat)) 
                           oddsratio (type=horizontalstat));
    class manufacturer (param=ref ref='toyota') 
    	  drive (param=ref ref='4wd')
	      type (param=ref ref='sedan')
		  odo_cat(param=ref ref='50001-100000') / param=ref;
    MLogit1: model price_cat1(ref='expensive') = manufacturer drive type odo_cat / selection= stepwise clodds=pl;
    output out=work.predict predprobs=i;
    title 'Car Model 1';
run;
/*CHECKING ACCURACY*/

proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;

/*******************************************************************************************************************/
/*MODEL 2- ADJACENT ORDINAL MODEL : WITH 4 PRICE CATEGORIES AND 7 VARIABLES AND 251135 OBSERVATIONS(This is MODEL 5 as per the report)*/
	
	ods graphics on;
    proc logistic data=work.vehicles2
          	plots(only)=  ( oddsratio (type=horizontalstat) );
   class cylinders (ref='4 cylinders')   	 
     	title_status (ref='clean')
   	  paint_color ( ref='red')
   	  type (ref='SUV')
   	  fuel(ref = 'gas')
   	 transmission(ref = 'automatic')
   	 drive(ref = 'fwd')
     	/ param=ref;
  	 ordinal1: model price_cat =cylinders type paint_color title_status drive transmission            fuel/
   	LINK=ALOGIT clodds=pl maxiter=1000 selection=stepwise ;
  	 output out=work.predict predprobs=i;
  	 title 'stepwise adj Log Model for all data price_cat =cylinders type paint_color title_status drive transmission fuel ';
    run;
ods graphics off;

/*CHECKING ACCURACY*/

proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;

/**********************************************************************************************************************/
/*  IN ALL THE MODELS FROM NOW, WE WILL NOW ONLY CONSIDER THE OBSERVATIONS OF TOP 10 MANUFACTURER AND STATES TO 
	GET A  MODEL WITH BETTER DATA*/

proc sql;
 select state,count(*) as c  from work.vehicles2 group by state order by c desc;
 select manufacturer,count(*) as ce from work.vehicles2 group by manufacturer order by ce desc;
run;

proc sql;
 delete from work.vehicles2 where state not in('ca','fl','tx','ny','oh','pa','mi','wa','nc','or')
 OR manufacturer not in('ford','chevrolet','gmc','toyota','chrysler','nissan','honda','ram','dodge','bmw');
run;

proc sql;
select distinct state from work.vehicles2;
run;

/*MODEL 3-ADJACENT ORDINAL LOGISTIC - This is MODEL 6 in Report*/

ods graphics on;
proc logistic data=work.vehicles2
          	plots(only)=  ( oddsratio (type=horizontalstat) );
   class cylinders (ref='4 cylinders')   	 
     	title_status (ref='clean')
   	  paint_color ( ref='red')
   	  type (ref='SUV')
   	 odo_cat (ref = '200001-250000')
   	 state (ref = 'nc')
   	 manufacturer (ref = 'ford')
   	 fuel (ref ='gas')
   	 transmission (ref = 'automatic')
     	/ param=ref;
  	 ordinal1: model price_cat =cylinders  type odo_cat paint_color title_status state manufacturer transmission fuel/
   			 LINK=ALOGIT clodds=pl maxiter=1000 selection=stepwise ;
  	 output out=work.predict predprobs=i;
  	 title 'adj Logistic Regression Model stepwise';
    run;
	ods graphics off;

/*ACCURACY*/

proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;

/****************************************************************************************/
	/*MODEL 4 - NOMINAL MODELING WITH 4 CATEGORIES(L1,L2,L3 AND L4), 
	STEPWISE WITH A SMALL DATA TO GET AN IDEA OF IMPORTANT VARIABLES - This is MODEL 2 in report*/


proc logistic data=work.vehicles2(obs=500)
              plots(only)=(effect(x=( drive type manufacturer odo_cat cylinders fuel title_status transmission)polybar) oddsratio (type=horizontalstat) );
         class manufacturer(ref='toyota')
		 drive(ref='4wd')
		 type(ref='sedan')
		 odo_cat(ref='50001-100000')
		 cylinders(ref='8 cylinders')
		 fuel(ref='gas')
		 title_status(ref='clean')
		 transmission(ref='manual')
    / param=ref;
   	nominal1: model price_cat(ref='L1') = cylinders fuel title_status transmission drive manufacturer type odo_cat / selection=stepwise link=glogit clodds=pl;
   	output out=work.predict predprobs=i;
   	title 'Nominal Logistic Regression Model on Used Vehicles';
	run;
/* ACCURACY */

proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;
/*********************************************************************************************/
/*MODEL 5 - NOMINAL MODEL - USING THE VARIABLES FROM STEPWISE SELECTION(50000 OBSERVATIONS) - This is MODEL 3 in report */

	proc logistic data=work.vehicles2(obs=50000)
              plots(only)=(effect(x=( drive type odo_cat cylinders)polybar) oddsratio (type=horizontalstat) );
         class	 drive(ref='4wd')
		 type(ref='sedan')
		 odo_cat(ref='50001-100000')
		 cylinders(ref='8 cylinders')	
    / param=ref;
   	nominal1: model price_cat(ref='L1') = cylinders drive type odo_cat / selection=stepwise link=glogit clodds=pl;
   	output out=work.predict predprobs=i;
   	title 'Nominal Logistic Regression Model on Used Vehicles';
	run;

/* ACCURACY */

	proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;
/**************************************************************************************/
/*MODEL 6  - NOMINAL MODEL - 91890 OBSERVATIONS AND EXTRA VARIABLE- This is Model 4 in report */

	proc logistic data=work.vehicles2
              plots(only)=(effect(x=( drive type odo_cat cylinders transmission)polybar) oddsratio (type=horizontalstat) );
         class 	 drive(ref='4wd')
		 type(ref='sedan')
		 odo_cat(ref='50001-100000')
		 cylinders(ref='8 cylinders')
          transmission(ref='manual')
		/ param=ref;
   	nominal1: model price_cat(ref='L1') = cylinders drive type odo_cat transmission / selection=stepwise link=glogit clodds=pl;
   	output out=work.predict predprobs=i;
   	title 'Nominal Logistic Regression Model on Used Vehicles';
	run;


	/*ACCURACY */

	proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;

/*******************************************************************/
/*MODEL 7- CUMULATIVE LOGISTIC ORDINAL - This is MODEL 7 in report*/

proc sql;
    update work.vehicles1 set price_cat='Low priced' where price<5000;
	update work.vehicles1 set price_cat='Reasonable' where price>5000 and price<15000;
	update work.vehicles1 set price_cat='Expensive' where price>15000;
quit;

proc logistic data=work.vehicles2(obs =100)
  plots(only)=(effect (individual showobs=yes)
                       oddsratio(type=horizontalstat));
   class price_cat 
         type(ref='SUV')
		 manufacturer(ref='ford')
		 state(ref='nc')
         cylinders(ref='4 cylinders')
         drive(ref='4wd')
         odo_cat(ref='100001-150000')
         paint_color(ref='white') ;
   model price_cat(ref='Low priced') = type manufacturer state cylinders drive odo_cat paint_color /selection=forward   clodds=pl;
	title 'Cumulative Logistic Regression';
	run;
	quit;
/*ACCURACY*/

    proc freq data=work.predict;
    tables _from_*_into_;
    title 'Crosstabulation of Observed Responses by Predicted Responses';
	quit;








