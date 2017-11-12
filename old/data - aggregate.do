* --------------------------------------- *
* Preliminary data preparation - aggregates
* Author: Chanwool Kim
* Date Created: 18 Feb 2017
* Last Update: 1 Jul 2017
* --------------------------------------- *

clear all
set more off

global data_ehs		: env data_ehs
global data_ihdp	: env data_ihdp
global data_abc		: env data_abc
global data_home	: env data_home
global klmshare		: env klmshare

* -------------- *
* Early Head Start

cd "$data_ehs"
use "std-ehs.dta", clear

* HOME total score
rename home_total2	home_total2y
rename home_total3	home_total3y
rename home_tot4	home_total4y
rename home_tot5	home_total10y

*HOME warmth
rename home_emot14m	home_warm14m
rename home_emot24m	home_warm2y
rename B3P_WARM		home_warm3y
rename home_warm4	home_warm4y
rename B5HMWARM		home_warm10y

* HOME parental lack of hostility
rename B5HMLCHO		home_host10y

* HOME parental verbal skills
rename B5HMVERB		home_verb10y

* Harsh scale
rename harshscale3	home_harsh3y

* HOME cognitive stimulation
rename home_lang*	home_cog*
rename home_cog3	home_cog3y
rename home_learn4	home_cog4y

* HOME internal environment
rename B3P_INPH		home_inenviro3y
rename home_inenviro5	home_inenviro10y

* HOME external environment
rename home_scale3	home_exenviro3y
rename home_phys4	home_exenviro4y
rename home_enviro5	home_exenviro10y

drop home_cog

#delimit ;
keep id
treat
home_total*
home_warm*
home_host*
home_verb*
home_nonpun*
home_harsh*
home_inenviro*
home_exenviro*
home_cog*
;
#delimit cr

rename *14m	*14
rename *24m	*24
rename *2y	*24
rename *3y	*36
rename *4y	*48
rename *10y	*120

local ehs_home_types	total cog exenviro harsh host inenviro nonpun verb warm

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ehs_home_types {
	foreach m of numlist 14 24 36 48 120 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

cd "$data_home"
save ehs-home-agg, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "base-ihdp.dta", clear

rename admin_treat	treat
rename ihdp			id

* HOME total score
rename homto_12_sumscore	home_total1y
rename homto_36_sumscore	home_total3y

* HOME warmth response
rename homre_12_sumscore	home_warm1y
rename homwa_36_sumscore	home_warm3y

* HOME acceptance score
rename homac_12_sumscore	home_accept1y
rename homac_36_sumscore	home_accept3y

* HOME organisation score
rename homor_12_sumscore	home_org1y

* HOME play materials score
rename hompm_12_sumscore	home_pm1y

* HOME involvement score
rename homin_12_sumscore	home_inv1y

* HOME variety score
rename homva_12_sumscore	home_var1y
rename homva_36_sumscore	home_var3y

* HOME learning environment
rename homle_36_sumscore	home_learn3y

* HOME lang & cog stimulation
rename homla_36_sumscore	home_lang3y

* HOME external environment
rename hompe_36_sumscore	home_exenviro3y

* HOME academic stimulation
rename homas_36_sumscore	home_acad3y

* HOME modeling score
rename hommo_36_sumscore	home_mod3y

drop home_lang

#delimit ;
keep id
treat
home_total*
home_accept*
home_org*
home_pm*
home_inv*
home_var*
home_learn*
home_lang*
home_exenviro*
home_warm*
home_acad*
home_mod*
;
#delimit cr

rename *1y	*12
rename *3y	*36

local ihdp_home_types	total acad accept exenviro inv lang learn mod org pm var warm

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local ihdp_home_types {
	foreach m of numlist 12 36 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

cd "$data_home"
save ihdp-home-agg, replace

* --------- *
* Abecedarian

cd "$data_abc"
use "append-abccare.dta", clear

* HOME total score
rename home0y6m	home_total0y6m
rename home1y6m	home_total1y6m
rename home2y6m	home_total2y6m
rename home3y6m	home_total3y6m
rename home4y6m	home_total4y6m
rename home8y	home_total8y

* HOME nonpunitive scale
rename home_abspun*	home_nonpun*

* HOME variety score
rename home_oppvar*	home_var*

* HOME lang & cog stimulation
rename home_leng8y	home_lang8y

* HOME involvement score
rename home_minvol*	home_inv*

* HOME warmth
rename home_affect* home_warm*

* HOME internal environment
rename home_orgenv*	home_inenviro*

* HOME external environment
rename home_phyenv*	home_exenviro*

drop *1y

#delimit ;
keep id
treat
program
home_total*
home_nonpun*
home_toys*
home_var*
home_devstm*
home_emotin*
home_exper*
home_indep*
home_lang*
home_masc*
home_inv*
home_warm*
home_absrst*
home_inenviro*
home_exenviro*
home_mature*
;
#delimit cr

rename home_emotin* home_warm*
rename *0y6m	*6
rename *1y6m	*18
rename *2y6m	*30
rename *3y6m	*42
rename *4y6m	*54
rename *8y		*96

local abc_home_types	total toys absrst exper devstm exenviro indep inenviro inv lang masc mature nonpun var warm

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local abc_home_types {
	foreach m of numlist 6 18 30 42 54 96 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

keep if program == "abc"

cd "$data_home"
save abc-home-agg, replace

* -- *
* CARE

cd "$data_abc"
use "append-abccare.dta", clear

* HOME total score
rename home0y6m	home_total0y6m
rename home1y6m	home_total1y6m
rename home2y6m	home_total2y6m
rename home3y6m	home_total3y6m
rename home4y6m	home_total4y6m
rename home8y	home_total8y

* HOME nonpunitive scale
rename home_abspun*	home_nonpun*

* HOME variety score
rename home_oppvar*	home_var*

* HOME lang & cog stimulation
rename home_leng8y	home_lang8y

* HOME involvement score
rename home_minvol*	home_inv*

* HOME warmth
rename home_affect* home_warm*

* HOME internal environment
rename home_orgenv*	home_inenviro*

* HOME external environment
rename home_phyenv*	home_exenviro*

drop treat
rename treat_CARE treat

drop *1y

#delimit ;
keep id
treat
program
home_total*
home_nonpun*
home_toys*
home_var*
home_devstm*
home_emotin*
home_exper*
home_indep*
home_lang*
home_masc*
home_inv*
home_warm*
home_absrst*
home_inenviro*
home_exenviro*
home_mature*
;
#delimit cr

rename home_emotin* home_warm*
rename *0y6m	*6
rename *1y6m	*18
rename *2y6m	*30
rename *3y6m	*42
rename *4y6m	*54
rename *8y		*96

local care_home_types	total toys absrst exper devstm exenviro indep inenviro inv lang masc mature nonpun var warm

* Normalise to have in-group sample mean 0 and variance 1
foreach t of local care_home_types {
	foreach m of numlist 6 18 30 42 54 96 {
	capture egen norm_home_`t'`m' = std(home_`t'`m')
	}
}

keep if program == "care"

cd "$data_home"
save care-home-agg, replace
