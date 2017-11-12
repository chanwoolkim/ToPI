* ---- *
* Master
* Author: Chanwool Kim
* Date Created: 2 Nov 2017
* Last Update: 6 Nov 2017
* ---- *

clear all
set more off
ssc install outreg, replace
adoupdate outreg

global klmshare 		: env klmshare

global master_path		"C:/Users/chanw/Dropbox (Personal)"

global main_path		"${master_path}/TOPI/treatment_effect"
global raw_path			"${master_path}/std"
global code 			"$main_path"

global data_ehs			"$raw_path"
global data_ehs_h		"${master_path}/Harvard Dataverse Sensitive Original Data/parent_interview"
global data_ihdp 		"$raw_path"
global data_abc			"$raw_path"

global data_home		"${main_path}/home_data"
global data_labor		"${main_path}/labor_data"

global basic_path		"${main_path}/analysis_basic"
global pile_path		"${main_path}/pile"
global homo_path		"${main_path}/homogenisation"
global medi_path		"${main_path}/mediation"

global covariates		m_age m_edu sibling m_iq race sex gestage mf
global programs			ehscenter ehshome ehsmixed ihdplow ihdphigh abc carehv careboth
global program_name		""EHS-Center" "EHS-Home" "EHS-Mixed" "IHDP-Low" "IHDP-High" "ABC" "CARE-Home" "CARE-Both""
global measure			home labor

global ehs_type			center home mixed
global ihdp_type		high low
global care_type		both hv

global early_home_types	total warmth verbal hostility learning activity develop
global later_home_types	total learning reading verbal warmth exterior interior activity hostility

* -------------- *
* Data Preperation

cd "${code}/data_basic"
	include "data - control"
cd "${code}/data_basic"
	include "data - participation"
cd "${code}/data_basic"
	include "data - labor"
cd "${code}/data_basic"
	include "data - home item"
cd "${code}/data_basic"
	include "data - home aggregate"
cd "${code}/data_basic"
	include "data - merge"
	
* -------- *
* Diagnostic

/*
cd "${code}/data_basic"
	include "patch - abccheck" //Check ABC scales
*/
cd "${code}/data_basic"
	include "data - description"

* ----------- *
* Main Analysis

cd "${code}/analysis_basic"
	include "treatment - longitudinal"
cd "${code}/analysis_basic"
	include "treatment - table"
	
* -- *
* Pile

cd "${code}/pile"
	include "data - aggregate pile"
cd "${code}/pile"
	include "data - item pile"
cd "${code}/pile"
	include "treatment - aggregate pile"
cd "${code}/pile"
	include "treatment - item pile"
cd "${code}/pile"
	include "treatment - pile (comparison)"
	
* ------------ *
* Homogenisation

cd "${code}/homogenisation"
	include "data - homo"
cd "${code}/homogenisation"
	include "data - homo (merge)"
cd "${code}/homogenisation"
	include "data - homo (table)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (table)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (aggregate)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (item)"
cd "${code}/homogenisation"
	include "treatment - homogenisation (comparison)"
cd "${code}/homogenisation"
	include "comparison - aggregate"
	
* ------- *
* Mediation

cd "${code}/mediation"
	include "treatment - mediation"
