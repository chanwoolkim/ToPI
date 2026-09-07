********************************************************************************
* EHS / ABC: descriptives, missingness, attrition, balance
********************************************************************************

clear all
set more off

clear all
set more off

global master_path		"~/Dropbox/TOPI"
global code_path 		"${master_path}/code"
global data_raw		    "${master_path}/Original datasets/"
global data_working		"${master_path}/working/"
global out				"${master_path}/../Apps/Overleaf/ToPI/EHStoABC/Results"
global git_out			"${code_path}/output_backup"

global data_dir   $data_working
global output_dir $out

********************************************************************************
* 1. Lists used throughout
********************************************************************************

local programs    ehsfull ehsmixed ehscenter abc
local samples     full subsample
local covariates                                              m_iq black sex m_age m_edu_2 m_edu_3 sibling gestage mf poverty
local descvars    iq_orig R E D alt sex black sibling gestage m_iq m_age m_edu_2 m_edu_3 mf poverty
local balancevars                   sex black sibling gestage m_iq m_age m_edu_2 m_edu_3 mf poverty
local pctvars             R E D alt sex black                            m_edu_2 m_edu_3 mf poverty

********************************************************************************
* 2. Prepare data
********************************************************************************

tempfile ehsfull ehsmixed ehscenter abc

* EHS datasets
local ehsnames "ehs-full ehsmixed_center ehscenter"
local ehsids   "ehsfull  ehsmixed       ehscenter"

forvalues i=1/3 {

    local name : word `i' of `ehsnames'
    local id   : word `i' of `ehsids'

    import delimited "${data_dir}/`name'-topi.csv", clear varnames(1)

    gen m_edu_2 = m_edu==2 if !missing(m_edu)
    gen m_edu_3 = m_edu==3 if !missing(m_edu)

    rename ppvt3y iq

    gen caregiver_home = caregiver_ever
    gen D   = d_12
    gen alt = p_12
    gen H   = (4140/6000)*D if !missing(D)

    save ``id''
}

* ABC
import delimited "${data_dir}/abc-topi.csv", clear varnames(1)

gen m_edu_2 = m_edu==2 if !missing(m_edu)
gen m_edu_3 = m_edu==3 if !missing(m_edu)

rename sb3y iq

gen D = d_12
gen E = d_12
gen alt = p_12
gen caregiver_home = 1

save `abc'


********************************************************************************
* 3. Complete-case sample
********************************************************************************

capture program drop clean_sample
program define clean_sample

    syntax [, SUBsample]

    keep if !missing(iq,R,E,D,alt,m_iq,black,sex,m_age, ///
                     sibling,gestage,mf,poverty)

    keep if inlist(m_edu,1,2,3)

    if "`subsample'"!="" {
        keep if black==1 & inlist(m_edu,1,2)
    }

end


********************************************************************************
* 4. Allocate result matrices
********************************************************************************

* Attrition:
* rows = programs
* cols = coefficient, SE, p-value
matrix ATTR = J(4,3,.)

* Missingness:
* rows alternate N / %
* cols = program × sample = 8
matrix MISS = J(12,8,.)

* Descriptives:
* 15 variables + N
* cols = program × sample = 8
matrix DESC = J(16,8,.)

* Balance:
* Full: T C p | Subsample: T C p
foreach p of local programs {
    matrix BAL_`p' = J(11,6,.)
}



********************************************************************************
* Text reponses to referees
********************************************************************************
use `ehscenter', clear
gen M = missing(iq)
tab M //35\% is missing
tab M if black==1 & inlist(m_edu,1,2) //30\% is missing

gen YD_nonmi= (iq!=.) & (d!=.)
tab YD_nonmi if black==1 & inlist(m_edu,1,2) //30\% is missing


use `ehsfull', clear
gen M = missing(iq)
tab M //52\% are missing



********************************************************************************
* 5. Attrition: Do we have differential attrition?
********************************************************************************
local programs  ehsfull ehsmixed ehscenter abc

local ip = 0
local col = 0

foreach p of local programs {

    local ip = `ip' + 1
    local file "``p''"

    use "`file'", clear

    gen M = missing(iq)

    quietly regress M r `covariates'

    matrix ATTR[`ip',1] = _b[r]
    matrix ATTR[`ip',2] = _se[r]
    matrix ATTR[`ip',3] = 2*ttail(e(df_r),abs(_b[r]/_se[r]))

}	

********************************************************************************
* 5. Attrition + Balance: Are the RESPONDENT samples balanced?
********************************************************************************

local balancevars sex black sibling gestage m_iq m_age m_edu_2 m_edu_3 mf poverty
local pctvars sex black m_edu_2 m_edu_3 mf poverty
local programs ehsfull ehsmixed ehscenter

matrix BAL = J(`=wordcount("`balancevars'")+1',9,.)

local ip = 0

foreach p of local programs {

    local ip = `ip' + 1
    local bcol = 3*`ip' - 2

    use ``p'', clear
	
	gen nonmi=!missing(iq)
		
    * Common complete-case sample
    count if !missing(iq,r,e,d,alt,m_iq,black,sex,m_age,sibling,gestage,mf,poverty) // 1308
	count if !missing(iq)															// 1424
	
*	keep if !missing(iq)															// 1424

    local r = 0

    foreach v of local balancevars {

		local r = `r' + 1

        quietly summarize `v' if r==1 & nonmi==1
        local mt = r(mean)
        local st = r(sd)

        quietly summarize `v' if r==0 & nonmi==1
        local mc = r(mean)
        local sc = r(sd)

            quietly ttest `v' if nonmi==1, by(r)
            local pv = r(p)

        if strpos(" `pctvars' "," `v' ") {
            local mt = 100*`mt'
            local mc = 100*`mc'
        }

        matrix BAL[`r',`bcol']   = `mt'
        matrix BAL[`r',`bcol'+1] = `mc'
        matrix BAL[`r',`bcol'+2] = `pv'
    }

    local r = `r' + 1

    quietly count if r==1 & nonmi==1
    matrix BAL[`r',`bcol'] = r(N)

    quietly count if r==0 & nonmi==1
    matrix BAL[`r',`bcol'+1] = r(N)
}

matrix list BAL

frmttable using "${output_dir}/balance_three_programs.tex", ///
    statmat(BAL) ///
    tex fragment replace ///
    ctitles( ///
       "\textbf{IQ Nonmissing Only}" \ "Program","All","","","Center $+$ Mixed","","","Center Only","" \ ///
        "","T","C","$p(\Delta)$", ///
           "T","C","$p(\Delta)$", ///
           "T","C","$p(\Delta)$" ///
    ) ///
    multicol(2,2,3; 2,5,3; 2,8,3) ///
    rtitles( ///
        "\% Male" \ ///
        "\% Black" \ ///
        "\# Siblings" \ ///
        "Gestational Age (Weeks)" \ ///
        "Mother's IQ" \ ///
        "Mother's Age" \ ///
        "\% HS Completed" \ ///
        "\% College Completed" \ ///
        "\% Father Figure at Home" \ ///
        "\% Above Poverty" \ ///
        "\# Observations" ///
    ) ///
    sdec(2,2,2,2,2,2,2,2,2) 




********************************************************************************
* 5. Attrition + Balance: Are the ORIGINAL samples balanced?
********************************************************************************

local balancevars nonmi sex black sibling gestage m_iq m_age m_edu_2 m_edu_3 mf poverty
local pctvars nonmi sex black m_edu_2 m_edu_3 mf poverty
local programs ehsfull ehsmixed ehscenter

matrix BAL = J(`=wordcount("`balancevars'")+1',9,.)

local ip = 0

foreach p of local programs {

    local ip = `ip' + 1
    local bcol = 3*`ip' - 2

    use ``p'', clear
	
		gen nonmi=!missing(iq)

    local r = 0

    foreach v of local balancevars {

		local r = `r' + 1

        quietly summarize `v' if r==1
        local mt = r(mean)
        local st = r(sd)

        quietly summarize `v' if r==0
        local mc = r(mean)
        local sc = r(sd)

            quietly ttest `v', by(r)
            local pv = r(p)

        if strpos(" `pctvars' "," `v' ") {
            local mt = 100*`mt'
            local mc = 100*`mc'
        }

        matrix BAL[`r',`bcol']   = `mt'
        matrix BAL[`r',`bcol'+1] = `mc'
        matrix BAL[`r',`bcol'+2] = `pv'
    }

    local r = `r' + 1

    quietly count if r==1
    matrix BAL[`r',`bcol'] = r(N)

    quietly count if r==0
    matrix BAL[`r',`bcol'+1] = r(N)
}

matrix list BAL

frmttable using "${output_dir}/balance_three_programs_all.tex", ///
    statmat(BAL) ///
    tex fragment replace ///
    ctitles( ///
       "\textbf{All Observations}" \ "Program","All","","","Center $+$ Mixed","","","Center Only","","" \ ///
        "","T","C","$p(\Delta)$", ///
           "T","C","$p(\Delta)$", ///
           "T","C","$p(\Delta)$" ///
    ) ///
    multicol(2,2,3; 2,5,3; 2,8,3) ///
    rtitles( ///
       "\% NonMissing IQ" \ ///
	   "\% Male" \ ///
        "\% Black" \ ///
        "\# Siblings" \ ///
        "Gestational Age (Weeks)" \ ///
        "Mother's IQ" \ ///
        "Mother's Age" \ ///
        "\% HS Completed" \ ///
        "\% College Completed" \ ///
        "\% Father Figure at Home" \ ///
        "\% Above Poverty" \ ///
        "\# Observations" ///
    ) ///
    sdec(2,2,2,2,2,2,2,2,2)
	
	
********************************************************************************
* DISADVANTAGE
********************************************************************************
* Compare BLACK VS NON BLACK and LOW EDUC VS HIGH EDUC

label var m_iq 		"Maternal IQ"
label var m_age 	"Maternal Age"
label var gestage 	"Gestational Age (Weeks)"
label var m_iq 		"Mother's IQ"
label var m_age		"Mother's Age"
label var m_edu_2	"\% HS Completed"
label var m_edu_3	"\% College Completed"
label var mf 		"\% Father Figure at Home"
label var poverty	"\% Above Poverty"
label var home_total36 "Home Environment (HOME)"


local advantage_var  m_iq m_age mf poverty home_total36

eststo clear

eststo black_low: 			estpost summarize `advantage_var'	if black==1 & (m_edu==1|m_edu==2)
eststo no_black_low: 	estpost summarize `advantage_var' 	if black==0 & (m_edu==1|m_edu==2)
eststo black_high: 		estpost summarize `advantage_var'   if black==1 & m_edu==3
eststo no_black_high: 	estpost summarize `advantage_var' 	if black==0 & m_edu==3

*------------------------------------------------------------
* 4. Display table in Stata
*------------------------------------------------------------
esttab 			   black_low   no_black_low       black_high    no_black_high,  ///
	label  ///
    nonumber noobs cells("mean(fmt(2))") collabels(none)

*mtitles("\shortstack{Black Low Eds.}" "\shortstack{Non-Black Low Ed.}"  "Black High Ed." "Non-Black High Ed.")	
	
*------------------------------------------------------------
* 5. Export to LaTeX
*------------------------------------------------------------
cd /Users/andres/Dropbox/Apps/Overleaf/ToPI/EHStoABC/Results
esttab black_low no_black_low black_high no_black_high using "subgroup_means.tex", replace ///
    cells("mean(fmt(2))") label mtitles("\shortstack{Black Low \\ Education}" "\shortstack{Non-Black Low \\ Education}" "\shortstack{Black High \\ Education}" "\shortstack{Non-Black High \\ Education}") ///
	nonumber noobs booktabs fragment collabels(none)


	
	
	
	
	
ASD



********************************************************************************
* 5. Loop over programs
********************************************************************************

	
local ip = 0
local col = 0

foreach p of local programs {

    local ip = `ip' + 1
    local file "``p''"
	
    ****************************************************************************
    * 5B. Full + subsample
    ****************************************************************************

    foreach s of local samples {

        local ++col

        use "`file'", clear


        ***********************************************************************
        * Missingness
        *
        * Subsample restriction happens BEFORE counting, exactly as in R.
        ***********************************************************************

        if "`s'"=="subsample" {
            keep if black==1 & inlist(m_edu,1,2)
        }

        gen ok_cov = !missing(R,m_iq,black,sex,m_age,sibling, ///
                             gestage,mf,poverty) ///
                     & inlist(m_edu,1,2,3)

        gen ok_E   = ok_cov & !missing(E)
        gen ok_D   = ok_E   & !missing(D)
        gen ok_alt = ok_D   & !missing(alt)
        gen ok_iq  = ok_alt & !missing(iq)

        quietly count if !missing(R)
        local N0 = r(N)

        local missvars "R ok_cov ok_E ok_D ok_alt ok_iq"

        local r = 0

        foreach v of local missvars {

            local ++r

            if "`v'"=="R" quietly count if !missing(R)
            else          quietly count if `v'

            local rr = 2*`r'-1

            matrix MISS[`rr',`col']   = r(N)
            matrix MISS[`rr'+1,`col'] = 100*r(N)/`N0'
        }


        ***********************************************************************
        * Clean sample for descriptives and balance
        ***********************************************************************

        use "`file'", clear

        if "`s'"=="subsample" clean_sample, subsample
        else                  clean_sample


        ***********************************************************************
        * Descriptive statistics
        ***********************************************************************

        local r = 0

        foreach v of local descvars {

            local ++r

            quietly summarize `v', meanonly
            local x = r(mean)

            if strpos(" `pctvars' "," `v' ") {
                local x = 100*`x'
            }

            matrix DESC[`r',`col'] = `x'
        }

        matrix DESC[16,`col'] = _N


        ***********************************************************************
        * Balance
        ***********************************************************************

        local bcol = cond("`s'"=="full",1,4)
        local r = 0

        foreach v of local balancevars {

            local ++r

            quietly summarize `v' if R==1
            local mt = r(mean)
            local st = r(sd)

            quietly summarize `v' if R==0
            local mc = r(mean)
            local sc = r(sd)

            if (`st'==0 | `sc'==0) {
                local pv = 1
            }
            else {
                quietly ttest `v', by(R)
                local pv = r(p)
            }

            if strpos(" `pctvars' "," `v' ") {
                local mt = 100*`mt'
                local mc = 100*`mc'
            }

            matrix BAL_`p'[`r',`bcol']   = `mt'
            matrix BAL_`p'[`r',`bcol'+1] = `mc'
            matrix BAL_`p'[`r',`bcol'+2] = `pv'
        }

        quietly count if R==1
        matrix BAL_`p'[11,`bcol'] = r(N)

        quietly count if R==0
        matrix BAL_`p'[11,`bcol'+1] = r(N)

    }
}


********************************************************************************
* 6. Labels
********************************************************************************

matrix rownames ATTR = ///
    EHS_All EHS_Mixed_Center EHS_Center ABC

matrix colnames ATTR = ///
    Estimate SE p_value

matrix rownames DESC = ///
    IQ Randomized Participate_Any Participate_Center Alternative_Care ///
    Male Black Siblings Gestational_Age ///
    Mother_IQ Mother_Age HS_Completed College_Completed ///
    Father_Home Above_Poverty Observations


********************************************************************************
* 7. Check results BEFORE doing any formatting
********************************************************************************

matrix list ATTR
matrix list MISS
matrix list DESC

matrix list BAL_ehsfull
matrix list BAL_ehsmixed
matrix list BAL_ehscenter
matrix list BAL_abc


********************************************************************************
* 8. LaTeX output
********************************************************************************

* Common 8-column header
local head8 ///
    `" "Program","EHS","","","","","","ABC","" \ "Type","All","","Center $+$ Mixed","","Center Only","","","" \ "Sample","Full","Subsample","Full","Subsample","Full","Subsample","Full","Subsample" "'


********************************************************************************
* Missingness
********************************************************************************

frmttable using "${output_dir}/number_counts.tex", ///
    statmat(MISS) tex fragment replace ///
    ctitles(`head8') ///
    multicol(1,2,6; 1,8,2; ///
             2,2,2; 2,4,2; 2,6,2; 2,8,2) ///
    rtitles( ///
        "All" \ "" \ ///
        "Non-Missing Covariates" \ "" \ ///
        "Non-Missing Participation (Any)" \ "" \ ///
        "Non-Missing Participation (Center)" \ "" \ ///
        "Non-Missing Alternate Care" \ "" \ ///
        "Non-Missing Outcome" \ "" ///
    ) ///
    sdec(0)


********************************************************************************
* Descriptive statistics
********************************************************************************

frmttable using "${output_dir}/descriptive_stats.tex", ///
    statmat(DESC) tex fragment replace ///
    ctitles(`head8') ///
    multicol(1,2,6; 1,8,2; ///
             2,2,2; 2,4,2; 2,6,2; 2,8,2) ///
    rtitles( ///
        "IQ" \ ///
        "\% Randomized" \ ///
        "\% Participated (Any)" \ ///
        "\% Participated (Center)" \ ///
        "\% Alternative Care" \ ///
        "\% Male" \ ///
        "\% Black" \ ///
        "\# Siblings" \ ///
        "Gestational Age (Weeks)" \ ///
        "Mother's IQ" \ ///
        "Mother's Age" \ ///
        "\% HS Completed" \ ///
        "\% College Completed" \ ///
        "\% Father Figure at Home" \ ///
        "\% Above Poverty" \ ///
        "\# Observations" ///
    ) ///
    sdec(1)


********************************************************************************
* Balance tables
********************************************************************************

local bal_titles ///
    `" "Sample","Full","","","Subsample","","" \ "","T","C","$p(\Delta)$","T","C","$p(\Delta)$" "'

local bal_rows ///
    `" "\% Male" \ "\% Black" \ "\# Siblings" \ "Gestational Age (Weeks)" \ "Mother's IQ" \ "Mother's Age" \ "\% HS Completed" \ "\% College Completed" \ "\% Father Figure at Home" \ "\% Above Poverty" \ "\# Observations" "'


foreach p of local programs {

    frmttable using "${output_dir}/balance_`p'.tex", ///
        statmat(BAL_`p') tex fragment replace ///
        ctitles(`bal_titles') ///
        multicol(1,2,3; 1,5,3) ///
        rtitles(`bal_rows') ///
        sdec(1,1,2,1,1,2)

}


********************************************************************************
* Attrition
********************************************************************************

frmttable using "${output_dir}/attrition_results.tex", ///
    statmat(ATTR) tex fragment replace ///
    ctitles("","Estimate","S.E.","$p$-value") ///
    rtitles("EHS: All" \ ///
            "EHS: Center $+$ Mixed" \ ///
            "EHS: Center Only" \ ///
            "ABC") ///
    sdec(3)
