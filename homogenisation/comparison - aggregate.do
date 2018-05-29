* -------------------- *
* Comparison - aggregate
* Author: Chanwool Kim
* -------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

local ehs_color			red
local ehscenter_color	red
local ehshome_color		red
local ehsmixed_color	red
local ihdp_color		green
local abc_color			blue
local care_color		purple
local careboth_color	purple
local carehome_color	purple

* -------------------------------------------- *
* Merge original and homogenisation pile results

foreach age of numlist 1 3 {
	cd "$data_analysis"
	use "agg-homo-`age'", clear
	rename *R* homo_*R*
	merge 1:1 row using agg-pile-`age', nogen nolabel
	drop scale scale_num scale_row
	include "${code_path}/function/home_agg"
	save agg-merge-`age', replace
}

* ---------------------- *
* Execution - Create graph

foreach age of numlist 1 3 {
	cd "$data_analysis"
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

		graph dot `p'Rinsig `p'R0_1 `p'R0_05 ///
			homo_`p'Rinsig homo_`p'R0_1 homo_`p'R0_05, ///
			marker(1,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color'*0) mlw(thick)) marker(2,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color'*0.5) mlw(thick)) marker(3,msize(large) msymbol(O) mlc(``p'_color') mfc(``p'_color') mlw(thick)) ///
			marker(4,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color'*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color'*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(``p'_color') mfc(``p'_color') mlw(thick)) ///
			over(scale, label(labsize(large)) sort(inv_`p'R_`age'coeff)) ///
			legend (order (3 "Original" 6 "Homogenisation") size(medsmall)) yline(0) ylabel(#6, labsize(medsmall)) ///
			ylabel($agg_axis_range) ///
			graphregion(fcolor(white))

		cd "${homo_out}/comparison"
		graph export "comparison_`p'_R_`age'.pdf", replace

		cd "${homo_git_out}/comparison"
		graph export "comparison_`p'_R_`age'.png", replace
	}
}
