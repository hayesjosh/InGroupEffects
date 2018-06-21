clear
set more off
cd "D:\Dropbox\Work\Diss\Method\Data\"
log using "D:\Dropbox\Work\Diss\Method\Code\Analysis1\Logs\ISSPDataInput.log", replace

****************************************************
************MAKING GLOBAL MACROS********************
****************************************************

*Always useful
global F5 use $data, clear

*    INDEP VARS
global controlVars yearnum female age age2 polspectrum citizen clas
global subGroups polRight clasLo educLo inDomRelig citizen clseHi ageHi female
  
*    DEP VARS
global outcomeVars1 impborn impcit imptime implang imprel implaw impfeel
global outcomeVars2 hiimpborn hiimpcit hiimptime hiimplang hiimprel hiimplaw hiimpfeel
global allVars year female age age2 citizen edyr clas wts country polspectrum relig religchrist countryname domrelcode domrel clse impborn impcit imptime implang imprel implaw impfeel 
global countryIDs 14 15 19 28 37 38 43

****************************************************
***INPUTTING AND CLEANING DATA FROM 1995************
****************************************************

use "D:\Dropbox\Work\Diss\Method\Data\ISSP1995\Raw\ZA2880.dta", clear
                
*Important Vars - 
* 1 - study number, i.e. year, but in code
*  2 - R's id number
*  3 - country (string)
*  7 - close to country
*  15 - how important to be born in
*  16 - have citizenship
*  17 - how important to spent most of life in country
*  18 - how important to speak language
*  19 - how important to be main religion
*  20 - how important to respect institutions/law
*  21 - how important to feel member of country
*  44 - "It is impossible for people who do not share country customs to become fully (citizen)
*  55 - how long you lived in other countries
*  56 - language spoken at home, first mention
*  57 - language spoken at home, second mention - 95%+ missing - so not keeping
*  58 - language spoken at home, third mention - 95%+ missing - so not keeping
*  59 - languages spoken well, first mention
*  60 - languages spoken well, second mention - 95%+ missing - so not keeping
*  61 - languages spoken well, third mention - 95%+ missing - so not keeping
*  63 - are you a citizen of (country)
*  64 - parents citizens of (country at birth)
*  65 - race/ethnicity
*  66 - how close you feel to ethnic group - 88% missing - so not keeping
*  200 - sex
*  201 - age
*  204 - education, years
*  205 - education, categories
*  206 - current employment status
*  265 - religious denomination
*  266 - religious services, how often
*  267 - subjective social clas
*  269 - party affiliation, left to right
*  342 - weighting factor
  
rename v1 year
rename v2 id
rename v3 countryid
rename v7 clse
rename v15 impborn
rename v16 impcit
rename v17 imptime
rename v18 implang
rename v19 imprel
rename v20 implaw
rename v21 impfeel
rename v44 assim
rename v63 citizen
rename v64 parcitizen
rename v65 ethn
rename v200 sex
rename v201 age
rename v204 edyr
rename v205 edcat
rename v206 work
rename v265 relig
rename v266 relinten
rename v267 clas
rename v269 polspectrum
rename v342 wts

*These are more variables than I need, so I'm going to reduce down to just what I'm using right now.
keep year countryid clse impborn impcit imptime implang imprel implaw impfeel citizen sex age edyr relig clas polspectrum wts

****************************************************************************************************
***Now I'm going to create/rename the variables into a standard format across all 3 years of data***
****************************************************************************************************

///year 
rename year yearnum
recode yearnum (2880=1), gen(year)
drop yearnum
label variable year "Year of study"

///female 
recode sex (1=0) (2=1), gen(female)
label define fem1 0 "Male" 1 "Female"
label values female fem1
label variable female "Gender"

///age age2 
*creating age squared
gen age2 = age*age
label variable age2 "Age Squared"

///edyr 
*years of education must be recoded in order to be consistent with all survey waves
recode edyr 97=0 21/59=21
drop if edyr==94 | edyr==95 | edyr==96
label define edlabels 0 "No Formal Education" 21 "21 or more years"
label values edyr edlabels
label variable edyr "Years of Education"

///polspectrum 
*political spectrum must be recoded in order to be consistent with all survey waves
rename polspectrum polspectrumincna
recode polspectrumincna (6/7=.), gen(polspectrum)
label define pollb1 1 "Far Left" 5 "Far Right"
label values polspectrum pollb1
label variable polspectrum "Political spectrum, Left to Right"

///citizen 
*recoding citizen into a dummy
recode citizen 2=0
label define cit1 0 "Not Citizen" 1 "Citizen"
label values citizen cit1
label variable citizen "Are you a citizen of (country)?"

///clas 
*    This year's coding of clas is going to become the default.
*    It is on a 6-level scale. The other years are on a 10-level scale.
*    So I am going to "collapse" the more nuanced measure into the broader measure system.
*    That way I am not trying to force/predict nuance into this year of data, which has 30k cases.
*    While considering how to recode the other years, I also chose the category-comparisons that match the %-distribution of survey-respondents most closely between waves.
*    So that if 30% of one sample says they are "working class," I aligned the coding to be with approximately 30% of the people who identified as being on the lower end of the 10-scale.
*    The breakdown is going to be as follows:
*    10-scale = 6-scale
*    -------------------------
*    (1/2)   = 1 "Lower Class"
*    (3/4)   = 2 "Working Class"
*    (5)     = 3 "Lower-Middle Class"
*    (6)     = 4 "Middle Class"
*    (7/8)   = 5 "Upper Middle Class"
*    (9/10)  = 6 "Upper Class"

///country 
*country code must be recoded in order to be consistent with all survey waves
gen int country = 0
replace country = 1 if countryid==1
replace country = 14 if countryid==2
replace country = 14 if countryid==3
replace country = 15 if countryid==4 
replace country = 43 if countryid==6 
replace country = 2 if countryid==7
replace country = 16 if countryid==8 
replace country = 20 if countryid==9
replace country = 19 if countryid==10
replace country = 26 if countryid==11 
replace country = 28 if countryid==12 
replace country = 38 if countryid==13
replace country = 8 if countryid==14
replace country = 34 if countryid==15
replace country = 30 if countryid==16
replace country = 4 if countryid==17
replace country = 32 if countryid==18
replace country = 25 if countryid==19
replace country = 5 if countryid==20
replace country = 29 if countryid==21
replace country = 22 if countryid==23
replace country = 37 if countryid==24
replace country = 23 if countryid==25
replace country = 33 if countryid==26
drop countryid

///relig
*creating a religious variable that works across all years
*collapsing relig into just the categories that are one of the "dominant" religions for a country

rename relig religcomplex
gen relig=.
*coding protestants (#1)
replace relig=1 if religcomplex==40 
replace relig=1 if religcomplex==41 
replace relig=1 if religcomplex==42
replace relig=1 if religcomplex==43
replace relig=1 if religcomplex==45 
replace relig=1 if religcomplex==46
replace relig=1 if religcomplex==47 
replace relig=1 if religcomplex==48 
replace relig=1 if religcomplex==49 
replace relig=1 if religcomplex==55 
replace relig=1 if religcomplex==60 
replace relig=1 if religcomplex==61 
replace relig=1 if religcomplex==91 
replace relig=1 if religcomplex==92 

*coding catholics (#2)
replace relig=2 if religcomplex==10
replace relig=2 if religcomplex==11
replace relig=2 if religcomplex==44 

*coding orthodox (#3)
replace relig=3 if religcomplex==54 

*coding other (#4)
replace relig=4 if religcomplex==12 
replace relig=4 if religcomplex==20 
replace relig=4 if religcomplex==30 
replace relig=4 if religcomplex==50 
replace relig=4 if religcomplex==51 
replace relig=4 if religcomplex==52 
replace relig=4 if religcomplex==53 
replace relig=4 if religcomplex==62 
replace relig=4 if religcomplex==93 
replace relig=4 if religcomplex==94
*#94 is "other not classified" which is an odd category - but since these people are self-identifying as not a part of the major religions, 
*I am lumping them into "other." In reference to my theoretical foundations, these are people who do not identify along with the "dominant majorities." 

*coding none (#5)
replace relig=5 if religcomplex==90 

label define relig1 1 "Protestant" 2 "Catholic" 3 "Orthodox" 4 "Other" 5 "None"
label values relig relig1
label variable relig "Religious Affiliation"

//////Creating a variable for religion with Christian-collapsed
*This is an alternative coding for religion, which I also use in my exploratory-analysis to get alternative perspective on relationships between variables
gen religchrist=. 
replace religchrist=1 if relig<4
replace religchrist=2 if relig==4
replace religchrist=3 if relig==5 

label define relig2 1 "Christian" 2 "Other" 3 "None"
label values religchrist relig2
label variable religchrist "Religious Affiliation - Christianity collapsed"

save "D:\Dropbox\Work\Diss\Method\Data\ISSP1995\Clean\95in.dta", replace

****************************************************
*****CREATING 1995 CLEAN-DATA FILE: COMPLETE********
****************************************************
clear

****************************************************
***INPUTTING AND CLEANING DATA FROM 2003************
****************************************************

use "D:\Dropbox\Work\Diss\Method\Data\ISSP2003\Raw\ZA3910_v2-1-0.dta", clear

*important vars - pg 474
* v1 - study number
* v3 - R id
* COUNTRY - country
* v4 - group R identifies with most
* v5 - 2nd group R identifies with most
* v6 - 3rd group R identifies with most
* v9 - close to country
* v11 - impborn
* v12 - impcit
* v13 - imptime
* v14 - implang
* v15 - imprel
* v16 - implaw
* v17 - impfeel
* v18 - impanc
* v47 - assim
* v56 - citizen
* v57 - parcitizen
* v58 - ethn
* v64 - spoken1
* v67 - ethnclse
* v68 - regional or national id stronger - *91% missing - so dropping
* sex - sex
* age - age
* educyrs - edyr
* degree - edcat 
* party_lr - polspectrum
* relig - relig
* religgrp - "religious main groups (derived)"
* attend - attendance of religious services
* topbot - top bottom self-placement 10 point scale
* ethnic - family origin, ethnic group, identity *not in all years - so dropping
* weight - weighting factor

*I only need to keep some of the variables
keep v1 V3 COUNTRY v4 v5 v6 v9 v11 v12 v13 v14 v15 v16 v17 v18 v47 v56 v57 v58 v64 v67 sex age educyrs degree party_lr relig religgrp attend topbot weight

*renaming variables in order to be consistent with all survey waves
rename v1 year
rename V3 id
rename COUNTRY countryid
rename v4 clseid1
rename v5 clseid2
rename v6 clseid3
rename v9 clse
rename v11 impborn
rename v12 impcit
rename v13 imptime
rename v14 implang
rename v15 imprel
rename v16 implaw
rename v17 impfeel
rename v18 impanc
rename v47 assim
rename v56 citizen
rename v57 parcitizen
rename v58 ethn
rename v64 spoken1
rename v67 canspeak1
rename educyrs edyr
rename degree edcat
rename party_lr polspectrum
rename topbot clas
rename weight wts

///year 
rename year yearnum
recode yearnum (3910=2), gen(year)
drop yearnum
label variable year "Year of study"

///female 
recode sex (1=0) (2=1) (.n=.), gen(female)
label define fem1 0 "Male" 1 "Female"
label values female fem1
label variable female "Gender"

///age age2 
gen age2 = age*age
label variable age2 "Age Squared"

///edyr 
*a lot of cases are marked "still in school" and "still at university" - so I could eventually try to impute values for these cases but I prefer to drop them and use the "complete case method" for missing data
recode edyr 97=0 21/82=21
drop if edyr==94 | edyr==95 | edyr==96
label define edlabels 0 "No Formal Education" 21 "21 or more years"
label values edyr edlabels
label variable edyr "Years of Education"

///polspectrum 
rename polspectrum polspectrumincna
recode polspectrumincna (6/7=.) (.a=.) (.d=.) (.n=.), gen(polspectrum)
label define pollb2 1 "Far Left" 5 "Far Right"
label values polspectrum pollb2
label variable polspectrum "Political spectrum, Left to Right"

///citizen 
*recoding citizen into a dummy
recode citizen 2=0 .n=.
label define cit1 0 "Not Citizen" 1 "Citizen"
label values citizen cit1
label variable citizen "Are you a citizen of (country)?"

///clas 
*   Recoding this year of "clas" in order to be consistent with all survey waves
*   The breakdown is going to be as follows:
*    10-scale = 6-scale
*    -------------------------
*    (1/2)   = 1 "Lower Class"
*    (3/4)   = 2 "Working Class"
*    (5)     = 3 "Lower-Middle Class"
*    (6)     = 4 "Middle Class"
*    (7/8)   = 5 "Upper Middle Class"
*    (9/10)  = 6 "Upper Class"
rename clas clas2
recode clas2 (1/2=1) (3/4=2) (5=3) (6=4) (7/8=5) (9/10=6) (.a=.) (.n=.), gen(clas)

///country 
*recoding country in order to be consistent with all survey waves
gen int country = 0
replace country = 1 if countryid==1
replace country = 14 if countryid==2
replace country = 14 if countryid==3
replace country = 15 if countryid==4 
replace country = 43 if countryid==6 
replace country = 2 if countryid==7
replace country = 16 if countryid==8 
replace country = 19 if countryid==10
replace country = 26 if countryid==11 
replace country = 28 if countryid==12 
replace country = 38 if countryid==13
replace country = 8 if countryid==14
replace country = 34 if countryid==15
replace country = 30 if countryid==16
replace country = 4 if countryid==17
replace country = 32 if countryid==18
replace country = 25 if countryid==19
replace country = 5 if countryid==20
replace country = 29 if countryid==21
replace country = 21 if countryid==22
replace country = 21 if countryid==23
replace country = 22 if countryid==24
replace country = 37 if countryid==25
replace country = 23 if countryid==26
replace country = 33 if countryid==27
replace country = 12 if countryid==28
replace country = 31 if countryid==30
replace country = 6 if countryid==31
replace country = 9 if countryid==32
replace country = 39 if countryid==33
replace country = 44 if countryid==36
replace country = 11 if countryid==37
replace country = 35 if countryid==40
replace country = 40 if countryid==41
replace country = 36 if countryid==42
replace country = 42 if countryid==43
drop countryid

///relig
*creating a religious variable that works across all years
*collapsing relig into just the categories that are one of the "dominant" religions for a country
rename relig religcomplex2
rename religgrp religcomplex
gen relig=.

*coding protestants (1)
replace relig=1 if religcomplex==3
replace relig=1 if religcomplex==9

*coding catholics (#2)
replace relig=2 if religcomplex==2

*coding orthodox (#3)
replace relig=3 if religcomplex==4 

*coding other (#4)
replace relig=4 if religcomplex==5 
replace relig=4 if religcomplex==6 
replace relig=4 if religcomplex==7 
replace relig=4 if religcomplex==8 
replace relig=4 if religcomplex==10 
replace relig=4 if religcomplex==11 

*coding none (#5)
replace relig=5 if religcomplex==1 

label define relig1 1 "Protestant" 2 "Catholic" 3 "Orthodox" 4 "Other" 5 "None"
label values relig relig1
label variable relig "Religious Affiliation"

//////Creating a variable for religion with Christian-collapsed
gen religchrist=. 
replace religchrist=1 if relig<4
replace religchrist=2 if relig==4
replace religchrist=3 if relig==5 

label define relig2 1 "Christian" 2 "Other" 3 "None"
label values religchrist relig2
label variable religchrist "Religious Affiliation - Christianity collapsed"

save "D:\Dropbox\Work\Diss\Method\Data\ISSP2003\Clean\03in.dta", replace

****************************************************
*****CREATING 2003 CLEAN-DATA FILE: COMPLETE********
****************************************************
clear 

****************************************************
***INPUTTING AND CLEANING DATA FROM 2013************
****************************************************

use "D:\Dropbox\Work\Diss\Method\Data\ISSP2013\Raw\ZA5950_v2-0-0.dta", clear

*important vars  - pg775
* V1 - study number
* V3 - country/sample
* V4 - country
* V7 - how close do you feel to country
* V9 - impborn
* V10 - impcit
* V11 - imptime
* V12 - implang
* V13 - imprel
* V14 - implaw
* V15 - impfeel
* V16 - impanc
* V45 - assim
* V63 - citizen
* V64 - parcitizen
* SEX - sex
* AGE - age
* EDUCYRS - edyr
* DEGREE - edcat
* WORK - occupational status
* ATTEND - attendance of religious service
* TOPBOT - top/bottom self placement
* PARTY_LR - polspectrum
* WEIGHT - wts
* RELIGGRP - religious group

*renaming variables in order to be consistent with all survey waves
rename V1 year
rename V3 id
rename V4 countryid
rename V7 clse
rename V9 impborn
rename V10 impcit
rename V11 imptime
rename V12 implang
rename V13 imprel
rename V14 implaw
rename V15 impfeel
rename V16 impanc
rename V45 assim
rename V63 citizen
rename V64 parcitizen
rename SEX sex
rename AGE age
rename EDUCYRS edyr
rename DEGREE edcat
rename PARTY_LR polspectrum
rename TOPBOT clas
rename WEIGHT wts
rename RELIGGRP relig

*keeping only the relevant variables
keep year countryid clse impborn impcit imptime implang imprel implaw impfeel impanc assim citizen parcitizen sex age edyr edcat polspectrum clas wts relig

///year 
rename year yearnum
recode yearnum (5950=3), gen(year)
drop yearnum
label variable year "Year of study"

///female
recode sex (1=0) (2=1) (9=.), gen(female)
label define fem1 0 "Male" 1 "Female"
label values female fem1
label variable female "Gender"

///age age2 
replace age=98 if age==112
drop if age==999
gen age2 = age*age
label variable age2 "Age Squared"

///edyr 
*a lot of cases are marked "still in school" and "still at university" - so I could eventually try to impute values for these cases but I prefer to drop them and use the "complete case method" for missing data
recode edyr 21/76=21 98/99=.
drop if edyr==94 | edyr==95 | edyr==96
label define edlabels 0 "No Formal Education" 21 "21 or more years"
label values edyr edlabels
label variable edyr "Years of Education"

///polspectrum 
rename polspectrum polspectrumincna
recode polspectrumincna (0=.) (6/99=.), gen(polspectrum)
label define pollb2 1 "Far Left" 5 "Far Right"
label values polspectrum pollb2
label variable polspectrum "Political spectrum, Left to Right"

///citizen 
*recoding citizen into a dummy
recode citizen 2=0 8/9=.
label define cit1 0 "Not Citizen" 1 "Citizen"
label values citizen cit1
label variable citizen "Are you a citizen of (country)?"

///clas 
*   Recoding this year of "clas" in order to be consistent with all survey waves
*   The breakdown is going to be as follows:
*    10-scale = 6-scale
*    -------------------------
*    (1/2)   = 1 "Lower Class"
*    (3/4)   = 2 "Working Class"
*    (5)     = 3 "Lower-Middle Class"
*    (6)     = 4 "Middle Class"
*    (7/8)   = 5 "Upper Middle Class"
*    (9/10)  = 6 "Upper Class"
rename clas clas2
recode clas2 (1/2=1) (3/4=2) (5=3) (6=4) (7/8=5) (9/10=6) (0=.) (98/99=.), gen(clas)

///country 
*recoding 2013 countries to be universal to all years
gen int country = 0
replace country = 3 if countryid==56
replace country = 40 if countryid==158
replace country = 7 if countryid==191
replace country = 8 if countryid==203
replace country = 9 if countryid==208 
replace country = 10 if countryid==233
replace country = 11 if countryid==246 
replace country = 12 if countryid==250
replace country = 13 if countryid==268 
replace country = 14 if countryid==276 
replace country = 16 if countryid==348
replace country = 17 if countryid==352
replace country = 18 if countryid==356
replace country = 19 if countryid==372 
replace country = 21 if countryid==376 
replace country = 22 if countryid==392
replace country = 36 if countryid==410 
replace country = 23 if countryid==428
replace country = 24 if countryid==440 
replace country = 27 if countryid==484 
replace country = 28 if countryid==578
replace country = 29 if countryid==608
replace country = 31 if countryid==620
replace country = 32 if countryid==643 
replace country = 33 if countryid==703 
replace country = 34 if countryid==705
replace country = 35 if countryid==710 
replace country = 37 if countryid==724
replace country = 38 if countryid==752 
replace country = 39 if countryid==756 
replace country = 41 if countryid==792
replace country = 15 if countryid==826
replace country = 43 if countryid==840
drop countryid

///relig
*creating a religious variable that works across all years
*collapsing relig into just the categories that are one of the "dominant" religions for a country
rename relig religcomplex
gen relig=.

*coding protestants (1)
replace relig=1 if religcomplex==2
replace relig=1 if religcomplex==4

*coding catholics (#2)
replace relig=2 if religcomplex==1

*coding orthodox (#3)
replace relig=3 if religcomplex==3 

*coding other (#4)
replace relig=4 if religcomplex==5 
replace relig=4 if religcomplex==6 
replace relig=4 if religcomplex==7 
replace relig=4 if religcomplex==8 
replace relig=4 if religcomplex==9 
replace relig=4 if religcomplex==10 

*coding none (#5)
replace relig=5 if religcomplex==0 

label define relig1 1 "Protestant" 2 "Catholic" 3 "Orthodox" 4 "Other" 5 "None"
label values relig relig1
label variable relig "Religious Affiliation"

//////Creating a variable for religion with Christian-collapsed
gen religchrist=. 
replace religchrist=1 if relig<4
replace religchrist=2 if relig==4
replace religchrist=3 if relig==5 

label define relig2 1 "Christian" 2 "Other" 3 "None"
label values religchrist relig2
label variable religchrist "Religious Affiliation - Christianity collapsed"

save "D:\Dropbox\Work\Diss\Method\Data\ISSP2013\Clean\13in.dta", replace

****************************************************
*****CREATING 2013 CLEAN-DATA FILE: COMPLETE********
****************************************************
clear

********************************************************************************
********************************************************************************
********************************************************************************

****************************************************
**ALL DATA FILES HOMOLOGIZED AND READY TO COMPILE***
****************************************************
use "D:\Dropbox\Work\Diss\Method\Data\ISSP1995\Clean\95in.dta", clear
append using "D:\Dropbox\Work\Diss\Method\Data\ISSP2003\Clean\03in.dta" "D:\Dropbox\Work\Diss\Method\Data\ISSP2013\Clean\13in.dta"

****************************************************
*USING MY OWN DATA-SET TO CODE DOMINANT RELIGION****
****************************************************
merge m:1 country using "D:\Dropbox\Work\Diss\Method\Data\DominantReligionKey.dta" 
drop if _merge==2
drop _merge

*Giving names to the numeric values for countries
labmask country, values(countryname)

*Keeping only the good variables, the variables that are relevant to my current study
keep $allVars

*Saving the Compiled-Dataset
save "D:\Dropbox\Work\Diss\Method\Data\ISSPALL\Clean\allinissp.dta", replace

****************************************************
*******CREATION OF FINAL-DATA FILE: COMPLETE********
****************************************************
clear
log close
