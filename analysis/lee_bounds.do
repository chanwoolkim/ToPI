* ------------------ *
* LEE BOUNDS
* Author: Chanwool Kim
* ------------------ *
timer clear
timer on 1

* ------------- *
* Define programs
* ------------- *
local programs_ehs ehs-full ehsmixed_center ehscenter
local programs `programs_ehs' abc

* -------------------------------------------- *
* Initialize results dataset (empty but defined)
* -------------------------------------------- *
tempfile results
clear
set obs 0
gen str30 program = ""
gen str10 type = ""
gen byte subsample = .
gen double lower = .
gen double upper = .
save `results', replace

* ------------------- *
* Loop through datasets
* ------------------- *
foreach p of local programs {
    cd $data_working
    di as txt "Processing program: `p'"

    * Load and prepare data
    import delimited "`p'-topi.csv", clear
    
    if ("`p'" == "abc") {
        rename sb3y iq
        keep if !missing(r)
    }
    else rename ppvt3y iq

    gen m_edu_2 = (m_edu==2) if !missing(m_edu)
    gen m_edu_3 = (m_edu==3) if !missing(m_edu)

    * ITT: leebounds of iq on r
    if ("`p'" == "ehscenter") {
        tabulate sitenum, generate(sitenum)
		leebounds iq r, tight(sitenum1 sitenum2 sitenum3 sitenum4)
    }
	else quietly leebounds iq r
    mat b = r(table)
    scalar lb = b[1,1]
    scalar ub = b[1,2]

    * Append results
    use `results', clear
    append using `results'
    set obs `=_N+1'
    replace program = "`p'" in L
    replace type = "r" in L
    replace subsample = 0 in L
    replace lower = lb in L
    replace upper = ub in L
    save `results', replace
	
	di as txt "Done with program: `p' on ITT"
	
    * LATE: leebounds of iq on r, instrumented by d, d_1, d_12
    foreach d in d d_1 d_12 {
        import delimited "`p'-topi.csv", clear
        if ("`p'" == "abc") {
            rename sb3y iq
            keep if !missing(r)
        }
        else rename ppvt3y iq
		
        gen m_edu_2 = (m_edu==2) if !missing(m_edu)
        gen m_edu_3 = (m_edu==3) if !missing(m_edu)

        if ("`p'" == "ehscenter") {
			tabulate sitenum, generate(sitenum)
			leebounds iq r, tight(sitenum1 sitenum2 sitenum3 sitenum4)
		}
		else quietly leebounds iq r
        mat itt = r(table)
        scalar itt_lb = itt[1,1]
        scalar itt_ub = itt[1,2]

        if ("`p'" == "ehscenter") {
			leebounds `d' r, tight(sitenum1 sitenum2 sitenum3 sitenum4)
		}
		else quietly leebounds `d' r
        mat fs = r(table)
        scalar fs_lb = fs[1,1]
        scalar fs_ub = fs[1,2]

        scalar late_lb = itt_lb / fs_ub
        scalar late_ub = itt_ub / fs_lb

        use `results', clear
        set obs `=_N+1'
        replace program = "`p'" in L
        replace type = "`d'" in L
        replace subsample = 0 in L
        replace lower = late_lb in L
        replace upper = late_ub in L
        save `results', replace
    }

	di as txt "Done with program: `p' on LATE"

    * ------------------------------------ *
    * Subsample: black==1 and m_edu in (1,2)
    * ------------------------------------ *
    import delimited "`p'-topi.csv", clear
    if ("`p'" == "abc") {
        rename sb3y iq
        keep if !missing(r)
    }
    else rename ppvt3y iq
	
    gen m_edu_2 = (m_edu==2) if !missing(m_edu)
    gen m_edu_3 = (m_edu==3) if !missing(m_edu)
    keep if black==1 & inlist(m_edu,1,2)

    if ("`p'" == "ehscenter") {
        tabulate sitenum, generate(sitenum)
		leebounds iq r, tight(sitenum1 sitenum4)
    }
	else quietly leebounds iq r
    mat b = r(table)
    scalar lb = b[1,1]
    scalar ub = b[1,2]

    use `results', clear
    set obs `=_N+1'
    replace program = "`p'" in L
    replace type = "r" in L
    replace subsample = 1 in L
    replace lower = lb in L
    replace upper = ub in L
    save `results', replace

    foreach d in d d_1 d_12 {
        import delimited "`p'-topi.csv", clear
        if ("`p'" == "abc") {
            rename sb3y iq
            keep if !missing(r)
        }
        else rename ppvt3y iq
		
        gen m_edu_2 = (m_edu==2) if !missing(m_edu)
        gen m_edu_3 = (m_edu==3) if !missing(m_edu)
		keep if black==1 & inlist(m_edu,1,2)

		if ("`p'" == "ehscenter") {
			tabulate sitenum, generate(sitenum)
			leebounds iq r, tight(sitenum1 sitenum4)
		}
		else quietly leebounds iq r
        mat itt = r(table)
        scalar itt_lb = itt[1,1]
        scalar itt_ub = itt[1,2]

        if ("`p'" == "ehscenter") {
			leebounds `d' r, tight(sitenum1 sitenum4)
		}
		else quietly leebounds `d' r
        mat fs = r(table)
        scalar fs_lb = fs[1,1]
        scalar fs_ub = fs[1,2]

        scalar late_lb = itt_lb / fs_ub
        scalar late_ub = itt_ub / fs_lb

        use `results', clear
        set obs `=_N+1'
        replace program = "`p'" in L
        replace type = "`d'" in L
        replace subsample = 1 in L
        replace lower = late_lb in L
        replace upper = late_ub in L
        save `results', replace
    }
}

* ---------- *
* Save results
* ---------- *
use `results', clear
export delimited using "lee_bounds_results.csv", replace

timer off 1
timer list 1
