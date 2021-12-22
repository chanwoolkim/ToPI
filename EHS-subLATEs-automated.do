clear all

cd "C:\Users\jpanta\Dropbox\TOPI\do-ToPI"



* Get sub-types from ABC
use "C:\Users\jpanta\Dropbox\TOPI\working\abc-topi.dta"

* The variable R is the randomization
* D is participation in ABC 
* Center is participation in alternative preschools.

keep R  D D_* P P_* sb3y id
keep if sb3y != .
keep if D !=.

foreach num of numlist 1 6 12 18 {
	
	gen None_`num'  = (D_`num'==0 & P_`num'==0)
	gen ABC_`num'   = (D_`num'==1)
	gen Other_`num' = (D_`num'==0 & P_`num'==1)
	
	su None_`num' if R==1
	scalar p_nn_ABC_`num' = r(mean)
	su Other_`num' if R==1
	scalar p_cc_ABC_`num' = r(mean)
	su ABC_`num' if R==0
	scalar p_hh_ABC_`num' = r(mean)
	su None_`num' if R==0
	scalar p_nh_ABC_`num' = r(mean)-p_nn_ABC_`num'
	su Other_`num' if R==0
	scalar p_ch_ABC_`num' = r(mean)-p_cc_ABC_`num'

	quietly{
	    
		noi di as text "ABC Sub-Types Using Threshold   " `num'
		noi di as text "Estimated Pr[n always-taker]   =" p_nn_ABC_`num'
		noi di as text "Estimated Pr[h always-taker]   =" p_hh_ABC_`num'
		noi di as text "Estimated Pr[c always-taker]   =" p_cc_ABC_`num'
		noi di as text "Estimated Pr[n-to-h complier]  =" p_nh_ABC_`num'
		noi di as text "Estimated Pr[c-to-h complier]  =" p_ch_ABC_`num'
	}
	
}




use "C:\Users\jpanta\Dropbox\TOPI\working\juan_ehs.dta", clear 
su
use "C:\Users\jpanta\Dropbox\TOPI\working\juan_ehs_centermixed.dta" , clear
su
use "C:\Users\jpanta\Dropbox\TOPI\working\ehscenter-juan-with-IVs.dta", clear
su
use "C:\Users\jpanta\Dropbox\TOPI\working\ehscenter-juan-with-IVs_mixed_center.dta", clear
su
use "C:\Users\jpanta\Dropbox\TOPI\working\ehs_mixed_center-topi.dta"
su

rename caregiver_ever caregiver_home
 
* Basic Data Clean-Up
keep id ppvt3y R sitenum m_edu m_iq bw m_age black sex D* P* alt caregiver_home cc_payments income_site cc_price_relative program_type bw

su      ppvt3y R sitenum m_edu m_iq bw m_age black sex D* P* alt caregiver_home cc_payments income_site cc_price_relative program_type

drop if  ppvt3y == .
su      ppvt3y R sitenum m_edu m_iq bw m_age black sex D* P* alt caregiver_home cc_payments income_site cc_price_relative program_type

* drop if       D == . /*D seems to have more missing than D_X for X=1,6,12,18 */
rename D oldD
gen D = D_18

rename alt oldalt
gen alt = P_18

 drop if       D == .
drop if     alt == .
drop if   black == .
drop if caregiver_home == . 

* N=728

drop if       R == .
drop if    m_iq == .
drop if     sex == .
drop if    cc_payments == . 
drop if sitenum == .
drop if   m_age == .
drop if   m_edu == .

* N=728
drop if m_edu!=1 & m_edu!=2 & m_edu!=3
* N=716

* drop if      bw == . 
*N=598

*drop if    income_site == . 
*drop if  cc_price_relative == .



rename R       Z_h
rename ppvt3y  Y
rename id      hhid
gen     treat_choice = .
replace treat_choice = 1 if D==1
replace treat_choice = 2 if alt==1
replace treat_choice = 3 if alt==0 & D==0

gen site_06 = (sitenum==6)
gen site_09 = (sitenum==9)
gen site_11 = (sitenum==11)
gen site_14 = (sitenum==14)

rename caregiver_home Z_n
rename cc_payments    Z_c

drop D alt sitenum

*replace m_edu = 0 if m_edu==1|m_edu==2
*replace m_edu = 1 if m_edu==3

gen m_edu_lessHS = (m_edu == 1)
gen m_edu_HS     = (m_edu == 2)
gen m_edu_moreHS = (m_edu == 3)

rename m_edu_moreHS medumoreHS 
rename m_edu_lessHS medulessHS 



gen nonblack = 1-black

 
*local covariates " m_iq nonblack       m_edu_moreHS sex bw m_age                " NO
*local covariates " m_iq                                                         " NO
*local covariates "      black                                                   " 
 local covariates " m_iq black sex m_age m_edu_HS medumoreHS                     " 
*local covariates " m_iq black                    sex                            " NO
*local covariates " m_iq black       m_edu_moreHS sex                            " NO
*local covariates " m_iq black       m_edu_moreHS sex bw                         " NO 
*local covariates " m_iq black       m_edu_moreHS sex bw m_age                   " NO
*local covariates "      black                                                   " NO
*local covariates "      black       m_edu_moreHS                                " NO
*local covariates "      black                    sex                            " NO
*local covariates "      black       m_edu_moreHS                                " NO
local important_covs "m_iq m_age"                    

local chop "black==1 & (m_edu_HS==1|medulessHS==1)"

* Norm the covariate vector X (see page 1830 KW(2016))

*foreach x of local covariates { 
*     egen mean_`x' = mean (`x')
*	  replace  `x' = `x' - mean_`x'
*}

* Recode treat_choice so that category are such that category 1 which will be assigned as baseline category is the "None" alternative (currently "None" is given code 3) Category 2 which  will be assigned as scale alternative is the "IHDP" alternative (currently IHDP is give code 2) and Category 3 which is the "Other" alternative (Currently "Other" is given code 2)

rename  treat_choice treat_choice_old
gen     treat_choice = treat_choice_old
replace treat_choice = 1 if treat_choice_old==3
replace treat_choice = 2 if treat_choice_old==1
replace treat_choice = 3 if treat_choice_old==2

label define lbltreatchoice 1 "None" 2 "EHS" 3 "Other"
label values treat_choice lbltreatchoice


*keep hhid Y Z_h Z_c Z_n treat_choice `covariates'
*keep hhid Y Z_h Z_c     treat_choice `covariates'
 keep hhid Y Z_h Z_c Z_n treat_choice `covariates' bw program_type medulessHS m_edu_HS

gen D =(treat_choice==2)
label var Z_h "Received EHS Offer"
label var D   "Participated in EHS"
label var black "Black"
label var m_iq "Mother's IQ"
label var sex "Male" 
label var bw "Birth Weight"
label var m_edu_HS "MomEdu = HS" 
label var medumoreHS "MomEdu More Than HS"
label var medulessHS "MomEdu Less Than HS"
label var m_age "Mother's Age"

sort hhid

* Chopping Line
keep if `chop'
save ehs_data.dta, replace

* EHS Types
gen None  = (treat_choice==1)
gen EHS   = (treat_choice==2)
gen Other = (treat_choice==3)

su None if Z_h==1
scalar p_nn = r(mean)
su Other if Z_h==1
scalar p_cc = r(mean)
su EHS if Z_h==0
scalar p_hh = r(mean)
su None if Z_h==0
scalar p_nh = r(mean)-p_nn
su Other if Z_h==0
scalar p_ch = r(mean)-p_cc



quietly{
noi di as text "Estimated Pr[n always-taker]   =" p_nn
noi di as text "Estimated Pr[h always-taker]   =" p_hh
noi di as text "Estimated Pr[c always-taker]   =" p_cc
noi di as text "Estimated Pr[n-to-h complier]  =" p_nh
noi di as text "Estimated Pr[c-to-h complier]  =" p_ch
}





***

* Full Sample - Center Only + Mixed
* ---------------------------------

reg Y Z_h              `covariates', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh

reg Y D              `covariates', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D

ivregress 2sls Y (D=Z_h) `covariates', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D

reg Y i.treat_choice `covariates', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice

reg Y Z_h              `covariates' bw, robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_bw

reg Y D              `covariates' bw, robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_bw

ivregress 2sls Y (D=Z_h) `covariates' bw, first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_bw

reg Y i.treat_choice `covariates' bw, robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_bw

esttab EHS_ols_Zh EHS_ols_D EHS_2sls_D EHS_ols_trchoice EHS_ols_Zh_bw EHS_ols_D_bw EHS_2sls_D_bw EHS_ols_trchoice_bw using topi_EHS_jp.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `covariates' bw) drop(1.treat_choice)

* Full Sample - Center Only + Mixed (Only Black as Covariate)
* ---------------------------------

reg Y Z_h              black, robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_blk

reg Y D              black, robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_blk

ivregress 2sls Y (D=Z_h) black, first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_blk

reg Y i.treat_choice black, robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_blk

reg Y Z_h              black if bw !=., robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_bw_blk

reg Y D               black if bw !=., robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_bw_blk

ivregress 2sls Y (D=Z_h) black if bw !=., first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_bw_blk

reg Y i.treat_choice black if bw !=., robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_bw_blk

esttab EHS_ols_Zh_blk EHS_ols_D_blk EHS_2sls_D_blk EHS_ols_trchoice_blk EHS_ols_Zh_bw_blk EHS_ols_D_bw_blk EHS_2sls_D_bw_blk EHS_ols_trchoice_bw_blk using topi_EHS_jp_blk.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice black) drop(1.treat_choice)

* Chopped Sample - Center Only + Mixed
* ---------------------------------

reg Y Z_h              `covariates' if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_chop

reg Y D              `covariates' if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_chop

ivregress 2sls Y (D=Z_h) `covariates' if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_chop

reg Y i.treat_choice `covariates' if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_chop


reg Y Z_h              `covariates' bw if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_chop_bw

reg Y D              `covariates' bw if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_chop_bw

ivregress 2sls Y (D=Z_h) `covariates' bw if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_chop_bw

reg Y i.treat_choice `covariates' bw if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_chop_bw

esttab EHS_ols_Zh_chop EHS_ols_D_chop EHS_2sls_D_chop EHS_ols_trchoice_chop EHS_ols_Zh_chop_bw EHS_ols_D_chop_bw EHS_2sls_D_chop_bw EHS_ols_trchoice_chop_bw using topi_EHS_jp_chop.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `covariates' bw) drop(1.treat_choice black medumoreHS)

* Chopped Sample - Center Only + Mixed - Important Covariates
* -----------------------------------------------------------

reg Y Z_h              `important_covs' if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_chop

reg Y D              `important_covs' if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_chop

ivregress 2sls Y (D=Z_h) `important_covs' if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_chop

reg Y i.treat_choice `important_covs' if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_chop


reg Y Z_h              `important_covs' bw if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_chop_bw

reg Y D              `important_covs' bw if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_chop_bw

ivregress 2sls Y (D=Z_h) `important_covs' bw if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_chop_bw

reg Y i.treat_choice `important_covs' bw if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_chop_bw

esttab EHS_ols_Zh_chop EHS_ols_D_chop EHS_2sls_D_chop EHS_ols_trchoice_chop EHS_ols_Zh_chop_bw EHS_ols_D_chop_bw EHS_2sls_D_chop_bw EHS_ols_trchoice_chop_bw using topi_EHS_jp_chop_importantX.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `important_covs' bw) drop(1.treat_choice)


preserve
keep if program_type==1

* Full Sample - Center Only
* -------------------------

reg Y Z_h              `covariates', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr

reg Y D              `covariates', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr

ivregress 2sls Y (D=Z_h) `covariates', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr

reg Y i.treat_choice `covariates', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr


reg Y Z_h              `covariates' bw, robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr_bw

reg Y D              `covariates' bw, robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr_bw

ivregress 2sls Y (D=Z_h) `covariates' bw, first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr_bw

reg Y i.treat_choice `covariates' bw, robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr_bw


esttab EHS_ols_Zh_ctr EHS_ols_D_ctr EHS_2sls_D_ctr EHS_ols_trchoice_ctr EHS_ols_Zh_ctr_bw EHS_ols_D_ctr_bw EHS_2sls_D_ctr_bw EHS_ols_trchoice_ctr_bw using topi_EHS_jp_centeronly.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `covariates' bw) drop(1.treat_choice)


* Chopped Sample - Center Only
* ----------------------------

reg Y Z_h              `covariates' if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr_chop

reg Y D              `covariates' if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr_chop

ivregress 2sls Y (D=Z_h) `covariates' if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr_chop

reg Y i.treat_choice `covariates' if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr_chp

reg Y Z_h              `covariates' bw if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr_chop_bw

reg Y D              `covariates' bw if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr_chop_bw

ivregress 2sls Y (D=Z_h) `covariates' bw if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr_chop_bw

reg Y i.treat_choice `covariates' bw if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr_chp_bw

esttab EHS_ols_Zh_ctr_chop EHS_ols_D_ctr_chop EHS_2sls_D_ctr_chop EHS_ols_trchoice_ctr_chp EHS_ols_Zh_ctr_chop_bw EHS_ols_D_ctr_chop_bw EHS_2sls_D_ctr_chop_bw EHS_ols_trchoice_ctr_chp_bw using topi_EHS_jp_centeronly_chop.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `covariates' bw) drop(1.treat_choice black medumoreHS)

* Chopped Sample - Center Only - Important Covariates
* ---------------------------------------------------

reg Y Z_h              `important_covs' if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr_chop

reg Y D              `important_covs' if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr_chop

ivregress 2sls Y (D=Z_h) `important_covs' if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr_chop

reg Y i.treat_choice `important_covs' if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr_chp

reg Y Z_h              `important_covs' bw if `chop', robust
su Y if e(Sample) & Z_h==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_Zh_ctr_chop_bw

reg Y D              `important_covs' bw if `chop', robust
su Y if e(Sample) & D==0
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_D_ctr_chop_bw

ivregress 2sls Y (D=Z_h) `important_covs' bw if `chop', first robust
su Y if e(Sample) & D==0  /*here compute complier control mean*/
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_2sls_D_ctr_chop_bw

reg Y i.treat_choice `important_covs' bw if `chop', robust
su Y if e(Sample) & treat_choice==1
estadd scalar MeanDepVarControl = r(mean)
eststo EHS_ols_trchoice_ctr_chp_bw

esttab EHS_ols_Zh_ctr_chop EHS_ols_D_ctr_chop EHS_2sls_D_ctr_chop EHS_ols_trchoice_ctr_chp EHS_ols_Zh_ctr_chop_bw EHS_ols_D_ctr_chop_bw EHS_2sls_D_ctr_chop_bw EHS_ols_trchoice_ctr_chp_bw using topi_EHS_jp_centeronly_chop_importantX.tex, b(%5.2f) se(%5.2f) label replace star(* 0.10 ** 0.05 *** 0.01) mtitles(OLS OLS 2SLS OLS OLS OLS 2SLS OLS) nonotes scalars(MeanDepVarControl) order(Z_h D 2.treat_choice 3.treat_choice `important_covs' bw) drop(1.treat_choice)



restore

****
*local covariates "m_iq black sex m_age m_edu_HS medumoreHS" 
*local covariates "black m_age" 
local covariates "m_age m_iq"

keep if `chop'
keep if bw !=.


* Types in EHS

su None if Z_h==1
scalar p_nn = r(mean)
su Other if Z_h==1
scalar p_cc = r(mean)
su EHS if Z_h==0
scalar p_hh = r(mean)
su None if Z_h==0
scalar p_nh = r(mean)-p_nn
su Other if Z_h==0
scalar p_ch = r(mean)-p_cc

quietly{
noi di as text "Estimated Pr[n always-taker]   =" p_nn
noi di as text "Estimated Pr[h always-taker]   =" p_hh
noi di as text "Estimated Pr[c always-taker]   =" p_cc
noi di as text "Estimated Pr[n-to-h complier]  =" p_nh
noi di as text "Estimated Pr[c-to-h complier]  =" p_ch
}


* Create Interactions of Instruments and Covariates.

foreach x of local covariates {
	gen Z_h_`x'   = Z_h*`x'
    gen Z_c_`x'   = Z_c*`x'
    gen Z_n_`x'   = Z_n*`x'
}

* Prepare Data for Multinomial Probit

expand 3
by hhid, sort: gen treat_options = _n
gen choice = (treat_options == treat_choice)
sort hhid treat_options


* Set up to zero the ECE offer Z and its interactions with covariates Z*X in the utility equations for the non-ECE choices.
* (treat options 1=NONE, 2=EHS, 3=OTHER)

replace Z_h           = 0 if treat_options == 1|treat_options == 3
foreach x of local covariates {
    replace Z_h_`x'   = 0 if treat_options == 1|treat_options == 3
}

replace Z_c           = 0 if treat_options == 1|treat_options == 2
foreach x of local covariates {
    replace Z_c_`x'   = 0 if treat_options == 1|treat_options == 2
}

replace Z_n           = 0 if treat_options == 2|treat_options == 3
foreach x of local covariates {
    replace Z_n_`x'   = 0 if treat_options == 2|treat_options == 3
}

*replace Z_n           = 0 if treat_options == 1
*foreach x of local covariates {
*    replace Z_n_`x'   = 0 if treat_options == 1
*}


* Set up the data as needed using "cmset" for multinomial probit command.

cmset hhid treat_options

* Set up pattern of standard deviations in Structural Var-Cov Matrix Omega so that the Variances of the two differenced utility errors associated with the two non-base alternatives in the Differenced Var-Cov Matrix Sigma is equal to 1, as in KW(2016, page 1827)

matrix stdpat = J(3, 1, sqrt(0.5))

* First Step Estimate multinomial probit model: using non-participation (j=1) as base alternative and IHDP (j=2) as scale alternative

 cmmprobit choice Z_n* Z_h* Z_c*, casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)
*cmmprobit choice      Z_h* Z_c*, casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)
*cmmprobit choice Z_n* Z_h*     , casevars(`covariates') basealternative(1) scalealternative(2) stddev(fixed stdpat)

predict pr_hat, pr
predict psi_hat, xb


* Manually Compute psi_h

gen psi_h_Zi       =  0
gen psi_h_Zi_Zhi_0 =  0
gen psi_h_Zi_Zhi_1 =  0

*local Zs "Z_n Z_n_black Z_h Z_h_black Z_c Z_c_black"

local Zs = ""
local Zs = "`Zs' Z_n"
foreach x of local covariates {
	local Zs = "`Zs' Z_n_`x'"
}
local Zs = "`Zs' Z_h"
foreach x of local covariates {
	local Zs = "`Zs' Z_h_`x'"
}
local Zs = "`Zs' Z_c"
foreach x of local covariates {
	local Zs = "`Zs' Z_c_`x'"
}

di "`Zs'"

local col = 0 

foreach var of local Zs {

	local col = `col' + 1
	di `col'
	local done = 0
	
		if `done'== 0 & "`var'" == "Z_h" {
			replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * Z_h
			replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * 0
			replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * 1
			local done = 1
		}
		
		foreach x of local covariates {
			
			if `done'== 0 & "`var'" == "Z_h_`x'" {			
				replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * Z_h_`x'
				replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * 0 * `x'
				replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * 1 * `x'
				local done = 1
			}
		}
		
		if `done'== 0 {
				replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * `var'
				replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * `var'	
				replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * `var'
			}
		
}

* Add case-specific coefficients and varibles for choice h
foreach x of local covariates {
	local col = `col' + 1
	replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col'] * `x' 
	replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col'] * `x' 
	replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col'] * `x' 
}

* Add constant for choice h
local col = `col' + 1
replace psi_h_Zi       = psi_h_Zi       + e(b)[1,`col']
replace psi_h_Zi_Zhi_0 = psi_h_Zi_Zhi_0 + e(b)[1,`col']
replace psi_h_Zi_Zhi_1 = psi_h_Zi_Zhi_1 + e(b)[1,`col']

* Compare manual and automatic.
browse psi_hat psi_h_Zi  if treat_options==2 

gen psi_hat_Zhi_0 = psi_h_Zi_Zhi_0
gen psi_hat_Zhi_1 = psi_h_Zi_Zhi_1

replace psi_hat_Zhi_0 = -999 if treat_options == 1 | treat_options == 3
replace psi_hat_Zhi_1 = -999 if treat_options == 1 | treat_options == 3

* Structural Representation of Var-Cov "Omega"

estat covariance

* Differenced Representation of Var-Cov "Sigma"

matrix Omega = r(cov)
matrix M = (1,-1,0 \ 1,0,-1)
matrix Sigma = M*Omega*M'
matrix list Sigma
scalar rho = Sigma[2,1]

* Second Step: Construct the 6 Bivariate Mills Ratios

  drop Z_n Z_n* Z_h Z_h* Z_c Z_c* choice `covariates' Y treat_choice psi_h_Zi psi_h_Zi_Zhi_0 psi_h_Zi_Zhi_1
* drop          Z_h Z_h* Z_c Z_c* choice `covariates' Y treat_choice
* drop Z_n Z_n* Z_h Z_h*          choice `covariates' Y treat_choice 
  
reshape wide psi_hat pr_hat psi_hat_Zhi_0 psi_hat_Zhi_1, i( hhid ) j( treat_options )

sort hhid
merge 1:1 hhid using ehs_data.dta
drop   psi_hat1
drop psi_hat_Zhi_01 psi_hat_Zhi_03
drop psi_hat_Zhi_11 psi_hat_Zhi_13
rename psi_hat2 psi_h
rename psi_hat3 psi_c
rename psi_hat_Zhi_02 psi_h_Zhi0
rename psi_hat_Zhi_12 psi_h_Zhi1
drop _merge


* lambda_h(.,.,h)
gen a = psi_h
gen b = (psi_h-psi_c) / sqrt(2*(1-rho))
scalar ksi = sqrt((1-rho)/2)
gen lambda_h_h = (-1)*(-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal((a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi))

* lambda_c(.,.,h)
drop a b 
scalar drop ksi
gen a = (psi_h-psi_c) / sqrt(2*(1-rho))
gen b = psi_h
scalar ksi = sqrt((1-rho)/2)
gen lambda_c_h = lambda_h_h + sqrt(2*(1-rho)) * (-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_c(.,.,c)
drop a b 
scalar drop ksi
gen a = psi_c
gen b = (psi_c-psi_h) / sqrt(2*(1-rho))
scalar ksi = sqrt((1-rho)/2)
gen lambda_c_c = (-1)*(-1)*( ( normalden(a)*normal( (b-ksi*a) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*b) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_h(.,.,c)
drop a b 
scalar drop ksi
gen a = (psi_c-psi_h) / sqrt(2*(1-rho))
gen b = psi_c
scalar ksi = sqrt((1-rho)/2)
gen lambda_h_c = lambda_c_c + sqrt(2*(1-rho)) * (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_h(.,.,n)
drop a b 
scalar drop ksi
gen a = -psi_h
gen b = -psi_c
scalar ksi = rho
gen lambda_h_n= (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

* lambda_c(.,.,n)
drop a b 
scalar drop ksi
gen a = -psi_c
gen b = -psi_h
scalar ksi = rho
gen lambda_c_n = (-1)*( ( normalden(a)*normal( (b-ksi*(a)) / sqrt(1-(ksi)^2) )   +  ksi*normalden(b)*normal( (a-ksi*(b)) / sqrt(1-(ksi)^2) ) ) / binormal(a,b,ksi) )

scalar drop ksi
drop a b 
drop psi_h

* Third Step: OLS controlling for bi-variate mills ratios.

gen D_n = (treat_choice==1)
gen D_h = (treat_choice==2)
gen D_c = (treat_choice==3)

gen      lambda_c_D = .
replace  lambda_c_D = lambda_c_n if D_n == 1
replace  lambda_c_D = lambda_c_h if D_h == 1
replace  lambda_c_D = lambda_c_c if D_c == 1

gen      lambda_h_D = .
replace  lambda_h_D = lambda_h_n if D_n == 1
replace  lambda_h_D = lambda_h_h if D_h == 1
replace  lambda_h_D = lambda_h_c if D_c == 1



* Norm the covariate vector X (see page 1830 KW(2016))
local normed_covariates = ""
  foreach x of local covariates{
     su   `x'
	 gen  `x'_normed = `x' - r(mean)
	 local normed_covariates = "`normed_covariates' `x'_normed"
 }

* Generate D_c and D_h interactions with (normed) covariates X
 
foreach x of local covariates {
	gen D_c_`x'   = D_c * `x'_normed
    gen D_h_`x'   = D_h * `x'_normed
}

gen D_c_lambda_h_c = D_c * lambda_h_c
gen D_c_lambda_c_c = D_c * lambda_c_c

gen D_h_lambda_h_h = D_h * lambda_h_h
gen D_h_lambda_c_h = D_h * lambda_c_h

 reg Y `normed_covariates' lambda_h_D lambda_c_D D_c D_c_*       D_h D_h_*       , robust

scalar gamma_nh_hat = _b[lambda_h_D]
scalar gamma_nc_hat = _b[lambda_c_D]
scalar gamma_hh_hat = _b[D_h_lambda_h_h] + gamma_nh_hat
scalar gamma_hc_hat = _b[D_h_lambda_c_h] + gamma_nc_hat
scalar gamma_ch_hat = _b[D_c_lambda_h_c] + gamma_nh_hat
scalar gamma_cc_hat = _b[D_c_lambda_c_c] + gamma_nc_hat

*reg Y `covariates' lambda_h_D lambda_c_D D_c D_c_lambda* D_h D_h_lambda* , robust
 
quietly{
noi di as text "Estimated theta_c0-theta_n0 = E[Yc-Yn]: = " _b[D_c]
noi di as text "Estimated theta_c0-theta_n0 = E[Yh-Yn]: = " _b[D_h]
}

scalar theta_c0_theta_n0_hat = _b[D_c]
scalar theta_h0_theta_n0_hat = _b[D_h]
scalar          theta_n0_hat = _b[_cons]
scalar          theta_h0_hat = theta_h0_theta_n0_hat + theta_n0_hat
scalar          theta_c0_hat = theta_c0_theta_n0_hat + theta_n0_hat

* ================================
* SubLATE E[Yh-Yn|n-to-h complier]
* SubLATE E[Yh-Yc|c-to-h complier]
* ================================

gen X_theta_hx_hat = 0
gen X_theta_cx_hat = 0
gen X_theta_nx_hat = 0


foreach x of local covariates {
	
	scalar          theta_nx_hat_`x' = _b[`x']
	scalar theta_cx_theta_nx_hat_`x' = _b[D_c_`x']
	scalar theta_hx_theta_nx_hat_`x' = _b[D_h_`x']
	scalar          theta_cx_hat_`x' = theta_cx_theta_nx_hat_`x' - theta_nx_hat_`x'
	scalar          theta_hx_hat_`x' = theta_hx_theta_nx_hat_`x' - theta_nx_hat_`x'

	replace X_theta_hx_hat = X_theta_hx_hat + `x' * theta_hx_hat_`x'
	replace X_theta_cx_hat = X_theta_cx_hat + `x' * theta_cx_hat_`x'
	replace X_theta_nx_hat = X_theta_nx_hat + `x' * theta_nx_hat_`x'
}

* ---------------------------------------------
* Complier Type Probabilities
* ---------------------------------------------

* Let omega_nh_hat be an estimate of the probability that individual i is a nh-complier conditional on his or her covariates:

gen a1 = -psi_h_Zhi0
gen b1 = -psi_c
gen a2 = -psi_h_Zhi1
gen b2 = -psi_c
gen   omega_nh_hat = binormal(a1,b1,rho) - binormal(a2,b2,rho)
total omega_nh_hat
scalar sum_omega_nh_hat = e(b)[1,1]
gen weight_nh = omega_nh_hat / sum_omega_nh_hat
drop a1 b1 a2 b2


* Let omega_ch_hat be an estimate of the probability that individual i is a ch-complier conditional on his or her covariates:

gen a1 = ( psi_c - psi_h_Zhi0 ) / sqrt(2*(1-rho))
gen b1 = psi_c
gen a2 = ( psi_c - psi_h_Zhi1 ) / sqrt(2*(1-rho))
gen b2 = psi_c
scalar corr_hminusc_c = sqrt((1-rho)/2)
gen   omega_ch_hat = binormal(a1,b1,corr_hminusc_c) - binormal(a2,b2,corr_hminusc_c)
total omega_ch_hat
scalar sum_omega_ch_hat = e(b)[1,1]
gen weight_ch = omega_ch_hat / sum_omega_ch_hat
drop a1 b1 a2 b2

* ----------------------------------------------------------------
* Means of Bivariate Standard Normals with 2-Sided Truncated Means.
* ----------------------------------------------------------------

*For nh-compliers
*----------------

* Lambda0_h_nh
gen a0 = -psi_h_Zhi1
gen a1 = -psi_h_Zhi0
gen b0 = -1000000
gen b1 = -psi_c
scalar ksi = rho

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_h_nh_FIRST   =  FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_h_nh_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_h_nh         = Lambda0_h_nh_FIRST + Lambda0_h_nh_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

* Lambda0_c_nh

gen a0 = -1000000
gen a1 = -psi_c
gen b0 = -psi_h_Zhi1
gen b1 = -psi_h_Zhi0
scalar ksi = rho

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_c_nh_FIRST   = FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_c_nh_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_c_nh         = Lambda0_c_nh_FIRST + Lambda0_c_nh_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

* ------------------------------------------------------

*For ch-compliers
*----------------

* Lambda0_hminusc_ch

gen a0 = -1000000
gen a1 =  psi_c
gen b0 = (psi_c - psi_h_Zhi1) / sqrt(2*(1-rho))
gen b1 = (psi_c - psi_h_Zhi0) / sqrt(2*(1-rho))
scalar ksi = sqrt((1-rho)/2)

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_hminusc_ch_FIRST   =  FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hminusc_ch_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_hminusc_ch         = Lambda0_hminusc_ch_FIRST + Lambda0_hminusc_ch_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

* Lambda0_c_ch

gen a0 = (psi_c - psi_h_Zhi1) / sqrt(2*(1-rho))
gen a1 = (psi_c - psi_h_Zhi0) / sqrt(2*(1-rho))
gen b0 = -1000000
gen b1 = psi_c
scalar ksi = sqrt((1-rho)/2)

gen COMMON_DENOMINATOR = binormal(a1,b1,ksi) - binormal(a1,b0,rho) - binormal(a0,b1,ksi) + 2*binormal(a0,b0,ksi)
gen  FIRST_NUMERATOR   =     normalden(a0)*(normal((b1-ksi*a0) / sqrt(1-(ksi)^2) ) - normal( (1-ksi)*a0  / sqrt(1-(ksi)^2))) -     normalden(a1)*(normal( (b1-ksi*a1) / sqrt(1-(ksi)^2) ) - normal( (b0-ksi*a1) / sqrt(1-(ksi)^2) ) ) 
gen SECOND_NUMERATOR   = ksi*normalden(b0)*(normal((a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b0) / sqrt(1-(ksi)^2))) - ksi*normalden(b1)*(normal( (a1-ksi*b1) / sqrt(1-(ksi)^2) ) - normal( (a0-ksi*b1) / sqrt(1-(ksi)^2) ) )

gen Lambda0_c_ch_FIRST   = FIRST_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_c_ch_SECOND  = SECOND_NUMERATOR / COMMON_DENOMINATOR
gen Lambda0_c_ch = Lambda0_c_ch_FIRST + Lambda0_c_ch_SECOND

drop a0 a1 b0 b1 FIRST_NUMERATOR SECOND_NUMERATOR COMMON_DENOMINATOR
scalar drop ksi

*--------------n-to-h compliers------------------------------

gen mu_hat_nh_h_X = theta_h0_hat + X_theta_hx_hat + gamma_hh_hat * Lambda0_h_nh + gamma_hc_hat * Lambda0_c_nh
gen mu_hat_nh_n_X = theta_n0_hat + X_theta_nx_hat + gamma_nh_hat * Lambda0_h_nh + gamma_nc_hat * Lambda0_c_nh

* To obtain unconditional estimates, we integrate over the distribution of Xi for nh-compliers

gen mu_hat_nh_h_X_weight_nh = mu_hat_nh_h_X * weight_nh
total mu_hat_nh_h_X_weight_nh
scalar mu_hat_nh_h = e(b)[1,1]

gen mu_hat_nh_n_X_weight_nh = mu_hat_nh_n_X * weight_nh
total mu_hat_nh_n_X_weight_nh
scalar mu_hat_nh_n = e(b)[1,1]

*-------------c-to-h compliers-------------------------------

gen E_vc_ch_complier = (-1) * Lambda0_c_ch
gen E_vh_ch_complier = Lambda0_hminusc_ch * (2*(1-rho))^(0.5) + E_vc_ch_complier

gen mu_hat_ch_h_X = theta_h0_hat + X_theta_hx_hat + gamma_hh_hat * E_vh_ch_complier + gamma_hc_hat * E_vc_ch_complier
gen mu_hat_ch_c_X = theta_c0_hat + X_theta_cx_hat + gamma_ch_hat * E_vh_ch_complier + gamma_cc_hat * E_vc_ch_complier

* To obtain unconditional estimates, we integrate over the distribution of Xi for ch-compliers

gen mu_hat_ch_h_X_weight_ch = mu_hat_ch_h_X * weight_ch
total mu_hat_ch_h_X_weight_ch
scalar mu_hat_ch_h = e(b)[1,1]

gen mu_hat_ch_c_X_weight_ch = mu_hat_ch_c_X * weight_ch
total mu_hat_ch_c_X_weight_ch
scalar mu_hat_ch_c = e(b)[1,1]

*--------------------------------------------
scalar subLATE_nh = mu_hat_nh_h - mu_hat_nh_n
scalar subLATE_ch = mu_hat_ch_h - mu_hat_ch_c
*--------------------------------------------

quietly{
noi di as text "Estimated Pr[n always-taker]   =" p_nn
noi di as text "Estimated Pr[h always-taker]   =" p_hh
noi di as text "Estimated Pr[c always-taker]   =" p_cc
noi di as text "Estimated Pr[n-to-h complier]  =" p_nh
noi di as text "Estimated Pr[c-to-h complier]  =" p_ch
}


scalar rel_percent_nh = p_nh/(p_nh+p_ch)
scalar rel_percent_ch = p_ch/(p_nh+p_ch)
scalar LATE_allcompliers = rel_percent_nh * subLATE_nh + rel_percent_ch * subLATE_ch


quietly{
	
noi di as text "Estimated E[Y(h)-Y(n)|n-to-h complier]               =" subLATE_nh
noi di as text "Estimated E[Y(h)-Y(c)|c-to-h complier]               =" subLATE_ch
noi di as text "Estimated n-to-h compliers as % of all compliers =" rel_percent_nh
noi di as text "Estimated c-to-h compliers as % of all compliers =" rel_percent_ch
noi di as text "Estimated E[Y(h)-Y(not h)|complier]                  =" LATE_allcompliers
noi di as text "Covariates Used                                      =" "`covariates'"
}

