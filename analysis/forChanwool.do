clear all

cd $data_working



* Get sub-types from ABC
use "abc-topi"

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



use "ehs_mixed_center-topi", clear
su

cd $git_out

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


scalar rel_percent_nh = p_nh/(p_nh+p_ch)
scalar rel_percent_ch = p_ch/(p_nh+p_ch)

quietly{
	
noi di as text "Estimated E[Y(h)-Y(n)|n-to-h complier]               =" 
noi di as text "Estimated E[Y(h)-Y(c)|c-to-h complier]               =" 
noi di as text "Estimated n-to-h compliers as % of all compliers =" rel_percent_nh
noi di as text "Estimated c-to-h compliers as % of all compliers =" rel_percent_ch
noi di as text "Covariates Used                                      =" "`covariates'"
}

