tostring row, gen(scale_num)
gen scale = ""

replace scale = "PPVT" if scale_num == "1"
replace scale = "Stanford-Binet" if scale_num == "2"
