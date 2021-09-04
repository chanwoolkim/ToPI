tostring row, gen(scale_num)
gen scale = ""

replace scale = "Total Score" if scale_num == "1"
replace scale = "Video Interaction" if scale_num == "2"

gen scale_row = .
replace scale_row = 1 if scale == "Total Score"
replace scale_row = 2 if scale == "Video Interaction"
