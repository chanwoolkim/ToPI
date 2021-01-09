*********************************
* Imputations and Factors 		*
* AH, Dec 30 2020 				*
*********************************

*******
* EHS *
*******
*Obtains theta14, theta24, theta36, theta14_R, theta24_R, theta36_R
*Obtains average14, average24, average36, average14_R, average24_R, average36_R


global i_home_36_develop 	`"home36_48 home36_49"'
global i_home_36_hostility 	`"home36_4 home36_35 home36_36 home36_37"'
global i_home_36_learning	`"home36_7 home36_8 home36_9 home36_10 home36_11 home36_12 home36_13 home36_14 home36_15 home36_34 home36_44 home36_50 home36_51 home36_5253 home36_54"'
global i_home_36_variety	`"home36_2 home36_3 home36_43 home36_45 home36_46 home36_58 home36_59 home36_60"'
global i_home_36_warmth		`"home36_16 home36_17 home36_18 home36_40 home36_61"'
global ehs_i_home_36 `"$i_home_36_develop $i_home_36_hostility $i_home_36_learning $i_home_36_variety $i_home_36_warmth"'

global ehs_i_home_24	home24_7 home24_15 home24_16 home24_18 home24_19 home24_20 home24_21 home24_22 ///
					home24_23 home24_24 home24_43 home24_60 ///
					home24_55 home24_56 home24_57 home24_58 home24_59 ///
					home24_11 home24_46 home24_47 home24_48 home24_61 ///
					home24_64 home24_65 ///
					home24_45 home24_52 home24_53 home24_54

global ehs_i_home_14 	home14_7 home14_15 home14_16 home14_18 home14_19 home14_20 home14_21 ///
					home14_22 home14_23 home14_24 home14_43 home14_60 home14_727374 ///
					home14_55 home14_56 home14_57 home14_58 home14_59 ///
					home14_11 home14_46 home14_47 home14_48 home14_61 ///
					home14_64 home14_65 ///
					home14_45 home14_52 home14_53 home14_54

foreach t of global ehs_type {
	cd "$data_working"
	use "ehs`t'-merge.dta", clear
	
	//what is this list? 
	foreach i of numlist 7 15/16 18/24 43 60 55/59 11 46/48 61 64/65 45 52/54 {
	
			reg home24_`i' home14_`i'
			local df_r = e(df_r)
			predict home24_`i'_p, xb
			gen home24_`i'_r = home24_`i' - home24_`i'_p
			qui sum home24_`i'_r
			local var_r = r(Var)
			sum home24_`i'_p
			replace home24_`i'_p = r(mean) if missing(home24_`i'_p)
			replace home24_`i'_p = home24_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
			replace home24_`i' = home24_`i'_p if missing(home24_`i')

			reg home14_`i' home24_`i'
			local df_r = e(df_r)
			predict home14_`i'_p, xb
			gen home14_`i'_r = home14_`i' - home14_`i'_p
			qui sum home14_`i'_r
			local var_r = r(Var)
			sum home14_`i'_p
			replace home14_`i'_p = r(mean) if missing(home14_`i'_p)
			replace home14_`i'_p = home14_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
			replace home14_`i' = home14_`i'_p if missing(home14_`i')
		
	}

		reg home14_727374 home_develop14
		local df_r = e(df_r)
		predict home14_727374_p, xb
		gen home14_727374_r = home14_727374 - home14_727374_p
		qui sum home14_727374_r
		local var_r = r(Var)
		sum home14_727374_p
		replace home14_727374_p = r(mean) if missing(home14_727374_p)
		replace home14_727374_p = home14_727374_p + rnormal()*sqrt(`var_r'/`df_r')
		replace home14_727374 = home14_727374_p if missing(home14_727374)
	
//where did this list come from?
	local develop_n		48 49
	local hostility_n	4 35 36 37
	local learning_n	7 8 9 10 11 12 13 14 15 34 44 50 51 5253 54
	local variety_n		2 3 43 45 46 58 59 60
	local warmth_n		16 17 18 40 61

	foreach v in develop hostility learning variety warmth {
		foreach i of numlist ``v'_n' {
			
				reg home36_`i' home_`v'36
				local df_r = e(df_r)
				predict home36_`i'_p, xb
				gen home36_`i'_r = home36_`i' - home36_`i'_p
				qui sum home36_`i'_r
				local var_r = r(Var)
				sum home36_`i'_p
				replace home36_`i'_p = r(mean) if missing(home36_`i'_p)
				replace home36_`i'_p = home36_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
				replace home36_`i' = home36_`i'_p if missing(home36_`i')
			
		}
	}

foreach m in 14 24 36{
qui factor ${ehs_i_home_`m'}
predict theta`m', bartlett
gen theta`m'_R = theta`m'*R
egen average`m'_aux=rowmean (${ehs_i_home_`m'} )
egen average`m'=std(average`m'_aux)
gen average`m'_R = average`m'*R
}

keep theta14 theta24 theta36 theta14_R theta24_R theta36_R ///
average14 average24 average36 average14_R average24_R average36_R R ///
$covariates ppvt36

save "ehs`t'-merge-imputations.dta", replace
}

* IHDP *

cd "$data_working"
use "ihdp-merge.dta", clear
global ihdp_i_home_36 home36_1 home36_2 home36_3 home36_4 home36_5 home36_6 home36_7 home36_12 home36_43 ///
	home36_41 home36_42 home36_52 home36_53 home36_54 home36_55 ///
	home36_11 home36_13 home36_14 home36_16 home36_27 home36_28 home36_29 home36_33 home36_34 home36_35 home36_36 home36_37 home36_38 home36_39 home36_40 home36_47 home36_49 ///
	home36_18 home36_44 home36_45 home36_46 home36_50 home36_51 ///
	home36_17 home36_26 home36_30 home36_31 home36_32
	
global ihdp_i_home_12	home12_18 home12_19 home12_24 home12_25 home12_26 home12_27 home12_28 home12_30 home12_31 home12_32 home12_33 home12_34 home12_45 ///
	home12_12 home12_13 home12_14 home12_15 home12_16 home12_17 ///
	home12_1 home12_2 home12_3 home12_7 home12_29 home12_35 home12_36 home12_37 home12_38 home12_39 home12_42 ///
	home12_21 home12_22 home12_23 home12_41 home12_43 home12_44 ///
	home12_8 home12_9 home12_10 home12_11

foreach m in 12 36{
qui factor ${ihdp_i_home_`m'}
predict theta`m', bartlett
gen theta`m'_R = theta`m'*R
egen average`m'_aux=rowmean (${ihdp_i_home_`m'} )
egen average`m'=std(average`m'_aux)
gen average`m'_R = average`m'*R
}

keep theta12 theta36 theta12_R theta36_R ///
average12 average36 average12_R average36_R R ///
$covariates ppvt36 sb36
save "ihdp-merge-imputations.dta", replace


cd "$data_working"
use "abc-merge.dta", clear

global abc_i_home_42 	home42_1 home42_2 home42_3 home42_4 home42_5 home42_6 home42_7 home42_8 home42_9 home42_10 home42_11 home42_12 home42_58 home42_71 home42_72 home42_73 ///
		home42_46 home42_47 home42_48 home42_49 home42_50 home42_51 home42_52 home42_79 home42_80 ///
	home42_22 home42_23 home42_24 home42_25 home42_26 home42_27 home42_28 home42_29 home42_30 home42_31 home42_32 home42_33 home42_45 home42_53 home42_54 home42_55 home42_57 home42_59 home42_60 home42_61 home42_62 home42_63 home42_64 home42_74 ///
	home42_16 home42_18 home42_19 home42_20 home42_21 home42_69 home42_70 home42_75 home42_76 home42_77 home42_78 ///
	home42_56 home42_65 home42_66 home42_67 home42_68

global abc_i_home_30 	home30_18 home30_19 home30_24 home30_25 home30_26 home30_27 home30_28 home30_30 home30_31 home30_32 home30_33 home30_34 home30_45 ///
		home30_12 home30_13 home30_14 home30_15 home30_16 home30_17 ///
	home30_1 home30_2 home30_3 home30_7 home30_29 home30_35 home30_36 home30_37 home30_38 home30_39 home30_42 ///
	home30_21 home30_22 home30_23 home30_41 home30_43 home30_44 ///
	home30_8 home30_9 home30_10 home30_11	

global abc_i_home_18 home18_18 home18_19 home18_24 home18_25 home18_26 home18_27 home18_28 home18_30 home18_31 home18_32 home18_33 home18_34 home18_45 ///
	home18_12 home18_13 home18_14 home18_15 home18_16 home18_17 ///
	home18_1 home18_2 home18_3 home18_7 home18_29 home18_35 home18_36 home18_37 home18_38 home18_39 home18_42 ///
	home18_21 home18_22 home18_23 home18_41 home18_43 home18_44 ///
	home18_8 home18_9 home18_10 home18_11

global abc_i_home_6 home6_18 home6_19 home6_24 home6_25 home6_26 home6_27 home6_28 home6_30 home6_31 home6_32 home6_33 home6_34 home6_45 ///
	home6_12 home6_13 home6_14 home6_15 home6_16 home6_17 ///
	home6_1 home6_2 home6_3 home6_7 home6_29 home6_35 home6_36 home6_37 home6_38 home6_39 home6_42 ///
	home6_21 home6_22 home6_23 home6_41 home6_43 home6_44 ///
	home6_8 home6_9 home6_10 home6_11	
	
foreach i of numlist 18/19 24/28 30/34 45 12/17 1/3 7 29 35/39 42 21/23 41 43/44 8/11 {
	quietly {
		reg home30_`i' home18_`i' home6_`i'
		local df_r = e(df_r)
		predict home30_`i'_p, xb
		gen home30_`i'_r = home30_`i' - home30_`i'_p
		qui sum home30_`i'_r
		local var_r = r(Var)
		sum home30_`i'_p
		replace home30_`i'_p = r(mean) if missing(home30_`i'_p)
		replace home30_`i'_p = home30_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
		replace home30_`i' = home30_`i'_p if missing(home30_`i')

		reg home18_`i' home30_`i' home6_`i'
		local df_r = e(df_r)
		predict home18_`i'_p, xb
		gen home18_`i'_r = home18_`i' - home18_`i'_p
		qui sum home18_`i'_r
		local var_r = r(Var)
		sum home18_`i'_p
		replace home18_`i'_p = r(mean) if missing(home18_`i'_p)
		replace home18_`i'_p = home18_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
		replace home18_`i' = home18_`i'_p if missing(home18_`i')

		reg home6_`i' home30_`i' home18_`i'
		local df_r = e(df_r)
		predict home6_`i'_p, xb
		gen home6_`i'_r = home6_`i' - home6_`i'_p
		qui sum home6_`i'_r
		local var_r = r(Var)
		sum home6_`i'_p
		replace home6_`i'_p = r(mean) if missing(home6_`i'_p)
		replace home6_`i'_p = home6_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
		replace home6_`i' = home6_`i'_p if missing(home6_`i')
	}
	drop *_p *_r
}


foreach m in 6 18 30 42{
qui factor ${abc_i_home_`m'}
qui predict theta`m', bartlett
gen theta`m'_R = theta`m'*R
egen average`m'_aux=rowmean (${abc_i_home_`m'} )
egen average`m'=std(average`m'_aux)
gen average`m'_R = average`m'*R
}

keep 	theta6 		theta18 	theta30 	theta42 ///
		theta6_R 	theta18_R 	theta30_R	theta42_R ///
		average6 	average18 	average30	average42 ///
		average6_R 	average18_R average30_R average42_R	///
		$covariates sb36 sb48 R
save "abc-merge-imputations.dta", replace

* CARE *
global care_type			""both" "home" """
foreach t of global care_type {
	di "`t'"
	cd "$data_working"
	use "abc-merge.dta", clear
	append using "care`t'-merge.dta"

	foreach i of numlist 18/19 24/28 30/34 45 12/17 1/3 7 29 35/39 42 21/23 41 43/44 8/11 {
		quietly {
			reg home30_`i' home18_`i' home6_`i'
			local df_r = e(df_r)
			predict home30_`i'_p, xb
			gen home30_`i'_r = home30_`i' - home30_`i'_p
			qui sum home30_`i'_r
			local var_r = r(Var)
			sum home30_`i'_p
			replace home30_`i'_p = r(mean) if missing(home30_`i'_p)
			replace home30_`i'_p = home30_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
			replace home30_`i' = home30_`i'_p if missing(home30_`i')

			reg home18_`i' home30_`i' home6_`i'
			local df_r = e(df_r)
			predict home18_`i'_p, xb
			gen home18_`i'_r = home18_`i' - home18_`i'_p
			qui sum home18_`i'_r
			local var_r = r(Var)
			sum home18_`i'_p
			replace home18_`i'_p = r(mean) if missing(home18_`i'_p)
			replace home18_`i'_p = home18_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
			replace home18_`i' = home18_`i'_p if missing(home18_`i')

			reg home6_`i' home30_`i' home18_`i'
			local df_r = e(df_r)
			predict home6_`i'_p, xb
			gen home6_`i'_r = home6_`i' - home6_`i'_p
			qui sum home6_`i'_r
			local var_r = r(Var)
			sum home6_`i'_p
			replace home6_`i'_p = r(mean) if missing(home6_`i'_p)
			replace home6_`i'_p = home6_`i'_p + rnormal()*sqrt(`var_r'/`df_r')
			replace home6_`i' = home6_`i'_p if missing(home6_`i')
		}
		drop *_p *_r
	}

foreach m in 6 18 30 42{
qui factor ${abc_i_home_`m'}
qui predict theta`m', bartlett
gen theta`m'_R = theta`m'*R
egen average`m'_aux=rowmean (${abc_i_home_`m'} )
egen average`m'=std(average`m'_aux)
gen average`m'_R = average`m'*R
}

keep 	theta6 		theta18 	theta30 	theta42 ///
		theta6_R 	theta18_R 	theta30_R	theta42_R ///
		average6 	average18 	average30	average42 ///
		average6_R 	average18_R average30_R average42_R	///
		$covariates sb36 sb48 R program

keep if program == "care"
save "care`t'-merge-imputations.dta", replace
}
