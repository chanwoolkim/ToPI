clear all

cd $data_working

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
 keep hhid Y Z_h Z_c Z_n treat_choice `covariates' bw program_type medulessHS m_edu_HS cc_price_relative

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

* Hull Implementation

egen m_iq_med = median(m_iq)
gen m_iq_h = m_iq > m_iq_med

egen m_age_med = median(m_age)
gen m_age_h = m_age > m_age_med

egen cc_price_med = median(cc_price_relative)
gen cc_price_h = cc_price_relative > cc_price_med

egen E_X_W = mean(cc_price_h), by(m_iq_h m_age_h)
egen E_Z_WX = mean(Z_h), by(m_iq_h m_age_h cc_price_h)
egen E_A_WXZ = mean(Other), by(m_iq_h m_age_h cc_price_h Z_h)
egen E_B_WXZ = mean(None), by(m_iq_h m_age_h cc_price_h Z_h)

gen lambda = (E_Z_WX-Z_h)/(E_Z_WX*(1-E_Z_WX))

gen P_Z_WX = E_Z_WX
replace P_Z_WX = 1-E_Z_WX if Z_h == 0

gen P_X_W = E_X_W
replace P_X_W = 1-E_X_W if cc_price_h == 0

egen E_lambdaA_W = sum(lambda*E_A_WXZ*P_Z_WX*P_X_W), by(m_iq_h m_age_h)
egen E_lambdaB_W = sum(lambda*E_B_WXZ*P_Z_WX*P_X_W), by(m_iq_h m_age_h)

egen E_lambdaAX_W = sum(lambda*E_A_WXZ*P_Z_WX*P_X_W) if cc_price_h == 1, by(m_iq_h m_age_h)
bysort m_iq_h m_age_h (E_lambdaAX_W) : replace E_lambdaAX_W = E_lambdaAX_W[_n-1] if missing(E_lambdaAX_W)
egen E_lambdaBX_W = sum(lambda*E_B_WXZ*P_Z_WX*P_X_W) if cc_price_h == 1, by(m_iq_h m_age_h)
bysort m_iq_h m_age_h (E_lambdaBX_W) : replace E_lambdaBX_W = E_lambdaBX_W[_n-1] if missing(E_lambdaBX_W)

sort hhid

gen mu_a = (E_lambdaAX_W-E_lambdaA_W*cc_price_h)/(E_X_W*(1-E_X_W))
gen mu_b = (E_lambdaBX_W-E_lambdaB_W*cc_price_h)/(E_X_W*(1-E_X_W))

egen E_lambdamu_bA_W = sum(lambda*mu_b*E_A_WXZ*P_Z_WX*P_X_W), by(m_iq_h m_age_h)
egen E_lambdamu_aB_W = sum(lambda*mu_a*E_B_WXZ*P_Z_WX*P_X_W), by(m_iq_h m_age_h)

egen E_lambdaA = mean(E_lambdaA_W)
egen E_lambdaB = mean(E_lambdaB_W)

gen Y_A = (E_lambdaA_W/E_lambdaA)*(lambda*mu_b/E_lambdamu_bA_W)
gen Y_B = (E_lambdaB_W/E_lambdaB)*(lambda*mu_a/E_lambdamu_aB_W)

su Y_A
scalar E_Y_A = r(mean)
su Y_B
scalar E_Y_B = r(mean)

quietly{
noi di as text "Estimated E[Y_1-Y_a|A_1<A_0] =" E_Y_A
noi di as text "Estimated E[Y_1-Y_b|B_1<B_0] =" E_Y_B
}


