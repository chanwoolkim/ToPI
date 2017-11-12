* ------------------------------------------ *
* Graphs of treatment effects - aggregate pile 
* Author: Chanwool Kim
* Date Created: 27 Jun 2017
* Last Update: 27 Jun 2017
* ------------------------------------------ *

clear all
set more off

global data_home "C:\Users\chanw\Dropbox\TOPI\treatment_effect\home"
global data_store "C:\Users\chanw\Dropbox\TOPI\treatment_effect\pile"

* --------------------------- *
* Define macros for abstraction

global covariates			m_age m_edu sibling m_iq race sex gestage mf

local programs				ehs ehscenter ehshome ehsmixed ihdp ihdplow ihdphigh abc carehv careboth
local ehs_home_types		total warm nonpun verb harsh inenviro exenviro lang

* ------------ *
* Prepare matrix

cd "$data_home"

foreach p of local programs {

use "`p'-home-ehs-merge.dta", clear

* Create an empty matrix that stores ages, coefficients, lower CIs and upper CIs.
qui matrix `p'D_1 = J(8, 5, .) // for participation variable (program specific)

qui matrix colnames `p'D_1 = `p'Dnum_1 `p'Dcoeff_1 `p'Dlower_1 `p'Dupper_1 `p'Dpval_1

local row = 1

* Loop over rows to fill in values into the empty matrix.
foreach t of local ehs_home_types {
	qui matrix `p'D_1[`row',1] = `row'
	
	capture confirm variable home_`t'1
	if !_rc {
		qui ivregress 2sls home_`t'1 (D = R) $covariates
		* r(table) stores values from regression (ex. coeff, var, CI).
		qui matrix list r(table)
		qui matrix r = r(table)
		
		qui matrix `p'D_1[`row',2] = r[1,1]
		qui matrix `p'D_1[`row',3] = r[5,1]
		qui matrix `p'D_1[`row',4] = r[6,1]
		qui matrix `p'D_1[`row',5] = r[4,1]
		
		local row = `row' + 1
		
	}
	
	else {
		local row = `row' + 1
	}
}

svmat `p'D_1, names(col)

keep `p'Dnum_1 `p'Dcoeff_1 `p'Dlower_1 `p'Dupper_1 `p'Dpval_1
rename `p'Dnum_1 row
keep if row != .

* Create tempfiles so that we could merge two matrix
tempfile tmp`p'_1
save "`tmp`p'_1'", replace
}

foreach p of local programs {
	merge 1:1 row using `tmp`p'_1', nogen nolabel
}

tempfile tmp_1
save "`tmp_1'", replace

foreach p of local programs {

use "`p'-home-ehs-merge.dta", clear

* Create an empty matrix that stores ages, coefficients, lower CIs and upper CIs.
qui matrix `p'D_3 = J(8, 5, .) // for participation variable (program specific)

qui matrix colnames `p'D_3 = `p'Dnum_3 `p'Dcoeff_3 `p'Dlower_3 `p'Dupper_3 `p'Dpval_3

local row = 1

* Loop over rows to fill in values into the empty matrix.
foreach t of local ehs_home_types {
	qui matrix `p'D_3[`row',1] = `row'
	
	capture confirm variable home_`t'3
	if !_rc {
		qui ivregress 2sls home_`t'3 (D = R) $covariates
		* r(table) stores values from regression (ex. coeff, var, CI).
		qui matrix list r(table)
		qui matrix r = r(table)
		
		qui matrix `p'D_3[`row',2] = r[1,1]
		qui matrix `p'D_3[`row',3] = r[5,1]
		qui matrix `p'D_3[`row',4] = r[6,1]
		qui matrix `p'D_3[`row',5] = r[4,1]
		
		local row = `row' + 1
		
	}
	
	else {
		local row = `row' + 1
	}
}

svmat `p'D_3, names(col)

keep `p'Dnum_3 `p'Dcoeff_3 `p'Dlower_3 `p'Dupper_3 `p'Dpval_3
rename `p'Dnum_3 row
keep if row != .

* Create tempfiles so that we could merge two matrix
tempfile tmp`p'_3
save "`tmp`p'_3'", replace
}

foreach p of local programs {
	merge 1:1 row using `tmp`p'_3', nogen nolabel
}

merge 1:1 row using `tmp_1', nogen nolabel

* --------*
* Questions

tostring row, gen(scale)

replace scale = "Total Score" if scale == "1"
replace scale = "Warmth Scale" if scale == "2"
replace scale = "Nonpunitive (Parental Lack of Hostility) Scale" if scale == "3"
replace scale = "Verbal/Social Scale (Parental Verbal Skills)" if scale == "4"
replace scale = "Harsh Scale" if scale == "5"
replace scale = "Internal Physical Environment Scale" if scale == "6"
replace scale = "External Physical Environment Scale" if scale == "7"
replace scale = "Lang Cog Stim (Learning and Literacy)" if scale == "8"

* ----------------- *
* Execution - P-value

foreach p of local programs {
	gen inv_`p'Dcoeff_1 = `p'Dcoeff_1 * -1
	gen inv_`p'Dcoeff_3 = `p'Dcoeff_3 * -1
}

save agg-pile-ehs-result, replace

* Age 1

drop if row == 5 | row == 6 | row == 7

gen ehsDinsig_1 = .
gen ehsD0_1_1 = .
gen ehsD0_05_1 = .
gen ehsD0_01_1 = .
replace ehsDinsig_1 = ehsDcoeff_1 if ehsDpval_1 > 0.1
replace ehsD0_1_1 = ehsDcoeff_1 if ehsDpval_1 <= 0.1 & ehsDpval_1 > 0.05
replace ehsD0_05_1 = ehsDcoeff_1 if ehsDpval_1 <= 0.05 & ehsDpval_1 > 0.01
replace ehsD0_01_1 = ehsDcoeff_1 if ehsDpval_1 <= 0.01

gen ehscenterDinsig_1 = .
gen ehscenterD0_1_1 = .
gen ehscenterD0_05_1 = .
gen ehscenterD0_01_1 = .
replace ehscenterDinsig_1 = ehscenterDcoeff_1 if ehscenterDpval_1 > 0.1
replace ehscenterD0_1_1 = ehscenterDcoeff_1 if ehscenterDpval_1 <= 0.1 & ehscenterDpval_1 > 0.05
replace ehscenterD0_05_1 = ehscenterDcoeff_1 if ehscenterDpval_1 <= 0.05 & ehscenterDpval_1 > 0.01
replace ehscenterD0_01_1 = ehscenterDcoeff_1 if ehscenterDpval_1 <= 0.01

gen ehshomeDinsig_1 = .
gen ehshomeD0_1_1 = .
gen ehshomeD0_05_1 = .
gen ehshomeD0_01_1 = .
replace ehshomeDinsig_1 = ehshomeDcoeff_1 if ehshomeDpval_1 > 0.1
replace ehshomeD0_1_1 = ehshomeDcoeff_1 if ehshomeDpval_1 <= 0.1 & ehshomeDpval_1 > 0.05
replace ehshomeD0_05_1 = ehshomeDcoeff_1 if ehshomeDpval_1 <= 0.05 & ehshomeDpval_1 > 0.01
replace ehshomeD0_01_1 = ehshomeDcoeff_1 if ehshomeDpval_1 <= 0.01

gen ehsmixedDinsig_1 = .
gen ehsmixedD0_1_1 = .
gen ehsmixedD0_05_1 = .
gen ehsmixedD0_01_1 = .
replace ehsmixedDinsig_1 = ehsmixedDcoeff_1 if ehsmixedDpval_1 > 0.1
replace ehsmixedD0_1_1 = ehsmixedDcoeff_1 if ehsmixedDpval_1 <= 0.1 & ehsmixedDpval_1 > 0.05
replace ehsmixedD0_05_1 = ehsmixedDcoeff_1 if ehsmixedDpval_1 <= 0.05 & ehsmixedDpval_1 > 0.01
replace ehsmixedD0_01_1 = ehsmixedDcoeff_1 if ehsmixedDpval_1 <= 0.01

gen ihdpDinsig_1 = .
gen ihdpD0_1_1 = .
gen ihdpD0_05_1 = .
gen ihdpD0_01_1 = .
replace ihdpDinsig_1 = ihdpDcoeff_1 if ihdpDpval_1 > 0.1
replace ihdpD0_1_1 = ihdpDcoeff_1 if ihdpDpval_1 <= 0.1 & ihdpDpval_1 > 0.05
replace ihdpD0_05_1 = ihdpDcoeff_1 if ihdpDpval_1 <= 0.05 & ihdpDpval_1 > 0.01
replace ihdpD0_01_1 = ihdpDcoeff_1 if ihdpDpval_1 <= 0.01

gen ihdphighDinsig_1 = .
gen ihdphighD0_1_1 = .
gen ihdphighD0_05_1 = .
gen ihdphighD0_01_1 = .
replace ihdphighDinsig_1 = ihdphighDcoeff_1 if ihdphighDpval_1 > 0.1
replace ihdphighD0_1_1 = ihdphighDcoeff_1 if ihdphighDpval_1 <= 0.1 & ihdphighDpval_1 > 0.05
replace ihdphighD0_05_1 = ihdphighDcoeff_1 if ihdphighDpval_1 <= 0.05 & ihdphighDpval_1 > 0.01
replace ihdphighD0_01_1 = ihdphighDcoeff_1 if ihdphighDpval_1 <= 0.01

gen ihdplowDinsig_1 = .
gen ihdplowD0_1_1 = .
gen ihdplowD0_05_1 = .
gen ihdplowD0_01_1 = .
replace ihdplowDinsig_1 = ihdplowDcoeff_1 if ihdplowDpval_1 > 0.1
replace ihdplowD0_1_1 = ihdplowDcoeff_1 if ihdplowDpval_1 <= 0.1 & ihdplowDpval_1 > 0.05
replace ihdplowD0_05_1 = ihdplowDcoeff_1 if ihdplowDpval_1 <= 0.05 & ihdplowDpval_1 > 0.01
replace ihdplowD0_01_1 = ihdplowDcoeff_1 if ihdplowDpval_1 <= 0.01

gen abcDinsig_1 = .
gen abcD0_1_1 = .
gen abcD0_05_1 = .
gen abcD0_01_1 = .
replace abcDinsig_1 = abcDcoeff_1 if abcDpval_1 > 0.1
replace abcD0_1_1 = abcDcoeff_1 if abcDpval_1 <= 0.1 & abcDpval_1 > 0.05
replace abcD0_05_1 = abcDcoeff_1 if abcDpval_1 <= 0.05 & abcDpval_1 > 0.01
replace abcD0_01_1 = abcDcoeff_1 if abcDpval_1 <= 0.01

gen carebothDinsig_1 = .
gen carebothD0_1_1 = .
gen carebothD0_05_1 = .
gen carebothD0_01_1 = .
replace carebothDinsig_1 = carebothDcoeff_1 if carebothDpval_1 > 0.1
replace carebothD0_1_1 = carebothDcoeff_1 if carebothDpval_1 <= 0.1 & carebothDpval_1 > 0.05
replace carebothD0_05_1 = carebothDcoeff_1 if carebothDpval_1 <= 0.05 & carebothDpval_1 > 0.01
replace carebothD0_01_1 = carebothDcoeff_1 if carebothDpval_1 <= 0.01

gen carehvDinsig_1 = .
gen carehvD0_1_1 = .
gen carehvD0_05_1 = .
gen carehvD0_01_1 = .
replace carehvDinsig_1 = carehvDcoeff_1 if carehvDpval_1 > 0.1
replace carehvD0_1_1 = carehvDcoeff_1 if carehvDpval_1 <= 0.1 & carehvDpval_1 > 0.05
replace carehvD0_05_1 = carehvDcoeff_1 if carehvDpval_1 <= 0.05 & carehvDpval_1 > 0.01
replace carehvD0_01_1 = carehvDcoeff_1 if carehvDpval_1 <= 0.01

* Sort by question numbers in IHDP

cd "$data_store\fig"

graph dot ehsDinsig_1 ehsD0_1_1 ehsD0_05_1 ehsD0_01_1 ///
		  ihdpDinsig_1 ihdpD0_1_1 ihdpD0_05_1 ihdpD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(row)) ///
legend (order (4 "EHS" 8 "IHDP" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_nobwg_notype_original.eps", replace

* Sort by question numbers in IHDP - divide EHS by program type and IHDP by birth weight group

graph dot ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(row)) ///
legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_original.eps", replace

* Sort by treatment effect size (by EHS-Center)

graph dot ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ehscenterDcoeff_1)) ///
legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_ehscenter.eps", replace

* Sort by treatment effect size (by EHS-Home)

graph dot ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ehshomeDcoeff_1)) ///
legend (order (8 "EHS-Center" 4 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_ehshome.eps", replace

* Sort by treatment effect size (by EHS-Mixed)

graph dot ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ehsmixedDcoeff_1)) ///
legend (order (8 "EHS-Center" 12 "EHS-Home" 4 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_ehsmixed.eps", replace

* Sort by treatment effect size (by IHDP-Low)

graph dot ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ihdplowDcoeff_1)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 4 "IHDP-Low" 8 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_ihdplow.eps", replace

* Sort by treatment effect size (by IHDP-High)

graph dot ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ihdphighDcoeff_1)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 8 "IHDP-Low" 4 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_ihdphigh.eps", replace

* Sort by treatment effect size (by ABC)

graph dot abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_abcDcoeff_1)) ///
legend (order (8 "EHS-Center" 12 "EHS-Home" 16 "EHS-Mixed" 20 "IHDP-Low" 24 "IHDP-High" 4 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_abc.eps", replace

* Sort by treatment effect size (by CARE-Both)

graph dot carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1, ///
marker(1, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
over(scale, sort(inv_carebothDcoeff_1)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 24 "IHDP-Low" 28 "IHDP-High" 32 "ABC" 4 "CARE-Both" 8 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_careboth.eps", replace

* Sort by treatment effect size (by ABC)

graph dot carehvDinsig_1 carehvD0_1_1 carehvD0_05_1 carehvD0_01_1 ///
		  carebothDinsig_1 carebothD0_1_1 carebothD0_05_1 carebothD0_01_1 ///
		  ehscenterDinsig_1 ehscenterD0_1_1 ehscenterD0_05_1 ehscenterD0_01_1 ///
		  ehshomeDinsig_1 ehshomeD0_1_1 ehshomeD0_05_1 ehshomeD0_01_1 ///
		  ehsmixedDinsig_1 ehsmixedD0_1_1 ehsmixedD0_05_1 ehsmixedD0_01_1 ///
		  ihdplowDinsig_1 ihdplowD0_1_1 ihdplowD0_05_1 ihdplowD0_01_1 ///
		  ihdphighDinsig_1 ihdphighD0_1_1 ihdphighD0_05_1 ihdphighD0_01_1 ///
		  abcDinsig_1 abcD0_1_1 abcD0_05_1 abcD0_01_1, ///
marker(1, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
over(scale, sort(inv_carehvDcoeff_1)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 24 "IHDP-Low" 28 "IHDP-High" 32 "ABC" 8 "CARE-Both" 4 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age1_carehv.eps", replace

* Age 3

cd "$data_home"

use agg-pile-ehs-result, clear

drop if row == 3 | row == 4

gen ehsDinsig_3 = .
gen ehsD0_1_3 = .
gen ehsD0_05_3 = .
gen ehsD0_01_3 = .
replace ehsDinsig_3 = ehsDcoeff_3 if ehsDpval_3 > 0.1
replace ehsD0_1_3 = ehsDcoeff_3 if ehsDpval_3 <= 0.1 & ehsDpval_3 > 0.05
replace ehsD0_05_3 = ehsDcoeff_3 if ehsDpval_3 <= 0.05 & ehsDpval_3 > 0.01
replace ehsD0_01_3 = ehsDcoeff_3 if ehsDpval_3 <= 0.01

gen ehscenterDinsig_3 = .
gen ehscenterD0_1_3 = .
gen ehscenterD0_05_3 = .
gen ehscenterD0_01_3 = .
replace ehscenterDinsig_3 = ehscenterDcoeff_3 if ehscenterDpval_3 > 0.1
replace ehscenterD0_1_3 = ehscenterDcoeff_3 if ehscenterDpval_3 <= 0.1 & ehscenterDpval_3 > 0.05
replace ehscenterD0_05_3 = ehscenterDcoeff_3 if ehscenterDpval_3 <= 0.05 & ehscenterDpval_3 > 0.01
replace ehscenterD0_01_3 = ehscenterDcoeff_3 if ehscenterDpval_3 <= 0.01

gen ehshomeDinsig_3 = .
gen ehshomeD0_1_3 = .
gen ehshomeD0_05_3 = .
gen ehshomeD0_01_3 = .
replace ehshomeDinsig_3 = ehshomeDcoeff_3 if ehshomeDpval_3 > 0.1
replace ehshomeD0_1_3 = ehshomeDcoeff_3 if ehshomeDpval_3 <= 0.1 & ehshomeDpval_3 > 0.05
replace ehshomeD0_05_3 = ehshomeDcoeff_3 if ehshomeDpval_3 <= 0.05 & ehshomeDpval_3 > 0.01
replace ehshomeD0_01_3 = ehshomeDcoeff_3 if ehshomeDpval_3 <= 0.01

gen ehsmixedDinsig_3 = .
gen ehsmixedD0_1_3 = .
gen ehsmixedD0_05_3 = .
gen ehsmixedD0_01_3 = .
replace ehsmixedDinsig_3 = ehsmixedDcoeff_3 if ehsmixedDpval_3 > 0.1
replace ehsmixedD0_1_3 = ehsmixedDcoeff_3 if ehsmixedDpval_3 <= 0.1 & ehsmixedDpval_3 > 0.05
replace ehsmixedD0_05_3 = ehsmixedDcoeff_3 if ehsmixedDpval_3 <= 0.05 & ehsmixedDpval_3 > 0.01
replace ehsmixedD0_01_3 = ehsmixedDcoeff_3 if ehsmixedDpval_3 <= 0.01

gen ihdpDinsig_3 = .
gen ihdpD0_1_3 = .
gen ihdpD0_05_3 = .
gen ihdpD0_01_3 = .
replace ihdpDinsig_3 = ihdpDcoeff_3 if ihdpDpval_3 > 0.1
replace ihdpD0_1_3 = ihdpDcoeff_3 if ihdpDpval_3 <= 0.1 & ihdpDpval_3 > 0.05
replace ihdpD0_05_3 = ihdpDcoeff_3 if ihdpDpval_3 <= 0.05 & ihdpDpval_3 > 0.01
replace ihdpD0_01_3 = ihdpDcoeff_3 if ihdpDpval_3 <= 0.01

gen ihdphighDinsig_3 = .
gen ihdphighD0_1_3 = .
gen ihdphighD0_05_3 = .
gen ihdphighD0_01_3 = .
replace ihdphighDinsig_3 = ihdphighDcoeff_3 if ihdphighDpval_3 > 0.1
replace ihdphighD0_1_3 = ihdphighDcoeff_3 if ihdphighDpval_3 <= 0.1 & ihdphighDpval_3 > 0.05
replace ihdphighD0_05_3 = ihdphighDcoeff_3 if ihdphighDpval_3 <= 0.05 & ihdphighDpval_3 > 0.01
replace ihdphighD0_01_3 = ihdphighDcoeff_3 if ihdphighDpval_3 <= 0.01

gen ihdplowDinsig_3 = .
gen ihdplowD0_1_3 = .
gen ihdplowD0_05_3 = .
gen ihdplowD0_01_3 = .
replace ihdplowDinsig_3 = ihdplowDcoeff_3 if ihdplowDpval_3 > 0.1
replace ihdplowD0_1_3 = ihdplowDcoeff_3 if ihdplowDpval_3 <= 0.1 & ihdplowDpval_3 > 0.05
replace ihdplowD0_05_3 = ihdplowDcoeff_3 if ihdplowDpval_3 <= 0.05 & ihdplowDpval_3 > 0.01
replace ihdplowD0_01_3 = ihdplowDcoeff_3 if ihdplowDpval_3 <= 0.01

gen abcDinsig_3 = .
gen abcD0_1_3 = .
gen abcD0_05_3 = .
gen abcD0_01_3 = .
replace abcDinsig_3 = abcDcoeff_3 if abcDpval_3 > 0.1
replace abcD0_1_3 = abcDcoeff_3 if abcDpval_3 <= 0.1 & abcDpval_3 > 0.05
replace abcD0_05_3 = abcDcoeff_3 if abcDpval_3 <= 0.05 & abcDpval_3 > 0.01
replace abcD0_01_3 = abcDcoeff_3 if abcDpval_3 <= 0.01

gen carebothDinsig_3 = .
gen carebothD0_1_3 = .
gen carebothD0_05_3 = .
gen carebothD0_01_3 = .
replace carebothDinsig_3 = carebothDcoeff_3 if carebothDpval_3 > 0.1
replace carebothD0_1_3 = carebothDcoeff_3 if carebothDpval_3 <= 0.1 & carebothDpval_3 > 0.05
replace carebothD0_05_3 = carebothDcoeff_3 if carebothDpval_3 <= 0.05 & carebothDpval_3 > 0.01
replace carebothD0_01_3 = carebothDcoeff_3 if carebothDpval_3 <= 0.01

gen carehvDinsig_3 = .
gen carehvD0_1_3 = .
gen carehvD0_05_3 = .
gen carehvD0_01_3 = .
replace carehvDinsig_3 = carehvDcoeff_3 if carehvDpval_3 > 0.1
replace carehvD0_1_3 = carehvDcoeff_3 if carehvDpval_3 <= 0.1 & carehvDpval_3 > 0.05
replace carehvD0_05_3 = carehvDcoeff_3 if carehvDpval_3 <= 0.05 & carehvDpval_3 > 0.01
replace carehvD0_01_3 = carehvDcoeff_3 if carehvDpval_3 <= 0.01

* Sort by question numbers in IHDP

cd "$data_store\fig"

graph dot ehsDinsig_3 ehsD0_1_3 ehsD0_05_3 ehsD0_01_3 ///
		  ihdpDinsig_3 ihdpD0_1_3 ihdpD0_05_3 ihdpD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(row)) ///
legend (order (4 "EHS" 8 "IHDP" 12 "ABC" 16 "CARE-Both" 20 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_nobwg_notype_original.eps", replace

* Sort by question numbers in IHDP - divide EHS by program type and IHDP by birth weight group

graph dot ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(row)) ///
legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_original.eps", replace

* Sort by treatment effect size (by EHS-Center)

graph dot ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ihdplowDcoeff_3)) ///
legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_ehscenter.eps", replace

* Sort by treatment effect size (by EHS-Home)

graph dot ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ehshomeDcoeff_3)) ///
legend (order (8 "EHS-Center" 4 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_ehshome.eps", replace

* Sort by treatment effect size (by EHS-Mixed)

graph dot ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ehsmixedDcoeff_3)) ///
legend (order (8 "EHS-Center" 12 "EHS-Home" 4 "EHS-Mixed" 16 "IHDP-Low" 20 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_ehsmixed.eps", replace

* Sort by treatment effect size (by IHDP-Low)

graph dot ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ihdplowDcoeff_3)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 4 "IHDP-Low" 8 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_ihdplow.eps", replace

* Sort by treatment effect size (by IHDP-High)

graph dot ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_ihdphighDcoeff_3)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 8 "IHDP-Low" 4 "IHDP-High" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_ihdphigh.eps", replace

* Sort by treatment effect size (by ABC)

graph dot abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
over(scale, sort(inv_abcDcoeff_3)) ///
legend (order (8 "EHS-Center" 12 "EHS-Home" 16 "EHS-Mixed" 20 "IHDP-Low" 24 "IHDP-High" 4 "ABC" 28 "CARE-Both" 32 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_abc.eps", replace

* Sort by treatment effect size (by CARE-Both)

graph dot carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3, ///
marker(1, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
over(scale, sort(inv_carebothDcoeff_3)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 24 "IHDP-Low" 28 "IHDP-High" 32 "ABC" 4 "CARE-Both" 8 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_careboth.eps", replace

* Sort by treatment effect size (by ABC)

graph dot carehvDinsig_3 carehvD0_1_3 carehvD0_05_3 carehvD0_01_3 ///
		  carebothDinsig_3 carebothD0_1_3 carebothD0_05_3 carebothD0_01_3 ///
		  ehscenterDinsig_3 ehscenterD0_1_3 ehscenterD0_05_3 ehscenterD0_01_3 ///
		  ehshomeDinsig_3 ehshomeD0_1_3 ehshomeD0_05_3 ehshomeD0_01_3 ///
		  ehsmixedDinsig_3 ehsmixedD0_1_3 ehsmixedD0_05_3 ehsmixedD0_01_3 ///
		  ihdplowDinsig_3 ihdplowD0_1_3 ihdplowD0_05_3 ihdplowD0_01_3 ///
		  ihdphighDinsig_3 ihdphighD0_1_3 ihdphighD0_05_3 ihdphighD0_01_3 ///
		  abcDinsig_3 abcD0_1_3 abcD0_05_3 abcD0_01_3, ///
marker(1, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.05) mlw(vthin)) marker(2, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(3, msize(vlarge) msymbol(T) mlc(green) mfc(green*0.75) mlw(vthin)) marker(4, msize(vlarge) msymbol(T) mlc(green) mfc(green) mlw(vthin)) ///
marker(5, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.05) mlw(vthin)) marker(6, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.5) mlw(vthin)) ///
marker(7, msize(vlarge) msymbol(O) mlc(green) mfc(green*0.75) mlw(vthin)) marker(8, msize(vlarge) msymbol(O) mlc(green) mfc(green) mlw(vthin)) ///
marker(9, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(10, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(11, msize(vlarge) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(12, msize(vlarge) msymbol(O) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(13, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(14, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(15, msize(vlarge) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(16, msize(vlarge) msymbol(T) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(17, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.05) mlw(vthin)) marker(18, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.5) mlw(vthin)) ///
marker(19, msize(vlarge) msymbol(S) mlc(purple) mfc(purple*0.75) mlw(vthin)) marker(20, msize(vlarge) msymbol(S) mlc(purple) mfc(purple) mlw(vthin)) ///
marker(21, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.05) mlw(vthin)) marker(22, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(23, msize(vlarge) msymbol(O) mlc(red) mfc(red*0.75) mlw(vthin)) marker(24, msize(vlarge) msymbol(O) mlc(red) mfc(red) mlw(vthin)) ///
marker(25, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.05) mlw(vthin)) marker(26, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.5) mlw(vthin)) ///
marker(27, msize(vlarge) msymbol(T) mlc(red) mfc(red*0.75) mlw(vthin)) marker(28, msize(vlarge) msymbol(T) mlc(red) mfc(red) mlw(vthin)) ///
marker(29, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(vthin)) marker(30, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(vthin)) ///
marker(31, msize(vlarge) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(vthin)) marker(32, msize(vlarge) msymbol(O) mlc(blue) mfc(blue) mlw(vthin)) ///
over(scale, sort(inv_carehvDcoeff_3)) ///
legend (order (12 "EHS-Center" 16 "EHS-Home" 20 "EHS-Mixed" 24 "IHDP-Low" 28 "IHDP-High" 32 "ABC" 8 "CARE-Both" 4 "CARE-Home")) yline(0) ylabel(#6) ///
graphregion(fcolor(white))

graph export "agg_pile_D_age3_carehv.eps", replace
