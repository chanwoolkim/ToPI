* ------------------------------------------------- *
* Data table - homogenisation + subpopulation (table)
* Author: Chanwool Kim
* ------------------------------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

#delimit ;
local combination	""Teen.BelowHS.UnderPoverty"
					"Teen.BelowHS.OverPoverty"
					"Teen.AboveHS.UnderPoverty"
					"Teen.AboveHS.OverPoverty"
					"Adult.BelowHS.UnderPoverty"
					"Adult.BelowHS.OverPoverty"
					"Adult.AboveHS.UnderPoverty"
					"Adult.AboveHS.OverPoverty"
					"Total""
;
#delimit cr

local nrow : list sizeof local(combination)
local ncol : list sizeof global(programs)

* ---------------------- *
* Execution - Unrestricted

matrix distribution = J(`nrow', `ncol', .)
matrix rownames distribution = `combination'
matrix colnames distribution = $program_name
local col = 1

foreach p of global programs {
	cd "$data_analysis"
	use "`p'-homo-merge.dta", clear
	di "`p'"

	* Count total number of observations
	count
	local total = r(N)
	* Count total number of nonmissing observations
	count if !missing(m_age_g) & !missing(m_edu_g) & !missing(poverty) & race_g == 0
	local nonmissing = r(N)

	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0
	matrix distribution[1,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0
	matrix distribution[2,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0
	matrix distribution[3,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0
	matrix distribution[4,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0
	matrix distribution[5,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0
	matrix distribution[6,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0
	matrix distribution[7,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0
	matrix distribution[8,`col'] = r(N)/`nonmissing'

	local psum = distribution[1,`col'] ///
		+ distribution[2,`col'] ///
		+ distribution[3,`col'] ///
		+ distribution[4,`col'] ///
		+ distribution[5,`col'] ///
		+ distribution[6,`col'] ///
		+ distribution[7,`col'] ///
		+ distribution[8,`col']
	matrix distribution[9,`col'] = `psum'

	local col = `col' + 1
}

matrix list distribution
cd "$homo_subpop_out"
frmttable using distribution, statmat(distribution) sdec(3) fragment tex replace nocenter

cd "$homo_subpop_git_out"
frmttable using distribution, statmat(distribution) sdec(3) fragment tex replace nocenter

matrix colnames distribution = $programs
svmat distribution, names(col)
keep $programs
keep if abc != . & abc != 1
cd "$data_analysis"
save distribution_homo_subpop, replace

* ---------------------- *
* Execution - Nonmissing D

matrix distribution_D = J(`nrow', `ncol', .)
matrix rownames distribution_D = `combination'
matrix colnames distribution_D = $program_name
local col = 1

foreach p of global programs {
	cd "$data_analysis"
	use "`p'-homo-merge.dta", clear
	di "`p'"

	* Count total number of observations
	count
	local total = r(N)
	* Count total number of nonmissing observations
	count if !missing(m_age_g) & !missing(m_edu_g) & !missing(poverty) & race_g == 0 & !missing(D)
	local nonmissing = r(N)

	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[1,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[2,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[3,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[4,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[5,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[6,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[7,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[8,`col'] = r(N)/`nonmissing'

	local psum = distribution_D[1,`col'] ///
		+ distribution_D[2,`col'] ///
		+ distribution_D[3,`col'] ///
		+ distribution_D[4,`col'] ///
		+ distribution_D[5,`col'] ///
		+ distribution_D[6,`col'] ///
		+ distribution_D[7,`col'] ///
		+ distribution_D[8,`col']
	matrix distribution_D[9,`col'] = `psum'

	local col = `col' + 1
}

matrix list distribution_D
cd "$homo_subpop_out"
frmttable using distribution_D, statmat(distribution_D) sdec(3) fragment tex replace nocenter

cd "$homo_subpop_git_out"
frmttable using distribution_D, statmat(distribution_D) sdec(3) fragment tex replace nocenter

matrix colnames distribution_D = $programs
svmat distribution_D, names(col)
keep $programs
keep if abc != . & abc != 1
cd "$data_analysis"
save distribution_homo_subpop_D, replace
