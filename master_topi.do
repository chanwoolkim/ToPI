* ------------------ *
* MASTER FILE
* Author: Chanwool Kim
* ------------------ *

clear all
set more off

global master_path		"~/Dropbox/Research/TOPI"
global code_path 		"${master_path}/code"
global data_raw		    "${master_path}/Original datasets"
global data_working		"${master_path}/working"
global out				"${master_path}/../../Apps/Overleaf/ToPI/EHStoABC/Results"
global git_out			"${code_path}/output_backup"

global covariates		m_age m_edu sibling m_iq black sex gestage mf
global programs			ehs abc

set seed 2022

* [UNMUTE THIS IF YOU DO NOT HAVE RELEVANT PACKAGES]
* cd $code_path
* ssc install estout, replace
* ssc install ivreg2, replace
* ssc install ranktest, replace
* net install github, from("https://haghish.github.io/github/")
* github install haghish/rcall, stable

* -------------- * 
* Data Preparation
* -------------- *

* Begin from: std-ehs, append-abccare
cd "${code_path}/data_basic"
	include "data_control"
cd "${code_path}/data_basic"
	include "data_labor"
cd "${code_path}/data_basic"
	include "data_instruments"
*cd "${code_path}/data_basic"
*	include "data_ehs_participation_explore" // exploring EHS participation
cd "${code_path}/data_basic"
	include "data_participation"
cd "${code_path}/data_basic"
	include "data_outcome"
cd "${code_path}/data_basic"
	include "data_merge"
cd "${code_path}/data_basic"
	include "data_merge_new"

* ------ * 
* Analysis
* ------ *

cd "${code_path}/analysis"
rcall : source("preliminary.R")
rcall : source("descriptive_table_tex.R")
rcall : source("analysis_table.R")
rcall : source("analysis_table_tex.R")
rcall : source("analysis_table_tex_appendix.R")
rcall : source("analysis_grpah.R")
