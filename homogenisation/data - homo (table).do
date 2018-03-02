* ------------------------- *
* Data table - homogenisation
* Author: Chanwool Kim
* Date Created: 4 Jul 2017
* Last Update: 15 Nov 2017
* ------------------------- *

clear all

* --------------------------- *
* Define macros for abstraction

#delimit ;
local combination	""Teen.BelowHS.UnderPoverty.Non-White"
					"Teen.BelowHS.UnderPoverty.White"
					"Teen.BelowHS.OverPoverty.Non-White"
					"Teen.BelowHS.OverPoverty.White"
					"Teen.AboveHS.UnderPoverty.Non-White"
					"Teen.AboveHS.UnderPoverty.White"
					"Teen.AboveHS.OverPoverty.Non-White"
					"Teen.AboveHS.OverPoverty.White"
					"Adult.BelowHS.UnderPoverty.Non-White"
					"Adult.BelowHS.UnderPoverty.White"
					"Adult.BelowHS.OverPoverty.Non-White"
					"Adult.BelowHS.OverPoverty.White"
					"Adult.AboveHS.UnderPoverty.Non-White"
					"Adult.AboveHS.UnderPoverty.White"
					"Adult.AboveHS.OverPoverty.Non-White"
					"Adult.AboveHS.OverPoverty.White"
					"Total""
;
#delimit cr

* ---------------------- *
* Execution - Unrestricted

matrix distribution = J(17, 8, .)
matrix rownames distribution = `combination'
matrix colnames distribution = $program_name
local col = 1
	
foreach p of global programs {
	cd "$homo_working"
	use "`p'-home-homo-merge.dta", clear
	di "`p'"
	
	* Count total number of observations
	count
	local total = r(N)
	* Count total number of nonmissing observations
	count if !missing(m_age_g) & !missing(m_edu_g) & !missing(poverty) & !missing(race_g)
	local nonmissing = r(N)
	
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0
	matrix distribution[1,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 1
	matrix distribution[2,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0
	matrix distribution[3,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 1
	matrix distribution[4,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0
	matrix distribution[5,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 1
	matrix distribution[6,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0
	matrix distribution[7,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 1
	matrix distribution[8,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0
	matrix distribution[9,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 1
	matrix distribution[10,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0
	matrix distribution[11,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 1
	matrix distribution[12,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0
	matrix distribution[13,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 1
	matrix distribution[14,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0
	matrix distribution[15,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 1
	matrix distribution[16,`col'] = r(N)/`nonmissing'
	
	local psum = distribution[1,`col'] ///
				 + distribution[2,`col'] ///
				 + distribution[3,`col'] ///
				 + distribution[4,`col'] ///
				 + distribution[5,`col'] ///
				 + distribution[6,`col'] ///
				 + distribution[7,`col'] ///
				 + distribution[8,`col'] ///
				 + distribution[9,`col'] ///
				 + distribution[10,`col'] ///
				 + distribution[11,`col'] ///
				 + distribution[12,`col'] ///
				 + distribution[13,`col'] ///
				 + distribution[14,`col'] ///
				 + distribution[15,`col'] ///
				 + distribution[16,`col']
	matrix distribution[17,`col'] = `psum'
	
	local col = `col' + 1
}

matrix list distribution
cd "$homo_out"
frmttable using distribution, statmat(distribution) sdec(3) fragment tex replace nocenter

cd "$homo_git_out"
frmttable using distribution, statmat(distribution) sdec(3) fragment tex replace nocenter

matrix colnames distribution = $programs
svmat distribution, names(col)
keep $programs
keep if abc != . & abc != 1
cd "$homo_working"
save distribution, replace

* ---------------------- *
* Execution - Nonmissing D

matrix distribution_D = J(17, 8, .)
matrix rownames distribution_D = `combination'
matrix colnames distribution_D = $program_name
local col = 1
	
foreach p of global programs {
	cd "$homo_working"
	use "`p'-home-homo-merge.dta", clear
	di "`p'"
	
	* Count total number of observations
	count
	local total = r(N)
	* Count total number of nonmissing observations
	count if !missing(m_age_g) & !missing(m_edu_g) & !missing(poverty) & !missing(race_g) & !missing(D)
	local nonmissing = r(N)
	
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[1,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 0 & race_g == 1 & !missing(D)
	matrix distribution_D[2,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[3,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 0 & poverty == 1 & race_g == 1 & !missing(D)
	matrix distribution_D[4,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[5,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 0 & race_g == 1 & !missing(D)
	matrix distribution_D[6,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[7,`col'] = r(N)/`nonmissing'
	count if m_age_g == 0 & m_edu_g == 1 & poverty == 1 & race_g == 1 & !missing(D)
	matrix distribution_D[8,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[9,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 0 & race_g == 1 & !missing(D)
	matrix distribution_D[10,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[11,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 0 & poverty == 1 & race_g == 1 & !missing(D)
	matrix distribution_D[12,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 0 & !missing(D)
	matrix distribution_D[13,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 0 & race_g == 1 & !missing(D)
	matrix distribution_D[14,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 0 & !missing(D)
	matrix distribution_D[15,`col'] = r(N)/`nonmissing'
	count if m_age_g == 1 & m_edu_g == 1 & poverty == 1 & race_g == 1 & !missing(D)
	matrix distribution_D[16,`col'] = r(N)/`nonmissing'
	
	local psum = distribution_D[1,`col'] ///
				 + distribution_D[2,`col'] ///
				 + distribution_D[3,`col'] ///
				 + distribution_D[4,`col'] ///
				 + distribution_D[5,`col'] ///
				 + distribution_D[6,`col'] ///
				 + distribution_D[7,`col'] ///
				 + distribution_D[8,`col'] ///
				 + distribution_D[9,`col'] ///
				 + distribution_D[10,`col'] ///
				 + distribution_D[11,`col'] ///
				 + distribution_D[12,`col'] ///
				 + distribution_D[13,`col'] ///
				 + distribution_D[14,`col'] ///
				 + distribution_D[15,`col'] ///
				 + distribution_D[16,`col']
	matrix distribution_D[17,`col'] = `psum'
	
	local col = `col' + 1
}

matrix list distribution_D
cd "$homo_out"
frmttable using distribution_D, statmat(distribution_D) sdec(3) fragment tex replace nocenter

cd "$homo_git_out"
frmttable using distribution_D, statmat(distribution_D) sdec(3) fragment tex replace nocenter

matrix colnames distribution_D = $programs
svmat distribution_D, names(col)
keep $programs
keep if abc != . & abc != 1
cd "$homo_working"
save distribution_D, replace
