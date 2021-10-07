
clear

cd "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/Data"


use "activityfile.dta", clear

*merge activity file with roster file

merge m:1 tucaseid using "respondentfile.dta" 
*282 rows were not matched

*saving this data 
save "activity_respondent_merged.dta", replace


rename tudiaryday diaryday
rename tuyear diaryyear
rename tumonth diarymonth
keep if diarymonth == 2 | diarymonth == 3 | diarymonth == 4 |diarymonth == 10| diarymonth == 11 |diarymonth == 12   

keep if trcodep == 010101| trcodep == 010102 | trcodep == 010199

rename trcodep activity



*creating DST variable and replacing the values (years from 2003 to 2015 have been replaced)
gen DST =.
replace DST = 0 if diaryyear == 2003 & diarymonth == 4 & diaryday == 6
replace DST = 0 if diaryyear == 2004 & diarymonth == 4 & diaryday == 4
replace DST = 0 if diaryyear == 2005 & diarymonth == 4 & diaryday == 3
replace DST = 0 if diaryyear == 2006 & diarymonth == 4 & diaryday == 2
replace DST = 0 if diaryyear == 2007 & diarymonth == 3 & diaryday == 11
replace DST = 0 if diaryyear == 2008 & diarymonth == 3 & diaryday == 9
replace DST = 0 if diaryyear == 2009 & diarymonth == 3 & diaryday == 8
replace DST = 0 if diaryyear == 2010 & diarymonth == 3 & diaryday == 14
replace DST = 0 if diaryyear == 2011 & diarymonth == 3 & diaryday == 13
replace DST = 0 if diaryyear == 2012 & diarymonth == 3 & diaryday == 11
replace DST = 0 if diaryyear == 2013 & diarymonth == 3 & diaryday == 10
replace DST = 0 if diaryyear == 2014 & diarymonth == 3 & diaryday == 9
replace DST = 0 if diaryyear == 2015 & diarymonth == 3 & diaryday == 8

*still to need days before and after DST

save "activity_respondent_merged.dta", replace



*drop seconds since none of the observations are in seconds


rename diaryday date
rename diarymonth month 
rename diaryyear year

*restricting sample only to spring
keep if month == 2 | month == 3 | month == 4 

save "activity_respondent_merged.dta", replace

use "activity_respondent_merged.dta", clear

label variable tuactdur24   "Duration of activity" 
rename tuactdur24 activity_duration

*dropping since there is only one observation
drop if activity == 10199
drop if activity == 010102

*save file for with nap

save "withnap.dta", replace
drop if activity_duration < 180
*activity code 10101 is sleeping while 10102 is sleeplessnes

*creating a relative time variable for the RD
gen relative_time = .
replace relative_time = 0 if month == 4 & year == 2003 & date == 6
replace relative_time = 0 if month == 4 & year == 2004 & date == 4
replace relative_time = 0 if month == 4 & year == 2005 & date == 3
replace relative_time = 0 if month == 4 & year == 2006 & date == 2



*manually creative the days before and after
*2003 
*after
replace relative_time = 1 if month == 4 & year == 2003 & date == 7
replace relative_time = 2 if month == 4 & year == 2003 & date == 8
replace relative_time = 3 if month == 4 & year == 2003 & date == 9
*before
replace relative_time = -1 if month == 4 & year == 2003 & date == 5
replace relative_time = -2 if month == 4 & year == 2003 & date == 4
replace relative_time = -3 if month == 4 & year == 2003 & date == 3
replace relative_time = -4 if month == 4 & year == 2003 & date == 2
replace relative_time = -5 if month == 4 & year == 2003 & date == 1

*2004
*after
replace relative_time = 1 if month == 4 & year == 2004 & date == 5
replace relative_time = 2 if month == 4 & year == 2004 & date == 6
replace relative_time = 3 if month == 4 & year == 2004 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2004 & date == 3
replace relative_time = -2 if month == 4 & year == 2004 & date == 2
replace relative_time = -3 if month == 4 & year == 2004 & date == 1

*2005
*after
replace relative_time = 1 if month == 4 & year == 2005 & date == 4
replace relative_time = 2 if month == 4 & year == 2005 & date == 5
replace relative_time = 3 if month == 4 & year == 2005 & date == 6
replace relative_time = 4 if month == 4 & year == 2005 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2005 & date == 2
replace relative_time = -2 if month == 4 & year == 2005 & date == 1

*2006
*after
replace relative_time = 1 if month == 4 & year == 2006 & date == 3
replace relative_time = 2 if month == 4 & year == 2006 & date == 4
replace relative_time = 3 if month == 4 & year == 2006 & date == 5
replace relative_time = 4 if month == 4 & year == 2006 & date == 6
replace relative_time = 5 if month == 4 & year == 2006 & date == 7


save "activity_respondent_merged.dta", replace
*try running an m:m merge with NIBRS data


*do not want to do a m:m merge, instead collapse sleep to a daily level as well which will be used to merge the data. 


rename activity_duration sleep_duration
rename tufnwgtp ATUSweight
*multiplying amount of time sleeping with weight
gen weighted_sleep = sleep_duration * ATUSweight



*collapse sleep data to a daily level
collapse (sum) weighted_sleep (sum) ATUSweight, by(date month year)

replace weighted_sleep = weighted_sleep/ATUSweight

merge 1:m date month year using "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/Data/IncidentLevelSTATA/IncidentLevelSTATA/STATA/incidentlevelcleaned.dta"

*save this data
save "ATUS_NIBRS_merged.dta", replace

use "ATUS_NIBRS_merged.dta", clear

*laelling the variables
label variable attempted "Number of attempted offenses"
label variable  completed "Number of completed offenses"
label variable total_offense "Number of offenses"
label variable  theft_offense "Number of theft offenses"
label variable  drug_offense "Number of drug offenses"
label variable  sex_offense "Number of sex offenses"
label variable  other_offense "Number of other offenses"
label variable  property_value "Value of recorded property"
label variable  stolen_motor "Number of stolen motor vehicles"

gen relative_time = .
replace relative_time = 0 if month == 4 & year == 2003 & date == 6
replace relative_time = 0 if month == 4 & year == 2004 & date == 4
replace relative_time = 0 if month == 4 & year == 2005 & date == 3
replace relative_time = 0 if month == 4 & year == 2006 & date == 2

*2003 
*after
replace relative_time = 1 if month == 4 & year == 2003 & date == 7
replace relative_time = 2 if month == 4 & year == 2003 & date == 8
replace relative_time = 3 if month == 4 & year == 2003 & date == 9
*before
replace relative_time = -1 if month == 4 & year == 2003 & date == 5
replace relative_time = -2 if month == 4 & year == 2003 & date == 4
replace relative_time = -3 if month == 4 & year == 2003 & date == 3
replace relative_time = -4 if month == 4 & year == 2003 & date == 2
replace relative_time = -5 if month == 4 & year == 2003 & date == 1

*2004
*after
replace relative_time = 1 if month == 4 & year == 2004 & date == 5
replace relative_time = 2 if month == 4 & year == 2004 & date == 6
replace relative_time = 3 if month == 4 & year == 2004 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2004 & date == 3
replace relative_time = -2 if month == 4 & year == 2004 & date == 2
replace relative_time = -3 if month == 4 & year == 2004 & date == 1

*2005
*after
replace relative_time = 1 if month == 4 & year == 2005 & date == 4
replace relative_time = 2 if month == 4 & year == 2005 & date == 5
replace relative_time = 3 if month == 4 & year == 2005 & date == 6
replace relative_time = 4 if month == 4 & year == 2005 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2005 & date == 2
replace relative_time = -2 if month == 4 & year == 2005 & date == 1

*2006
*after
replace relative_time = 1 if month == 4 & year == 2006 & date == 3
replace relative_time = 2 if month == 4 & year == 2006 & date == 4
replace relative_time = 3 if month == 4 & year == 2006 & date == 5
replace relative_time = 4 if month == 4 & year == 2006 & date == 6
replace relative_time = 5 if month == 4 & year == 2006 & date == 7

*before
replace relative_time = -1 if month == 4 & year == 2006 & date == 1


*SAVE THIS DATA (PRE DROPPING Arizona)
save "witharizona.dta", replace

*drop if state is Arizona because they do not observe DST
drop if state2 == "AR"
keep if year == 2003 |year == 2004 |year == 2005 |year == 2006 
drop if date > 7


*drop data which is in using only
keep if month == 4

*generating date and then using that to generate day of the week fixed effects
rename date day
gen date = mdy(month, day, year)
*gen day of the week (dow)
gen dow = dow(date)

gen dayof =.
replace dayof = 1 if relative_time == 1
replace dayof = 0 if dayof == .


gen post =.
replace post= 1 if relative_time >= 0
replace post = 0 if relative_time <0

gen post_relative_time = post*relative_time

save "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/dataset_forprofLee.dta", replace

use "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/dataset_forprofLee.dta", clear



*first stage of regressio
reg weighted_sleep  post post*relative_time relative_time i.state_n, robust


*this is what the regression would look like
encode state2, gen(state_n)
est clear
ivregress 2sls total_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store a
ivregress 2sls theft_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store b
ivregress 2sls drug_offense  (weighted_sleep = post post*relative_time relative_time)   i.state_n, first
est store c
ivregress 2sls sex_offense  (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store d
ivregress 2sls other_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store e



esttab a b c d e using "crime_regression.rtf", compress title("Table 5: Effect of sleep on crime") mtitles("Total Offense" "Theft Offense" "Drug Offense" "Sex Offense" "Other Offense") varwidth(5) noconstant modelwidth(11) drop(*.state_n) replace  star(* 0.10 ** 0.05 *** 0.01) label


* attempted and completed
ivregress 2sls attempted  (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store f
ivregress 2sls completed  (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store g

esttab f g using "attempted_regression.rtf", compress title("Table 5: Effect of sleep on attempted and completed crime") mtitles("Attempted" "Completed" ) varwidth(10) noconstant modelwidth(11) drop(*.state_n) replace star(* 0.10 ** 0.05 *** 0.01) label


*running first stage by itself
reg weighted_sleep post post_relative_time i.state_n
est store h

esttab h using "first_stage.rtf", compress title("Table 5: First Stage: Effect of DST on Sleep") varwidth(15) noconstant modelwidth(11) drop(*.state_n) replace label star(* 0.10 ** 0.05 *** 0.01) 

*creating graphs

*twoway (weighted_sleep relative_time ) (connect beta year), xlabel(2000(2)2016)ytitle("Carbon Emissions in Million Metric Tonnes") xtitle("Years") legend(order(1 "95% Confidence Interval" 2 "Beta")) title("Effect of RGGI on states") xline(2009)


scatter weighted_sleep relative_time, xline(0)
scatter sex_offense relative_time, xline(0) 

gen DST_summarystats =.
replace DST_summarystats = 0 if relative_time < 0
replace DST_summarystats = 1 if relative_time >=0



*creating summary stats
estpost ttest weighted_sleep, by(DST_summarystats)

estpost tabstat weighted_sleep, by(DST_summarystats) ///
statistics(mean sd) columns(statistics) listwise
est store a

esttab a using "sleep summary.rtf", main(mean) aux(sd) nostar unstack ///
 nonote nonumber collabels ("Pre DST" "Post DST") mtitles("Pre DST" "Post DST") title("Summary Stats of sleep") replace


gen dayof =.
replace dayof = 1 if relative_time == 1
gen daybefore =.
replace daybefore = 1 if relative_time == -1

sum sleep_duration if dayof == 1
sum sleep_duration if daybefore == 1


*** crime summary statistics
estpost tabstat total_offense attempted completed theft_offense drug_offense sex_offense other_offense property_value stolen_motor, by(DST_summarystats) ///
statistics(mean sd) columns(statistics) listwise
est store b

esttab b using "crime summary.rtf", label main(mean) aux(sd) nostar unstack ///
 nonote nonumber title("Summary Stats of Crime") replace
 
 
 ** creating graphs
 collapse (mean) weighted_sleep total_offense, by(relative_time)
 
 scatter weighted_sleep relative_time,  xline(0) title("Sleep in minutes before and after DST") ytitle("sleep in minutes") xtitle("Relative days to DST")
 
 scatter drug_offense weighted_sleep 

 
  scatter total_offense relative_time,  xline(0) title("Number of offenses  before and after DST") ytitle("Number of crimes") xtitle("Relative days to DST")
*esttab A B using "statesummary.rtf", main(mean) aux(sd) nostar unstack ///
 *nonote compress nonumber collabels ("Non RGGI States" "RGGI States") mtitles("Pre RGGI" "Post RGGI") title("Summary stats by RGGI States") replace



 ***************************************************************************************************************************************
 
 ************************************** ROBUSTNESS CHECK 1**************************
 
 
 ***************************************************************************************************************************************
*creating a relative time variable for the RD
use "withnap.dta", clear


gen relative_time = .
replace relative_time = 0 if month == 4 & year == 2003 & date == 6
replace relative_time = 0 if month == 4 & year == 2004 & date == 4
replace relative_time = 0 if month == 4 & year == 2005 & date == 3
replace relative_time = 0 if month == 4 & year == 2006 & date == 2



*manually creative the days before and after
*2003 
*after
replace relative_time = 1 if month == 4 & year == 2003 & date == 7
replace relative_time = 2 if month == 4 & year == 2003 & date == 8
replace relative_time = 3 if month == 4 & year == 2003 & date == 9
*before
replace relative_time = -1 if month == 4 & year == 2003 & date == 5
replace relative_time = -2 if month == 4 & year == 2003 & date == 4
replace relative_time = -3 if month == 4 & year == 2003 & date == 3
replace relative_time = -4 if month == 4 & year == 2003 & date == 2
replace relative_time = -5 if month == 4 & year == 2003 & date == 1

*2004
*after
replace relative_time = 1 if month == 4 & year == 2004 & date == 5
replace relative_time = 2 if month == 4 & year == 2004 & date == 6
replace relative_time = 3 if month == 4 & year == 2004 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2004 & date == 3
replace relative_time = -2 if month == 4 & year == 2004 & date == 2
replace relative_time = -3 if month == 4 & year == 2004 & date == 1

*2005
*after
replace relative_time = 1 if month == 4 & year == 2005 & date == 4
replace relative_time = 2 if month == 4 & year == 2005 & date == 5
replace relative_time = 3 if month == 4 & year == 2005 & date == 6
replace relative_time = 4 if month == 4 & year == 2005 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2005 & date == 2
replace relative_time = -2 if month == 4 & year == 2005 & date == 1

*2006
*after
replace relative_time = 1 if month == 4 & year == 2006 & date == 3
replace relative_time = 2 if month == 4 & year == 2006 & date == 4
replace relative_time = 3 if month == 4 & year == 2006 & date == 5
replace relative_time = 4 if month == 4 & year == 2006 & date == 6
replace relative_time = 5 if month == 4 & year == 2006 & date == 7

rename activity_duration sleep_duration
rename tufnwgtp ATUSweight
*multiplying amount of time sleeping with weight
gen weighted_sleep = sleep_duration * ATUSweight



*collapse sleep data to a daily level
collapse (sum) weighted_sleep (sum) ATUSweight, by(date month year)

replace weighted_sleep = weighted_sleep/ATUSweight

merge 1:m date month year using "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/Data/IncidentLevelSTATA/IncidentLevelSTATA/STATA/incidentlevelcleaned.dta"

*save this data
*save "ATUS_NIBRS_merged.dta", replace

*use "ATUS_NIBRS_merged.dta", clear

*laelling the variables
label variable attempted "Number of attempted offenses"
label variable  completed "Number of completed offenses"
label variable total_offense "Number of offenses"
label variable  theft_offense "Number of theft offenses"
label variable  drug_offense "Number of drug offenses"
label variable  sex_offense "Number of sex offenses"
label variable  other_offense "Number of other offenses"
label variable  property_value "Value of recorded property"
label variable  stolen_motor "Number of stolen motor vehicles"

gen relative_time = .
replace relative_time = 0 if month == 4 & year == 2003 & date == 6
replace relative_time = 0 if month == 4 & year == 2004 & date == 4
replace relative_time = 0 if month == 4 & year == 2005 & date == 3
replace relative_time = 0 if month == 4 & year == 2006 & date == 2

*2003 
*after
replace relative_time = 1 if month == 4 & year == 2003 & date == 7
replace relative_time = 2 if month == 4 & year == 2003 & date == 8
replace relative_time = 3 if month == 4 & year == 2003 & date == 9
*before
replace relative_time = -1 if month == 4 & year == 2003 & date == 5
replace relative_time = -2 if month == 4 & year == 2003 & date == 4
replace relative_time = -3 if month == 4 & year == 2003 & date == 3
replace relative_time = -4 if month == 4 & year == 2003 & date == 2
replace relative_time = -5 if month == 4 & year == 2003 & date == 1

*2004
*after
replace relative_time = 1 if month == 4 & year == 2004 & date == 5
replace relative_time = 2 if month == 4 & year == 2004 & date == 6
replace relative_time = 3 if month == 4 & year == 2004 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2004 & date == 3
replace relative_time = -2 if month == 4 & year == 2004 & date == 2
replace relative_time = -3 if month == 4 & year == 2004 & date == 1

*2005
*after
replace relative_time = 1 if month == 4 & year == 2005 & date == 4
replace relative_time = 2 if month == 4 & year == 2005 & date == 5
replace relative_time = 3 if month == 4 & year == 2005 & date == 6
replace relative_time = 4 if month == 4 & year == 2005 & date == 7
*before
replace relative_time = -1 if month == 4 & year == 2005 & date == 2
replace relative_time = -2 if month == 4 & year == 2005 & date == 1

*2006
*after
replace relative_time = 1 if month == 4 & year == 2006 & date == 3
replace relative_time = 2 if month == 4 & year == 2006 & date == 4
replace relative_time = 3 if month == 4 & year == 2006 & date == 5
replace relative_time = 4 if month == 4 & year == 2006 & date == 6
replace relative_time = 5 if month == 4 & year == 2006 & date == 7

*before
replace relative_time = -1 if month == 4 & year == 2006 & date == 1

*drop if state is Arizona because they do not observe DST
drop if state2 == "AR"
keep if year == 2003 |year == 2004 |year == 2005 |year == 2006 
drop if date > 7

*drop data which is in using only
keep if month == 4

*generating date and then using that to generate day of the week fixed effects
rename date day
gen date = mdy(month, day, year)
*gen day of the week (dow)
gen dow = dow(date)

gen dayof =.
replace dayof = 1 if relative_time == 1
replace dayof = 0 if dayof == .


gen post =.
replace post= 1 if relative_time >= 0
replace post = 0 if relative_time <0

gen post_relative_time = post*relative_time


*first stage of the regresion
reg weighted_sleep post post_relative_time i.state_n
est store h

esttab h using "first_stage_robust.rtf", compress title("Table 5: First Stage: Effect of DST on Sleep") varwidth(15) noconstant modelwidth(11) drop(*.state_n) replace label star(* 0.10 ** 0.05 *** 0.01) 




*Preparing to run the regression
est clear
encode state2, gen(state_n)
est clear
ivregress 2sls total_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store a
ivregress 2sls theft_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store b
ivregress 2sls drug_offense  (weighted_sleep = post post*relative_time relative_time)   i.state_n, first
est store c
ivregress 2sls sex_offense  (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store d
ivregress 2sls other_offense (weighted_sleep = post post*relative_time relative_time)  i.state_n, first
est store e


esttab a b c d e using "crime_regression_robust.rtf", compress title("Table 5: Effect of sleep on crime") mtitles("Total Offense" "Theft Offense" "Drug Offense" "Sex Offense" "Other Offense") varwidth(5) noconstant modelwidth(11) drop(*.state_n) replace  star(* 0.10 ** 0.05 *** 0.01) label

 
 
 
***************************************************************************************************************************************
 
 ************************************** ROBUSTNESS CHECK 2**************************
 
 
 ***************************************************************************************************************************************
use "witharizona.dta", clear

keep if year == 2003 |year == 2004 |year == 2005 |year == 2006 
drop if date > 7


*drop data which is in using only
keep if month == 4

*generating date and then using that to generate day of the week fixed effects
rename date day
gen date = mdy(month, day, year)
*gen day of the week (dow)
gen dow = dow(date)

gen dayof =.
replace dayof = 1 if relative_time == 1
replace dayof = 0 if dayof == .



gen post =.
replace post= 1 if relative_time >= 0
replace post = 0 if relative_time <0

gen post_relative_time = post*relative_time

*gen a treatment and control group
gen treat = 1 if state2 != "AR"
replace treat = 0 if state2 == "AR"

*gen treat*post variable
gen treat_post = treat*post


encode state2, gen(state_n)
*running the diff in diff regression
est clear

reg total_offense treat*post treat post i.state_n
est store a 
reg drug_offense treat*post treat post i.state_n
est store b 
reg sex_offense treat*post treat post i.state_n
est store c
reg attempted treat*post treat post i.state_n
est store d
reg completed treat*post treat post i.state_n 
est store e

esttab a b c d e using "robustness.rtf", compress title("Table 5: Effect of sleep on crime") mtitles("Total Offense" "Drug Offense" "Sex Offense" "Attempted" "Completed") varwidth(5) noconstant modelwidth(11) drop(*.state_n) replace label star(* 0.10 ** 0.05 *** 0.01) 

*reghdfe log_emissions RGGIxpost RPS GDP population if state != "california" | state != "new jersey", absorb(state year) cluster(state)
est store a

* this is the path for importing NIBRS cleaned data
*use "/Users/ishaantibrewal/Desktop/Classes/S1/Econ of crime/project/Data/IncidentLevelSTATA/IncidentLevelSTATA/STATA/incidentlevelcleanedhusk.dta", clear

*code for creating summary stats
*estpost ttest call ofjobs yearsexp computerskills female, by(black)
*remember that Arizona and Hawaii do not adopt DST
/*
years and when daylight savings started
2000-
2001
2002
2003- April 6
2004- April 4
2005- April 3
2006- April 2
2007- March 11
2008- March 9
2009- March 8
2010- March 14
2011- March 13
2012- March 11
2013- March 10
2014- March 9
2015- March 8
2016- March 13
2017- March 12
2018- March 11
*/
