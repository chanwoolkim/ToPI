tostring row, gen(scale_num)
gen scale = ""

replace scale = "Attention/Arousal" if scale_num == "1"
replace scale = "Emotional Regulation" if scale_num == "2"
replace scale = "Orientation/Engagement" if scale_num == "3"

gen scale_row = .
replace scale_row = 1 if scale == "Attention/Arousal"
replace scale_row = 2 if scale == "Emotional Regulation"
replace scale_row = 3 if scale == "Orientation/Engagement"
