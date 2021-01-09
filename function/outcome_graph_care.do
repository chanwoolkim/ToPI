graph dot carebothRinsig carebothR0_1 carebothR0_05 ///
		  carehomeRinsig carehomeR0_1 carehomeR0_05, ///
marker(1,msize(large) msymbol(O) mlc(navy) mfc(navy*0) mlw(thick)) marker(2,msize(large) msymbol(O) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(3,msize(large) msymbol(O) mlc(navy) mfc(navy) mlw(thick)) ///
marker(4,msize(large) msymbol(T) mlc(navy) mfc(navy*0) mlw(thick)) marker(5,msize(large) msymbol(T) mlc(navy) mfc(navy*0.5) mlw(thick)) marker(6,msize(large) msymbol(T) mlc(navy) mfc(navy) mlw(thick)) ///
over(scale, label(labsize(large)) sort(scale_row)) ///
legend (order (3 "CARE-Both" 6 "CARE-Home" ) size(medsmall)) yline(0) ylabel(#7, labsize(medsmall)) ///
ylabel($outcome_axis_range2) ysize(1) xsize(2) ///
graphregion(fcolor(white)) bgcolor(white)
