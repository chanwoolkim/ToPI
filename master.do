* ---- *
* Master
* Author: Chanwool Kim
* Date Created: 2 Nov 2017
* Last Update: 22 Jan 2018
* ---- *

clear all
set more off
ssc install outreg, replace
adoupdate outreg
ssc install hotdeck, replace
adoupdate hotdeck

global klmshare 			: env klmshare

global master_path			"/Users/ckim/Dropbox (Work)"

global main_path			"${master_path}/TOPI/treatment_effect"
global raw_path				"${master_path}/Data/std"
global code 				"/Users/ckim/Desktop/ToPI"

global data_ehs				"$raw_path"
global data_ehs_h			"${master_path}/Data/Harvard Dataverse Sensitive Original Data/parent_interview"
global data_ihdp 			"$raw_path"
global data_abc				"$raw_path"

global data_home			"${main_path}/data/home"
global data_labor			"${main_path}/data/labor"

global data_out				"${main_path}/out/data_basic"
global analysis_out			"${main_path}/out/analysis_basic"
global pile_out				"${main_path}/out/pile"
global homo_out				"${main_path}/out/homogenisation"
global subpop_out			"${main_path}/out/subpopulation"
global homo_subpop_out		"${main_path}/out/homo_subpop"

global pile_working			"${main_path}/working/pile"
global homo_working			"${main_path}/working/homogenisation"
global subpop_working		"${main_path}/working/subpopulation"
global homo_subpop_working	"${main_path}/working/homo_subpop"

global covariates			m_age m_edu sibling m_iq race sex gestage mf
global programs				ehscenter ehshome ehsmixed ihdplow ihdphigh abc carehv careboth
global program_name			""EHS-Center" "EHS-Home" "EHS-Mixed" "IHDP-Low" "IHDP-High" "ABC" "CARE-Home" "CARE-Both""
global measure				home labor

global ehs_type				""center" "home" "mixed" """
global ihdp_type			""high" "low" """
global care_type			""both" "hv""

global early_home_types		total warmth verbal hostility learning activity develop
global later_home_types		total learning reading verbal warmth exterior interior activity hostility

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
	include "treatment - aggregate pile (ihdp sub)"
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
	
* ----------- *
* Subpopulation

cd "${code}/subpopulation"
	include "data - subpop"
cd "${code}/subpopulation"
	include "data - subpop (merge)"
cd "${code}/subpopulation"
	include "data - subpop (table)"
cd "${code}/subpopulation"
	include "treatment - subpop (aggregate)"
cd "${code}/subpopulation"
	include "treatment - subpop (item)"

* ---------------------------- *
* Homogenisation + Subpopulation

cd "${code}/homo_subpop"
	include "data - homo_subpop (table)"
cd "${code}/homo_subpop"
	include "treatment - homo_subpop (aggregate)"
cd "${code}/homo_subpop"
	include "treatment - homo_subpop (item)"

* ------- *
* Mediation

cd "${code}/mediation"
	include "treatment - mediation"
