* ------------------------------------------- *
* Treatment effects - population homogenisation
* Author: Chanwool Kim
* Date Created: 14 Sep 2017
* Last Update: 14 Sep 2017
* ------------------------------------------- *

clear all
set more off

global data_working "C:\Users\chanw\Dropbox\TOPI\treatment_effect\homogenisation\working"
global data_store "C:\Users\chanw\Dropbox\TOPI\treatment_effect\homogenisation\out"

* --------------------------- *
* Define macros for abstraction

global covariates		sibling m_iq sex gestage mf

local programs			ehscenter ehshome ehsmixed ihdplow ihdphigh abc carehv careboth
local 0to3_home_types	total warmth verbal hostility learning activity develop
local 3to6_home_types	total learning reading verbal warmth exterior interior activity hostility

/*
Weights: benchmark is ABC

Mother's age: 1 Adult 0 Teenage
Mother's education: 1 Graduated high school or above 0 Some high school or below
Poverty: 1 Over poverty line 0 Under poverty line
Race: 1 White 0 Non-white
*/

local abc_0000 = 0.404
local abc_0001 = 0
local abc_0010 = 0.009
local abc_0011 = 0
local abc_0100 = 0.07
local abc_0101 = 0
local abc_0110 = 0
local abc_0111 = 0
local abc_1000 = 0.228
local abc_1001 = 0
local abc_1010 = 0.026
local abc_1011 = 0
local abc_1100 = 0.184
local abc_1101 = 0.009
local abc_1110 = 0.061
local abc_1111 = 0.009

local cond_1 "m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_2 "m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 1"
local cond_3 "m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_4 "m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 1"
local cond_5 "m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_6 "m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 1"
local cond_7 "m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0"
local cond_8 "m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 1"
local cond_9 "m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0"
local cond_10 "m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 1"
local cond_11 "m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0"
local cond_12 "m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 1"
local cond_13 "m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0"
local cond_14 "m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 1"
local cond_15 "m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0"
local cond_16 "m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 1"

local cond_all "sibling != . & m_iq != . & sex != . & gestage != . & mf != ."

* ------------ *
* Prepare matrix

foreach p of local programs {

cd "$data_working"
use "`p'-home-agg-homo.dta", clear

* Create an empty matrix that stores ages, coefficients, p-values, lower CIs, and upper CIs.
qui matrix `p'R_1 = J(7, 4, .) // for randomisation variable
qui matrix `p'R_3 = J(9, 4, .) // for randomisation variable

qui matrix colnames `p'R_1 = `p'R_1num `p'R_1coeff `p'R_1se `p'R_1df
qui matrix colnames `p'R_3 = `p'R_3num `p'R_3coeff `p'R_3se `p'R_3df

local row_1 = 1
local row_3 = 1

	* Loop over rows to fill in values into the empty matrix.
	foreach r of local 0to3_home_types {
		qui matrix `p'R_1[`row_1',1] = `row_1'
		
		capture confirm variable norm_home_`r'1
			if !_rc {
			* Randomisation variable: create matrix of each estimate
			qui matrix `p'R_1_`row_1' = J(16, 2, .)
			
			* Store total count
			count if norm_home_`r'1 != . & `cond_all'
			local total_count = r(N)
			
			forvalues i = 1/16 {
				count if norm_home_`r'1 != . & `cond_`i'' & `cond_all'
				local num_count = r(N)
				
				if `num_count' > 1 {
					qui regress norm_home_`r'1 R $covariates if `cond_`i''
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'R_1_`row_1'[`i',1] = r[1,1]
					qui matrix `p'R_1_`row_1'[`i',2] = r[1,2] * r[1,2] * `num_count'
				}
				
				else {
					qui matrix `p'R_1_`row_1'[`i',1] = 0
					qui matrix `p'R_1_`row_1'[`i',2] = 0
				}
			}
			
			qui matrix `p'R_1[`row_1',2] = `p'R_1_`row_1'[1,1] * `abc_0000' ///
										 + `p'R_1_`row_1'[2,1] * `abc_0001' ///
										 + `p'R_1_`row_1'[3,1] * `abc_0010' ///
										 + `p'R_1_`row_1'[4,1] * `abc_0011' ///
										 + `p'R_1_`row_1'[5,1] * `abc_0100' ///
										 + `p'R_1_`row_1'[6,1] * `abc_0101' ///
										 + `p'R_1_`row_1'[7,1] * `abc_0110' ///
										 + `p'R_1_`row_1'[8,1] * `abc_0111' ///
										 + `p'R_1_`row_1'[9,1] * `abc_1000' ///
										 + `p'R_1_`row_1'[10,1] * `abc_1001' ///
										 + `p'R_1_`row_1'[11,1] * `abc_1010' ///
										 + `p'R_1_`row_1'[12,1] * `abc_1011' ///
										 + `p'R_1_`row_1'[13,1] * `abc_1100' ///
										 + `p'R_1_`row_1'[14,1] * `abc_1101' ///
										 + `p'R_1_`row_1'[15,1] * `abc_1110' ///
										 + `p'R_1_`row_1'[16,1] * `abc_1111'
										 
			local sum_sd = `p'R_1_`row_1'[1,2] * `abc_0000' ///
						 + `p'R_1_`row_1'[2,2] * `abc_0001' ///
						 + `p'R_1_`row_1'[3,2] * `abc_0010' ///
						 + `p'R_1_`row_1'[4,2] * `abc_0011' ///
						 + `p'R_1_`row_1'[5,2] * `abc_0100' ///
						 + `p'R_1_`row_1'[6,2] * `abc_0101' ///
						 + `p'R_1_`row_1'[7,2] * `abc_0110' ///
						 + `p'R_1_`row_1'[8,2] * `abc_0111' ///
						 + `p'R_1_`row_1'[9,2] * `abc_1000' ///
						 + `p'R_1_`row_1'[10,2] * `abc_1001' ///
						 + `p'R_1_`row_1'[11,2] * `abc_1010' ///
						 + `p'R_1_`row_1'[12,2] * `abc_1011' ///
						 + `p'R_1_`row_1'[13,2] * `abc_1100' ///
						 + `p'R_1_`row_1'[14,2] * `abc_1101' ///
						 + `p'R_1_`row_1'[15,2] * `abc_1110' ///
						 + `p'R_1_`row_1'[16,2] * `abc_1111'
		
			qui matrix `p'R_1[`row_1',3] = sqrt(`sum_sd'/`total_count')
			qui matrix `p'R_1[`row_1',4] = `total_count' - 7
			
			local row_1 = `row_1' + 1
			}

			else {
			local row_1 = `row_1' + 1
			}
	}

	* Loop over rows to fill in values into the empty matrix.
	foreach r of local 3to6_home_types {
		qui matrix `p'R_3[`row_3',1] = `row_3'
		
		capture confirm variable norm_home_`r'3
			if !_rc {
			* Randomisation variable: create matrix of each estimate
			qui matrix `p'R_3_`row_3' = J(16, 2, .)
			
			* Store total count
			count if norm_home_`r'3 != . & `cond_all'
			local total_count = r(N)

			forvalues i = 1/16 {
				count if norm_home_`r'3 != . & `cond_`i'' & `cond_all'
				local num_count = r(N)
				
				if `num_count' > 1 {
					qui regress norm_home_`r'3 R $covariates if `cond_`i''
					* r(table) stores values from regression (ex. coeff, var, CI).
					qui matrix list r(table)
					qui matrix r = r(table)

					qui matrix `p'R_3_`row_3'[`i',1] = r[1,1]
					qui matrix `p'R_3_`row_3'[`i',2] = r[1,2] * r[1,2] * `num_count'
				}
				
				else {
					qui matrix `p'R_3_`row_3'[`i',1] = 0
					qui matrix `p'R_3_`row_3'[`i',2] = 0
				}
			}
			
			qui matrix `p'R_3[`row_3',2] = `p'R_3_`row_3'[1,1] * `abc_0000' ///
										 + `p'R_3_`row_3'[2,1] * `abc_0001' ///
										 + `p'R_3_`row_3'[3,1] * `abc_0010' ///
										 + `p'R_3_`row_3'[4,1] * `abc_0011' ///
										 + `p'R_3_`row_3'[5,1] * `abc_0100' ///
										 + `p'R_3_`row_3'[6,1] * `abc_0101' ///
										 + `p'R_3_`row_3'[7,1] * `abc_0110' ///
										 + `p'R_3_`row_3'[8,1] * `abc_0111' ///
										 + `p'R_3_`row_3'[9,1] * `abc_1000' ///
										 + `p'R_3_`row_3'[10,1] * `abc_1001' ///
										 + `p'R_3_`row_3'[11,1] * `abc_1010' ///
										 + `p'R_3_`row_3'[12,1] * `abc_1011' ///
										 + `p'R_3_`row_3'[13,1] * `abc_1100' ///
										 + `p'R_3_`row_3'[14,1] * `abc_1101' ///
										 + `p'R_3_`row_3'[15,1] * `abc_1110' ///
										 + `p'R_3_`row_3'[16,1] * `abc_1111'
										 
			local sum_sd = `p'R_3_`row_3'[1,2] * `abc_0000' ///
						 + `p'R_3_`row_3'[2,2] * `abc_0001' ///
						 + `p'R_3_`row_3'[3,2] * `abc_0010' ///
						 + `p'R_3_`row_3'[4,2] * `abc_0011' ///
						 + `p'R_3_`row_3'[5,2] * `abc_0100' ///
						 + `p'R_3_`row_3'[6,2] * `abc_0101' ///
						 + `p'R_3_`row_3'[7,2] * `abc_0110' ///
						 + `p'R_3_`row_3'[8,2] * `abc_0111' ///
						 + `p'R_3_`row_3'[9,2] * `abc_1000' ///
						 + `p'R_3_`row_3'[10,2] * `abc_1001' ///
						 + `p'R_3_`row_3'[11,2] * `abc_1010' ///
						 + `p'R_3_`row_3'[12,2] * `abc_1011' ///
						 + `p'R_3_`row_3'[13,2] * `abc_1100' ///
						 + `p'R_3_`row_3'[14,2] * `abc_1101' ///
						 + `p'R_3_`row_3'[15,2] * `abc_1110' ///
						 + `p'R_3_`row_3'[16,2] * `abc_1111'
		
			qui matrix `p'R_3[`row_3',3] = sqrt(`sum_sd'/`total_count')
			qui matrix `p'R_3[`row_3',4] = `total_count' - 7
			
			local row_3 = `row_3' + 1
			}
			
			else {
			local row_3 = `row_3' + 1
			}
	}

cd "$data_working"

svmat `p'R_1, names(col)
rename `p'R_1num row_1
keep row_1 `p'R_1coeff `p'R_1se `p'R_1df
keep if row_1 != .
gen `p'R_1t = `p'R_1coeff / `p'R_1se
gen `p'R_1pval = 2 * ttail(`p'R_1df, `p'R_1t)
keep row_1 `p'R_1coeff `p'R_1pval
save "`p'-homo-agg-1", replace

svmat `p'R_3, names(col)
rename `p'R_3num row_3
keep row_3 `p'R_3coeff `p'R_3se `p'R_3df
keep if row_3 != .
gen `p'R_3t = `p'R_3coeff / `p'R_3se
gen `p'R_3pval = 2 * ttail(`p'R_3df, `p'R_3t)
keep row_3 `p'R_3coeff `p'R_3pval
save "`p'-homo-agg-3", replace
}

cd "$data_working"

use ehscenter-homo-agg-1, clear

foreach p of local programs {
	merge 1:1 row_1 using `p'-homo-agg-1, nogen nolabel
}

rename row_1 row
save agg-homo-1, replace

use ehscenter-homo-agg-3, clear

foreach p of local programs {
	merge 1:1 row_3 using `p'-homo-agg-3, nogen nolabel
}

rename row_3 row
save agg-homo-3, replace

* --------*
* Questions

cd "$data_working"

use agg-homo-1, clear

tostring row, gen(scale_num)

local 0to3_home_types	total warmth verbal hostility learning activity develop
local 3to6_home_types	total learning reading verbal warmth exterior interior activity hostility

replace scale = "Total Score" if scale_num == "1"
replace scale = "Parental Warmth" if scale_num == "2"
replace scale = "Parental Verbal Skills" if scale_num == "3"
replace scale = "Parental Lack of Hostility" if scale_num == "4"
replace scale = "Learning/Literacy" if scale_num == "5"
replace scale = "Activities/Outings" if scale_num == "6"
replace scale = "Developmental Advance" if scale_num == "7"

save agg-homo-1, replace

use agg-homo-3, clear

tostring row, gen(scale_num)

replace scale = "Total Score" if scale_num == "1"
replace scale = "Learning Stimulation" if scale_num == "2"
replace scale = "Access to Reading" if scale_num == "3"
replace scale = "Parental Verbal Skills" if scale_num == "4"
replace scale = "Parental Warmth" if scale_num == "5"
replace scale = "Home Exterior" if scale_num == "6"
replace scale = "Home Interior" if scale_num == "7"
replace scale = "Outings/Activities" if scale_num == "8"
replace scale = "Parental Lack of Hostility" if scale_num == "9"

save agg-homo-3, replace

* ----------------- *
* Execution - P-value

foreach age of numlist 1 3 {
	cd "$data_working"
	use agg-homo-`age', clear
	
	foreach p of local programs {
		gen inv_`p'Rcoeff = `p'R_`age'coeff * -1
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		gen `p'R0_01 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05 & `p'R_`age'pval > 0.01
		replace `p'R0_01 = `p'R_`age'coeff if `p'R_`age'pval <= 0.01
	}
	
	cd "$data_store"

	graph dot ehscenterRinsig ehscenterR0_1 ehscenterR0_05 ehscenterR0_01 ///
			  ehshomeRinsig ehshomeR0_1 ehshomeR0_05 ehshomeR0_01 ///
			  ehsmixedRinsig ehsmixedR0_1 ehsmixedR0_05 ehsmixedR0_01 ///
			  ihdphighRinsig ihdphighR0_1 ihdphighR0_05 ihdphighR0_01 ///
			  ihdplowRinsig ihdplowR0_1 ihdplowR0_05 ihdplowR0_01 ///
			  abcRinsig abcR0_1 abcR0_05 abcR0_01 ///
			  carebothRinsig carebothR0_1 carebothR0_05 carebothR0_01 ///
			  carehvRinsig carehvR0_1 carehvR0_05 carehvR0_01, ///
	marker(1,msize(large) msymbol(O) mlc(red) mfc(red*0.05) mlw(thin)) marker(2,msize(large) msymbol(O) mlc(red) mfc(red*0.5) mlw(thin)) ///
	marker(3,msize(large) msymbol(O) mlc(red) mfc(red*0.75) mlw(thin)) marker(4,msize(large) msymbol(O) mlc(red) mfc(red) mlw(thin)) ///
	marker(5,msize(large) msymbol(T) mlc(red) mfc(red*0.05) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(red) mfc(red*0.5) mlw(thin)) ///
	marker(7,msize(large) msymbol(T) mlc(red) mfc(red*0.75) mlw(thin)) marker(8,msize(large) msymbol(T) mlc(red) mfc(red) mlw(thin)) ///
	marker(9,msize(large) msymbol(S) mlc(red) mfc(red*0.05) mlw(thin)) marker(10,msize(large) msymbol(S) mlc(red) mfc(red*0.5) mlw(thin)) ///
	marker(11,msize(large) msymbol(S) mlc(red) mfc(red*0.75) mlw(thin)) marker(12,msize(large) msymbol(S) mlc(red) mfc(red) mlw(thin)) ///
	marker(13,msize(large) msymbol(T) mlc(green) mfc(green*0.05) mlw(thin)) marker(14,msize(large) msymbol(T) mlc(green) mfc(green*0.5) mlw(thin)) ///
	marker(15,msize(large) msymbol(T) mlc(green) mfc(green*0.75) mlw(thin)) marker(16,msize(large) msymbol(T) mlc(green) mfc(green) mlw(thin)) ///
	marker(17,msize(large) msymbol(O) mlc(green) mfc(green*0.05) mlw(thin)) marker(18,msize(large) msymbol(O) mlc(green) mfc(green*0.5) mlw(thin)) ///
	marker(19,msize(large) msymbol(O) mlc(green) mfc(green*0.75) mlw(thin)) marker(20,msize(large) msymbol(O) mlc(green) mfc(green) mlw(thin)) ///
	marker(21,msize(large) msymbol(O) mlc(blue) mfc(blue*0.05) mlw(thin)) marker(22,msize(large) msymbol(O) mlc(blue) mfc(blue*0.5) mlw(thin)) ///
	marker(23,msize(large) msymbol(O) mlc(blue) mfc(blue*0.75) mlw(thin)) marker(24,msize(large) msymbol(O) mlc(blue) mfc(blue) mlw(thin)) ///
	marker(25,msize(large) msymbol(O) mlc(purple) mfc(purple*0.05) mlw(thin)) marker(26,msize(large) msymbol(O) mlc(purple) mfc(purple*0.5) mlw(thin)) ///
	marker(27,msize(large) msymbol(O) mlc(purple) mfc(purple*0.75) mlw(thin)) marker(28,msize(large) msymbol(O) mlc(purple) mfc(purple) mlw(thin)) ///
	marker(29,msize(large) msymbol(T) mlc(purple) mfc(purple*0.05) mlw(thin)) marker(30,msize(large) msymbol(T) mlc(purple) mfc(purple*0.5) mlw(thin)) ///
	marker(31,msize(large) msymbol(T) mlc(purple) mfc(purple*0.75) mlw(thin)) marker(32,msize(large) msymbol(T) mlc(purple) mfc(purple) mlw(thin)) ///
	over(scale, label(labsize(tiny)) sort(scale_num)) ///
	legend (order (4 "EHS-Center" 8 "EHS-Home" 12 "EHS-Mixed" 16 "IHDP-High" 20 "IHDP-Low" 24 "ABC" 28 "CARE-Both" 32 "CARE-Home") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
	graphregion(fcolor(white))

	graph export "agg_homo_R_`age'.eps", replace
	graph export "agg_homo_R_`age'.pdf", replace
}
