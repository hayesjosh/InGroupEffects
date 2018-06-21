clear
set more off
cd "D:\Dropbox\Work\Diss\Method\Data\"
log using "D:\Dropbox\Work\Diss\Method\Code\Analysis1\Logs\ISSPMakingVariables.log", replace

****************************************************
************MAKING GLOBAL MACROS********************
****************************************************

*CHANGE THESE FOR EVERY DO FILE
global data "D:\Dropbox\Work\Diss\Method\Data\ISSPALL\Clean\allinissp.dta"
global maindir "D:\Dropbox\Work\Diss\Method\Visualizations\"
global tableloc "D:\Dropbox\Work\Diss\Method\Visualizations\"
global graphloc "D:\Dropbox\Work\Diss\Method\Visualizations\"

*Always useful
global F5 use $data, clear

*    INDEP VARS
global controlVars yearnum female age age2 polspectrum citizen clas
global subGroups polRight clasHi educHi inDomRelig citizen clseHi ageHi female
  
*    DEP VARS
global outcomeVars1 impborn impcit imptime implang imprel implaw impfeel
global countryIDs 14 15 19 28 37 38 43

****************************************************
*******OPENING DATA FILE****************************
****************************************************
use $data, clear

****************************************************
*******CREATING NEW RELIGIOUS VARIABLES*************
****************************************************

**** Creating a categorical version for year as well as a continuous version
* year = categorical (i.e. 1995 and 2003 are 1 unit apart, 2003 and 2013 are 1 unit apart)
* yearnum = continuous (i.e. 1995 and 2003 are 8 units apart, 2003 and 2013 are 10 units apart)
gen yearnum=year 
recode yearnum 1=1995 2=2003 3=2013
label define ylab_1 1 "1995" 2 "2003" 3 "2013"
label values year ylab_1
label variable yearnum "Year"

***** Creating "In" or "Out" of "Dominant Religion" Variable
*I made my own variable that codes each nation's "dominant religion" as a string variable.
*So for this new variable, I check to see if a respondent's "religious affiliation" (relig) corresponds to their nation's "Dominant Religion" (domrel)
gen inDomRelig = 0
replace inDomRelig = . if relig==.
*    Marking those in "Christian" dominant nations
replace inDomRelig = 1 if religchrist==1 & domrel=="Christian"
*    Marking those in "Protestant" dominant nations
replace inDomRelig = 1 if relig==1 & domrel=="Protestant"
*    Marking those in "Catholic" dominant nations
replace inDomRelig = 1 if relig==2 & domrel=="Catholic"
*    Marking those in "Orthodox" dominant nations
replace inDomRelig = 1 if relig==3 & domrel=="Orthodox"

** Marking those in "Other" dominant nations
*    Coding for India - 
replace inDomRelig = 1 if relig==4 & country==18
*    Coding for Israel
replace inDomRelig = 1 if relig==4 & country==21
*    Coding for Japan 
replace inDomRelig = 1 if relig==4 & country==22
*    Coding for South Korea - 
replace inDomRelig = 1 if relig==4 & country==36
*    Coding for Taiwan - 
replace inDomRelig = 1 if relig==4 & country==40
*    Coding for Turkey - 
replace inDomRelig = 1 if relig==4 & country==41
*    One should be very cautious about making comparisons with the above list of "Other" countries. 
*    Each has a very unique context, which the survey does not capture particularly well.
label define relig3 1 "Dominant Group" 0 "Minority Group" 
label values inDomRelig relig3
label variable inDomRelig "If R is in/out of (country)'s dominant religious affiliation" 

****Association with Nation Variable - Highest Patriotism v All Others
gen clseHi=clse
recode clseHi 1=1 2/4=0 8/9=. .c=. .n=.
label define clseHi_1 1 "Highest Association" 0 "Lower Association"
label values clseHi clseHi_1
label variable clseHi  "Feelings of Closeness with Nation"

******Political Binary - Left v Right
gen polRight=polspectrum
recode polRight 4/5=1 3=. 1/2=0
label define polRight_1 1 "Identifies as Right" 0 "Identifies as Left"
label values polRight polRight_1
label variable polRight "R's Political Affiliation"

******Education Binary - HS or less v College Degree or More
gen educHi=edyr
recode educHi 16/99=1 13/15=. 0/12=0 .a=. .d=. .n=.
label define educHi_1 1 "College Degree or Higher" 0 "High School or Less"
label values educHi educHi_1
label variable educHi "Educational Attainment"

******Age Binary - Under 35 v over 45
gen ageHi=age
recode ageHi 14/35=0 45/98=1 36/44=. .n=. 112/999=.
label define ageHi_1 1 "Over 45" 0 "Under 35"
label values ageHi ageHi_1
label variable ageHi "Age Group"

******Social Class Binary - Low v High
gen clasHi = clas
recode clasHi 1/3=0 5/6=1 4=.
label define clasHi_1 0 "Lower Than Middle-Class" 1 "Higher Than Middle-Class"
label values clasHi clasHi_1
label variable clasHi "Self-Identified Social Class"

********Clearing up country names
label define countryid1 1 "Australia" 2 "Austria" 3 "Belgium" 4 "Bulgaria" 5 "Canada" 6 "Chile" 7 "Croatia" 8 "Czech Republic" 9 "Denmark" 10 "Estonia" 11 "Finland" 12 "France" 13 "Georgia" 14 "Germany" 15 "Great Britain" 16 "Hungary" 17 "Iceland" 18 "India" 19 "Ireland" 20 "Israel" 21 "Italy" 22 "Japan" 23 "Latvia" 24 "Lithuania" 25 "Mexico" 26 "Netherlands" 27 "New Zealand" 28 "Norway" 29 "Philippines" 30 "Poland" 31 "Portugal" 32 "Russian Federation" 33 "Slovakia" 34 "Slovenia" 35 "South Africa" 36 "South Korea" 37 "Spain" 38 "Sweden" 39 "Switzerland" 40 "Taiwan" 41 "Turkey" 42 "Uruguay" 43 "United States" 44 "Venezuela"
label values country countryid1
label variable country "Nation"


tab clse clseHi, missing nol
tab polspectrum polRight, missing nol
tab edyr educHi, missing nol
tab age ageHi, missing nol
tab clas clasHi, missing nol


****************************************************
**********CREATING VARIABLES TO DIFFERENTIATE*******
*******MORE OR LESS RELIABLE SUBSETS OF SAMPLE******
****************************************************
*Creating a unique identifier for each survey
egen surveyid = group(countryname yearnum)

*Creating a variable to denote all countries in survey
gen sampleFull = 1
label define sampleFull_1 1 "Full Sample" 
label values sampleFull sampleFull_1
label variable sampleFull "All Countries"

*Creating a variable that denotes "East" nations
gen sampleA = 1
*India
replace sampleA = 0 if country==18
*Israel
replace sampleA = 0 if country==21
*Japan
replace sampleA = 0 if country==22
*South Korea
replace sampleA = 0 if country==36
*Taiwan
replace sampleA = 0 if country==40
*Turkey
replace sampleA = 0 if country==41
label define sampleA_1 1 "Non-Outlier Sample" 0 "Other Countries"
label values sampleA sampleA_1
label variable sampleA "Non-Outlier Countries"

*Creating a variable that denotes "East" nations that completed all 3-waves of the survey
gen sampleB = 0
replace sampleB = 1 if country==8  
replace sampleB = 1 if country==16 
replace sampleB = 1 if country==23 
replace sampleB = 1 if country==32 
replace sampleB = 1 if country==33 
replace sampleB = 1 if country==34 
label define sampleB_1 1 "East Nations" 0 "Missed Surveys"
label values sampleB sampleB_1
label variable sampleB "East Full-Survey Nations Only"


*Creating a variable to denote those countries that completed all 3-waves of the survey 
gen sampleC = 0
replace sampleC = 1 if country==14  
replace sampleC = 1 if country==15 
replace sampleC = 1 if country==19 
replace sampleC = 1 if country==28 
replace sampleC = 1 if country==37 
replace sampleC = 1 if country==38 
replace sampleC = 1 if country==43 
label define sampleC_1 1 "West Nations" 0 "Missed Surveys"
label values sampleC sampleC_1
label variable sampleC "West Full-Survey Nations Only"

****************************************************
**********CREATING DEPENDENT VARIABLES**************
****************************************************

*mdesc
*    Let's drop the missing cases from the "national identity construction" variables - its about 13k cases out of 119k. 
*    They were all evenly distributed between countries except for 2k+ which came from South Africa not being asked these questions in 2015
foreach cleanVar in $outcomeVars1 {
drop if `cleanVar'>7
drop if `cleanVar'==.
drop if `cleanVar'==.c
drop if `cleanVar'==.n
drop if `cleanVar'==0
}

*I'm turning all of my variables around. Im going to make it so that an incrase in value means an increase in caring for the symbolic foundation of national identity.
*i.e. the population mean going from 2 to 3 means that the population cares more about X
*This should make interpreting coefficients later more intuitive
label define impscale 1 "Not important at all" 2 "Not very important" 3 "Fairly important" 4 "Very important"
foreach twist in $outcomeVars1 {
gen `twist'_inv = `twist'
replace `twist' = 1 if `twist'_inv==4
replace `twist' = 2 if `twist'_inv==3
replace `twist' = 3 if `twist'_inv==2
replace `twist' = 4 if `twist'_inv==1
label values `twist' impscale
drop `twist'_inv
}

*removing the case of Ireland in the question of importance of language only, since it was asked as "How important is it to speak Irish?" which has very skewed results
*Ireland represents a radical outlier in this regard, but I want it in the rest of the imp* analyses
replace implang=. if country==19

***************************************************************************
***************** CREATING AND VERIFYING VARIABLES IS DONE*****************
***************************************************************************
save "D:\Dropbox\Work\Diss\Method\Data\ISSPALL\Clean\newvarsallyearsissp.dta", replace

clear
log close
