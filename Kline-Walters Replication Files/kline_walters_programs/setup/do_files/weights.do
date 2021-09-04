
********* THIS PROGRAM FORMATS THE WEIGHT DATA ***********

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

*************************************************************
******* READ IN RAW WEIGHT FILE ****************************
************************************************************



	cd "`raw'"

		clear
		infile using "`dict'/da29462-0029.dct"
		compress
		sort hsis_childid
		save "`statafiles'/child_weights.dta", replace

