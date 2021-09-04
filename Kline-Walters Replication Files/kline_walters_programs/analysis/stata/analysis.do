
*Chris Walters
*This program is the master analysis file for the HS substitution project

**************************************************
***** SET UP STATA *******************************
**************************************************

	*********Basic setup****************
		clear all
		cap set more off
		cap set trace off
		set matsize 10000


		*Directories
		local root="/head_start"
		local datapath="`root'/data/stata_files"
		local matlabroot="`root'/kline_walters/programs/matlab/site_fe/v88"
		local bs_folder="`root'/kline_walters/bootstrap"
		
		*File date
		local analysisdate="10_2014"
	
	******Switches**********************

		*Main tables
			local define_programs=1
			local data_setup=1
			local desc_stats=0
			local sub_bias=0
			local exp_impacts=0
			local two_step=0
				local two_step_choice=0
				local two_step_stop=0
			local two_stage=0
			local sub_late=0
			local rationing=0
			local mte=0
			
		*Appendix material

			local choicefit=0
			local controlfunction_firststage=0
			local late_fit=0
			local subpop_means=0
			local mom_works=0
			local funding=0

	*****Options*********************

			*Select model
				local model="covs_sites"
				*local model="covs"
				*local model="sites"
				
			*Select restrictions
				local restrictions="covsrestrict"
				*local restrictions="selectrestrict"
				*local restrictions="crossrestrict"

			*Outcome
				local outcome="ppvt_wj3"
				
			*Minimum site size
				local thresh=10
				
			*Whether to interact covs with site type
				local interact_P=0
			
			*Covariates and instruments
				if "`model'"=="covs" {
					local X "X_male X_mom_teen X_mom_married X_sped X_testlang X_m_income X_income_2 X_income_3 X_b_2 X_b_3 X_bothparents X_only_sib X_one_sib X_urban"
					local W="X_transportation X_quality X_black X_spanish X_mom_ed X_income_4 X_b_1 X_age4"
					local matlabpath="`matlabroot'/covs"
				}
				if "`model'"=="sites" {
					local X ""
					local W=""
					local matlabpath="`matlabroot'/sites"
					local P="`W'"
				}
				if "`model'"=="covs_sites" {
					local X "X_male X_mom_teen X_mom_married X_sped X_testlang X_m_income X_income_2 X_income_3 X_b_2 X_b_3 X_bothparents X_only_sib X_one_sib X_urban"
					local W="X_transportation X_quality X_black X_spanish X_mom_ed X_income_4 X_b_1 X_age4"
					local matlabpath="`matlabroot'/covs_and_sites"
				}
				local Z_inter=""
				foreach x in `W' {
					local Z_inter="`Z_inter' Z_`x'"
				}
				local Z="Z `Z_inter'"
			
**************************************************
***** DEFINE PROGRAMS ****************************
**************************************************

if `define_programs'==1 {


************ Function for Computing Truncated Bivariate Normal Conditional Expectation *************************** 
			
			
			cap prog drop Gamma
			prog define Gamma
			
				gen double denom=binormal(x2,y2,tau) - binormal(x1,y2,tau) - binormal(x2,y1,tau) + binormal(x1,y1,tau)
				replace denom = binormal(x2,y2,tau) - binormal(x1,y2,tau) if x1!=. & y1==.
				replace denom = binormal(x2,y2,tau) - binormal(x2,y1,tau) if x1==. & y1!=.
				replace denom = binormal(x2,y2,tau) if x1==. & y1==.
				
				
				gen double arg1=(y2-tau*x2)/sqrt(1-(tau^2))
				gen double arg2=(y1-tau*x2)/sqrt(1-(tau^2))
				gen double arg3=(x2-tau*y2)/sqrt(1-(tau^2))
				gen double arg4=(x1-tau*y2)/sqrt(1-(tau^2))
				gen double arg5=(y2-tau*x1)/sqrt(1-(tau^2))
				gen double arg6=(x1-tau*x1)/sqrt(1-(tau^2))
				gen double arg7=(x2-tau*y1)/sqrt(1-(tau^2))
				gen double arg8=(x1-tau*y1)/sqrt(1-(tau^2))
				
				gen double term1=normalden(x2)*(normal(arg1) - normal(arg2))
				replace term1=normalden(x2)*normal(arg1) if y1==.
				gen double term2=normalden(y2)*(normal(arg3) - normal(arg4))
				replace term2=normalden(y2)*normal(arg3) if x1==.
				gen double term3=normalden(x1)*(normal(arg5) - normal(arg6))
				replace term3=0 if x1==.
				gen double term4=normalden(y1)*(normal(arg7) - normal(arg8))
				replace term4=normalden(y1)*normal(arg7) if x1==.
				replace term4=0 if y1==.
				
				gen double num = -term1 - tau*term2 + term3 + tau*term4
				
				gen double gamma = num/denom

				drop arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 term1 term2 term3 term4 num denom
			
			end

}

**************************************************
***** DATA SETUP **********************************
**************************************************

if `data_setup'==1 {

*Load master analysis file
	use "`datapath'/analysis_file.dta", clear

	
	*Define choice and drop if choice not observed
	gen D=.
	replace D=2 if arrangement=="H"
	replace D=1 if arrangement=="P"
	replace D=0 if arrangement=="N"
	drop if D==.
	
	*Define choices in Spring '04
	gen D_parent_04=2 if arrangement_parent_04=="H"
	replace D_parent_04=1 if arrangement_parent_04=="P"
	replace D_parent_04=0 if arrangement_parent_04=="N"
	
	*Define years of preschool in each period
	gen years_HS_03=(D==2) if D!=.
	gen years_any_03=(D>0) if D!=.
	gen years_HS_04=(D==2) + (D_parent_04==2) if D!=. & D_parent_04!=.
	gen years_any_04 = (D>0) + (D_parent_04>0) if D!=. & D_parent_04!=.
	replace years_HS_04 = years_HS_03 if childcohort==4
	replace years_any_04 = years_any_03 if childcohort==4
	gen years_HS_05 = years_HS_04
	gen years_HS_06 = years_HS_04
	gen years_any_05 = years_any_04
	gen years_any_06 = years_any_04
	
	*Choice dummies
	gen D_h=D==2
	gen D_c=D==1
	gen D_n=D==0
	gen D_h_03=D_h
	gen D_c_03=D_c
	gen D_n_03=D_n
	gen D_h_04=D_parent_04==2 if D_parent_04!=.
	gen D_c_04=D_parent_04==1 if D_parent_04!=.
	gen D_n_04=D_parent_04==0 if D_parent_04!=.
	
	
	*A constant
	gen cons=1
	
	*Weight
	bys hsis_racntrid: egen Zbar=mean(Z)
	gen w=1/Zbar
	replace w=1/(1-Zbar) if Z==0
	drop if w==.
			
	*Define outcome

	if "`outcome'"=="ppvt_wj3" {
		gen Y=.
		gen Y_s_wj3preacademic_w =.
		gen Y_ppvt_irt=.
		gen b_s_wj3preacademic_w=.
		gen b_ppvt_irt=.
		foreach n of numlist 3/4 {
		
			foreach t in s_wj3preacademic_w ppvt_irt {
				sum `t'_03 if Z==0 & childcohort==`n' [aw=w]
				replace Y_`t' = (`t'_03 - r(mean))/r(sd) if childcohort==`n'
				sum `t'_02 if Z==0 & childcohort==`n' [aw=w]
				replace b_`t' = (`t'_02 - r(mean))/r(sd) if childcohort==`n'
			}
			replace Y = (Y_s_wj3preacademic_w + Y_ppvt_irt)/2 if childcohort==`n'
			replace X_baseline_cog = (b_s_wj3preacademic_w + b_ppvt_irt)/2 if childcohort==`n'
			
			
		}
		
		foreach y of numlist 3/6 {
		
			foreach n of numlist 3/4 {
			
				foreach t in s_wj3preacademic_w ppvt_irt {
					sum `t'_0`y' if Z==0 & childcohort==`n' [aw=w]
					local `t'_mean=r(mean)
					local `t'_sd=r(sd)
				}
				replace Y_0`y' = 0.5*(((s_wj3preacademic_w_0`y' - `s_wj3preacademic_w_mean')/`s_wj3preacademic_w_sd') + ((ppvt_irt_0`y' - `ppvt_irt_mean')/`ppvt_irt_sd')) if childcohort==`n'

		
			}
		}
		
		
		
	}
	
	
	*Keep estimation sample
	keep if Y!=. & X_baseline_cog!=.

	*Code covariates
	gen X_age4=childcohort==4
	gen X_mom_ed=0
	replace X_mom_ed=1 if X_mom_dropout==0 & X_mom_college==0
	replace X_mom_ed=2 if X_mom_college==1
	gen X_testlang=d_fallspr
	ren c_competition_high X_comp_high
	ren c_competition2 X_comp
	ren c_quality X_quality
	ren c_transportation X_transportation
	ren c_visits_3 X_visits_3
	ren c_serv_fullday X_serv_fullday
	
	*Number of siblings
	gen X_only_sib=kids_hh==1
	gen X_one_sib=kids_hh==2
	gen X_three_sib=kids_hh>3 if kids_hh!=.
	gen X_m_sib=kids_hh==.
	gen X_transportation_black=X_transportation*X_black

	*Baseline score
	foreach n of numlist 1/3 {
		gen X_b_`n'=X_baseline_cog^`n'
		gen X_nc_`n'=X_baseline_noncog^`n'
		
	}
	sum X_b_1, detail
	gen X_above_median = X_b_1>r(p50)
	
	*Scale income as fraction of FPL
	gen size_hh=adults_hh + kids_hh
	gen FPL=8860
	replace FPL=11940 if size_hh==2
	replace FPL=15020 if size_hh==3
	replace FPL=18100 if size_hh==4
	replace FPL=21180 if size_hh==5
	replace FPL=24260 if size_hh==6
	replace FPL=27340 if size_hh==7
	replace FPL=30420 if size_hh==8
	replace FPL=FPL+(3080)*(size_hh-8) if size_hh>8
	replace X_income=X_income*12
	gen above_FPL=X_income>FPL if X_m_income!=1
	gen X_income_annual=X_income
	replace X_income=X_income/FPL if X_m_income!=1
	replace X_m_income=1 if X_income==.
	replace X_income=0 if X_income==.
	gen X_income_1 = ((X_income<=0.5) & (X_m_income!=1))
	gen X_income_2 = ((X_income>0.5) & (X_income<=0.75) & (X_m_income!=1))
	gen X_income_3 = ((X_income>0.75) & (X_income<=1) & (X_m_income!=1))
	gen X_income_4 = ((X_income>1) & (X_m_income!=1))

	*Baseline score quartiles
	sum X_b_1 [aw=w], detail
	gen X_b_q1 = (X_b_1<=r(p25))
	gen X_b_q2 = (X_b_1>r(p25)) & (X_b_1<=r(p50))
	gen X_b_q3 = (X_b_1>r(p50)) & (X_b_1<=r(p75))
	gen X_b_q4 = (X_b_1>r(p75))
	gen X_b_q34 = X_b_q3 + X_b_q4
	gen X_white = 1 - X_black - X_hisp
	
	*Drop missings
	foreach x of varlist `X' `W' {
		drop if `x'==.
	}

	*Interacting variables
	foreach x of varlist `X' `W' {
		sum `x' [aw=w]
		gen `x'_old=`x'
		replace `x' = `x' - r(mean)
		gen Z_`x'=Z*`x'
	}
	
	*Counts of treated and control by center
	bys hsis_racntrid: gen N=_N
	bys hsis_racntrid: egen N_Z=sum(Z)
	gen N_oneminusZ = N - N_Z
	
	*Re-label Y's for grade level and not calendar time
	foreach t in Y years_HS years_any {
		gen `t'_PK1 = `t'_03 if childcohort==3
		gen `t'_PK2 = `t'_04 if childcohort==3
		replace `t'_PK2 = `t'_03 if childcohort==4
		gen `t'_K=`t'_05 if childcohort==3
		replace `t'_K = `t'_04 if childcohort==4
		gen `t'_1=`t'_06 if childcohort==3
		replace `t'_1 = `t'_05 if childcohort==4
	}

	*Rescale weights so that likelihood units are correct
	egen wsum=sum(w)
	replace w = (w/wsum)*_N

	*********Define aggregated sites***************
			egen site=group(hsis_racntrid)
			egen supersite=group(hsis_raprogid)
			bys site: gen N_site=_N
			
				*Group small sites together within program area
				local complete=0
				while `complete'<1 {
				
					*Step 1: Try to combine single smallest site size at each site
					bys site: egen sd_Z=sd(Z)
					gen tag=(N_site<`thresh') 
					bys supersite: egen N_min=min(N_site)
					replace tag=0 if N_site!=N_min
					replace site=0 if tag==1
					egen newsite=group(site supersite tag)
					bys newsite: gen N_new=_N
					gen changed=N_site!=N_new
					bys supersite: egen anychange=max(changed)
					drop site N_site
					ren newsite site
					ren N_new N_site
					drop tag N_min changed sd_Z
					
					*Step 2: If step 1 generated no changes at a site, combine smallest site size with second smallest
					bys site: egen sd_Z=sd(Z)
					gen tag=((N_site<`thresh')) & (anychange==0)
					bys supersite: egen anytag=max(tag)
					bys supersite: egen N_min=min(N_site)
					gen N_site2=N_site if N_site!=N_min
					bys supersite: egen N_min2=min(N_site2)
					replace tag=1 if anytag==1 & (N_min2==N_site2)
					replace site=0 if tag==1
					egen newsite=group(site supersite tag)
					bys newsite: gen N_new=_N
					gen changed=N_site!=N_new
					bys supersite: egen anychange2=max(changed)
					drop site N_site
					ren newsite site
					ren N_new N_site
					drop tag N_min changed N_site2 N_min2 anytag sd_Z
					
					
					*Check if any successful groupings in this iteration
					egen anychange_final1=max(anychange)
					sum anychange_final1
					local change1=r(mean)
					egen anychange_final2=max(anychange2)
					sum anychange_final2
					local change2=r(mean)
					if (`change1'==0) & (`change2'==0) {
						local complete=1
					}
					drop anychange_final1 anychange_final2 anychange anychange2
				}
				
				*Group small program areas together
				local complete=0
				while `complete'<1 {
				
					*Step 1: Try to combine single smallest site size
					bys site: egen sd_Z=sd(Z)
					gen tag=(N_site<`thresh')
					egen N_min=min(N_site)
					replace tag=0 if N_site!=N_min
					replace site=0 if tag==1
					egen newsite=group(site tag)
					bys newsite: gen N_new=_N
					gen changed=N_site!=N_new
					egen anychange=max(changed)
					drop site N_site
					ren newsite site
					ren N_new N_site
					drop tag N_min changed sd_Z
					
					*Step 2: If step 1 generated no changes, combine smallest site size with second smallest
					bys site: egen sd_Z=sd(Z)
					gen tag=((N_site<`thresh')) & (anychange==0)
					egen anytag=max(tag)
					egen N_min=min(N_site)
					gen N_site2=N_site if N_site!=N_min
					egen N_min2=min(N_site2)
					replace tag=1 if anytag==1 & (N_min2==N_site2)
					replace site=0 if tag==1
					egen newsite=group(site tag)
					bys newsite: gen N_new=_N
					gen changed=N_site!=N_new
					egen anychange2=max(changed)
					drop site N_site
					ren newsite site
					ren N_new N_site
					drop tag N_min changed N_site2 N_min2 anytag sd_Z
					
					
					*Check if any successful groupings in this iteration
					egen anychange_final1=max(anychange)
					sum anychange_final1
					local change1=r(mean)
					egen anychange_final2=max(anychange2)
					sum anychange_final2
					local change2=r(mean)
					if (`change1'==0) & (`change2'==0) {
						local complete=1
					}
					drop anychange_final1 anychange_final2 anychange anychange2
				}

	*Save
	save "`datapath'/kline_walters.dta", replace
	


}



**************************************************
***** DESCRIPTIVE STATS **************************
**************************************************

if `desc_stats'==1 {

	*Load data
	use "`datapath'/kline_walters.dta", clear
	replace X_spanish_old = 1 - X_spanish_old
	
	*Results storage
	matrix T=J(50,10,.)
	local r=1
	local c=1
	
	local list ""
	foreach x in male black hisp mom_teen mom_married bothparents mom_dropout mom_college ///
	spanish sped only_sib income age4 b_1 urban transportation quality ///
			 {
	
			cap gen X_m_`x'_old=0
			cap gen X_`x'_old = X_`x'
			qui sum X_`x'_old if Z==1 & X_m_`x'_old!=1 [aw=w]
			matrix T[`r',`c']=r(mean)
			local ++c
			qui sum X_`x'_old if Z==0 & X_m_`x'_old!=1 [aw=w]
			matrix T[`r',`c']=r(mean)f
			local ++c
			
			qui reg X_`x'_old Z if X_m_`x'_old!=1 [aw=w], r cluster(hsis_racntrid)
			matrix T[`r',`c']=_b[Z]
			matrix T[`r'+1,`c']=_se[Z]
			local c=`c'+2
			
			foreach d in 2 1 0 {
			
				qui sum X_`x'_old if D==`d' & X_m_`x'_old!=1 [aw=w]
				matrix T[`r',`c']=r(mean)
				local ++c
			
			}
			local c=1
			local r=`r'+2
			local list "`list' X_`x'_old"
	
	}
	
	
	count
	matrix list T
	matrix T[`r',`c']=r(N)
	disp `r'
	disp `c'
	local c=`c'+2
	
	foreach d in 2 1 0 {
	
		count if D==`d'
		matrix T[`r',`c']=r(N)
		local ++c
	
	}
	
	foreach x in  `X' `W' {
		reg `x' Z [aw=finalwt]
		estimates store `x'
	}
	suest `X' `W', r cluster(hsis_racntrid)
	test Z
stop
	
	clear
	svmat T
	browse
	stop

}


**************************************************
***** SUBSTITUTION PATTERNS **************************
**************************************************

if `sub_bias'==1 {

	*Load data
	use "`datapath'/kline_walters.dta", clear

	
	*Results storage
	matrix T=J(50,10,.)
	local r=1
	local c=1
	
	
	**ITTs
	gen cohort3=childcohort==3
	gen cohort4=childcohort==4
	cap gen all=1
	matrix RF=J(15,10,.)
	local row=1
	local col=1
	
	foreach t in PK1 PK2 K 1 {
	
		foreach c in cohort3 cohort4 all {
	
			preserve
			keep if `c'==1 & Y_`t'!=. & years_HS_`t'!=.
			count
			if r(N)>0 {
			
				reg Y_`t' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix RF[`row',`col']=_b[Z]
				matrix RF[`row'+1,`col']=_se[Z]
				matrix RF[`row'+2,`col']=e(N)
				
				cap gen D_`t' = years_HS_`t'>0 
				ivreg2 Y_`t' (D_`t' = Z) `X' `W' [aw=w], r cluster(hsis_racntrid) first
				matrix RF[`row', `col'+4]=_b[D_`t']
				matrix RF[`row'+1,`col'+4]=_se[D_`t']
				matrix RF[`row'+2,`col'+4]=e(N)
			
			
			}
			
			restore
			
			local ++col
	
		}
		
		local col=1
		local row=`row'+4
	
	}
	
	preserve
	clear
	svmat RF
	browse
	restore
	
	cap gen cohort3=childcohort==3
	cap gen cohort4=childcohort==4
	cap gen all=1
	replace D_h_04=1 if D_h_03==1
	gen D_h_05=D_h_04
	gen D_h_06=D_h_04
	ivreg2 Y_03 (D_h=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
	gen Dtemp=-D_h
	ivreg2 D_c (Dtemp=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
	
	*preserve
	gen i=_n
	expand 2
	bys i: gen s=_n==1
	cap drop Y
	gen Y=.
	replace Y=Y_03 if s==1
	replace Y=-D_c if s==0
	gen T1=D_h*s
	gen T2=D_h*(1-s)
	gen Z1=Z*s
	gen Z2=Z*(1-s)
	foreach x in `X' `W' {
		gen T_`x'=s*`x'
	}
	ivreg2 Y (T1 T2 = Z1 Z2) `X' `W' s T_* [aw=w], r cluster(hsis_racntrid i)
	
	nlcom 8000/_b[T1]
	nlcom (8000 - 0.5*8000*_b[T2])/_b[T1]
	nlcom (8000 - 0.75*8000*_b[T2])/_b[T1]
	
	nlcom (34339*_b[T1])/(10000*(1 - 0*_b[T2]))
	matrix b=r(b)
	matrix V=r(V)
	local b1=b[1,1]
	local T1= (b[1,1] - 1)/sqrt(V[1,1])
	nlcom (34339*_b[T1])/(10000*(1 - 0.5*_b[T2]))
	matrix b=r(b)
	local b2=b[1,1]
	local T2= (b[1,1] - 1)/sqrt(V[1,1])
	nlcom (34339*_b[T1])/(10000*(1 - 0.75*_b[T2]))
	matrix b=r(b)
	local b3=b[1,1]
	local T3= (b[1,1] - 1)/sqrt(V[1,1])
	 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0*_b[T2])-0.35*34339*_b[T1])
	matrix b=r(b)
	local b4=b[1,1]
	 local T4= (b[1,1] - 1)/sqrt(V[1,1])
	 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0.5*_b[T2])-0.35*34339*_b[T1])
	matrix b=r(b)
	local b5=b[1,1]
	 local T5= (b[1,1] - 1)/sqrt(V[1,1])
	 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0.75*_b[T2])-0.35*34339*_b[T1])
	matrix b=r(b)
	local b6=b[1,1]
	 local T6= (b[1,1] - 1)/sqrt(V[1,1])
	 
	 
	 
	 
	 ******BOOTSTRAP
	 local B=1000
	 local b=1
	 matrix T=J(`B',6,.)
	 while `b' <=`B' {
	 
		quietly {
		
			preserve
			bsample, cluster(hsis_racntrid)
			ivreg2 Y (T1 T2 = Z1 Z2) `X' `W' s T_* [aw=w], r cluster(hsis_racntrid i)
			nlcom (34339*_b[T1])/(10000*(1 - 0*_b[T2]))
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',1]=(b[1,1] - `b1')/sqrt(V[1,1])
			matrix list T
			nlcom (34339*_b[T1])/(10000*(1 - 0.5*_b[T2]))
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',2]=(b[1,1] - `b2')/sqrt(V[1,1])
			nlcom (34339*_b[T1])/(10000*(1 - 0.75*_b[T2]))
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',3]=(b[1,1] - `b3')/sqrt(V[1,1])
			 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0*_b[T2])-0.35*34339*_b[T1])
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',4]=(b[1,1] - `b4')/sqrt(V[1,1])
			 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0.5*_b[T2])-0.35*34339*_b[T1])
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',5]=(b[1,1] - `b5')/sqrt(V[1,1])
			 nlcom ((1-0.35)*34339*_b[T1])/(8000*(1 - 0.75*_b[T2])-0.35*34339*_b[T1])
			matrix b=r(b)
			matrix V=r(V)
			matrix T[`b',6]=(b[1,1] - `b6')/sqrt(V[1,1])
			 restore
		
		}
	 
		local prog=`b'/`B'
		disp "PROGRESS=`prog'"
		local ++b
	 
	 }
	 
	 clear
	 svmat T
	 foreach n of numlist 1/6 {
		gen t`n'=T`n'>`T`n''
		sum t`n'
		local p`n' = r(mean)
	 }
	 foreach n of numlist 1/6 {
		disp "Version `n': b = `b`n'', t = `T`n'', BSp = `p`n''"
	 }
	 stop
	
	*restore
	
	foreach y in 03 04 05 06 {
	
		foreach c in cohort3 cohort4 all {
		
			preserve
			keep if Y_`y'!=. & D_h_`y'!=. & `c'==1
			count
			if r(N)>0 {
			
				ivreg2 Y_`y' Z `X' `W' [aw=w], r cluster(hsis_racntrid )
				matrix T[`row',`col']=_b[Z]
				matrix T[`row'+1,`col']=_se[Z]
				matrix T[`row'+2,`col']=e(N)
			
				ivreg2 Y_`y' (D_h_`y'=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix T[`row',`col'+4]=_b[D_h_`y']
				matrix T[`row'+1,`col'+4]=_se[D_h_`y']
				matrix T[`row'+2,`col'+4]=e(N)
			
			
			}
		
			local ++col
			restore
	
		}
		matrix list T
		local col=1
		local row=`row'+4
	
	}
	clear
	svmat T
	browse
stop
	
	

	
	
	
	****DISPLAY ESTIMATES BY YR
		matrix LR=J(20,20,.)
	local row=1
	local col=2
		
		
	foreach y in PK1 PK2 K 1 {
		foreach t in HS any {

			preserve
	
				disp "YEAR = `y', TREATMENT = `t'"
				keep if Y_`y'!=.
				keep if years_`t'_`y'!=.
				gen dummy_`t'_`y'=years_`t'_`y'>0
				ivreg2 Y_`y' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix LR[`row',1]=_b[Z]
				matrix LR[`row'+1,1]=_se[Z]
				matrix LR[`row'+2,1]=e(N)
				ivreg2 dummy_`t'_`y' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix LR[`row',`col']=_b[Z]
				matrix LR[`row'+1,`col']=_se[Z]
				ivreg2 Y_`y' (dummy_`t'_`y'=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix LR[`row',`col'+1]=_b[dummy_`t'_`y']
				matrix LR[`row'+1,`col'+1]=_se[dummy_`t'_`y']
				ivreg2 years_`t'_`y' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix LR[`row',`col'+3]=_b[Z]
				matrix LR[`row'+1,`col'+3]=_se[Z]
				ivreg2 Y_`y' (years_`t'_`y'=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
				matrix LR[`row',`col'+4]=_b[years_`t'_`y']
				matrix LR[`row'+1,`col'+4]=_se[years_`t'_`y']
				local col=`col'+6
				
				
		
			restore
		}
		local col=2
		local row=`row'+4
	}
	
	clear
	svmat LR
	browse
	

	matrix SB=J(20,7,.)
	local row=1
	local col=1
	
	*Preschool choices
	foreach t in 03 04 {
	
		foreach c in 3 4 {
		
			foreach d in h c n {
			
				foreach z in 1 0 {
				
					disp "PERIOD: `t', COHORT: `c', TREATMENT: `d', OFFER: `z'"
					sum D_`d'_`t' [aw=w] if childcohort==`c' & Z==`z'
					matrix SB[`row',`col']=r(mean)
					local col=`col'+4
					matrix list SB
					
				
				}
				
				local col=`col'-7
			
			}
			
			local col=1
			local row=`row'+2
						
		
		}
	
	
	}

	clear
	svmat SB
	browse
	
	
}


**************************************************
****** Experimental Impacts ************************
**************************************************

if `exp_impacts'==1 {

	use "`datapath'/kline_walters.dta", clear

	matrix T=J(100,20,.)
	local r=1
	local c=1
	
		gen cohort_3=childcohort==3
		gen cohort_4=childcohort==4
		gen cohort_all=1
		
		cap drop D_03 D_04 D_05 D_06
		gen D_03 = D==2
		gen D_04 =D_03
		replace D_04 = 1 if D_parent_04==2
		gen D_05=D_04
		gen D_06=D_04
		replace D_04=. if D_parent_04==.
		replace D_05=. if D_parent_04==.
		replace D_06=. if D_parent_04==.
		
		foreach t in 03 04 05 06 {
		
			foreach co in 3 4 all {
			
				preserve
				keep if cohort_`co'==1 & Y_`t'!=. & D_`t'!=.
				count
				if r(N)>0 {
			
					reg Y_`t' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
					matrix T[`r',`c']=_b[Z]
					matrix T[`r'+1,`c']=_se[Z]
					
				
					reg D_`t' Z `X' `W' [aw=w], r cluster(hsis_racntrid)
					matrix T[`r',`c'+1]=_b[Z]
					matrix T[`r'+1,`c'+1]=_se[Z]
					matrix T[`r'+2,`c'+1]=e(N)
					
					ivreg2 Y_`t' (D_`t' = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
					matrix T[`r',`c'+2]=_b[D_`t']
					matrix T[`r'+1,`c'+2]=_se[D_`t']
					
				
				
				
				}
				
				local c=`c'+4
				restore
			
			
			}
			
			local c=1
			local r=`r'+4
			
		}
		clear
		svmat T
		browse
		stop

}
		

		
		
	

**************************************************
****** TWO-STEP ESTIMATES ************************
**************************************************

if `two_step'==1 {

	
	*****SETUP

			*Load data
			use "`datapath'/kline_walters.dta", clear
		
			
			
	*****FIRST STEP
		if `two_step_choice'==1 {
		
			*Export matlab data
			egen micro_site=group(hsis_racntrid)
			
			outsheet hsis_childid micro_site site Y D_h D_c D_n Z w `W' `X' using "`matlabpath'/sitedata.csv", nonames comma replace
				
		*****IMPORT MATLAB RESULTS
				preserve
				insheet using "`matlabpath'/output.csv", nonames comma clear
				foreach x of varlist v* {
					cap destring `x', replace force
				}	
			
				ren v1 hsis_childid
				ren v2 psi_h_0
				ren v3 psi_h_1
				ren v4 psi_h
				ren v5 psi_c
				ren v6 rho
				local v=7
				foreach d in h c n {
					foreach q in h c {
						ren v`v' lambda_`d'_`q'
						local ++v
					}
				}
				ren v`v' v_h
				local ++v
				ren v`v' v_c
				local ++v
				ren v`v' delta_v_h
				local ++v
				ren v`v' delta_v_c
				local ++v
				if "`model'"!="covs" {
					foreach d in h c n {
						foreach t in h c {
							ren v`v' dlambda_`d'_`t'
							local ++v
						}
					}
				}
				foreach t in nc cc nnt cnt at {
					foreach q in "w_" "v_h_" "v_c_" {
						ren v`v' `q'`t'
						local ++v
					}
				}
				local K=0
				local done=0
				while `done'<1 {
					local knew=`K'+1
					cap ren v`v' T_`knew'
					if _rc==0 {
						local ++K
						local ++v
					}
					if _rc!=0 {
						local ++done
					}
				}
				save "`datapath'/matlab_output.dta", replace
				restore
				
				*Merge
				merge 1:1 hsis_childid using "`datapath'/matlab_output.dta"
				drop _merge
				
			
			
			****Save number of types
			gen K=`K'
			sum K
			
			***Deal w/a few negative weights due to matlab rounding
			foreach g in nc cc nnt cnt at {
				replace w_`g'=0 if w_`g'<0
				foreach d in h c {
						replace v_`d'_`g'=. if w_`g'==0
				}
			}
			gen w_all=w_nc+w_cc+w_nnt+w_cnt+w_at
			foreach g in nc cc nnt cnt at {
				replace w_`g'=w_`g'/w_all
			}
			drop w_all
			
			
					
			*****Save
			save "`datapath'/kline_walters_twostep_`model'.dta", replace
		}
		
	******** SECOND STEP ********************************
				
		*Load data
		use "`datapath'/kline_walters_twostep_`model'.dta", clear
		
		sum K
		local K=r(mean)
		
			***Format covs
			drop T_1
			local T=""
			foreach t of numlist 2/`K' {
				cap sum T_`t'
				
				if _rc==0 {
					replace T_`t'=T_`t'-r(mean)
					local T="`T' T_`t'"
					if `interact_P'==1 {
					
						foreach p of varlist `P' {
							gen T_`t'_`p'=T_`t'*`p'
							local T="`T' T_`t'_`p'"
						}
					}
					
				}
			}
			
			
			****No control fns
				
				*No covs
				reg Y D_h D_c [aw=w], r cluster(hsis_racntrid)
				
				*Unrestricted covs
				foreach x in `X' `W'  {
					gen `x'_inter_h=`x'*D_h
					gen `x'_inter_c=`x'*D_c
					local inters="*_inter_*"
				}
				reg Y D_h D_c `X' `W' `inters' [aw=w], r cluster(hsis_racntrid)
				
				
				*Restricted covs
				cap drop *_inter_* 
				cap foreach x in `W' {
					gen `x'_inter_h=`x'*D_h
					gen `x'_inter_c=`x'*D_c
					local inters="*_inter_*"
				}
				reg Y D_h D_c `X' `W' `inters' [aw=w], r cluster(hsis_racntrid)
				


			**** MODELS WITH SITES IN CONTROL FNS************
			
				***Unrestricted
				cap drop *_inter_*
				foreach x of varlist `X' `W' `T' v_h v_c {
					gen `x'_inter_h=`x'*D_h
					gen `x'_inter_c=`x'*D_c
				}

				reg Y D_h D_c v_h v_c ///
								`T' `W' `X' *_inter_*  ///
								[aw=w], r cluster(hsis_racntrid)
				test v_h_inter_c=v_c_inter_h=0
				test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=0
				test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=v_h=v_c=0
				estimates save "`datapath'/unrestricted_`model'.ster", replace
			
				
				****Covs restricted
					drop *_inter_*
					foreach x of varlist `W' `T' v_h v_c {
						gen `x'_inter_h=`x'*D_h
						gen `x'_inter_c=`x'*D_c
					}
					
					reg Y D_h D_c v_h v_c ///
									`T' `X' `W' *_inter_*  ///
									[aw=w], r cluster(hsis_racntrid)
					estimates save "`datapath'/covsrestrict_`model'.ster", replace
									
					*Tests for selection
					test v_h_inter_c=v_c_inter_h=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=v_h=v_c=0
					
					*Test for selection restrictions
					test (v_h_inter_h=v_h_inter_c) (v_c_inter_c=v_c_inter_h)
					test v_h_inter_c=v_c_inter_h=0
					
					*Test for constraint restrictions
					local cons=1
					local constraints=""
					local tester=""
					foreach x of varlist v_h v_c {
						constraint `cons' _b[`x'_inter_h]=_b[`x'_inter_c]
						local constraints "`constraints' `cons'"
						local tester "`tester' (_b[`x'_inter_h]=_b[`x'_inter_c])"
						local ++cons
					}
					test `tester'
					
					
					*Score test
					predict e_hat, res
					local tester=""
					foreach x in `W' `T' {
						gen scoreh_`x'=v_h*`x'
						gen scorec_`x'=v_c*`x'
						local tester "`tester' scoreh_`x' scorec_`x'"
						
					}
					reg e_hat D_h D_c v_h v_c `T' `X' `W' *_inter_* score* [aw=w], r cluster(hsis_racntrid)
					estimates save "`datapath'/score_covsrestrict_`model'.ster", replace
					test `tester'
					drop e_hat score*
					
				
				****Selection restricted 
					drop *_inter_*
					foreach x of varlist `W' `T' v_h v_c  {
						gen `x'_inter_h=`x'*D_h
						gen `x'_inter_c=`x'*D_c
					}
					cnsreg Y D_h D_c v_h v_c ///
									`T' `X' `W' *_inter_*  ///
									[aw=w], r cluster(hsis_racntrid) constraints(`constraints')
					estimates save "`datapath'/selectrestrict_`model'.ster", replace
					
			
					*Tests for selection
					test v_h_inter_c=v_c_inter_h=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=v_h=v_c=0
				
					*Score test
					predict e_hat, res
					local tester=""
					foreach x in `W' `T' {
						gen scoreh_`x'=v_h*`x'
						gen scorec_`x'=v_c*`x'
						local tester "`tester' scoreh_`x' scorec_`x'"
					}
					qui reg e_hat D_h D_c v_h v_c `T' `X' `W' *_inter_* score* [aw=w], r cluster(hsis_racntrid)
					estimates save "`datapath'/score_selectrestrict_`model'.ster", replace
					test `tester'
					drop e_hat score*
					
				****Cross terms restricted 
					drop *_inter_*
					foreach x of varlist `W' `T' v_h v_c  {
						gen `x'_inter_h=`x'*D_h
						gen `x'_inter_c=`x'*D_c
					}
					constraint 3 _b[v_h_inter_c]=0
					constraint 4 _b[v_c_inter_h]=0
					cnsreg Y D_h D_c v_h v_c ///
									`T' `X' `W' *_inter_*  ///
									[aw=w], r cluster(hsis_racntrid) constraints(3 4)
					estimates save "`datapath'/crossrestrict_`model'.ster", replace
				
					*Tests for selection
					test v_h_inter_c=v_c_inter_h=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=0
					test v_h_inter_h=v_h_inter_c=v_c_inter_h=v_c_inter_c=v_h=v_c=0
				
					*Score test
					predict e_hat, res
					local tester=""
					foreach x in `W' `T' {
						gen scoreh_`x'=v_h*`x'
						gen scorec_`x'=v_c*`x'
						local tester "`tester' scoreh_`x' scorec_`x'"
					}
					qui reg e_hat D_h D_c v_h v_c `T' `X' `W' *_inter_* score* [aw=w], r cluster(hsis_racntrid)
					estimates save "`datapath'/score_selectrestrict_`model'.ster", replace
					test `tester'
					drop e_hat score*
				
				
			
	*******Save data set with control function estimates for this model
			save "`datapath'/kline_walters_`model'.dta", replace
			
			if `two_step_stop'==1 {
					stop
				}
			
			
			
		

				
}

		
**************************************************
****** TWO-STAGE LEAST SQUARES ************************
**************************************************

if `two_stage'==1 {

	use "`datapath'/kline_walters_`model'.dta", clear


	matrix results=J(100,20,.)
	local r=1
	local c=1
	
	
		*Define endog vars of interest
		cap drop D_*
		cap drop Z_*
		gen Dh=D==2
		gen Dany=D!=0
		gen Dc=D==1
		
		*Define covs
			local X "X_male X_mom_teen X_mom_married X_sped X_testlang X_m_income X_income_2 X_income_3 X_b_2 X_b_3 X_bothparents X_only_sib X_one_sib X_urban"
			local W="X_transportation X_quality X_black X_spanish X_mom_ed X_income_4 X_b_1 X_age4"
		
		*Just ID
		ivreg2 Y (Dh = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
		matrix results[`r',`c']=_b[Dh]
		matrix results[`r'+1,`c']=_se[Dh]
		local r=`r'+2

		
		*Offer*covs
		foreach w of varlist `W'  {
			gen Z_`w'=Z*`w'
		}

			*Univariate 2SLS
			ivreg2 Y (Dh = Z Z_*) `X' `W' [aw=w], r cluster(hsis_racntrid) first
			matrix results[`r',`c']=_b[Dh]
			matrix results[`r'+1,`c']=_se[Dh]
			local c=`c'+2
			
			*Bivariate 2SLS
			ivreg2 Y (Dh Dc = Z Z_*) `X' `W' [aw=w], r cluster(hsis_racntrid) first
			matrix results[`r',`c']=_b[Dh]
			matrix results[`r'+1,`c']=_se[Dh]
			matrix results[`r',`c'+1]=_b[Dc]
			matrix results[`r'+1,`c'+1]=_se[Dc]
			local c=`c'-2
			local r=`r'+2
			
		*Offer*Sites
			
	
			cap drop Z_*
			sum K
			local K=r(mean)
			foreach t of numlist 2/`K' {
				cap gen covT_`t'=T_`t'
				cap gen Z_`t'=Z*T_`t'
			}

			*Univariate 2SLS
			ivreg2 Y (Dh = Z Z_*) `X' `W' covT_* [aw=w], r partial(`X' `W' covT_*) first cluster(hsis_racntrid)
			
			*Bivariate 2SLS
			ivreg2 Y (Dh Dc = Z Z_*) `X' `W' covT_* [aw=w], r partial(`X' `W' covT_*) first cluster(hsis_racntrid)
	
			
		*Offer*covs and offer*sites

			*Construct instruments
			drop Z_*
			sum K
			local K=r(mean)
			foreach t of numlist 2/`K' {
				cap gen covT_`t'=T_`t'
				cap gen Z_`t'=Z*T_`t'
			}
			foreach x of varlist `W' {
				gen Z_`x'=Z*`x'
			}
			
			*Univariate 2SLS
			ivreg2 Y (Dh = Z Z_*) `X' `W' covT_* [aw=w], r partial(`X' `W' covT_*) first cluster(hsis_racntrid)
			
			*Bivariate 2SLS
			ivreg2 Y (Dh Dc = Z Z_*) `X' `W' covT_* [aw=w], r partial(`X' `W' covT_*) first cluster(hsis_racntrid)
			
			
		*Offer*micro sites
			
			*Construct instruments
			drop Z_*
			sum site
			local S=r(max)
			foreach s of numlist 1/`S' {
				gen sdum_`s'=(site==`s')
				gen Z_sdum_`s'=Z*sdum_`s'
			}
			
			*Univeriate models
			
				*2SLS
				*ivreg2 Y (Dh = Z_*) sdum_* `X' `W' [aw=w], r partial(`X' `W') first
				
				*LIML
				ivreg2 Y (Dh = Z_*) sdum_* `X' `W' [aw=w], r partial(`X' `W') liml
				
				*JIVE
					*Partial out before JIVE
					foreach x of varlist Y Dh Dc Z_* {
						qui reg `x' sdum_* `X' `W' [aw=w], nocons
						qui predict tilde`x', res
						qui sum tilde`x'
						if r(sd)<0.0000000000000001 {
							drop `x'
						}
					}
					jive tildeY (tildeDh = tildeZ_*), r jive2
					****Parameters
											matrix C=1
										
											******Construct preliminary matrices
											
												**Y
												mkmat tildeY, matrix(Y)
												
												**X
												mkmat tildeDh, matrix(X)
												
												**Z
												mkmat tildeZ_*, matrix(Z)
												
												**Weights
												mkmat w, matrix(W)


											*****Do calculations in mata
												mata
													
													y=st_matrix("Y")
													X=st_matrix("X")
													Z=st_matrix("Z")
													C=st_matrix("C")
													W=st_matrix("W")
													
													N=rows(y)
													K=cols(Z)
													G=cols(X)
													
													W_half=J(N,N,0)
													i=1
													while (i<=N) {
														W_half[i,i]=sqrt(W[i,1])
														i++
													}
													y=W_half*y
													X=W_half*X
													Z=W_half*Z
													

													P=Z*invsym(Z'*Z)*Z'
													P_ii=diagonal(P)
													
													P_XX=J(cols(X),cols(X),0)
													P_Xy=J(cols(X),1,0)
													i=1
													while (i<=N) {
														P_XX=P_XX+P_ii[i,1]*X[i,.]'*X[i,.]
														P_Xy=P_Xy+P_ii[i,1]*X[i,.]'*y[i,1]
														i++
													}
													

													
													delta_hat=invsym(X'*P*X-P_XX)*(X'*P*y-P_Xy)
													
													ones_N=J(N,1,1)
													e_hat=y-X*delta_hat
													e_hat_2=e_hat:^2
													P_sq=P:*P
													V_hat=((e_hat_2'*P_sq*e_hat_2)-(e_hat_2'*diag(diag(P_sq))*e_hat_2))/K
													num=e_hat'*P*e_hat-(e_hat'*diag(diag(P))*e_hat)
													T=(num/sqrt(V_hat))+K
													overid=cols(Z)-cols(X)
													
													
													T
													overid
													delta_hat
											
												end
								
								
			*Bivariate models
			
				*2SLS
				*ivreg2 Y (Dh Dc = Z_*) sdum_* `X' `W' [aw=w], r partial(`X' `W') first
				
				*LIML
				ivreg2 Y (Dh Dc = Z_*) sdum_* `X' `W' [aw=w], r partial(`X' `W' sdum_*) liml
				stop
				*JIVE
				jive tildeY (tildeDh tildeDc = tildeZ_*), r jive2

								****Parameters
											matrix C=1
										
											******Construct preliminary matrices
											
												**Y
												mkmat tildeY, matrix(Y)
												
												**X
												mkmat tildeDh tildeDc, matrix(X)
												
												**Z
												mkmat tildeZ_*, matrix(Z)
												
												**Weights
												mkmat w, matrix(W)


											*****Do calculations in mata
												mata
													
													y=st_matrix("Y")
													X=st_matrix("X")
													Z=st_matrix("Z")
													C=st_matrix("C")
													W=st_matrix("W")
													
													N=rows(y)
													K=cols(Z)
													G=cols(X)
													
													W_half=J(N,N,0)
													i=1
													while (i<=N) {
														W_half[i,i]=sqrt(W[i,1])
														i++
													}
													y=W_half*y
													X=W_half*X
													Z=W_half*Z
													

													P=Z*invsym(Z'*Z)*Z'
													P_ii=diagonal(P)
													
													P_XX=J(cols(X),cols(X),0)
													P_Xy=J(cols(X),1,0)
													i=1
													while (i<=N) {
														P_XX=P_XX+P_ii[i,1]*X[i,.]'*X[i,.]
														P_Xy=P_Xy+P_ii[i,1]*X[i,.]'*y[i,1]
														i++
													}
													

													
													delta_hat=invsym(X'*P*X-P_XX)*(X'*P*y-P_Xy)
													
													ones_N=J(N,1,1)
													e_hat=y-X*delta_hat
													e_hat_2=e_hat:^2
													P_sq=P:*P
													V_hat=((e_hat_2'*P_sq*e_hat_2)-(e_hat_2'*diag(diag(P_sq))*e_hat_2))/K
													num=e_hat'*P*e_hat-(e_hat'*diag(diag(P))*e_hat)
													T=(num/sqrt(V_hat))+K
													overid=cols(Z)-cols(X)
													
													
													T
													overid
													delta_hat
											
												end
				
	
stop
		

}

**************************************************
***** SUBLATEs ****************************
**************************************************

if `sub_late'==1 {


		******** Results storage *********************************
		
			matrix T=J(50,50,.)
			local r=1
			local c=1

		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			
		***** GET TYPES
			sum K
			local K=r(mean)
			local T=""
			if `K' >1 {
				foreach t of numlist 2/`K' {
					cap sum T_`t'
					if _rc==0 {
						local T="`T' T_`t'"
					}
				}
			}
			
		
		***** Replace small numbers of negative weights with zeros
			foreach x of varlist w_* {
				replace `x'=0 if `x'<0.005
			}
			egen wall=rsum(w_*)
			foreach x of varlist w_* {
				replace `x'=`x'/wall
				sum `x' [aw=w]
				local `x'=r(mean)
			}
			
		******* IV *****************************************
		
			ivreg2 Y (D_h = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
			matrix T[`r',`c']=_b[D_h]
			matrix T[`r'+1,`c']=_se[D_h]
			local ++c
			
	
		****** RESTRICTED COVS **************************************
			preserve
			estimates use "`datapath'/`restrictions'_`model'.ster"
		

				**Complier mean gamma's and choice prob
				
					foreach x of varlist `X' `W' `T' {
						sum `x' [aw=w_nc*w]
						local `x'_nc=r(mean)
					}
					
					sum v_h_nc [aw=w_nc*w]
					local v_h_nc = r(mean)
					sum v_c_nc [aw=w_nc*w]
					local v_c_nc = r(mean)
					
					
				**Sublate
				local interaction_coefs_nc=""
				foreach x of varlist `W' `T' {
					local interaction_coefs_nc "`interaction_coefs_nc' + _b[`x'_inter_h]*``x'_nc'"
				}
				
				
					lincom _b[D_h]  `interaction_coefs_nc' ///
					 +_b[v_h_inter_h]*`v_h_nc' ///
							+ _b[v_c_inter_h]*`v_c_nc'
							
					matrix T[`r'+3,`c']=r(estimate)
					matrix T[`r'+4,`c']=r(se)
					
					
			*** C-h subLATE
			
				**Complier mean gamma's and choice prob
				
					foreach x of varlist `X' `W' `T' {
						sum `x' [aw=w_cc*w]
						local `x'_cc=r(mean)
					}
					sum v_h_cc [aw=w_cc*w]
					local v_h_cc = r(mean)
					sum v_c_cc [aw=w_cc*w]
					local v_c_cc = r(mean)
				
					
				**Sublate
				
				local interaction_coefs_cc=""
				foreach x of varlist `W' `T' {
					local interaction_coefs_cc "`interaction_coefs_cc' + (_b[`x'_inter_h] - _b[`x'_inter_c])*``x'_cc'"
				}
				
					lincom _b[D_h] - _b[D_c] `interaction_coefs_cc' ///
						+(_b[v_h_inter_h]-_b[v_h_inter_c])*`v_h_cc' ///
							+ (_b[v_c_inter_h]-_b[v_c_inter_c])*`v_c_cc'
							
					matrix T[`r'+6,`c']=r(estimate)
					matrix T[`r'+7,`c']=r(se)
					
			
			
			*** LATE
				sum w_nc [aw=w]
				local w_nc=r(mean)

				lincom ((`w_nc')/(`w_nc' + `w_cc'))*(_b[D_h]  `interaction_coefs_nc' ///
					 +_b[v_h_inter_h]*`v_h_nc' ///
							+ _b[v_c_inter_h]*`v_c_nc') ///
						+((`w_cc')/(`w_nc' + `w_cc'))*(_b[D_h] - _b[D_c] `interaction_coefs_cc' ///
						+(_b[v_h_inter_h]-_b[v_h_inter_c])*`v_h_cc' ///
							+ (_b[v_c_inter_h]-_b[v_c_inter_c])*`v_c_cc')
							
				matrix T[`r',`c']=r(estimate)
				matrix T[`r'+1,`c']=r(se)
				
			*** n-h ATE
			
				matrix T[`r'+9,`c']=_b[D_h]
				matrix T[`r'+10,`c']=_se[D_h]
			
			*** c-h ATE
				lincom _b[D_h] - _b[D_c]
				matrix T[`r'+12,`c']=r(estimate)
				matrix T[`r'+13,`c']=r(se)
				
				local r=`r'+15
				
				restore
				
	

		*********** DISTRIBUTION OF LATEs *********************		
				
				*Load model estimates
				estimates use "`datapath'/`restrictions'_`model'.ster"
				
				
				*Construct LATEs by observation
				gen mu_n=_b[_cons]
				foreach x of varlist `X' `W' `T' {
					replace mu_n=mu_n+_b[`x']*`x'
				}
				foreach d in h c {
					gen mu_`d'=mu_n+_b[D_`d']
					foreach x of varlist `W' `T' {
						replace mu_`d'=mu_`d'+_b[`x'_inter_`d']*`x'
					}
				}
				gen LATE_nh=(mu_h-mu_n)+_b[v_h_inter_h]*v_h_nc+_b[v_c_inter_h]*v_c_nc
				gen LATE_ch=(mu_h-mu_c)+(_b[v_h_inter_h]-_b[v_h_inter_c])*v_h_cc+(_b[v_c_inter_h]-_b[v_c_inter_c])*v_c_cc
				gen w_c=w_nc+w_cc
				gen s=w_cc/w_c
				sum s [aw=w]
				local s_bar=r(mean)
				gen LATE_bar=(1-`s_bar')*LATE_nh+`s_bar'*LATE_ch
				gen LATE_h=(1-s)*LATE_nh+s*LATE_ch
				xtile LATE_q=LATE_h, nq(5)
				foreach q of numlist 1 5 {
					preserve
					keep if LATE_q==`q'
					
					
					sum LATE_h [aw=w*w_c]
					matrix T[`r',`c']=r(mean)
					sum LATE_bar [aw=w*w_c]
					matrix T[`r'+3,`c']=r(mean)
					local r=`r'+6
					
					
					restore
				}
				
				
				
				clear
				svmat T
				browse
				stop
		


}



	



**************************************************
***** RATIONING ****************************
**************************************************

if `rationing'==1 {


		******** Results storage *********************************
		
		matrix T=J(20,6,.)
		local r=1
		local c=1

		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			
		***** GET TYPES
			sum K
			local K=r(mean)
			foreach t of numlist 2/`K' {
				cap sum T_`t'
				if _rc==0 {
					local T="`T' T_`t'"
				}
			}

			
			estimates use "`datapath'/`restrictions'_`model'.ster"
			
			*** Define offer rate and offer utility effect using HS offer rate and effect
			*** Set HS offer to zero for this population to mimic HS non-applicants
			*** Move c utility from (U - delta), non-offered utility, back to U
			
				gen delta=psi_h_1-psi_h_0
				sum delta [aw=w]
				local delta=r(mean)	
				gen psi_c0=psi_c-`delta'
				gen psi_c1=psi_c
			
			
				*Probability of complying from n to c in response to an offer
				gen w_ncc = binormal(-psi_c0,-psi_h_0,rho) - binormal(-psi_c1,-psi_h_0,rho)

				
				*E[Y]
				
					gen x1=.
					gen x2=-psi_h_0
					gen y1=-psi_c1
					gen y2=-psi_c0
					gen tau=rho
					Gamma
					ren gamma v_h_ncc
					drop x1 x2 y1 y2 tau
					
					gen x1=-psi_c1
					gen x2=-psi_c0
					gen y1=.
					gen y2=-psi_h_0
					gen tau=rho
					Gamma
					ren gamma v_c_ncc
					drop x1 x2 y1 y2 tau

					
					
			
				**Complier mean gamma's and choice prob
					foreach x of varlist w_* {
						replace `x'=0 if `x'<0
					}
				
					foreach x of varlist `W' `T' v_h_ncc v_c_ncc {
						sum `x' [aw=w_ncc*w]
						local `x'_ncc=r(mean)
					}
					
					
		
					
				**Sublate
				local interaction_coefs_ncc=""
				foreach x of varlist `W' `T'  {
					local interaction_coefs_ncc "`interaction_coefs_ncc' + _b[`x'_inter_c]*``x'_ncc'"
				}
			
					lincom _b[D_c]  `interaction_coefs_ncc' +_b[v_h_inter_c]*`v_h_ncc_ncc' + _b[v_c_inter_c]*`v_c_ncc_ncc' ///

							stop
				

}


	
	
**************************************************
***** MTEs **********************************
**************************************************

if `mte'==1 {

		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			
			
		***** GET TYPES
			sum K
			local K=r(mean)
			local T=""
			foreach t of numlist 2/`K' {
				cap sum T_`t'
				if _rc==0 {
					local T="`T' T_`t'"
				}
			}
			
	
		****Get HS offer rate
			sum Z [aw=w]
			gen P_Z=r(mean)

		****Load estimates
		estimates use "`datapath'/`restrictions'_`model'.ster"

		******* Compute MTEs as a function of f ***************
		matrix T=J(1000,11,.)
		local r=1
		local fmin=-1.3
		local fmax=2.05
		local finc=0.05
		*local f=0
		local f=`fmin'-`finc'
		while `f'<=`fmax' {
		
			local f=`f'+`finc'
		
			preserve
			
				******Compute MTE(f) **********************
				
					***Utilities
					replace psi_h=psi_h+`f'
					gen psi_h0 = psi_h_0+`f'
					gen psi_h1=psi_h_1+`f'
					
					
					****Probabilities
					gen arg_nm=(-psi_c - rho*(-psi_h))/sqrt(1-(rho^2))
					gen w_nm=normalden(-psi_h)*normal(arg_nm)
					gen tau=(psi_c-psi_h)/sqrt(2*(1-rho))
					gen chi=sqrt((1-rho)/2)
					gen arg_cm=(psi_c - chi*tau)/sqrt(1-(chi^2))
					gen w_cm=normalden(tau)*normal(arg_cm)
					gen w_m=w_nm+w_cm
					
					
					***MTE_c

						
						*V's
						gen v_c_cm = -(chi*tau-sqrt(1-(chi^2))*(normalden(arg_cm)/normal(arg_cm)))
						gen v_h_cm = v_c_cm+(psi_c - psi_h)
						
						foreach v in h c {
							qui sum v_`v'_cm [aw=w*w_m]
							local v_`v'_cm = r(mean)
						}
						
						*Covs
						local inter_cm="_b[D_h] - _b[D_c]"
						foreach x of varlist `W' `T' {
							qui sum `x' [aw=w*w_m]
							local `x'_cm = r(mean)
							local inter_cm "`inter_cm' + (_b[`x'_inter_h]-_b[`x'_inter_c])*``x'_cm'"
						}
						
						*SubLATE
						lincom `inter_cm'+(_b[v_h_inter_h]-_b[v_h_inter_c])*`v_h_cm'+(_b[v_c_inter_h]-_b[v_c_inter_c])*`v_c_cm'
						local MTE_c=r(estimate)
					
					***MTE_n
					

						*V's
						gen v_h_nm = -psi_h
						gen v_c_nm = rho*v_h_nm - sqrt(1-(rho^2))*(normalden(arg_nm)/normal(arg_nm))
						foreach v in h c {
							qui sum v_`v'_nm [aw=w*w_m]
							local v_`v'_nm = r(mean)
						}
						
						*Covs
						local inter_nm="_b[D_h]"
						foreach x of varlist `W' `T' {
							qui sum `x' [aw=w*w_m]
							local `x'_nm = r(mean)
							local inter_nm "`inter_nm' + _b[`x'_inter_h]*``x'_nm'"
						}
						
						*SubLATE
						lincom `inter_nm'+_b[v_h_inter_h]*`v_h_nm'+_b[v_c_inter_h]*`v_c_nm'
						local MTE_n=r(estimate)
						

						
					***S
						gen s_m = w_cm/w_m
						sum s_m [aw=w_m]
						local s_m = r(mean)
						
					***MTE_h 
						lincom (1-`s_m')*(`inter_nm'+_b[v_h_inter_h]*`v_h_nm'+_b[v_c_inter_h]*`v_c_nm') ///
								+(`s_m')*(`inter_cm'+(_b[v_h_inter_h]-_b[v_h_inter_c])*`v_h_cm'+(_b[v_c_inter_h]-_b[v_c_inter_c])*`v_c_cm')
						local MTE_h = r(estimate)
			
				
				*****Compute P_h(f) *********************
				
							***NAT's
							
									cap drop w_nat
									gen w_nat=binormal(psi_h0,-psi_c,-rho)
														
							
							****CAT's
								cap drop w_cat
								gen w_cat=binormal((psi_h0 - psi_c)/sqrt(2*(1-rho)),psi_c,-sqrt((1-rho)/2))
								
													
							****NNT's
							
								*Type probability
									cap drop w_nnt
									gen w_nnt=binormal(-psi_h1,-psi_c,rho)
							
							****CNT's
							
								*Type probability
									cap drop w_cnt
									gen w_cnt=binormal((psi_c - psi_h1)/sqrt(2*(1-rho)),psi_c,sqrt((1-rho)/2))
								
								
							****NC's
							
								*Type probability
									cap drop w_nc
									gen w_nc=binormal(-psi_h0,-psi_c,rho) - binormal(-psi_h1,-psi_c,rho)
								
													
							
							****CC's
							
								*Type probability
									cap drop w_cc
									gen w_cc=binormal((psi_c - psi_h0)/sqrt(2*(1-rho)),psi_c,sqrt((1-rho)/2)) ///
											 - binormal((psi_c - psi_h1)/sqrt(2*(1-rho)),psi_c,sqrt((1-rho)/2))
														
						
							*****Get new market share
								
								
							gen P_h = w_nat+w_cat+P_Z*(w_nc+w_cc)
							sum P_h [aw=w]
							local P_h_m=r(mean)
					
					
				****Costs/Benefits
					local phi=8
					local cost_final=`phi'
					local cost_0=`phi'-0.5*`phi'*`s_m'
					local cost_half=`phi'-0.75*`phi'*`s_m'
					local cost_full=`phi'-`phi'*`s_m'
					local benefit=34.34*`MTE_h'
		
		
				*****Results
					matrix T[`r',1]=`f'
					matrix T[`r',2]=`s_m'
					matrix T[`r',3]=`MTE_h'
					matrix T[`r',4]=`MTE_n'
					matrix T[`r',5]=`MTE_c'
					matrix T[`r',6]=`cost_0'
					matrix T[`r',7]=`cost_half'
					matrix T[`r',8]=`cost_full'
					matrix T[`r',9]=`benefit'
					matrix T[`r',10]=`cost_final'
					matrix T[`r',11]=`P_h_m'
					
					
					local ++r
		
			restore
		
		}
			
		clear
		svmat T
		ren T1 f
		ren T2 s
		ren T3 PRTE
		ren T4 PRTE_n
		ren T5 PRTE_c
		ren T6 cost_0
		ren T7 cost_half
		ren T8 cost_full
		ren T9 benefit
		ren T10 cost_final
		ren T11 P_h
		drop if f==.
		sum P_h if abs(f)<0.0001
		local P0=r(mean)
		local eta=0.5
		gen phi_eta = `phi'*exp(`eta'*(log(P_h) - log(`P0')))
		gen s_c=s
		gen phi_h=8
		
		gen mvpf_0=((1-0.35)*34.339*PRTE)/(`phi' - 0.35*34.339*PRTE)
		gen mvpf_1=((1-0.35)*34.339*PRTE)/(`phi' - 0.75*`phi'*s_c - 0.35*34.339*PRTE)
		gen mvpf_2=((1-0.35)*34.339*PRTE)/(phi_eta*(1+`eta') - 0.75*phi_eta*s_c - 0.35*34.339*PRTE)
		
		tempfile tempsave
		save "`tempsave'"
		
		*Get bootstrap CIs
		use "`datapath'/mteci_results_new.dta", clear
		bys f: egen ci_u_mte=pctile(PRTE), p(95)
		bys f: egen ci_l_mte=pctile(PRTE), p(5)
		bys f: egen ci_u_mvpf_0=pctile(mvpf_0), p(95)
		bys f: egen ci_l_mvpf_0=pctile(mvpf_0),  p(5)
		bys f: egen ci_u_mvpf_1=pctile(mvpf_1), p(95)
		bys f: egen ci_l_mvpf_1=pctile(mvpf_1),  p(5)
		bys f: egen ci_u_mvpf_2=pctile(mvpf_2), p(95)
		bys f: egen ci_l_mvpf_2=pctile(mvpf_2),  p(5)
		keep f ci_u* ci_l*
		duplicates drop
		merge 1:1 f using "`tempsave'"
		keep if _merge==2 | _merge==3
		gen high=PRTE+(1.96/4)*(ci_u_mte - ci_l_mte)
		gen low=PRTE-(1.96/4)*(ci_u_mte - ci_l_mte)
		replace ci_u_mte=high
		replace ci_l_mte=low
		
		sort P_h
		
		
		graph twoway line PRTE P_h, yaxis(1) lcolor(navy) ///
		|| line PRTE_n P_h, lpattern(dash) yaxis(1) lcolor(maroon) ///
		|| line s_c P_h, yaxis(2) lcolor(forest_green) ///
		|| line PRTE_c P_h, lpattern(dash) yaxis(1) lcolor(dkorange) ///
		|| pci -0.1 0.5 0.6 0.5, lcolor(black) lpattern(dash) ///
			xtitle("Head Start attendance rate") ytitle("Test score effect (std. dev.)", axis(1)) ytitle("Other preschool complier share", axis(2)) ///
			legend(lab(1 "MTE{sub:h}") lab(2 "MTE{sub:nh}") ///
			lab(5 "S{sub:c}") lab(3 "MTE{sub:ch}") //////
			order(1 2 5 3)  size(small) ) ylabel(-0.1(0.1)0.6, nogrid axis(1)) ylabel(0.25(0.05)0.45, nogrid axis(2)) 
			
		
		graph twoway rarea ci_l_mte ci_u_mte P_h, sort color(gs14) yaxis(1) ///
		|| line PRTE P_h, yaxis(1) lcolor(black) ///
		|| line PRTE_n P_h, lpattern(dash) yaxis(1) lcolor(black) ///
		|| line s_c P_h, yaxis(2) lcolor(black) lpattern(dash_dot) ///
		|| line PRTE_c P_h, lpattern(longdash) yaxis(1) lcolor(black) ///
		|| pci -0.1 0.5 0.6 0.5, lcolor(black) lpattern(dot) ///
			xtitle("Head Start attendance rate") ytitle("Test score effect (std. dev.)", axis(1)) ytitle("Other preschool complier share", axis(2)) ///
			legend(lab(2 "MTE{sub:h}") lab(3 "MTE{sub:nh}") ///
			lab(6 "S{sub:c}") lab(4 "MTE{sub:ch}") //////
			order(2 3 6 4)  size(small) ) ylabel(-0.1(0.1)0.6, nogrid axis(1)) ylabel(0.35(0.05)0.5, nogrid axis(2)) scheme(s1color)

		sort P_h
		graph twoway line mvpf_1 P_h, lcolor(black) ///
			  || line mvpf_0 P_h, lcolor(black) lpattern(dash) ///
		  || line mvpf_2 P_h, lcolor(black) lpattern(longdash) ///
				xline(0.487, lpattern(dot) lcolor(black))  ///
				yline(1, lpattern(dot) lcolor(black)) ///
			xtitle("Head Start attendance rate") ytitle("Marginal value of public funds") ///
			legend(lab(2 "{it:{&phi}{sub:c}} = 0, {it:{&eta}}= 0") lab(1 "{it:{&phi}{sub:c}} = 0.75{it:{&phi}{sub:h}}, {it:{&eta}} = 0") lab(3 "{it:{&phi}{sub:c}} = 0.75{it:{&phi}{sub:h}}, {it:{&eta}} = 0.5")) ///
			ylabel(0(1)4, nogrid) ///
			text(3.3 0.32 "{it:p}-values for") ///
			text(3.1 0.32  "{it:MVPF{&le}1}:") ///
			text(2.9 0.45 "{it:p} = 0.00") ///
			text(1.37 0.45 "{it:p} = 0.10") ///
			text(0.88 0.45 "{it:p} = 0.59") ///
			scheme(s1color)
	
			
}

	



*************************************************
***** Choice fit **********************************
**************************************************

if `choicefit'==1 {

		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
	
			
		******** GET PREDICTED PROBABILITIES ***************
		gen pi_h = binormal(psi_h,((psi_h - psi_c)/sqrt(2*(1-rho))),sqrt((1-rho)/2))
		gen pi_c = binormal(psi_c,((psi_c - psi_h)/sqrt(2*(1-rho))),sqrt((1-rho)/2))
		gen pi_n = 1 - pi_h - pi_c


		*****Split into groups
		xtile q_h=pi_h, nq(5)
		xtile q_c=pi_c, nq(5)
		egen Q=group(q_h q_c)
		sum Q
		local Q=r(max)
		bys Q: replace Q=`Q'+1 if _N<50
		egen Q2=group(Q)
		drop Q
		ren Q2 Q
		sum Q
		local Q=r(max)
		gen pi_h_bar=.
		gen pi_c_bar=.
		gen p_h=.
		gen p_c=.
		
		***Sum probabilities by Q
		local testerh=""
		local testerc=""
		foreach q of numlist 1/`Q' {
			sum pi_h if Q==`q'
			local b=r(mean)
			local testerh "`testerh' (_b[qh_`q']=`b')"
			replace pi_h_bar=`b' if Q==`q'
			sum pi_c if Q==`q'
			local b=r(mean)
			local testerc "`testerc' (_b[qc_`q']=`b')"
			replace pi_c_bar=`b' if Q==`q'
		}

		
		****Regressions
		expand 2
		bys hsis_childid: gen s=_n==1
		gen T=D_h
		replace T=D_c if s==0
		foreach q of numlist 1/`Q' {
			gen qh_`q'=(Q==`q')*s
			gen qc_`q'=(Q==`q')*(1-s)
		}
		reg T qh_* qc_*, nocons r cluster(hsis_childid)
		test `testerh'
		test `testerc'
		test `testerh' `testerc'
		
		foreach q of numlist 1/`Q' {
			replace p_h=_b[qh_`q'] if Q==`q'
			replace p_c=_b[qc_`q'] if Q==`q'
		}
		keep Q pi_h_bar pi_c_bar p_h p_c
		duplicates drop
		
		graph twoway scatter p_h pi_h_bar, mcolor(black) || function y=x, range(pi_h_bar) lpattern(dash) lcolor(black) ///
			xtitle("Model predicted {it:{&pi}{sub:h}}") ytitle("Empirical {it:P}({it:D}={it:h})") legend(off) ///
			ylabel(,nogrid) ///
			text(0.8 0.2 "{it:{&chi}}{sup:2}(20) = 14.8")  ///
			text(0.72 0.2 "{it:p} = 0.79") scheme(s1color)
			
			
	
			
		graph twoway scatter p_c pi_c_bar, mcolor(black) || function y=x, range(pi_c_bar) lpattern(dash) lcolor(black) ///
			xtitle("Model predicted {it:{&pi}{sub:c}}") ytitle("Empirical {it:P}({it:D}={it:c})") legend(off) ///
			ylabel(,nogrid) ///
			text(0.39 0.1 "{it:{&chi}}{sup:2}(19) = 13.3")  ///
			text(0.35 0.1 "{it:p} = 0.82") scheme(s1color)
			stop
			
		***Export excel files
		outsheet using "`datapath'/choice_model_fit.csv", names comma replace

}
	
	

**************************************************
***** CONTROL FUNCTION FIRST STAGE TESTS ****************************
**************************************************

if `controlfunction_firststage'==1 {

	
		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			foreach x of varlist w_* {
				drop if `x'<0
			}
			
			*****Weights
			sum Z [aw=w]
			local p=r(mean)
			gen w_h=w_at+`p'*(w_nc+w_cc)
			gen w_n=w_nnt+(1-`p')*w_nc
			gen w_c=w_cnt+(1-`p')*w_cc
			

		
			*Polynomial in lambda diffs
			foreach p in 2 3 {
				foreach d in h c n {
					foreach t in h c {
						gen dlambda_`d'_`t'_`p'=dlambda_`d'_`t'^`p'
					}
				}
			}
			
			
			foreach d in h c n {
			
				qui reg dlambda_`d'_c dlambda_`d'_h [aw=w*w_`d'], nocons
				local b_`d'=_b[dlambda_`d'_h]
			
			}
			
			
	******Means by percentile
			local nq=100
			qui foreach d in h c n {
				egen ving_`d'_h=xtile(dlambda_`d'_h), nq(`nq')
				gen delta_vh_`d'_bar=.
				gen delta_vc_`d'_bar=.
				foreach n of numlist 1/`nq' {
					sum dlambda_`d'_h if ving_`d'_h==`n' [aw=w*w_`d']
					replace delta_vh_`d'_bar=r(mean) if ving_`d'_h==`n'
					sum dlambda_`d'_c if ving_`d'_h==`n' [aw=w*w_`d']
					replace delta_vc_`d'_bar=r(mean) if ving_`d'_h==`n'
				}
			}
			
			
			
	*******Make graph		
			*drop if delta_v_h_bar<-3
			foreach d in h c n {
				replace delta_vc_`d'_bar=. if delta_vh_`d'_bar<-3
				replace delta_vh_`d'_bar=. if delta_vh_`d'_bar<-3
			}
			
	
	
	graph twoway scatter delta_vc_h_bar delta_vh_h_bar, msize(small) mcolor(black) msymbol(Th) || function y=`b_h'*x, range(-3 0) lpattern(dash) lcolor(black) ///
			|| scatter delta_vc_c_bar delta_vh_c_bar, msize(small) mcolor(black) msymbol(Oh) || function y=`b_c'*x, range(-3 0) lpattern(longdash) lcolor(black) ///
			|| scatter delta_vc_n_bar delta_vh_n_bar, msize(small) mcolor(black) msymbol(Sh) || function y=`b_n'*x, range(-3 0) lpattern(dash_dot) lcolor(black) ///
			xtitle("Difference in {&lambda}{sub:{it:h}}") ytitle("Difference in {&lambda}{sub:{it:c}}") ///
			ylabel(, nogrid) ///
			legend(order(1 3 5 2 4 6) rows(2) lab(1 "Head Start") lab(3 "Other centers") lab(5 "No preschool") ///
			lab(2 "") lab(4 "") lab(6 "")) ///
			text(1.2 -0.5 "Head Start: {it:F} = 16.8 {it:p} = 0.00", size(small)) ///
			text(1.08 -0.5 "Other centers: {it:F} = 18.7, {it:p} = 0.00", size(small)) ///
			text(0.96 -0.5 "No preschool: {it:F} = 80.9, {it:p} = 0.00", size(small)) scheme(s1color)
			stop
			
}


*************************************************
****** LATE FIT *********************************
************************************************

if `late_fit'==1 {

		******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			
		***** GET TYPES
			sum K
			local K=r(mean)
			foreach t of numlist 2/`K' {
				cap sum T_`t'
				if _rc==0 {
					local T="`T' T_`t'"
				}
			}
			
			*Load model estimates: and zero out a few negative weights
			estimates use "`datapath'/`restrictions'_`model'.ster"
			foreach x of varlist w_* {
				*replace `x'=. if `x'<0
			}
			gen w_c=w_cc+w_nc
			
		*Predicted mean potential outcomes
		
		*Means
		foreach g in nc cc nnt cnt at {
					
			qui {
				gen mu_n_`g'=_b[_cons]
				gen mu_h_`g'=_b[D_h]
				gen mu_c_`g'=_b[D_c]
						
				foreach x in `X' {
					replace mu_n_`g'=mu_n_`g'+_b[`x']*`x'
				}
				foreach x of varlist `W' `T' {
					replace mu_n_`g'=mu_n_`g'+_b[`x']*`x'
					replace mu_h_`g'= mu_h_`g'+_b[`x'_inter_h]*`x'
					replace mu_c_`g'= mu_c_`g'+_b[`x'_inter_c]*`x'
				}
				foreach t in h c {
					replace mu_n_`g'=mu_n_`g'+_b[v_`t']*v_`t'_`g'
					replace mu_h_`g'=mu_h_`g'+_b[v_`t'_inter_h]*v_`t'_`g'
					replace mu_c_`g'=mu_c_`g'+_b[v_`t'_inter_h]*v_`t'_`g'
				}
				replace mu_h_`g' = mu_h_`g' + mu_n_`g'
				replace mu_c_`g'= mu_c_`g' + mu_n_`g'
			}
				
		}
		

	*Graph predicted against actual LATE by quintile
		gen s_c=(w_cc/(w_nc+w_cc))
		gen LATE_ch = mu_h_cc - mu_c_cc
		gen LATE_nh = mu_h_nc - mu_n_nc
		gen LATE_h = s_c*LATE_ch + (1-s_c)*LATE_nh
		
				local Q=20
				xtile dec_LATE=LATE_h, nq(`Q')
				gen LATE_h_hat = .
				gen LATE_h_X = .
				
				foreach n of numlist 1/`Q' {
				
					gen quin_`n'=dec_LATE==`n'
					gen D_h_q`n'=D_h*quin_`n'
					gen Z_h_q`n'=Z*quin_`n'
					gen base_quin`n'=X_b_1*quin_`n'
					
				}
				
				*Drop observations not predicted to comply
				drop if w_c<=0
				
				ivreg2 Y (D_h_q* = Z_h_q*) quin_* `X' `W' [aw=w], r cluster(hsis_racntrid)
				
				
				
				local hypothesis=""
				foreach n of numlist 1/`Q' {
					qui replace LATE_h_hat=_b[D_h_q`n'] if quin_`n'==1
					qui sum LATE_h if quin_`n'==1 [aw=w*w_c]
					qui replace LATE_h_X=r(mean) if quin_`n'==1
					local b=r(mean)
					*reg D_h Z if quin_`n'==1 [aw=w], r cluster(hsis_racntrid)
					local hypothesis "`hypothesis' (_b[D_h_q`n'] = `b')"
					
					
					
				}
				
				test `hypothesis'
				reg D_h Z [aw=w], r cluster(hsis_racntrid)
				
				bys dec_LATE: keep if _n==1
				
				graph twoway scatter LATE_h_hat LATE_h_X, mcolor(black) || function y = x, range(LATE_h_X) lpattern(dash) lcolor(black) ///
				xtitle("Model-predicted LATE{sub:h}") ytitle("IV estimate") legend(off) ylabel(, nogrid) ///
				xlabel(-0.2(0.2)0.8) ///
				text(0.6 0 "{it:{&chi}}{sup:2}(20) = 23.6") ///
				text(0.54 0 "{it:p} = 0.26") scheme(s1color)
				stop

}
	
	

*************************************************
***** SUBPOPULATION MEANS **********************************
**************************************************

if `subpop_means'==1 {

	local t1=1
	local t2=1
	local t3=1
	local t4=1
	local t5=1
	
	*************** FULL SAMPLE REGS ************************
	
	******** Load data *********************************
			use "`datapath'/kline_walters_`model'.dta", clear
			
			***************Choice probs **************
			
					*N-compliers
					
						*IV
						cap gen D_n=D==0
						reg D_n Z [aw=w], r cluster(hsis_racntrid)
						local w_nc=-_b[Z]
						
						*2step
						sum w_nc [aw=w]
						gen theta1_`t1'=r(mean)-`w_nc'
						gen theta5_`t5'=theta1_`t1'
						local ++t1
						local ++t5
					
					*C-compliers
					
						*IV
						reg D_c Z [aw=w], r cluster(hsis_racntrid)
						local w_cc=-_b[Z]
						
						*2step
						sum w_cc [aw=w]
						gen theta1_`t1'=r(mean)-`w_cc'
						gen theta5_`t5'=theta1_`t1'
						local ++t1
						local ++t5
					
					*NNTs
					
						*IV
						reg D_n [aw=w] if Z==1, r cluster(hsis_racntrid)
						local w_nnt=_b[_cons]
						
						*2step
						sum w_nnt [aw=w]
						gen theta1_`t1'=r(mean)-`w_nnt'
						gen theta5_`t5'=theta1_`t1'
						local ++t1
						local ++t5
					
					*CNTs
					
						*IV
						reg D_c [aw=w] if Z==1, r cluster(hsis_racntrid)
						local w_cnt=_b[_cons]
						
						*2step
						sum w_cnt [aw=w]
						gen theta1_`t1'=r(mean)-`w_cnt'
						gen theta5_`t5'=theta1_`t1'
						local ++t1
						local ++t5
						
					
					*ATs
							/*
						*IV
						reg D_h [aw=w] if Z==0, r cluster(hsis_racntrid)
						local w_at=_b[_cons]
						
						*2step
						sum w_at [aw=w]
						gen theta1_`t1'=r(mean)-`w_at'
						gen theta5_`t5'=theta1_`t1'
						local ++t1
						local ++t5
						*/
						
		************** POTENTIAL OUTCOMES
		
				estimates use "`datapath'/covsrestrict_`model'.ster"
			
		
				*****Get mean potential outcomes
					gen mu_n=_b[_cons]
					foreach x of varlist `X' `W' `T' {
						replace mu_n=mu_n+_b[`x']*`x'
					}
					foreach d in h c {
						gen mu_`d'=_b[D_`d']+mu_n
						foreach x of varlist `W' `T' {
							replace mu_`d'=mu_`d'+_b[`x'_inter_`d']*`x'
						}
					}
					
				****Get subgroup means
					foreach g in nc cc nnt cnt at {
						gen mu_n_`g'=mu_n+_b[v_h]*v_h_`g'+_b[v_c]*v_c_`g'
						foreach d in h c {
							gen mu_`d'_`g'=mu_`d'+(mu_n_`g'-mu_n)+_b[v_h_inter_`d']*v_h_`g'+_b[v_c_inter_`d']*v_c_`g'
						}
					}
					
					****LIST ALL MEANS
					foreach g in nc cc nnt cnt at {
						disp "Results for group: `g'"
						sum w_`g' [aw=w]
						foreach d in h c n {
							sum mu_`d'_`g' [aw=w*w_`g']
						}
					}
					
		stop
		
	
	}
				
	
	
	
**************************************************
****** MATERNAL LABOR SUPPLY *********************
**************************************************

if `mom_works'==1 {

	use "`datapath'/kline_walters.dta", clear
	
	gen mom_works_fulltime=mother_work_03==1 if mother_work_03!=.
	gen mom_works=mother_work_03<=2 if mother_work_03!=.
	

	reg mom_works_fulltime Z `X' `W' [aw=w], r cluster(hsis_racntrid)
	sum mom_works_fulltime [aw=w] if e(sample)
	
	reg mom_works Z `X' `W' [aw=w], r cluster(hsis_racntrid)
	sum mom_works [aw=w] if e(sample)
	
	
	stp[
	
}



	
************************************************
****** FUNDING SOURCES ************************
**************************************************

if `funding'==1 {

	*Load data
	use "`datapath'/kline_walters.dta", clear
	
	*code largest fund var
	gen largest_fund = c5lrgsr1
	replace largest_fund = "M" if largest_fund=="8" | largest_fund=="9" | largest_fund==""
	gen largest_fund_missing=largest_fund=="M"
	gen largest_fund_headstart=largest_fund=="A"
	gen largest_fund_fee=largest_fund=="B"
	gen largest_fund_food=largest_fund=="C"
	gen largest_fund_state=largest_fund=="D"
	gen largest_fund_ccsub=largest_fund=="E"
	gen largest_fund_other=largest_fund=="F"
	gen largest_fund_none=largest_fund=="G"
	
	*Make table
	matrix T=J(20,10,.)
	local r=1
	local c=1
	foreach t in headstart fee food state ccsub other none missing {
	
		*Fraction in H
		sum largest_fund_`t' if D_h==1 [aw=w]
		matrix T[`r',`c']=r(mean)
		local ++c
		
		*Fraction in C
		sum largest_fund_`t' if D_c==1 [aw=w]
		matrix T[`r',`c']=r(mean)
		local ++c
		
		*Compliers
		preserve
		gen Y_Dc=largest_fund_`t'*D_c
		ivreg2 Y_Dc (D_c=Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
		matrix T[`r',`c']=_b[D_c]
				
		
		restore
		
		local c=1
		local r=`r'+2
	
	
	}
	
	*Make table on inputs
	
	matrix T2=J(100,10,.)
	local r=1
	local c=1
	
	gen g1=D==2
	gen g2=D==2 & Z==0
	gen g3=D==1
	
	*Fix home visiting var
	replace visits_3=0 if visits_3==. & staff_directorexp!=.
	
	
	foreach n of numlist 1/3 {
		local models_`n'=""
		foreach x in transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
			reg `x' [aw=w] if g`n'==1
			estimates store `x'_`n'
			matrix T2[`r',`c']=_b[_cons]
			local r=`r'+2
			local models_`n'="`models_`n'' `x'_`n'"
		}
		matrix T2[`r',`c']=e(N)
		local r=1
		local ++c
	}
	
	
	
	suest `models_1' `models_2' `models_3', r cluster(hsis_racntrid)
	local tests2=""
	local tests3=""
	foreach x in  transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
		local tests2="`tests2' (_b[`x'_1_mean:_cons]=_b[`x'_2_mean:_cons])"
		local tests3="`tests3' (_b[`x'_1_mean:_cons]=_b[`x'_3_mean:_cons])"
	}
	test `tests2'
	test `tests3'
	
	*Inputs for compliers
	matrix TC=J(100,10,.)
	local r=1
	local c=1
	foreach x in transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
			cap drop out
			cap drop Dc
			cap gen Dc=D==1
			gen out=`x'*(D==1)
			ivreg2 out (Dc = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
			matrix TC[`r',`c']=_b[Dc]
			local r=`r'+2
		}
		clear
		svmat TC
		browse 
		
	
	
	*Make table on inputs for AT's
	matrix T3=J(100,10,.)
	local r=1
	local c=1
	keep if D==2 & Z==0
	
		ren X_transportation_old c_transportation
		ren X_kidperstaff c_staff_kidperstaff
		ren X_directorexp c_staff_directorexp
		
		*Keep non-missings for comparison
		foreach x in transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
			
				drop if c_`x'==. | `x'==.
			
			}
			
		foreach x in transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
			reg c_`x' [aw=w]
			estimates store c_`x'
			matrix T3[`r',`c']=_b[_cons]
			reg `x' [aw=w]
			estimates store `x'
			matrix T3[`r',`c'+1]=_b[_cons]
			
			local r=`r'+2
			local models="`models' c_`x' `x'"
		}
		matrix T3[`r',`c']=e(N)
		
		suest `models', r cluster(hsis_racntrid)

		local tests=""
		foreach x in  transportation quality staff_bach staff_cert staff_directorexp staff_kidperstaff serv_fullday visits_3 {
			local tests="`tests' (_b[`x'_mean:_cons]=_b[c_`x'_mean:_cons])"

		}
		test `tests'
		


	clear
	svmat T3
	browse
	stop
	
}
