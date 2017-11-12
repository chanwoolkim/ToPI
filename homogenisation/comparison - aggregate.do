* -------------------- *
* Comparison - aggregate
* Author: Chanwool Kim
* Date Created: 22 Sep 2017
* Last Update: 2 Nov 2017
* -------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local ehscenter_color	red
local ehshome_color		red
local ehsmixed_color	red
local ihdplow_color		green
local ihdphigh_color	green
local abc_color			blue
local carehv_color		purple
local careboth_color	purple

* -------------------------------------------- *
* Merge original and homogenisation pile results

foreach age of numlist 1 3 {
	cd "${homo_path}/working"
	use "agg-homo-`age'", clear
	rename *R* homo_*R*
	drop scale_num
	
	cd "${pile_path}/working"
	merge 1:1 row using agg-pile-`age', nogen nolabel
	
	cd "${homo_path}/working"
	save agg-merge-`age', replace
}

* ---------------------- *
* Execution - Create graph

foreach age of numlist 1 3 {
	cd "${homo_path}/working"
	use agg-merge-`age', clear
	
	foreach p of global programs {
		gen `p'Rinsig = .
		gen `p'R0_1 = .
		gen `p'R0_05 = .
		replace `p'Rinsig = `p'R_`age'coeff if `p'R_`age'pval > 0.1
		replace `p'R0_1 = `p'R_`age'coeff if `p'R_`age'pval <= 0.1 & `p'R_`age'pval > 0.05
		replace `p'R0_05 = `p'R_`age'coeff if `p'R_`age'pval <= 0.05
		
		gen homo_`p'Rinsig = .
		gen homo_`p'R0_1 = .
		gen homo_`p'R0_05 = .
		replace homo_`p'Rinsig = homo_`p'R_`age'coeff if homo_`p'R_`age'pval > 0.1
		replace homo_`p'R0_1 = homo_`p'R_`age'coeff if homo_`p'R_`age'pval <= 0.1 & homo_`p'R_`age'pval > 0.05
		replace homo_`p'R0_05 = homo_`p'R_`age'coeff if homo_`p'R_`age'pval <= 0.05
		
		gen inv_`p'R_`age'coeff = `p'R_`age'coeff * -1
		
		cd "${homo_path}/out/comparison"

		graph dot `p'Rinsig `p'R0_1 `p'R0_05 ///
				  homo_`p'Rinsig homo_`p'R0_1 homo_`p'R0_05, ///
		marker(1,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color'*0) mlw(thin)) marker(2,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color'*0.5) mlw(thin)) marker(3,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color') mlw(thin)) ///
		marker(4,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color'*0) mlw(thin)) marker(5,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color'*0.5) mlw(thin)) marker(6,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color') mlw(thin)) ///
		over(scale_num, label(labsize(tiny)) sort(inv_`p'R_`age'coeff)) ///
		legend (order (3 "Original" 6 "Homogenisation") size(vsmall)) yline(0) ylabel(#6, labsize(vsmall)) ///
		graphregion(fcolor(white))

		graph export "comparison_`p'_R_`age'.pdf", replace
	}
}
