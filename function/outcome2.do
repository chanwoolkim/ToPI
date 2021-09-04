tostring row, gen(scale_num)
gen scale = ""

replace scale = "PPVT" if scale_num == "1"
replace scale = "Stanford-Binet" if scale_num == "2"
replace scale = "Non-cognitive" if scale_num == "3"
