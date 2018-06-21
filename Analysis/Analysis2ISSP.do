clear
set more off
log using "D:\Dropbox\Work\Diss\Method\Code\Analysis2\Logs\Analysis2AnalysisA.log", replace
cd "D:\Dropbox\Work\Diss\Method\Data\"

****************************************************
************MAKING GLOBAL MACROS********************
****************************************************
*    CHANGE THESE FOR EVERY DO FILE
global data "D:\Dropbox\Work\Diss\Method\Data\ISSPALL\Clean\newvarsallyearsissp.dta"
global maindir "D:\Dropbox\Work\Diss\Method\Visualizations\Analysis2"
global tableloc "D:\Dropbox\Work\Diss\Method\Visualizations\Analysis2\Tables"
global graphloc "D:\Dropbox\Work\Diss\Method\Visualizations\Analysis2\Graphs"

*    Always useful
global F5 use $data, clear

*    INDEP VARS
global indepVars yearnum inDomRelig citizen
  
*    DEP VARS
global depVars impcit imprel

*    Table Info
global meantable "noaster excel dec(2) sum(detail) eqkeep(mean)"
global sdtable "noaster excel dec(2) sum(detail) eqkeep(sd) par(coef)"
global logittable "bdec(3) tdec(2) alpha(0.001, 0.01, 0.05) symbol(***, **, *) excel tstat addstat(BIC', -e(chi2)+(e(df_m))*ln(e(N)))"
global testtable "bdec(3) tdec(2) alpha(0.001, 0.01, 0.05, 0.1) symbol(***, **, *, #) excel tstat"
global margintable "bdec(3) tdec(2) alpha(0.001, 0.01, 0.05) symbol(***, **, *) excel tstat"

***********************************************************************
******LET'S START PLAYING WITH DATA!***********************************
***********************************************************************
cd $maindir
use $data, clear

keep impcit imprel citizen inDomRelig country year yearnum wts relig domrelcode sampleA surveyid countryname female age edyr clas
keep if sampleA==1

recode impcit 1/2=0 3/4=1, gen(biimpcit)
recode imprel 1/2=0 3/4=1, gen(biimprel)

replace age=. if age<18

****************************************************
**********CLEANING VARIABLES************************
****************************************************
mdesc
foreach var in $indepVars{
drop if `var'==. 
}
mdesc

****************************************************
**********DESCRIPTIVES OF VARIABLES*****************
****************************************************

*Getting Descriptive Stats
outreg2 using $tableloc\SumStatsISSP.xls, replace sum(log) keep(yearnum impcit imprel citizen inDomRelig biimpcit biimprel female age edyr clas) eqkeep(N mean sd min max)

***********************************************************************
*************ANALYSIS BELOW HERE **************************************
***********************************************************************

*Testing differences

*****************************
****** CITIZENSHIP **********
*****************************

*Dropping out countries where there are not enough non-citizens to make reasonable conclusions
sort surveyid citizen
by surveyid : egen totalnoncit = total(citizen==0)
replace citizen = . if totalnoncit <20

*and doing the same for dominant religion
sort surveyid inDomRelig
by surveyid : egen totalnonrel = total(inDomRelig==0)
replace inDomRelig=. if totalnonrel<20


*****************************
********** LOGITS ***********
*****************************
*Nested logits for impcit by citizen
*outputting using putexcel

*stage1 impcit
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("impcit1") replace
putexcel J1 = ("N") K1 = ("chi2")
logit biimpcit citizen, vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

*stage2 impcit
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("impcit2") modify
putexcel J1 = ("N") K1 = ("chi2")
logit biimpcit citizen yearnum, vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

*stage2 impcit
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("impcit3") modify
putexcel J1 = ("N") K1 = ("chi2")
logit biimpcit citizen yearnum female age edyr clas, vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

****RELIGION NOW

*stage1 imprel
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("imprel1") modify
putexcel J1 = ("N") K1 = ("chi2")
logit biimprel inDomRelig, vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

*stage2 imprel
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("imprel2") modify
putexcel J1 = ("N") K1 = ("chi2")
logit biimprel inDomRelig yearnum , vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

*stage2 imprel
putexcel set "$tableloc/ISSP/Logits_ISSP.xlsx", sheet("imprel3") modify
putexcel J1 = ("N") K1 = ("chi2")
logit biimprel inDomRelig yearnum female age edyr clas, vce(cluster country) or
matrix results = r(table)
matrix results = results[1..6,1...]'
matlist results
putexcel A1 = matrix(results), names nformat(number_d2) hcenter
putexcel J2 = (e(N)) 
putexcel K2 = (e(chi2)) 

***********************************************************************
*******VISUALIZATIONS BELOW HERE **************************************
***********************************************************************

*Creating the bargraph that compares the ISSP data for US, imprel/impcit across religious id
preserve
keep if country==43

local vloop2 impcit imprel
foreach p of local vloop2 {
gen `p'1 = `p'
recode `p'1 1/2 = 0 3/4 = 1
}

gen relsimp = relig
recode relsimp 1/3=1
label define rellab_2 1 "Christian" 4 "Other Religion" 5 "No religion"
label values relsimp rellab_2
label variable relsimp "Simplified Religious ID"

sum relsimp

*comparisons
#delimit ;
graph bar impcit1 imprel1, over(relsimp)
bargap(-30)
legend(label(1 "Citizenship") label(2 "Being Christian"))
title("How important is ____ for National Identity?")
subtitle("Compared across religious groups in the United States")
ytitle("% of group that says 'important'", height(5))
ylabel(0 "0%" .25 "25" .50 "50" .75 "75" 1 "100%") 
blabel(total, position(inside) color(white) format(%9.2f))
bar(1, color(maroon))
bar(2, color(navy))
note("Note: Data Source: ISSP, n=3501.")
;
#delimit cr
restore
*I don't save this one programmatically because I edit some of its visuals manually

*****************************
****** CITIZENSHIP **********
*****************************
*impcit across whole sample
#delimit ;
histogram impcit, 
discrete 
percent fcolor(navy) lcolor(black) 
addlabel addlabopts(mlabsize(medium)) 
xlabel(, alternate) 
title("How important is it to (Have Citizenship)", color(black))
 subtitle("in order to be a true member of (Country)?", size(large)) 
 xtitle(" ") xscale(range(1 4)) 
 xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
 ytitle("Percentage %")
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60%") 
 ylabel(, angle(0))
 note("Note: Averaged across all available surveys.")
;
#delimit cr
graph export $graphloc\issp\impcit\impcitIssp.tif, width(825) height(600) replace

*impcit by in/out group - in this case, who has citizenship or not
#delimit ;
histogram impcit, 
discrete 
percent fcolor(navy) lcolor(black) 
addlabel addlabopts(mlabsize(small)) 
by(citizen, noiy legend(off) title("How important to (Have Citizenship)" "to be a true member of (Country)?", color(black)) 
     subtitle("Compared across citizenship status", size(medium)) note("Note: Averaged across all available surveys.")
	  col(2))
xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very")
xlabel(, alternate) 
ytitle("Percentage %")
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60" 80 "80%") 
 ylabel(, angle(0)) ytitle(, height(5)) 
 xtitle(" ") 
;
#delimit cr
graph export $graphloc\issp\impcit\impcitByCitIssp.tif, width(825) height(600) replace

*LOOP FOR EACH NATION TO HAVE ITS OWN VERSION OF THE ABOVE GRAPH -- IMPCIT BY CITIZEN
preserve
drop if citizen==.
levelsof countryname, local(fullCountry)
foreach num of local fullCountry{
 #delimit ;
histogram impcit if countryname=="`num'", 
discrete 
percent fcolor(navy) lcolor(black) 
addlabel addlabopts(mlabsize(medium)) 
by(citizen, noiy legend(off) title("How important to (Have Citizenship)" "to be a true member of (Country)?", color(black)) 
subtitle("Compared across in/out-group of citizenship status", size(medium) color(darkgrey)) 
note("Specific to country `num'")) 
xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
xlabel(, alternate) 
ytitle("Percentage %")
xtitle(" ") 
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60" 80 "80" 100 "100%") 
;
#delimit cr
graph export "$graphloc/issp/impcit/nations/`num'.tif", width(825) height(600) replace
 }
 restore
 *

*****************************
********* RELIGION **********
*****************************
 *imprel across whole sample
#delimit ;
histogram imprel, 
discrete 
percent fcolor(cranberry) lcolor(black) 
addlabel addlabopts(mlabsize(medium)) 
xlabel(, alternate) 
title("How important is it to be (Dominant Religion)", color(black))
 subtitle("in order to be a true member of (Country)?", size(large)) 
 xtitle(" ") xscale(range(1 4)) 
 xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
 ytitle("Percentage %")
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60%") 
 ylabel(, angle(0))
 note("Note: Averaged across all available surveys.")
;
#delimit cr
graph export $graphloc\issp\imprel\imprelIssp.tif, width(825) height(600) replace

 *imprel by in/out group - in this case, who is a member of dominant religion
#delimit ;
histogram imprel, 
discrete 
percent fcolor(cranberry) lcolor(black) 
addlabel addlabopts(mlabsize(small)) 
by(inDomRelig, noiy legend(off) title("How important to be (Dominant Religion)" "to be a true member of (Country)?", color(black)) 
     subtitle("Compared across religious affiliation", size(medium)) note("Averaged across all available surveys.")
	  col(2))
xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very")
xlabel(, alternate) 
ytitle("Percentage %")
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60" 80 "80%") 
 ylabel(, angle(0)) ytitle(, height(5)) 
 xtitle(" ") 
;
#delimit cr
graph export $graphloc\issp\imprel\imprelByIndomRIssp.tif, width(825) height(600) replace
 
  *Imprel, by year
#delimit ;
histogram imprel, 
discrete 
percent fcolor(cranberry) lcolor(black) 
addlabel addlabopts(mlabsize(small)) 
by(year, noiy legend(off) title("How important to be (Dominant Religion)" "to be a true member of (Country)?", color(black)) 
     subtitle("Compared across years", size(medium)) note("Averaged across all available surveys.")
	  col(3))
xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
xlabel(, alternate) 
ytitle("Percentage %")
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60%") 
 ylabel(, angle(0)) ytitle(, height(5)) 
 xtitle(" ") 
;
#delimit cr
graph export $graphloc\issp\imprel\imprelByYear.tif, width(825) height(600) replace
  
 *LOOP FOR EACH NATION TO HAVE ITS OWN VERSION OF THE ABOVE GRAPH -- IMPREL by INDOMRELIG
 preserve
 drop if inDomRelig==.
levelsof countryname, local(fullCountry)
foreach num of local fullCountry{
 #delimit ;
histogram imprel if countryname=="`num'", 
discrete 
percent fcolor(cranberry) lcolor(black) 
addlabel addlabopts(mlabsize(medium)) 
by(inDomRelig, noiy legend(off) title("How important to be (Dominant Religion)" "to be a true member of (Country)?", color(black)) 
subtitle("Compared across in/out-group of citizenship status", size(medium) color(darkgrey)) 
note("Specific to country `num'")) 
xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
xlabel(, alternate) 
ytitle("Percentage %")
xtitle(" ") 
 ylabel(0 "0%" 20 "20"  40 "40" 60 "60" 80 "80" 100 "100%") 
;
#delimit cr
graph export "$graphloc/issp/imprel/nations/`num'.tif", width(825) height(600) replace
 }
 restore
 *
 
*******************************************************************************
********************Making visualizations that are **************************** 
******************going to require transforming the data **********************
*******************************************************************************  
use $data, clear

keep impcit imprel citizen inDomRelig country year yearnum wts relig domrelcode sampleA surveyid
keep if sampleA==1

****Creating a graph to show the distributions of impcit and imprel
*Creating citizenship coordinates
sort surveyid citizen

*Creating a Mean
egen cm = mean(impcit), by(surveyid citizen)
*Creating a coordinate for each survey for dominant group
egen cx = mean(cm) if citizen==1, by(surveyid)
*Spreading that value across all Respondents for that survey
sort surveyid cx
qui bysort surveyid: replace cx=cx[1]
*Creating a coordinate for each survey for minority group
egen cy = mean(cm) if citizen==0, by(surveyid)
*Spreading that value across all R for that survey
sort surveyid cy
qui bysort surveyid: replace cy=cy[1]

*Doing the same for religion
egen rm = mean(imprel), by(surveyid inDomRelig)
egen rx = mean(rm) if inDomRelig==1, by(surveyid)
sort surveyid rx
qui bysort surveyid: replace rx=rx[1]
egen ry = mean(rm) if inDomRelig==0, by(surveyid)
sort surveyid ry
qui bysort surveyid: replace ry=ry[1]

*Now I want to drop those surveys that have unreasonably low counts, let's say:
*** "Low counts < 10"
egen totalnoncit = sum(citizen==0), by(surveyid)
replace cy=. if totalnoncit<10
replace cx=. if totalnoncit<10

egen totalnonrel = sum(inDomRelig==0), by(surveyid)
replace ry=. if totalnonrel<10
replace rx=. if totalnonrel<10

*Reducing down to Survey-Level analysis from Respondent-level analysis
*Let's keep just one response from each survey, so our n goes from ~103k to 89.
bysort surveyid: keep if _n==1

**Graphing
#delimit ;
graph twoway 
(scatter ry rx, msymbol(oh)) ///
(scatter cy cx, msymbol(dh)), ///
legend(size(small) 
		label(1 "Religion") 
		label(2 "Citizenship")) 
  title("Comparing average importance placed""on Citizenship and Religion by In/Out Groups", size(medium) color(black))
  ytitle("Minority Group Average", size(medium) height(30))
  ylabel(, angle(0)) 
  yscale(range(1 4))
  ylabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
  ylabel(, angle(0)) ytitle(, height(10))
  xtitle("Dominant Group Average")
  xscale(range(1 4))
  xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
  
;
 #delimit cr 
*I save this one manually because I alter its formatting significantly

**Graphing
#delimit ;
graph twoway 
(scatter ry rx if year==1, msymbol(oh) mcolor(emerald)) 
(scatter cy cx if year==1, msymbol(dh) mcolor(navy))
(scatter ry rx if year==2, msymbol(oh) mcolor(forest_green)) 
(scatter cy cx if year==2, msymbol(dh) mcolor(midblue))
(scatter ry rx if year==3, msymbol(oh) mcolor(midgreen)) 
(scatter cy cx if year==3, msymbol(dh) mcolor(eltblue)),
legend(size(small) 
		label(1 "Religion 1995") 
		label(2 "Citizenship 1995")
		label(3 "Religion 2004") 
		label(4 "Citizenship 2004")
		label(5 "Religion 2014") 
		label(6 "Citizenship 2014")
		) 
  title("Comparing average importance placed""on Citizenship and Religion by In/Out Groups", size(medium) color(black))
  ytitle("Minority Group Average", size(medium) height(30))
  ylabel(, angle(0)) 
  yscale(range(1 4))
  ylabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
  ylabel(, angle(0)) ytitle(, height(10))
  xtitle("Dominant Group Average")
  xscale(range(1 4))
  xlabel(1 "Not at all" 2 "Not Very" 3 "Fairly" 4 "Very") 
  legend(ring(0) col(2) pos(10) region(lcolor(none)))
  note("Each plot-point represents a nation-wide survey. Approximately 38 countries represented.""Number of surveys for religion and citizenship vary based on data availability. Data: ISSP 1995-2015.", size(vsmall))

;
 #delimit cr 
*I save this one manually because I alter its formatting significantly


********************************************************************************
***************************WRAPPING UP FOR NOW**********************************
********************************************************************************
log close
