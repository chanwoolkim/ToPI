* ------------------------------------- *
* Graphs of treatment effects - item pile
* Author: Chanwool Kim
* Date Created: 5 Jun 2017
* Last Update: 27 Jun 2017
* ------------------------------------- *

clear all
set more off

global data_home "C:\Users\chanw\Dropbox\TOPI\treatment_effect\home"
global data_store "C:\Users\chanw\Dropbox\TOPI\treatment_effect\pile"

* --------------------------- *
* Define macros for abstraction

global covariates			m_age m_edu sibling m_iq race sex gestage mf

local programs				ehs ihdp ihdplow ihdphigh abc carehv careboth

* ------------ *
* Prepare matrix

cd "$data_home"

foreach p of local programs {

use "`p'-home-item-merge.dta", clear

* Create an empty matrix that stores ages, coefficients, lower CIs and upper CIs.
*qui matrix `p'R = J(55, 5, .) // for randomisation variable
qui matrix `p'D = J(55, 5, .) // for participation variable (program specific)

*qui matrix colnames `p'R = `p'Rnum `p'Rcoeff `p'Rlower `p'Rupper `p'Rpval
qui matrix colnames `p'D = `p'Dnum `p'Dcoeff `p'Dlower `p'Dupper `p'Dpval

if "`p'" == "ehs" {
	foreach r of numlist 3 7 11 13 15 17 19/25 27/33 36 40 48 52/54 {
		qui matrix `p'D[`r',1] = `r'
		
		qui ivregress 2sls home_`r' (D = R) $covariates
		* r(table) stores values from regression (ex. coeff, var, CI).
		qui matrix list r(table)
		qui matrix r = r(table)
			
		qui matrix `p'D[`r',2] = r[1,1]
		qui matrix `p'D[`r',3] = r[5,1]
		qui matrix `p'D[`r',4] = r[6,1]
		qui matrix `p'D[`r',5] = r[4,1]
	}
}

else {
* Loop over rows to fill in values into the empty matrix.
foreach r of numlist 1/55 {
*	qui matrix `p'R[`r',1] = `r'
	qui matrix `p'D[`r',1] = `r'
	
/*	* Randomisation variable
	qui regress home_`r' R $covariates
	* r(table) stores values from regression (ex. coeff, var, CI).
	qui matrix list r(table)
	qui matrix r = r(table)

	qui matrix `p'R[`r',2] = r[1,1]
	qui matrix `p'R[`r',3] = r[5,1]
	qui matrix `p'R[`r',4] = r[6,1]
	qui matrix `p'R[`r',5] = r[4,1]
*/			
	* Participation variable (program specific)
	qui ivregress 2sls home_`r' (D = R) $covariates
	* r(table) stores values from regression (ex. coeff, var, CI).
	qui matrix list r(table)
	qui matrix r = r(table)
		
	qui matrix `p'D[`r',2] = r[1,1]
	qui matrix `p'D[`r',3] = r[5,1]
	qui matrix `p'D[`r',4] = r[6,1]
	qui matrix `p'D[`r',5] = r[4,1]
}
}

*svmat `p'R, names(col)
svmat `p'D, names(col)

keep `p'Dnum /*`p'Rcoeff `p'Rlower `p'Rupper `p'Rpval*/ `p'Dcoeff `p'Dlower `p'Dupper `p'Dpval
rename `p'Dnum row
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
gen scale = question

replace scale = "Learning Stimulation" if question == "1" | question == "2" |  question == "3" |  question == "4" |  question == "5" |  question == "6" |  question == "7" |  question == "8" |  question == "9" |  question == "10" |  question == "11"
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

replace scale = "Language Stimulation" if question == "12" | question == "13" |  question == "14" |  question == "15" |  question == "16" |  question == "17" |  question == "18"
replace question = "Child has toys that help teach the names of animals" if question == "12"
replace question = "Child is encouraged to learn the alphabet" if question == "13"
replace question = "Parent teaches child simple verbal manners" if question == "14"
replace question = "Mother uses correct grammar and pronunciation" if question == "15"
replace question = "Parent encourages child to talk and takes time to listen" if question == "16"
replace question = "Parent's voice conveys positive feelings to child" if question == "17"
replace question = "Child is permitted choice in breakfast or lunch menu" if question == "18"

replace scale = "Physical Environment" if question == "19" | question == "20" |  question == "21" |  question == "22" |  question == "23" |  question == "24" |  question == "25"
replace question = "Building appears safe" if question == "19"
replace question = "Outside play environment appears safe" if question == "20"
replace question = "Interior of apartment not dark or perceptually monotonous" if question == "21"
replace question = "Neighborhood is aesthetically pleasing" if question == "22"
replace question = "House has 100 sq. ft. of living space per person" if question == "23"
replace question = "Rooms are not overcrowded with furniture" if question == "24"
replace question = "House is reasonably clean and minimally cluttered" if question == "25"

replace scale = "Warmth and Acceptance" if question == "26" | question == "27" |  question == "28" |  question == "29" |  question == "30" |  question == "31" |  question == "32"
replace question = "Parent holds child close 10-15 minutes per day" if question == "26"
replace question = "Parent converses with child at least twice during visit" if question == "27"
replace question = "Parent answers child's questions or requests verbally" if question == "28"
replace question = "Parent usually responds to child's speech" if question == "29"
replace question = "Parent spontaneously praises child's qualities twice during visit" if question == "30"
replace question = "Parent caresses, kisses, or cuddles child during visit" if question == "31"
replace question = "Parent helps child demonstrate some achievement during visit" if question == "32"

replace scale = "Academic Stimulation" if question == "33" | question == "34" |  question == "35" |  question == "36" |  question == "37"
replace question = "Child is encouraged to learn colors" if question == "33"
replace question = "Child is encouraged to learn patterned speech (songs, etc.)" if question == "34"
replace question = "Child is encouraged to learn spatial relationships" if question == "35"
replace question = "Child is encouraged to learn numbers" if question == "36"
replace question = "Child is encouraged to learn to read a few words" if question == "37"

replace scale = "Modeling" if question == "38" | question == "39" |  question == "40" |  question == "41" |  question == "42"
replace question = "Some delay of food gratification is expected" if question == "38"
replace question = "TV is used judiciously" if question == "39"
replace question = "Parent introduces visitor to child" if question == "40"
replace question = "Child can express negative feelings without reprisal" if question == "41"
replace question = "Child can hit parent without harsh reprisal" if question == "42"

replace scale = "Variety in Experience" if question == "43" | question == "44" |  question == "45" |  question == "46" |  question == "47" |  question == "48" |  question == "49" |  question == "50" |  question == "51"
replace question = "Child has real or toy musical instrument" if question == "43"
replace question = "Child is taken on outing by family member at least every other week" if question == "44"
replace question = "Child has been on trip more than 50 miles during last year" if question == "45"
replace question = "Child has been taken to a museum during past year" if question == "46"
replace question = "Parent encourages child to put away toys without help" if question == "47"
replace question = "Parent uses complex sentences structure and vocabulary" if question == "48"
replace question = "Child's art work is displayed some place in house" if question == "49"
replace question = "Child eats at least one meal per day with mother and father" if question == "50"
replace question = "Parent lets child choose some foods or brands at grocery store" if question == "51"

replace scale = "Acceptance" if question == "52" | question == "53" |  question == "54" |  question == "55"
replace question = "Parent does not scold or derogate child more than once" if question == "52"
replace question = "Parent does not physical restraint during visit" if question == "53"
replace question = "Parent neither slaps nor spanks child during visit" if question == "54"
replace question = "No more than once instance of physical punishment during past week" if question == "55"

* ------------ *
* Execution - CI

/*
* Sort by question numbers in IHDP

cd "$data_store\fig"

graph dot ihdpDcoeff abcDcoeff ihdpDlower ihdpDupper abcDlower abcDupper, ///
marker(1,msize(small) mlc(black) mfc(black) msymbol(O)) marker(2,msize(small) msymbol(T) mcolor(black)) ///
marker(3,msize(vsmall) msymbol(O) mlc(black) mfc(none) mlw(vthin)) marker(4,msize(vsmall) msymbol(O) mlc(black) mfc(none) mlw(vthin)) ///
marker(5,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin)) marker(6,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin)) ///
over(question, label(labsize(vsmall)) sort(row)) ///
legend (order (1 "IHDP" 2 "ABC") size(small)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "D_item_original_ci.eps", replace

* Sort by treatment effect size (max of IHDP and ABC)

graph dot ihdpDcoeff abcDcoeff ihdpDlower ihdpDupper abcDlower abcDupper, ///
marker(1,msize(small) mlc(black) mfc(black) msymbol(O)) marker(2,msize(small) msymbol(T) mcolor(black)) ///
marker(3,msize(vsmall) msymbol(O) mlc(black) mfc(none) mlw(vthin)) marker(4,msize(vsmall) msymbol(O) mlc(black) mfc(none) mlw(vthin)) ///
marker(5,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin)) marker(6,msize(vsmall) msymbol(T) mlc(black) mfc(none) mlw(vthin)) ///
over(question, label(labsize(vsmall)) sort(maxD)) ///
legend (order (1 "IHDP" 2 "ABC") size(small)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "D_item_size_ci.eps", replace
*/

* ----------------- *
* Execution - P-value

foreach p of local programs {
	gen inv_`p'Dcoeff = `p'Dcoeff * -1
}

/*
gen ihdpRinsig = .
gen ihdpR0_1 = .
gen ihdpR0_05 = .
gen ihdpR0_01 = .
replace ihdpRinsig = ihdpRcoeff if ihdpRpval > 0.1
replace ihdpR0_1 = ihdpRcoeff if ihdpRpval <= 0.1 & ihdpRpval > 0.05
replace ihdpR0_05 = ihdpRcoeff if ihdpRpval <= 0.05 & ihdpRpval > 0.01
replace ihdpR0_01 = ihdpRcoeff if ihdpRpval <= 0.01

gen abcRinsig = .
gen abcR0_1 = .
gen abcR0_05 = .
gen abcR0_01 = .
replace abcRinsig = abcRcoeff if abcRpval > 0.1
replace abcR0_1 = abcRcoeff if abcRpval <= 0.1 & abcRpval > 0.05
replace abcR0_05 = abcRcoeff if abcRpval <= 0.05 & abcRpval > 0.01
replace abcR0_01 = abcRcoeff if abcRpval <= 0.01
*/

gen ehsDinsig = .
gen ehsD0_1 = .
gen ehsD0_05 = .
gen ehsD0_01 = .
replace ehsDinsig = ehsDcoeff if ehsDpval > 0.1
replace ehsD0_1 = ehsDcoeff if ehsDpval <= 0.1 & ehsDpval > 0.05
replace ehsD0_05 = ehsDcoeff if ehsDpval <= 0.05 & ehsDpval > 0.01
replace ehsD0_01 = ehsDcoeff if ehsDpval <= 0.01

gen ihdpDinsig = .
gen ihdpD0_1 = .
gen ihdpD0_05 = .
gen ihdpD0_01 = .
replace ihdpDinsig = ihdpDcoeff if ihdpDpval > 0.1
replace ihdpD0_1 = ihdpDcoeff if ihdpDpval <= 0.1 & ihdpDpval > 0.05
replace ihdpD0_05 = ihdpDcoeff if ihdpDpval <= 0.05 & ihdpDpval > 0.01
replace ihdpD0_01 = ihdpDcoeff if ihdpDpval <= 0.01

gen ihdphighDinsig = .
gen ihdphighD0_1 = .
gen ihdphighD0_05 = .
gen ihdphighD0_01 = .
replace ihdphighDinsig = ihdphighDcoeff if ihdphighDpval > 0.1
replace ihdphighD0_1 = ihdphighDcoeff if ihdphighDpval <= 0.1 & ihdphighDpval > 0.05
replace ihdphighD0_05 = ihdphighDcoeff if ihdphighDpval <= 0.05 & ihdphighDpval > 0.01
replace ihdphighD0_01 = ihdphighDcoeff if ihdphighDpval <= 0.01

gen ihdplowDinsig = .
gen ihdplowD0_1 = .
gen ihdplowD0_05 = .
gen ihdplowD0_01 = .
replace ihdplowDinsig = ihdplowDcoeff if ihdplowDpval > 0.1
replace ihdplowD0_1 = ihdplowDcoeff if ihdplowDpval <= 0.1 & ihdplowDpval > 0.05
replace ihdplowD0_05 = ihdplowDcoeff if ihdplowDpval <= 0.05 & ihdplowDpval > 0.01
replace ihdplowD0_01 = ihdplowDcoeff if ihdplowDpval <= 0.01

gen abcDinsig = .
gen abcD0_1 = .
gen abcD0_05 = .
gen abcD0_01 = .
replace abcDinsig = abcDcoeff if abcDpval > 0.1
replace abcD0_1 = abcDcoeff if abcDpval <= 0.1 & abcDpval > 0.05
replace abcD0_05 = abcDcoeff if abcDpval <= 0.05 & abcDpval > 0.01
replace abcD0_01 = abcDcoeff if abcDpval <= 0.01

gen carebothDinsig = .
gen carebothD0_1 = .
gen carebothD0_05 = .
gen carebothD0_01 = .
replace carebothDinsig = carebothDcoeff if carebothDpval > 0.1
replace carebothD0_1 = carebothDcoeff if carebothDpval <= 0.1 & carebothDpval > 0.05
replace carebothD0_05 = carebothDcoeff if carebothDpval <= 0.05 & carebothDpval > 0.01
replace carebothD0_01 = carebothDcoeff if carebothDpval <= 0.01

gen carehvDinsig = .
gen carehvD0_1 = .
gen carehvD0_05 = .
gen carehvD0_01 = .
replace carehvDinsig = carehvDcoeff if carehvDpval > 0.1
replace carehvD0_1 = carehvDcoeff if carehvDpval <= 0.1 & carehvDpval > 0.05
replace carehvD0_05 = carehvDcoeff if carehvDpval <= 0.05 & carehvDpval > 0.01
replace carehvD0_01 = carehvDcoeff if carehvDpval <= 0.01

* Sort by question numbers in IHDP

cd "$data_store\fig"

graph dot ihdpDinsig ihdpD0_1 ihdpD0_05 ihdpD0_01 ///
		  ihdpDinsig ihdpD0_1 ihdpD0_05 ihdpD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(6,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(8,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(13,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(row)) ///
legend (order (4 "IHDP" 8 "ABC" 12 "CARE-Both" 16 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_nobwg_original.eps", replace

* Sort by question numbers in IHDP - divide IHDP birth weight group

graph dot ehsDinsig ehsD0_1 ehsD0_05 ehsD0_01 ///
		  ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(10,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(12,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(17,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(21,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(22,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(23,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(24,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(row)) ///
legend (order (4 "EHS" 8 "IHDP-Low" 12 "IHDP-High" 16 "ABC" 20 "CARE-Both" 24 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_original.eps", replace

* Sort by treatment effect size (by EHS)

graph dot ehsDinsig ehsD0_1 ehsD0_05 ehsD0_01 ///
		  ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(10,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(12,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(17,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(21,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(22,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(23,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(24,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_ehsDcoeff)) ///
legend (order (4 "EHS" 8 "IHDP-Low" 12 "IHDP-High" 16 "ABC" 20 "CARE-Both" 24 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_ehs.eps", replace

* Sort by treatment effect size (by IHDP-Low)

graph dot ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_ihdplowDcoeff)) ///
legend (order (4 "IHDP-Low" 8 "IHDP-High" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_ihdplow.eps", replace

* Sort by treatment effect size (by IHDP-High)

graph dot ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_ihdphighDcoeff)) ///
legend (order (4 "IHDP-Low" 8 "IHDP-High" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_ihdphigh.eps", replace

* Sort by treatment effect size (by ABC)

graph dot ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_abcDcoeff)) ///
legend (order (4 "IHDP-Low" 8 "IHDP-High" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_abc.eps", replace

* Sort by treatment effect size (by CARE-Both)

graph dot ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_carebothDcoeff)) ///
legend (order (4 "IHDP-Low" 8 "IHDP-High" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_careboth.eps", replace

* Sort by treatment effect size (by ABC)

graph dot ihdplowDinsig ihdplowD0_1 ihdplowD0_05 ihdplowD0_01 ///
		  ihdphighDinsig ihdphighD0_1 ihdphighD0_05 ihdphighD0_01 ///
		  abcDinsig abcD0_1 abcD0_05 abcD0_01 ///
		  carebothDinsig carebothD0_1 carebothD0_05 carebothD0_01 ///
		  carehvDinsig carehvD0_1 carehvD0_05 carehvD0_01, ///
marker(1,msize(small) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2,msize(small) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3,msize(small) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4,msize(small) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5,msize(small) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6,msize(small) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7,msize(small) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8,msize(small) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9,msize(small) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10,msize(small) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11,msize(small) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12,msize(small) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13,msize(small) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14,msize(small) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15,msize(small) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16,msize(small) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17,msize(small) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18,msize(small) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19,msize(small) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20,msize(small) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(question, label(labsize(tiny)) sort(inv_carehvDcoeff)) ///
legend (order (4 "IHDP-Low" 8 "IHDP-High" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
ysize(11) xsize(8.5) graphregion(fcolor(white))

graph export "item_pile_D_carehv.eps", replace
