
********* THIS PROGRAM FORMATS THE CENTER CHARACTERISTIC DATA ***********

***************************************************************
******** SET UP STATA *****************************************
***************************************************************

*Basic Stata setup
clear all
set mem 500m
set more off

*Set working directories
local drive="/Users/Chris/projects/head_start"
local dict="`drive'/site_heterogeneity/programs/dictionaries"
local raw="`drive'/data/raw_data"
local statafiles="`drive'/data/stata_files"


*Switches to choose which parts of program to run
local readraw=1
local setup=1


*************************************************************
******* READ IN RAW FILES USING DICTIONARIES ****************
************************************************************

if `readraw'==1 {

	cd "`raw'"

	foreach f in 01 09 {
	
		clear
		infile using "`dict'/da29462-00`f'_v2.dct"
		compress
		save "`statafiles'/da29462-00`f'_v2.dta", replace
	}

}

*******************************************************
******* SET UP CENTER AND TEACHER FILES ****************
*******************************************************

if `setup'==1 {


	
	**Process child experiences file
	use "`statafiles'/da29462-0001_v2.dta", clear
	
	gen teacher_aa=d_vl3_degaa==3 if d_vl3_degaa!=.
	gen parent_care=d_vl3_degaa==1 if d_vl3_degaa!=.
	gen teacher_ba=d_vl3_degba==3 if d_vl3_degba!=.
	gen staff_kidperstaff=d_childstaffratio if d_childstaffratio!=.
	gen arrangement=""
	replace arrangement="H" if d_focarr1==7 & d_focarr1!=.
	replace arrangement="P" if d_focarr1==1 & d_focarr1!=.
	replace arrangement="N" if d_focarr1!=1 & d_focarr1!=7 & d_focarr1!=.

	gen competition1 = (5 - d_cd_competition)*(d_cd_competition>2) if d_cd_competition!=.
	gen competition2 = 3-d_cd_competition_rev if d_cd_competition_rev!=.
	gen quality = d_qualcomp
	
	keep hsis_childid teacher_aa parent_care teacher_ba staff_kidperstaff ///
		arrangement competition1 competition2 quality
		ren teacher_ba staff_bach 
	save "`statafiles'/child_experiences.dta", replace
	
	

	**Bring in center file for Spring '03
	use "`statafiles'/da29462-0009_v2.dta", clear
	**Code key center-level variables

	
		*Classification of center
		gen type_hs = c5hsnhs == 1 if c5hsnhs!=.
		gen type_indep = c5indep ==1 if c5indep!=8 & c5indep!=9 & c5indep!=.
		gen type_commun = c5commun ==1 if c5commun!=8 & c5commun!=9 & c5commun!=.
		gen type_govt = c5feder==2 if c5feder!=8 & c5feder!=9 & c5feder!=.
		gen type_chain=c5nation==3 if c5nation!=8 & c5nation!=9 & c5nation!=.
		gen type_public=c5public==4 if c5public!=8 & c5public!=9 & c5public!=.
		gen type_private=c5priv==5 if c5priv!=8 & c5priv!=9 & c5priv!=.
		gen type_other=c5other==6 if c5other!=8 & c5other!=9 & c5other!=.
		
		*Funding sources
		local t=1
		foreach x in headst parfee fdprog stprek ccsubs othfund none {
			gen funding_`x' = c5`x'==`t' if c5`x'!=8 & c5`x'!=9 & c5`x'!=.
			local ++t
		}
	
		*Center director experience
		gen years_hs=c3yrhs if c3yrhs<96 & c3yrhs!=.
		replace years_hs=0 if c3yrhs==96
		gen years_nonhs=c5nonhs if c5nonhs<99 & c5nonhs!=.
		gen staff_directorexp = years_hs +years_nonhs
		
		
		
	
		*Teacher education
		replace c5bachel=. if c5bachel==999
		gen staff_bach_surv=c5bachel/100
		
		*Teacher certification
		replace c5tchlic=. if c5tchlic==998 | c5tchlic==999
		gen staff_cert=c5tchlic/100
		
		*Class size
		replace c1lead=. if c1lead==99
		replace c5asstch=. if c5asstch==999
		replace c5paidt=. if c5paidt==999
		replace c5capac=. if c5capac==9999
		gen staff_kidperstaff_surv = (c5capac)/(c1lead + c5asstch + c5paidt)
		
		*Instruction time
		replace c5full=. if c5full==9
		gen serv_fullday=c5full==1 if c5full!=.
		
		*High/Scope curriculum
		gen curric_hscope=c1curnam==2 if c1curnam!=99 & c1curnam!=.
		
		*Home visiting
		gen visits_3=c5numvis==3 if c5numvis!=6 & c5numvis!=9 & c5numvis!=.
			
		*Competition
		gen competition3=c5compet if c5compet!=8 & c5compet!=9 & c5compet!=.
		gen competition_high=competition3==1 if competition3!=.
		gen competition_med=competition3<3 if competition3!=.
		
		*Transportation
		gen transportation=c5tranp==1 if c5tranp!=9 & c5tranp!=.
		
		*Easy to replace teachers
		gen replacements_difficulty=c1find if c1find!=8 & c1find!=9 & c1find!=.
		gen replacements_hard=c1find>2 if c1find!=8  & c1find!=9 & c1find!=.
		
		*Speak native language
		gen native_language=c5speak if c5speak!=9 & c5speak!=.
		gen native_language_yes=c5speak<3 if c5speak!=9 & c5speak!=.
		
			
		*Merge on observations on other vars
		merge 1:1 hsis_childid using "`statafiles'/child_experiences.dta"
		drop _merge
		
		save "`statafiles'/child_experiences_final.dta", replace
		
	**Reshape to one observation per treatment center
		
		*Keep treated students in Head Start centers
		keep if hsis_caresid!=.
		keep if childresultgroup == 2 & crossover!=1 & noshow!=1
		keep if c5hsnhs==1

		*Keep care setting attended most frequently by treated students at each site
		
			*Keep students going to most commonly attended center;
			egen groupvar=group(hsis_racntrid)
			bys groupvar hsis_caresid: gen N_center=_N
			bys groupvar: egen N_center_max=max(N_center)			
			sort groupvar N_center
			bys groupvar: gen in_max_center=hsis_caresid==hsis_caresid[_N]
			sum in_max_center
			keep if N_center==N_center_max
			
			*Set to missing if don't know which center of RA it is
			foreach x in native_language native_language_yes replacements_difficulty replacements_hard transportation competition3 competition1 competition2 competition_high competition_med staff_bach teacher_aa staff_cert staff_directorexp staff_kidperstaff visits_3 serv_fullday curric_hscope quality {
				bys hsis_racntrid: egen sd_`x'=sd(`x')
				bys hsis_racntrid: egen c_`x'=mean(`x')
				*replace c_`x'=. if sd_`x'!=0
				
			}
			

			*Reshape to one observation per site
			bys groupvar: keep if _n==1

		replace c_competition2=0 if c_competition2<1 & c_competition2!=.
		replace c_competition2=1 if c_competition2>1 & c_competition2<2
		
		
	**Keep relevant variables
	keep hsis_racntrid c_*
	sort hsis_racntrid
	save "`statafiles'/center_characteristics.dta", replace

}


