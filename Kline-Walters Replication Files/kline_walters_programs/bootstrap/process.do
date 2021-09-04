
*Chris Walters
*This program does bootstrap inference

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
	
		*Number of cores
		local cores=200
		local trials=100

		*Switches
			local bs_construct=0
			local choice_model=0
			local two_step=0
			local sub_late=0
			local rationing=0
			local mte=0
			local controlfunction_firststage=0
			local subpop_means=0
			local te_p=0
			
	*****Options*********************

			*Select model
				local model="covs_sites"
				*local model="covs"
				*local model="sites"
				local restrictions="covsrestrict"
	
			*Outcome
				local outcome="ppvt_wj3"
				
			*Whether to interact covs with site type
				local interact_P=0
			
			*Covariates and instruments
				if "`model'"=="covs" {
					local X "X_male X_mom_teen X_mom_married X_sped X_testlang X_m_income X_income_2 X_income_3 X_b_2 X_b_3 X_bothparents X_only_sib X_one_sib X_urban"
					local W="X_transportation X_quality X_black X_spanish X_mom_ed X_income_4 X_b_1 X_age4"
					local matlabpath="`matlabroot'/covs_only"
					local bs_folder="`bs_folder'/covs_only"
				}
				if "`model'"=="sites" {
					local X ""
					local W=""
					local matlabpath="`matlabroot'/sites_only"
					local bs_folder="`bs_folder'/sites_only"
				}
				if "`model'"=="covs_sites" {
					local X "X_male X_mom_teen X_mom_married X_sped X_testlang X_m_income X_income_2 X_income_3 X_b_2 X_b_3 X_bothparents X_only_sib X_one_sib"
					local W="X_transportation X_quality X_black X_spanish X_mom_ed X_income_4 X_b_1 X_age4"
					local matlabpath="`matlabroot'/covs_and_sites"
					local bs_folder="`bs_folder'/covs_and_sites"
				}
				local Z_inter=""
				foreach x in `W' {
					local Z_inter="`Z_inter' Z_`x'"
				}
				local Z="Z `Z_inter'"

**************************************************************************************
******************* RECONSTRUCT BS SAMPLES *******************************************
**************************************************************************************

if `bs_construct'==1 {

	foreach core of numlist 1/`cores' {
	
		foreach b of numlist 1/`trials' {
		
			qui {
			
				cap insheet using "`bs_folder'/output_core`core'_trial`b'.csv", nonames comma clear
				
				if _rc==0 {
				
			
		
								*****IMPORT MATLAB RESULTS
								foreach x of varlist v* {
									cap destring `x', replace force
								}	
								local v=1
								ren v`v' hsis_childid
								local ++v
								ren v`v' w_bs
								local ++v
								ren v`v' psi_h_0
								local ++v
								ren v`v' psi_h_1
								local ++v
								ren v`v' psi_h
								local ++v
								ren v`v' psi_c
								local ++v
								ren v`v' rho
								local ++v
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
								save "`bs_folder'/matlab_output_core`core'_trial`b'_`model'.dta", replace

								
								*Merge w/main data set
								use "`datapath'/kline_walters.dta"
								merge 1:1 hsis_childid using "`bs_folder'/matlab_output_core`core'_trial`b'_`model'.dta"
								keep if _merge==3
								drop _merge
								
						***Deal w/a few negative weights due to matlab rounding
									foreach g in nc cc nnt cnt at {
										replace w_`g'=0 if w_`g'<0.001
										foreach d in h c {
												replace v_`d'_`g'=. if w_`g'==0
										}
									}
									gen w_all=w_nc+w_cc+w_nnt+w_cnt+w_at
									foreach g in nc cc nnt cnt at {
										replace w_`g'=w_`g'/w_all
									}
									drop w_all

							
							****Save number of types
							gen K=`K'
							sum K

							****Define new bootstrap weights
							gen weightold=w
							replace w=w*w_bs
							
							*****Save
							save "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", replace
							
				}
			}
			
			disp "Bootstrap sample reconstruction: Core `core', trial `b'"
			
		}
	
	}
	
}
							

*************************************************
****** TWO-STEP ESTIMATES ************************
**************************************************

if `two_step'==1 {

	*Result storage
	matrix T=J(1000,10,.)
	local r=1
	local c=1
	cap erase "`bs_folder'/twostep_tests.dta"
	cap erase "`bs_folder'/twostep_fullsamp.dta"
	
	
	
	***************** FULL SAMPLE ESTIMATES ****************************************************	
	
				*Get cov lists
				use "`datapath'/kline_walters_twostep_`model'.dta", clear
				sum K
				local K=r(max)
				drop T_1
				local T="" 
				if `K' > 1 {
				foreach t of numlist 2/`K' {
				cap sum T_`t' [aw=w]						
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
				}
				
				*Get test stats
				clear
				set obs 1
					
					*Selection
					estimates use "`datapath'/covsrestrict_`model'.ster"
					
						*Any selection
						gen select_1=_b[v_h]
						gen select_2=_b[v_h]+_b[v_h_inter_h]
						gen select_3=_b[v_h]+_b[v_h_inter_c]
						gen select_4=_b[v_c]
						gen select_5=_b[v_c]+_b[v_c_inter_h]
						gen select_6=_b[v_c]+_b[v_c_inter_c]
											
						*Gains
						gen gains_1=_b[v_h_inter_h]
						gen gains_2=_b[v_h_inter_c]
						gen gains_3=_b[v_c_inter_h]
						gen gains_4=_b[v_c_inter_c]
						
					*Score test
					estimates use "`datapath'/score_covsrestrict_`model'.ster"
					local scoretest=""
					local loctest=""
					foreach x in `W' `T' {
						local b1=_b[scoreh_`x']
						local b2=_b[scorec_`x']
						local scoretest "`scoretest' (_b[scoreh_`x']=`b1') (_b[scorec_`x']=`b2')"
						local loctest "`loctest' (_b[scoreh_`x']=0) (_b[scorec_`x']=0)"
					}
						test `loctest'
						gen score_1=r(F)
					
					save "`bs_folder'/twostep_fullsamp.dta", replace
					
				
	
	
	***************** BOOTSTRAP RESULTS ****************************************************
	
	
	*Estimation
	foreach core of numlist 1/`cores' {
	
		foreach b of numlist 1/`trials' {
		
			qui {
			
				cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
				
				if _rc==0 {
				
				
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
							
							
								***Format group type covs
								sum K
								local K=r(max)
								matrix T[`r',`c']=0
								if `K' >1 {
									foreach t of numlist 1/`K' {
										sum T_`t'
										if r(mean)==0 {
											matrix T[`r',`c']=1
										}
									}
								}
								local ++c
								drop T_1
								local T="" 
								if `K' > 1 {
									foreach t of numlist 2/`K' {
										cap sum T_`t' [aw=w]
										
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
								}
								
								****Generate interactions
								foreach x of varlist `W' `T' v_h v_c {
									gen `x'_inter_h=`x'*D_h
									gen `x'_inter_c=`x'*D_c
								}
								
								*Estimate model
								reg Y D_h D_c v_h v_c ///
												`T' `X' `W' *_inter_*  ///
												[aw=w], r cluster(hsis_racntrid)
												
								estimates save "`bs_folder'/covsrestrict_core`core'_trial`b'_`model'.ster", replace
								foreach x of varlist D_h D_c v_h v_h_inter_h v_h_inter_c v_c v_c_inter_h v_c_inter_c {
									matrix T[`r',`c']=_b[`x']
									local ++c
								}
								
								*Get test statistics
								
									*Any selection
									gen select_1=_b[v_h]
									gen select_2=_b[v_h]+_b[v_h_inter_h]
									gen select_3=_b[v_h]+_b[v_h_inter_c]
									gen select_4=_b[v_c]
									gen select_5=_b[v_c]+_b[v_c_inter_h]
									gen select_6=_b[v_c]+_b[v_c_inter_c]
									
									*Gains
									gen gains_1=_b[v_h_inter_h]
									gen gains_2=_b[v_h_inter_c]
									gen gains_3=_b[v_c_inter_h]
									gen gains_4=_b[v_c_inter_c]
									
							*Score test
							predict e_hat, res
							foreach x of varlist `W' `T' {
								gen scoreh_`x'=v_h*`x'
								gen scorec_`x'=v_c*`x'
							}
							reg e_hat D_h D_c v_h v_c `T' `X' `W' *_inter_* score* [aw=w], r cluster(hsis_racntrid)
							test `scoretest'
							gen score_1=r(F)
								
								
				***************** END LOOP OVER TRIALS
				
								keep select_* gains_* score_*
								duplicates drop
								cap append using "`bs_folder'/twostep_tests.dta"
								save "`bs_folder'/twostep_tests.dta", replace
		
		
				local ++r
				local c=1
				
				}
			}
			
			disp "Two-step estimation: Core `core', trial `b'"
			
		}
	
	}
	
	***************** SEE RESULTS ****************************************************
	
		*Estimates w/BS SEs
		clear
		svmat T
		keep if T1!=.
		sum
		sum, detail
		
		*Wald tests
		foreach t in select gains {
							
							use "`bs_folder'/twostep_tests.dta", clear
							correlate `t'_*, cov
							matrix V_hat=r(C)
							use "`bs_folder'/twostep_fullsamp.dta", clear
							mkmat `t'_*, matrix(theta_hat)
							matrix W=theta_hat*inv(V_hat)*(theta_hat')
							local Wald=W[1,1]
							local df=colsof(theta_hat)
							local p = 1-chi2(`df',`Wald')
							disp "Test= `t': Wald =`Wald', p=`p'"
								
							
				}
				
		*Score test
		use "`bs_folder'/twostep_fullsamp.dta", clear
		sum score_1
		local S=r(mean)
		use "`bs_folder'/twostep_tests.dta", clear
		gen reject=`S'>score`s'
		sum reject
		
	
}

**************************************************
****** SUBLATEs **********************************
**************************************************

if `sub_late'==1 {


	*Result storage
	matrix T=J(1000,20,.)
	local r=1
	local c=1
	
	
	*Estimation
	foreach core of numlist 1/`cores' {
	
		foreach b of numlist 1/`trials' {


		
			qui {
			
				cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
				
				if _rc==0 {
				
				matrix T[`r',`c']=`core'
				local ++c
				matrix T[`r',`c']=`b'
				local ++c
			
		***** GET TYPES
			sum K
			local K=r(mean)
			drop T_1
			local T=""
			if `K' >1 {
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
			}
			
		
		***** Replace small numbers of negative weights with zeros
			foreach x of varlist w_* {
				replace `x'=0 if `x'<0
			}
			egen wall=rsum(w_*)
			foreach x of varlist w_* {
				replace `x'=`x'/wall
				sum `x' [aw=w]
				local `x'=r(mean)
			}
			gen w_c=w_nc+w_cc
			gen s=w_cc/w_c
			gen any=(s>0)*(s<1)
			replace w=w*any
	
		****** RESTRICTED COVS **************************************
			preserve
			estimates use  "`bs_folder'/covsrestrict_core`core'_trial`b'_`model'.ster"
		

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
							
					local subLATE_n=r(estimate)
					matrix T[`r',`c']=r(estimate)
					local ++c
					
					
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
							
					local subLATE_c=r(estimate)
							
					matrix T[`r',`c']=r(estimate)
					local ++c
					
			
			
			*** LATE
				sum w_nc [aw=w]
				local w_nc=r(mean)

				lincom ((`w_nc')/(`w_nc' + `w_cc'))*(_b[D_h]  `interaction_coefs_nc' ///
					 +_b[v_h_inter_h]*`v_h_nc' ///
							+ _b[v_c_inter_h]*`v_c_nc') ///
						+((`w_cc')/(`w_nc' + `w_cc'))*(_b[D_h] - _b[D_c] `interaction_coefs_cc' ///
						+(_b[v_h_inter_h]-_b[v_h_inter_c])*`v_h_cc' ///
							+ (_b[v_c_inter_h]-_b[v_c_inter_c])*`v_c_cc')
					local LATE=r(estimate)
							
					matrix T[`r',`c']=r(estimate)
					local ++c
				
			*** n-h ATE
			
				matrix T[`r',`c']=_b[D_h]
				local ATE_n=r(estimate)
				local ++c
			
			*** c-h ATE
				lincom _b[D_h] - _b[D_c]
				matrix T[`r',`c']=r(estimate)
				local ATE_c=r(estimate)
				local ++c
				
			***ATE/LATE difference
				matrix T[`r',`c']=`subLATE_n'-`ATE_n'
				local ++c
				matrix T[`r',`c']=`subLATE_c'-`ATE_c'
				local ++c

				
				restore
				
	

		*********** DISTRIBUTION OF LATEs *********************		
				
				*Load model estimates
				estimates use "`bs_folder'/covsrestrict_core`core'_trial`b'_`model'.ster"
				
				
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
				sum s [aw=w]
				local s_bar=r(mean)
				gen LATE_bar=(1-`s_bar')*LATE_nh+`s_bar'*LATE_ch
				gen LATE_h=(1-s)*LATE_nh+s*LATE_ch
				sum LATE_h [aw=w*w_c]
				
				xtile LATE_q=LATE_h, nq(5)
				foreach q of numlist 1 5 {
					preserve
					keep if LATE_q==`q'
					
					
					sum LATE_h [aw=w*w_c]
					matrix T[`r',`c']=r(mean)
					local ++c
					sum LATE_bar [aw=w*w_c]
					matrix T[`r',`c']=r(mean)
					local ++c
					
					
					restore
				}
				

				***************** END LOOP OVER TRIALS
		
		
				local ++r
				local c=1
				
				}
			}
			
			disp "subLATE estimation: Core `core', trial `b'"
			
		}
	
	}
	
	clear
	svmat T
	keep if T1!=.
	sum






}

**************************************************
****** CONTROL FUNCTION **************************
**************************************************

if `controlfunction_firststage'==1 {


	*Results storage
	cap erase "`bs_folder'/waldtest_fullsamp.dta"
	cap erase "`bs_folder'/waldtest_tests.dta"

	*************** FULL SAMPLE REGS ************************
	
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

				replace w_c=D_`d'
				
				reg dlambda_`d'_h dlambda_`d'_c dlambda_`d'_c_2 dlambda_`d'_c_3 [aw=w*w_c]
				gen waldtest_0_`d'=_b[_cons]
				gen waldtest_1_`d'=_b[dlambda_`d'_c_2]
				gen waldtest_2_`d'=_b[dlambda_`d'_c_3]
				test _b[_cons]=_b[dlambda_`d'_c]=_b[dlambda_`d'_c_2]=_b[dlambda_`d'_c_3]=0
					
					
			}
			
			keep waldtest_*
			duplicates drop
			save "`bs_folder'/waldtest_fullsamp.dta", replace
			

	*************** BOOTSTRAP REGS ************************
		foreach core of numlist 1/`cores' {
			
				foreach b of numlist 1/`trials' {
				
					qui {
					
						cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
						
						if _rc==0 {
						
						
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
								
										replace w_c=D_`d'
								
										reg dlambda_`d'_h dlambda_`d'_c dlambda_`d'_c_2 dlambda_`d'_c_3 [aw=w*w_c]
										gen waldtest_0_`d'=_b[_cons]
										gen waldtest_1_`d'=_b[dlambda_`d'_c_2]
										gen waldtest_2_`d'=_b[dlambda_`d'_c_3]
																
										
								}
								
								keep waldtest_*
								duplicates drop
								cap append using "`bs_folder'/waldtest_tests.dta"
								save "`bs_folder'/waldtest_tests.dta", replace
				
		
						
						}
					}
					
					disp "CF ID estimation: Core `core', trial `b'"
					
				}
			
			}
			
			
		*Wald tests
		foreach t in h c n {
							
							use "`bs_folder'/waldtest_tests.dta", clear
							correlate waldtest_*_`t', cov
							matrix V_hat=r(C)
							use "`bs_folder'/waldtest_fullsamp.dta", clear
							mkmat waldtest_*_`t', matrix(theta_hat)
							matrix W=theta_hat*inv(V_hat)*(theta_hat')
							local Wald=W[1,1]
							local df=colsof(theta_hat)
							local F=`Wald'/`df'
							local p = 1-chi2(`df',`Wald')
							disp "Test= `t': Wald =`Wald', F=`F', p=`p'"
								
							
				}
			
			
			
}


**************************************************
****** SUBPOP MEANS ******************************
**************************************************

if `subpop_means'==1 {


	*Results storage
	cap erase "`bs_folder'/subpop_fullsamp.dta"
	cap erase "`bs_folder'/subpop_tests.dta"
	local t1=1
	local t2=1
	local t3=1
	local t4=1
	local t5=1
	local t6=1
	
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
					
					
						
			***************** H potential outcomes
			
					*********** Compliers
					
							*IV
							gen Y_Dh=Y*D_h
							ivreg2 Y_Dh (D_h = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
							local y=_b[D_h]
							
							
							*2step
							cap gen w_c=w_nc+w_cc
							gen mu_h_c=(w_nc/w_c)*mu_h_nc+(w_cc/w_c)*mu_h_cc
							sum mu_h_c [aw=w*w_c]
							gen theta2_`t2'=r(mean)-`y'
							gen theta5_`t5'=theta2_`t2'
							local ++t2
							local ++t5
							
							
							
					*********** ATs
					
							*IV
							gen Y_Dh_oneminusZ = Y_Dh*(1-Z)
							gen Dh_oneminusZ=D_h*(1-Z)
							reg Y_Dh_oneminusZ Dh_oneminusZ [aw=w], r cluster(hsis_racntrid)
							local y=_b[Dh_oneminusZ]
							
							
							*2step	
							sum mu_h_at [aw=w_at*w]
							gen theta2_`t2'=r(mean)-`y'
							gen theta5_`t5'=theta2_`t2'
							local ++t2
							local ++t5
							
			***************** C potential outcomes	
			
					******* C Compliers
					
						*IV
						gen Y_Dc=Y*D_c
						ivreg2 Y_Dc (D_c = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
						local y=_b[D_c]
						
						*2step
						sum mu_c_cc [aw=w_cc*w]
						gen theta3_`t3'=r(mean)-`y'
						gen theta5_`t5'=theta3_`t3'
						local ++t3
						local ++t5
					
					
					******* C Never takers
					
						*Iv
						gen Y_Dc_Z = Y_Dc*Z
						gen Dc_Z=D_c*Z
						reg Y_Dc_Z Dc_Z [aw=w], r cluster(hsis_racntrid)
						local y=_b[Dc_Z]
						
						
						*2step
						sum mu_c_cnt [aw=w_cnt*w]
						gen theta3_`t3'=r(mean)-`y'
						gen theta5_`t5'=theta3_`t3'
						local ++t3
						local ++t5
						
						
						
						
			***************** N potential outcomes	
			
					******* N Compliers
					
						*IV
						gen Y_Dn=Y*D_n
						ivreg2 Y_Dn (D_n = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
						local y=_b[D_n]
						
						*2step
						sum mu_n_nc [aw=w_nc*w]
						gen theta4_`t4'=r(mean)-`y'
						gen theta5_`t5'=theta4_`t4'
						local ++t4
						local ++t5
					
					
					******* N Never takers
					
						*Iv
						gen Y_Dn_Z = Y_Dn*Z
						gen Dn_Z=D_n*Z
						reg Y_Dn_Z Dn_Z [aw=w], r cluster(hsis_racntrid)
						local y=_b[Dn_Z]
						
						*2step
						sum mu_n_nnt [aw=w_nnt*w]
						gen theta4_`t4'=r(mean)-`y'
						gen theta5_`t5'=theta4_`t4'
						local ++t4
						local ++t5
						
					***********Save full sample estimates for tests
						keep theta1* theta2* theta3* theta4* theta5*
						duplicates drop
						save "`bs_folder'/subpop_fullsamp.dta", replace

						
		******************* BS TRIALS ****************************
	
				*Estimation
				foreach core of numlist 1/`cores' {
				
					foreach b of numlist 1/`trials' {
					
						qui {
						
							cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
							
							if _rc==0 {
													
							local t1=1
							local t2=1
							local t3=1
							local t4=1
							local t5=1
							local t6=1
	
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
					
							estimates use "`bs_folder'/covsrestrict_core`core'_trial`b'_`model'.ster"
					
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
								
									
						***************** H potential outcomes
						
								*********** Compliers
								
										*IV
										gen Y_Dh=Y*D_h
										ivreg2 Y_Dh (D_h = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
										local y=_b[D_h]
										
										
										*2step
										cap gen w_c=w_nc+w_cc
										gen mu_h_c=(w_nc/w_c)*mu_h_nc+(w_cc/w_c)*mu_h_cc
										sum mu_h_c [aw=w*w_c]
										gen theta2_`t2'=r(mean)-`y'
										gen theta5_`t5'=theta2_`t2'
										local ++t2
										local ++t5
										
										
										
								*********** ATs
								
							
										*IV
										gen Y_Dh_oneminusZ = Y_Dh*(1-Z)
										gen Dh_oneminusZ=D_h*(1-Z)
										reg Y_Dh_oneminusZ Dh_oneminusZ [aw=w], r cluster(hsis_racntrid)
										local y=_b[Dh_oneminusZ]
										
										
										*2step	
										sum mu_h_at [aw=w_at*w]
										gen theta2_`t2'=r(mean)-`y'
										gen theta5_`t5'=theta2_`t2'
										local ++t2
										local ++t5
										
						***************** C potential outcomes	
						
								******* C Compliers
								
									*IV
									gen Y_Dc=Y*D_c
									ivreg2 Y_Dc (D_c = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
									local y=_b[D_c]
									
									*2step
									sum mu_c_cc [aw=w_cc*w]
									gen theta3_`t3'=r(mean)-`y'
									gen theta5_`t5'=theta3_`t3'
									local ++t3
									local ++t5
								
								
								******* C Never takers
								
									*Iv
									gen Y_Dc_Z = Y_Dc*Z
									gen Dc_Z=D_c*Z
									reg Y_Dc_Z Dc_Z [aw=w], r cluster(hsis_racntrid)
									local y=_b[Dc_Z]
									
									
									*2step
									sum mu_c_cnt [aw=w_cnt*w]
									gen theta3_`t3'=r(mean)-`y'
									gen theta5_`t5'=theta3_`t3'
									local ++t3
									local ++t5
									
									
						***************** N potential outcomes	
						
								******* N Compliers
								
									*IV
									gen Y_Dn=Y*D_n
									ivreg2 Y_Dn (D_n = Z) `X' `W' [aw=w], r cluster(hsis_racntrid)
									local y=_b[D_n]
									
									*2step
									sum mu_n_nc [aw=w_nc*w]
									gen theta4_`t4'=r(mean)-`y'
									gen theta5_`t5'=theta4_`t4'
									local ++t4
									local ++t5
								
								
								******* N Never takers
								
									*Iv
									gen Y_Dn_Z = Y_Dn*Z
									gen Dn_Z=D_n*Z
									reg Y_Dn_Z Dn_Z [aw=w], r cluster(hsis_racntrid)
									local y=_b[Dn_Z]
									
									*2step
									sum mu_n_nnt [aw=w_nnt*w]
									gen theta4_`t4'=r(mean)-`y'
									gen theta5_`t5'=theta4_`t4'
									local ++t4
									local ++t5
									
		
						
					***********Save BS sample estimates
						keep theta1* theta2* theta3* theta4* theta5*
						duplicates drop
						cap append using "`bs_folder'/subpop_tests.dta"
						save "`bs_folder'/subpop_tests.dta", replace
							
							
							
							***************** END LOOP OVER TRIALS
					
				
							
							}
						}
						
						disp "Subpop estimation: Core `core', trial `b'"
						
					}
				
				}


		******************* TESTS ****************************
		foreach t of numlist 1/5 {
							
							use "`bs_folder'/subpop_tests.dta", clear
							correlate theta`t'_*, cov
							matrix V_hat=r(C)
							use "`bs_folder'/subpop_fullsamp.dta", clear
							mkmat theta`t'_*, matrix(theta_hat)
							matrix W=theta_hat*inv(V_hat)*(theta_hat')
							local Wald=W[1,1]
							local df=colsof(theta_hat)
							local p = 1-chi2(`df',`Wald')
							disp "Test= `t': Wald =`Wald', p=`p'"
								
							
				}
				stop

}

**************************************************
****** MTE ******************************
**************************************************

if `mte'==1 {

			*Result storage
			matrix T=J(1000,10,.)
			local r=1
			local c=1
			cap erase "`datapath'/mteci_results_new.dta"
			
			
			*Estimation
			foreach core of numlist 1/`cores' {
			
				foreach b of numlist 1/`trials' {
				
					qui {
					
						cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
						
									if _rc==0 {
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
					
					gen mvpf_0=((1-0.35)*34.339*PRTE)/(8 - 0.35*34.339*PRTE)
					gen mvpf_1=((1-0.35)*34.339*PRTE)/(8 - 0.75*8*s - 0.35*34.339*PRTE)
					gen mvpf_2=((1-0.35)*34.339*PRTE)/(phi_eta*(1+`eta') - 0.75*phi_eta*s - 0.35*34.339*PRTE)
			
					gen core=`core'
					gen trial=`b'
					keep core trial f PRTE mvpf_0 mvpf_1 mvpf_2
					cap append using "`datapath'/mteci_results_new.dta"
					save "`datapath'/mteci_results_new.dta", replace
				
				}
			}
			
			disp "MTE estimation: Core `core', trial `b'"
			
		}
	
	}


}

**************************************************
****** P-VAl FOR TE HET **********************
**************************************************

if `te_p'==1 {


	*Result storage
	matrix T=J(1000,20,.)
	local r=1
	local c=1
	
	
	*Estimation
	foreach core of numlist 1/`cores' {
	
		foreach b of numlist 1/`trials' {


		
			qui {
			
				cap use "`bs_folder'/kline_walters_core`core'_trial`b'_`model'.dta", clear
				
				if _rc==0 {
				
				matrix T[`r',`c']=`core'
				local ++c
				matrix T[`r',`c']=`b'
				local ++c
			
		***** GET TYPES
			sum K
			local K=r(mean)
			drop T_1
			local T=""
			if `K' >1 {
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
			}
			
		
		***** Replace small numbers of negative weights with zeros
			foreach x of varlist w_* {
				replace `x'=0 if `x'<0
			}
			egen wall=rsum(w_*)
			foreach x of varlist w_* {
				replace `x'=`x'/wall
				sum `x' [aw=w]
				local `x'=r(mean)
			}
			gen w_c=w_nc+w_cc
			gen s=w_cc/w_c
			gen any=(s>0)*(s<1)
			replace w=w*any
	
	******** ESTIMATE TE **********************************
			
			estimates use  "`bs_folder'/covsrestrict_core`core'_trial`b'_`model'.ster"
		

				***** N->H FOR NC COMPLIERS 
					foreach x of varlist `X' `W' `T' {
						sum `x' [aw=w_nc*w]
						local `x'_nc=r(mean)
					}
					
					sum v_h_nc [aw=w]
					local v_h_nc = r(mean)
					sum v_c_nc [aw=w]
					local v_c_nc = r(mean)
					
					
				**Sublate
				local interaction_coefs_nc=""
				foreach x of varlist `W' `T' {
					local interaction_coefs_nc "`interaction_coefs_nc' + _b[`x'_inter_h]*``x'_nc'"
				}
				
				
					lincom _b[D_h]  `interaction_coefs_nc' ///
					 +_b[v_h_inter_h]*`v_h_nc' ///
							+ _b[v_c_inter_h]*`v_c_nc'	
					local b_nc=r(estimate)
					
				***** N->H FOR AT's
					foreach x of varlist `X' `W' `T' {
						sum `x' [aw=w_at*w]
						local `x'_at=r(mean)
					}
					
					sum v_h_at [aw=w]
					local v_h_at = r(mean)
					sum v_c_at [aw=w]
					local v_c_at = r(mean)
					
					
				**Sublate
				local interaction_coefs_at=""
				foreach x of varlist `W' `T' {
					local interaction_coefs_at "`interaction_coefs_at' + _b[`x'_inter_h]*``x'_at'"
				}
				
				
					lincom _b[D_h]  `interaction_coefs_at' ///
					 +_b[v_h_inter_h]*`v_h_at' ///
							+ _b[v_c_inter_h]*`v_c_at'	
					local b_at=r(estimate)
					
				***** N->H FOR NNT's
					foreach x of varlist `X' `W' `T' {
						sum `x' [aw=w_nnt*w]
						local `x'_nnt=r(mean)
					}
					
					sum v_h_nnt [aw=w]
					local v_h_nnt = r(mean)
					sum v_c_nnt [aw=w]
					local v_c_nnt = r(mean)
					
					
				**Sublate
				local interaction_coefs_nnt=""
				foreach x of varlist `W' `T' {
					local interaction_coefs_nnt "`interaction_coefs_nnt' + _b[`x'_inter_h]*``x'_nnt'"
				}
				
				
					lincom _b[D_h]  `interaction_coefs_nnt' ///
					 +_b[v_h_inter_h]*`v_h_nnt' ///
							+ _b[v_c_inter_h]*`v_c_nnt'	
					local b_nnt=r(estimate)
					
					
				**************** PARAMS OF INTEREST
				matrix T[`r',`c']=`b_nc'
				local ++c
				matrix T[`r',`c']=`b_at'
				local ++c
				matrix T[`r',`c']=`b_nnt'
				local ++c
				matrix T[`r',`c']=`b_nc' - `b_nnt'
				local ++c
				matrix T[`r',`c']=`b_at' - `b_nnt'
				
					
				***************** END LOOP OVER TRIALS
		
		
				local ++r
				local c=1
				
				}
			}
			
			disp "TE het estimation: Core `core', trial `b'"
			
		}
	
	}
	
	clear
	svmat T
	keep if T1!=.
	sum

stop

}

	



