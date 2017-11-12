* ------------------------------------- *
* Graphs of Treatment effects - item pile
* Author: Chanwool Kim
* Date Created: 5 Jun 2017
* Last Update: 5 Jun 2017
* ------------------------------------- *

clear all
set more off

global data_ehs	"C:\Users\chanw\Dropbox\Work\CEHD\home"
global data_ihdp "C:\Users\chanw\Dropbox\Work\CEHD\home"
global data_abc	"C:\Users\chanw\Dropbox\Work\CEHD\home"
global data_store "C:\Users\chanw\Dropbox\Work\CEHD\home"

global data_ihdp "/Users/andres/Dropbox/TOPI/treatment_effect/home"
global data_abc	"/Users/andres/Dropbox/TOPI/treatment_effect/home"


* --------------------------- *
* Define macros for abstraction

global covariates			m_age m_edu sibling m_iq race sex gestage mf

local programs				/*ehs*/ ihdp abc

* ---------------------- *
* Define macros for graphs

local region				graphregion(color(white))

local xtitle				xtitle(Chronological Age)
local ytitle				ytitle(Regression Coefficient: ``t'_name' ``t'_`s'_name')

local ehs_xlabel			xlabel(12(12)130, labsize(small))
local ihdp_xlabel			xlabel(0(12)96, labsize(small))
local abc_xlabel			xlabel(0(12)100, labsize(small))

local home_name 			HOME

local home_total_name		Total Score

* ------------ *
* Prepare matrix

foreach p of local programs {
cd "${data_`p'}"
use "`p'-home-item.dta", clear

merge 1:1 id using "`p'-home-control", nogen nolabel
merge 1:1 id using "`p'-home-participation", nogen nolabel

save `p'-home-item-merge, replace

* Create an empty matrix that stores ages, coefficients, lower CIs and upper CIs.
qui matrix `p'R = J(55, 3, .) // for randomisation variable
qui matrix `p'D = J(55, 3, .) // for participation variable (program specific)

qui matrix colnames `p'R = `p'Rnum `p'Rcoeff `p'Rpval
qui matrix colnames `p'D = `p'Dnum `p'Dcoeff `p'Dpval

* Loop over rows to fill in values into the empty matrix.
foreach r of numlist 1/55 {
	qui matrix `p'R[`r',1] = `r'
	qui matrix `p'D[`r',1] = `r'
	
	* Randomisation variable
	qui regress home_`r' R $covariates
	* r(table) stores values from regression (ex. coeff, var, CI).
	 matrix list r(table)
	 *asd
	qui matrix r = r(table)

	qui matrix `p'R[`r',2] = r[1,1]
	qui matrix `p'R[`r',3] = r[4,1]
			
	* Participation variable (program specific)
	qui ivregress 2sls home_`r' (D = R) $covariates
	* r(table) stores values from regression (ex. coeff, var, CI).
	qui matrix list r(table)
	qui matrix r = r(table)
		
	qui matrix `p'D[`r',2] = r[1,1]
	qui matrix `p'D[`r',3] = r[4,1]
}

svmat `p'R, names(col)
svmat `p'D, names(col)

keep `p'Rnum `p'Rcoeff `p'Rpval `p'Dcoeff `p'Dpval
rename `p'Rnum row
keep if row != .

* Create tempfiles so that we could merge two matrix
tempfile tmp`p'
save "`tmp`p''", replace
}

foreach p of local programs {
	merge 1:1 row using `tmp`p'', nogen nolabel
}

* --------*
* Questions

tostring row, gen(question)
replace question = "Toys that teach color, size, shape" if question == "1"
replace question = "Three or more puzzles" if question == "2"
replace question = "Record player and >5 children's records" if question == "3"
replace question = "Child has toys permitting free expression" if question == "4"
replace question = "Child has toys or games requiring refined movements" if question == "5"
replace question = "Child has toys or games which help teach numbers" if question == "6"
replace question = "Child has at least 10 children's books" if question == "7"

replace question = "At least 10 books are visible in the apartment" if question == "8"
replace question = "Family buys and reads a daily newspaper" if question == "9"
replace question = "Family subscribes to at least one magazine" if question == "10"

replace question = "Child is encouraged to learn shapes" if question == "11"
replace question = "Child has toys that help teach the names of animals" if question == "12"
replace question = "Child is encouraged to learn the alphabet" if question == "13"
replace question = "Parent teaches child simple verbal manners" if question == "14"
replace question = "Mother uses correct grammar and pronunciation" if question == "15"
replace question = "Parent encourages child to talk and takes time to listen" if question == "16"
replace question = "Parent's voice conveys positive feelings to child" if question == "17"
replace question = "Child is permitted choice in breakfast or lunch menu" if question == "18"

replace question = "Building appears safe" if question == "19"
replace question = "Outside play environment appears safe" if question == "20"
replace question = "Interior of apartment not dark or perceptually monotonous" if question == "21"
replace question = "Neighborhood is aesthetically pleasing" if question == "22"
replace question = "House has 100 sq. ft. of living space per person" if question == "23"
replace question = "Rooms are not overcrowded with furniture" if question == "24"
replace question = "House is reasonably clean and minimally cluttered" if question == "25"

replace question = "Parent holds child close 10-15 minutes per day" if question == "26"
replace question = "Parent converses with child at least twice during visit" if question == "27"
replace question = "Parent answers child's questions or requests verbally" if question == "28"
replace question = "Parent usually responds to child's speech" if question == "29"
replace question = "Parent spontaneously praises child's qualities twice during visit" if question == "30"
replace question = "Parent caresses, kisses, or cuddles child during visit" if question == "31"
replace question = "Parent helps child demonstrate some achievement during visit" if question == "32"

replace question = "Child is encouraged to learn colors" if question == "33"
replace question = "Child is encouraged to learn patterned speech (songs, etc.)" if question == "34"
replace question = "Child is encouraged to learn spatial relationships" if question == "35"
replace question = "Child is encouraged to learn numbers" if question == "36"
replace question = "Child is encouraged to learn to read a few words" if question == "37"

replace question = "Some delay of food gratification is expected" if question == "38"
replace question = "TV is used judiciously" if question == "39"
replace question = "Parent introduces visitor to child" if question == "40"
replace question = "Child can express negative feelings without reprisal" if question == "41"
replace question = "Child can hit parent without harsh reprisal" if question == "42"

replace question = "Child has real or toy musical instrument" if question == "43"

replace question = "Child is taken on outing by family member at least every other week" if question == "44"
replace question = "Child has been on trip more than 50 miles during last year" if question == "45"
replace question = "Child has been taken to a museum during past year" if question == "46"
replace question = "Parent encourages child to put away toys without help" if question == "47"
replace question = "Parent uses complex sentences structure and vocabulary" if question == "48"
replace question = "Child's art work is displayed some place in house" if question == "49"
replace question = "Child eats at least one meal per day with mother and father" if question == "50"
replace question = "Parent lets child choose some foods or brands at grocery store" if question == "51"

replace question = "Parent does not scold or derogate child more than once" if question == "52"
replace question = "Parent does not physical restraint during visit" if question == "53"
replace question = "Parent neither slaps nor spanks child during visit" if question == "54"
replace question = "No more than once instance of physical punishment during past week" if question == "55"

/*
label define question ///
1 "Toys that teach color, size, shape" ///
2 "Three or more puzzles" ///
3 "Record player and >5 children's records" ///
4 "Child has toys permitting free expression" ///
5 "Child has toys or games requiring refined movements" ///
6 "Child has toys or games which help teach numbers" ///
7 "Child has at least 10 children's books" ///
8 "At least 10 books are visible in the apartment" ///
9 "Family buys and reads a daily newspaper" ///
10 "Family subscribes to at least one magazine" ///
11 "Child is encouraged to learn shapes" ///
12 "Child has toys that help teach the names of animals" ///
13 "Child is encouraged to learn the alphabet" ///
14 "Parent teaches child simple verbal manners" ///
15 "Mother uses correct grammar and pronunciation" ///
16 "Parent encourages child to talk and takes time to listen" ///
17 "Parent's voice conveys positive feelings to child" ///
18 "Child is permitted choice in breakfast or lunch menu" ///
19 "Building appears safe" ///
20 "Outside play environment appears safe" ///
21 "Interior of apartment not dark or perceptually monotonous" ///
22 "Neighborhood is aesthetically pleasing" ///
23 "House has 100 sq. ft. of living space per person" ///
24 "Rooms are not overcrowded with furniture" ///
25 "House is reasonably clean and minimally cluttered" ///
26 "Parent holds child close 10-15 minutes per day" ///
27 "Parent converses with child at least twice during visit" ///
28 "Parent answers child's questions or requests verbally" ///
29 "Parent usually responds to child's speech" ///
30 "Parent spontaneously praises child's qualities twice during visit" ///
31 "Parent caresses, kisses, or cuddles child during visit" ///
32 "Parent helps child demonstrate some achievement during visit" ///
33 "Child is encouraged to learn colors" ///
34 "Child is encouraged to learn patterned speech (songs, etc.)" ///
35 "Child is encouraged to learn spatial relationships" ///
36 "Child is encouraged to learn numbers" ///
37 "Child is encouraged to learn to read a few words" ///
38 "Some delay of food gratification is expected" ///
39 "TV is used judiciously" ///
40 "Parent introduces visitor to child" ///
41 "Child can express negative feelings without reprisal" ///
42 "Child can hit parent without harsh reprisal" ///
43 "Child has real or toy musical instrument" ///
44 "Child is taken on outing by family member at least every other week" ///
45 "Child has been on trip more than 50 miles during last year" ///
46 "Child has been taken to a museum during past year" ///
47 "Parent encourages child to put away toys without help" ///
48 "Parent uses complex sentences structure and vocabulary" ///
49 "Child's art work is displayed some place in house" ///
50 "Child eats at least one meal per day with mother and father" ///
51 "Parent lets child choose some foods or brands at grocery store" ///
52 "Parent does not scold or derogate child more than once" ///
53 "Parent does not physical restraint during visit" ///
54 "Parent neither slaps nor spanks child during visit" ///
55 "No more than once instance of physical punishment during past week"

label val row question
*/

* ------- *
* Execution

local matval Rcoeff Rpval Dcoeff Dpval

/*
foreach p of local programs {
	foreach v of local matval {
		egen norm_`p'`v' = std(`p'`v')
		drop `p'`v'
		rename norm_`p'`v' `p'`v'
	}
}
*/



*gen maxR = max(abcRcoeff,ihdpRcoeff)
*gen maxD = max(abcDcoeff,ihdpDcoeff)

gen abcleft=abcRcoeff-0.2
gen abcright=abcRcoeff+0.2

gen ihdpleft=ihdpRcoeff-0.1
gen ihdpright=ihdpRcoeff+0.1


*sort maxR
*gen Rnum = _n
*sort maxD
*gen Dnum = _n


graph dot ihdpRcoeff abcRcoeff ihdpleft ihdpright abcleft abcright,  ///
marker(1,msize(small) mlc(grey) mfc(grey) msymbol(O) ) marker(2,msize(small) msymbol(T) mcolor(black)) ///
marker(3,msize(vsmall) msymbol(O) mlc(grey) mfc(none) mlw(vthin))  marker(4,msize(vsmall) msymbol(O) mlc(grey) mfc(none) mlw(vthin)) ///
marker(5,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin))  marker(6,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin)) ///
over(question ,  label(labsize(vsmall)) sort(row) )  ///
legend (order (1 "IHDP" 2 "ABC" ) size(small)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))



asd


twoway (scatter row ihdpRcoeff) (scatter row abcRcoeff)
 
 
 
asd
*  
aspectratio(2)
gap(70): doesn't work!
*default order is alphabetical
//ysize: tiny labels, big lines
dots( msize(vtiny)): the Default
yscale(noex) useless: log scale, inverted scale, etc
 scale(1)
blabel(question)
ylabel(, size(small))
label variable ihdpRcoeff IHDP
labsize(small)
gap(*0.5)
linetype(line) ugly
linegap(0) //useful if we wanted to separate the line of IHDP and the line of ABC





/*
clear 
input quintile     total       afi   rfi 
             1   1096.83    717.27   .44 
             2    4045.8   1430.88   .35 
             3   5741.28    1747.3    .3 
             4   9429.86   2414.48   .27 
             5   19040.5   4688.59   .27 
end 

gen xtot = quintile - .2 
gen xafi = quintile +.2 
twoway (bar total xtot, barw(.40) ) (bar afi xafi, barw(.4) ) (line rfi quintile ,yaxis(2) ) ylab(0(.1).5, axis(2)) 
	   
twoway (scatter group est1) (rcap est1_u est1_l group, horizontal) (scatter group est2) (rcap est2_u est2_l group, horizontal), ///
ylabel(1/13, valuelabel angle(0)) ytitle("")
*/
