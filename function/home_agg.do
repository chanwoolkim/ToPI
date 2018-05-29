tostring row, gen(scale_num)
gen scale = ""

replace scale = "Total Score" if scale_num == "1"
replace scale = "Learning Stimulation" if scale_num == "2"
replace scale = "Development Materials" if scale_num == "3"
replace scale = "Opportunities for Variety" if scale_num == "4"
replace scale = "Lack of Hostility" if scale_num == "5"
replace scale = "Parental Warmth" if scale_num == "6"

gen scale_row = .
replace scale_row = 1 if scale == "Total Score"
replace scale_row = 2 if scale == "Learning Stimulation"
replace scale_row = 3 if scale == "Development Materials"
replace scale_row = 4 if scale == "Opportunities for Variety"
replace scale_row = 5 if scale == "Lack of Hostility"
replace scale_row = 6 if scale == "Parental Warmth"
