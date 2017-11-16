* --------------------------------------- *
* Preliminary data preparation - HOME items
* Author: Chanwool Kim
* Date Created: 1 Mar 2017
* Last Update: 5 Nov 2017
* --------------------------------------- *

clear all

* -------------- *
* Early Head Start

cd "$data_ehs_h"

* Merge all ages

use "00097_Early_Head_Start_B1P_ruf.dta", clear

forvalues n = 2/5 {
	merge 1:1 id using "00097_Early_Head_Start_B`n'P_ruf.dta", nogen nolabel
}

* Rename and label variables
* Recode, especially ordering categorical to 0-1
* (Note: will only do obvious cases for now)

foreach n of numlist 1/4 {
	rename b`n'p513		home`n'_1
	label var home`n'_1 "In past month how often has F looked after FC"
	rename b`n'p525		home`n'_2
	label var home`n'_2	"In the past month how often has F looked after FC"
	rename b`n'p542		home`n'_3
	label var home`n'_3	"In the past month how often has father figure taken care of FC"
	
	forvalues i = 1/3 {
		recode home`n'_`i' (1 = 4) (2 = 3) (3 = 2) (4 = 1) (5 = 0)
		replace home`n'_`i' = home`n'_`i'/4
	}
	
	rename b`n'p904		home`n'_4
	label var home`n'_4	"In the past week have you or anyone in the household spanked FC for misbehaving"
}

foreach n of numlist 1 2 4 5 {
	rename b`n'p212		home`n'_5
	label var home`n'_5	"Since FC's birth/first birthday how many times has FC gone for well-baby checkups"
	replace home`n'_5 = (home`n'_5 - 1)/4
}

foreach n of numlist 1/3 {
	rename b`n'p61		home`n'_6
	label var home`n'_6	"Do you have a television"
	rename b`n'p803		home`n'_7
	label var home`n'_7	"About how many books do you have in the house (10 or more)"
	recode home`n'_7 (1 = 0) (2 3 = 1)
	rename b`n'p707c	home`n'_8
	label var home`n'_8	"In the past month how many times have you: sing nursery rhymes like 'Jack and Jill' with him/her"
	rename b`n'p707d	home`n'_9
	label var home`n'_9	"In the past month how many times have you: sing songs with him/her"
	rename b`n'p707e	home`n'_10
	label var home`n'_10	"In the past month how many times have you: dance with him/her"
	rename b`n'p707f	home`n'_11
	label var home`n'_11	"In the past month how many times have you: read stories to child (3/week)"
	recode home`n'_11 (4 5 6 = 0) (2 3 = 1)
	rename b`n'p707g	home`n'_12
	label var home`n'_12	"In the past month how many times have you: tell stories to him/her"
	rename b`n'p707h	home`n'_13
	label var home`n'_13	"In the past month how many times have you: play outside (4/week)"
	recode home`n'_13 (3 4 5 6 = 0) (2 = 1)
	rename b`n'p707i	home`n'_14
	label var home`n'_14	"In the past month how many times have you: play chasing games"
	
	foreach i of numlist 8/10 12 14 {
		recode home`n'_`i' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (6 = 0)
		replace home`n'_`i' = home`n'_`i'/5
	}
}

foreach n of numlist 1 2 {
	rename b`n'pa01a	home`n'_15
	label var home`n'_15	"What kind of toys does FC have: push or pull toys"
	rename b`n'pa01b	home`n'_16
	label var home`n'_16	"What kind of toys does FC have: muscle toys"
	rename b`n'pa01c	home`n'_17
	label var home`n'_17	"What kind of toys does FC have: piece toys"
	rename b`n'pa01d	home`n'_18
	label var home`n'_18	"What kind of toys does FC have: block toys"
	rename b`n'pa01e	home`n'_19
	label var home`n'_19	"What kind of toys does FC have: soft or role-playing toys"
	rename b`n'pa01f	home`n'_20
	label var home`n'_20	"What kind of toys does FC have: number of books"
	rename b`n'pa01g	home`n'_21
	label var home`n'_21	"What kind of toys does FC have: music toys"
	rename b`n'pa01h	home`n'_22
	label var home`n'_22	"What kind of toys does FC have: ride toys"
	
	forvalues i = 15/22 {
		recode home`n'_`i' (1 = 0) (2 3 4 = 1)
	}
	
	rename b`n'pa02a	home`n'_23
	label var home`n'_23	"What furniture does FC have: a highchair (24m: or booster chair)"
	rename b`n'pa02b	home`n'_24
	label var home`n'_24	"What furniture does FC have: a child-sized table and chair"
	rename b`n'pa03		home`n'_25
	label var home`n'_25	"Where are FC's toys usually kept"
	rename b`n'pa0401	home`n'_26
	label var home`n'_26	"What do you do when FC gets bored and isn't sure what to do: nothing"
	rename b`n'pa0402	home`n'_27
	label var home`n'_27	"What do you do when FC gets bored and isn't sure what to do: give him/her a cookie or something to eat"
	rename b`n'pa0403	home`n'_28
	label var home`n'_28	"What do you do when FC gets bored and isn't sure what to do: put him/her to bed for a nap"
	rename b`n'pa0404	home`n'_29
	label var home`n'_29	"What do you do when FC gets bored and isn't sure what to do: let him/her figure out what he wants to do"
	rename b`n'pa0405	home`n'_30
	label var home`n'_30	"What do you do when FC gets bored and isn't sure what to do: picks him up"
	rename b`n'pa0406	home`n'_31
	label var home`n'_31	"What do you do when FC gets bored and isn't sure what to do: gets out toy"
	rename b`n'pa0407	home`n'_32
	label var home`n'_32	"What do you do when FC gets bored and isn't sure what to do: plays with child"
	rename b`n'pa0408	home`n'_33
	label var home`n'_33	"What do you do when FC gets bored and isn't sure what to do: turn on TV/video"
	rename b`n'pa0409	home`n'_34
	label var home`n'_34	"What do you do when FC gets bored and isn't sure what to do: read to him"
	rename b`n'pa0410	home`n'_35
	label var home`n'_35	"What do you do when FC gets bored and isn't sure what to do: other (specify)"
	rename b`n'pa0411	home`n'_36
	label var home`n'_36	"What do you do when FC gets bored and isn't sure what to do: takes child outside"
	rename b`n'pa0412	home`n'_37
	label var home`n'_37	"What do you do when FC gets bored and isn't sure what to do: gives child bath"
	rename b`n'pa0413	home`n'_38
	label var home`n'_38	"What do you do when FC gets bored and isn't sure what to do: child does not get bored"
	rename b`n'pa05		home`n'_39
	label var home`n'_39	"Do you think it's a good idea to have toys around that are a little advanced for FC"
	recode home`n'_39 (2 = 0)
	rename b`n'pa06		home`n'_40
	label var home`n'_40	"If someone gives FC a toy that is for a slightly older child what do you do"
	rename b`n'pa08		home`n'_41
	label var home`n'_41	"Does FC ever want to make a mess on clothes, table, floor"
	rename b`n'pa09		home`n'_42
	label var home`n'_42	"How do you feel about such messy play"
	recode home`n'_42 (2 = 0)	
	rename b`n'pa10		home`n'_43
	label var home`n'_43	"Do you have a pet such as a dog, cat, goldfish or turtle"
	rename b`n'pa11		home`n'_44
	label var home`n'_44	"When doing housework and FC wants attention what do you do: talk to child"
	recode home`n'_44 (1 3 4 5 = 0) (2 = 1)
	rename b`n'pa12		home`n'_45
	label var home`n'_45	"Did parent respond positively do praise of the child"
	rename b`n'pf01		home`n'_46
	label var home`n'_46	"Parent spontaneously vocalized to FC twice"
	rename b`n'pf02		home`n'_47
	label var home`n'_47	"Parent responded verbally to FC's vocalizations"
	rename b`n'pf03		home`n'_48
	label var home`n'_48	"Parent told FC name of an object or person during visit"
	rename b`n'pf04		home`n'_49
	label var home`n'_49	"Parent's speech was audible and distinct"
	rename b`n'pf05		home`n'_50
	label var home`n'_50	"Parent initiated verbal exchanges with visitor"
	rename b`n'pf06		home`n'_51
	label var home`n'_51	"Parent conversed freely and easily" 
	rename b`n'pf07		home`n'_52
	label var home`n'_52	"Parent spontaneously praised FC at least twice"
	rename b`n'pf08		home`n'_53
	label var home`n'_53	"Parent's voice conveys positive feeling towards FC"
	rename b`n'pf09		home`n'_54
	label var home`n'_54	"Parent caressed or kissed FC at least once"
	rename b`n'pf10		home`n'_55
	label var home`n'_55	"Parent did not shout at FC"
	rename b`n'pf11		home`n'_56
	label var home`n'_56	"Parent did not express annoyance with or hostility towards FC"
	rename b`n'pf12		home`n'_57
	label var home`n'_57	"Parent neither spanked nor slapped FC during visit"
	rename b`n'pf13		home`n'_58
	label var home`n'_58	"Parent did not scold or criticize FC during visit"
	rename b`n'pf14		home`n'_59
	label var home`n'_59	"Parent did not interfere or restrict more FC more than 3 times"
	rename b`n'pf15		home`n'_60
	label var home`n'_60	"Child's play environment is safe"
	rename b`n'pf16		home`n'_61
	label var home`n'_61	"Parent provided toys for FC during visit"
	rename b`n'pf17		home`n'_62
	label var home`n'_62	"Parent kept FC in visual range when FC was not cared for by someone else, looked at FC often"
	rename b`n'p707j	home`n'_63
	label var home`n'_63	"In the past month how many times have you: have relatives visit you"
	rename b`n'p707k	home`n'_64
	label var home`n'_64	"In the past month how many times have you: take child with you to visit relatives (1/month)"
	recode home`n'_64 (6 = 0) (2 3 4 5 = 1)
	rename b`n'p707l	home`n'_65
	label var home`n'_65	"In the past month how many times have you: take child grocery shopping with you"
	recode home`n'_65 (6 5 = 0) (2 3 4 = 1)
	rename b`n'p707m	home`n'_66
	label var home`n'_66	"In the past month how many times have you: take child with you to a religious services"
	rename b`n'p707n	home`n'_67
	label var home`n'_67	"In the past month how many times have you: take child with you to an activity at a community center"
	rename b`n'p707o	home`n'_68
	label var home`n'_68	"In the past month how many times have you: go to a restaurant or out to eat with child"
	rename b`n'p707p 	home`n'_69
	label var home`n'_69	"In the past month how many times have you: go to a public place like a zoo or museum with child"
	rename b`n'p707q	home`n'_70
	label var home`n'_70	"In the past month how many times have you: try to tease child to get him/her to laugh"
	rename b`n'p811		home`n'_71
	
	foreach i of numlist 63 66/70 {
		recode home`n'_`i' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (6 = 0)
		replace home`n'_`i' = home`n'_`i'/5
	}

	label var home`n'_71	"In the past month how many people have helped you and watched FC when you were away from home and couldn't take FC with you"
	replace home`n'_71 = (home`n'_71 - 1)/3
}

rename b1pa02c	home1_72
label var home1_72	"What furniture does FC have: a playpen"
rename b1pa02d	home1_73
label var home1_73	"What furniture does FC have: a booster chair"
rename b1pa02e	home1_74
label var home1_74	"What furniture does FC have: any mobiles"
rename b1p707a	home1_75
label var home1_75	"In the past month how many times have you: play peek-a-boo with child"
rename b1p707b	home1_76
label var home1_76	"In the past month how many times have you: play patty cake with child"

foreach i of numlist 75 76 {
	recode home1_`i' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (6 = 0)
	replace home1_`i' = home1_`i'/5
}

rename b1pa07	home1_77
label var home1_77	"If FC is trying to feed himself and takes the spoon, but can't get food in his mouth what do you usually do"
replace home1_77 = (home1_77 - 1)/2

rename b2pa07	home2_72
label var home2_72	"If FC is trying to dress himself and picks up clothes but isn't able to put them on what do you usually do"

foreach n of numlist 3/5 {
	rename b`n'pfa03	home`n'_72
	label var home`n'_72	"Parent spontaneously vocalized to FC twice"
	rename b`n'pfa04	home`n'_73
	label var home`n'_73	"Parent responded verbally to FC's vocalizations"
	rename b`n'pfa06	home`n'_74
	label var home`n'_74	"Parent spontaneously praised FC at least twice"
	rename b`n'pfa07	home`n'_75
	label var home`n'_75	"Parent caressed or kissed FC at least once"
	rename b`n'pfa08	home`n'_76
	label var home`n'_76	"Caregiver sets up situation that allows child to 'Show Off' during visit"
	rename b`n'pfa10	home`n'_77
	label var home`n'_77	"Mother uses complex sentence structure and some long words in conversing"
	rename b`n'pfb01	home`n'_78
	label var home`n'_78	"Structural safety of home"
	rename b`n'pfb04	home`n'_79
	label var home`n'_79	"Adequate living space"
	rename b`n'pfb06	home`n'_80
	label var home`n'_80	"Overall physical organization"
	rename b`n'pfb07	home`n'_81
	label var home`n'_81	"Cleanliness"
	rename b`n'pfb09	home`n'_82
	label var home`n'_82	"Condition of street"
}

foreach n of numlist 3 4 {
	forvalues i = 78/82 {
		replace home`n'_`i' = (home`n'_`i' - 1)/2
	}
	
	rename b`n'p905_1	home`n'_83
	label var home`n'_83	"What would you do if your child got angry and hit you: hit him/her back"
	rename b`n'p905_2	home`n'_84
	label var home`n'_84	"What would you do if your child got angry and hit you: send him/her to his/her room"
	rename b`n'p905_3	home`n'_85
	label var home`n'_85	"What would you do if your child got angry and hit you: spank him/her"
	rename b`n'p905_4	home`n'_86
	label var home`n'_86	"What would you do if your child got angry and hit you: talk to him/her"
	rename b`n'p905_5	home`n'_87
	label var home`n'_87	"What would you do if your child got angry and hit you: ignore it"
	rename b`n'p905_6	home`n'_88
	label var home`n'_88	"What would you do if your child got angry and hit you: give him/her household chore"
	rename b`n'p905_7	home`n'_89
	label var home`n'_89	"What would you do if your child got angry and hit you: hold child's hands until he/she was calm"
	rename b`n'p905_8	home`n'_90
	label var home`n'_90	"What would you do if your child got angry and hit you: other (specify)"
	rename b`n'p905_9	home`n'_91
	label var home`n'_91	"What would you do if your child got angry and hit you: yell at child"
	rename b`n'pfa05	home`n'_92
	label var home`n'_92	"Parent usually responds verbally to child's talking"
	rename b`n'pfa11	home`n'_93
	label var home`n'_93	"Parent did not scold or criticize FC more than once during visit"
	rename b`n'pfa12	home`n'_94
	label var home`n'_94	"Caregiver does not use physical restraint, shake, grab or pinch child during visit"
	rename b`n'pfa13	home`n'_95
	label var home`n'_95	"Parent neither slapped nor spanked FC during visit"
	rename b`n'pfb08	home`n'_96
	label var home`n'_96	"Outside play environment"
	replace home`n'_96 = (home`n'_96 - 1)/2
	rename b`n'pfa01	home`n'_97
	label var home`n'_97	"Parent uses correct grammar and pronunciation"

}

foreach n of numlist 3 5 {
	rename b`n'pfa02	home`n'_98
	label var home`n'_98	"Parent's voice conveys positive feeling towards FC"
}

foreach n of numlist 4 5 {
	rename b`n'pf13		home`n'_99
	label var home`n'_99	"Parent encourages child to talk and takes time to listen"
	rename b`n'pfb02a	home`n'_100
	label var home`n'_100	"Interior of apartment/home is not dark or perceptually monotonous"
	replace home`n'_100 = (home`n'_100 - 1)/2
}

rename b3p61b	home3_101
label var home3_101	"How many hours does FC watch TV on weekend day"
rename b3p61c	home3_102
label var home3_102	"How much time does FC watch TV on weekday"
rename b3p69	home3_103
label var home3_103	"How much choice does FC have in deciding what to eat"
recode home3_103 (1 = 3) (2 = 2) (3 = 1) (4 = 0)
replace home3_103 = home3_103/3
rename b3p7_2a	home3_104
label var home3_104	"How often have other family members done the following: read to FC"
rename b3p7_2b	home3_105
label var home3_105	"How often have other family members done the following: taken FC on outing"
rename b3p7_3	home3_106
label var home3_106	"How often have family members taken FC to museum"
replace home3_106 = home3_106/4
rename b3p7_4	home3_107
label var home3_107	"How many people have watched FC in last month"
rename b3p712	home3_108
label var home3_108	"How many children's books does FC own?"
recode home3_108 (1 2 = 0) (3 = 1)
rename b3p713	home3_109
label var home3_109	"Does FC have use of tape recorder, etc.?"
rename b3p714a	home3_110
label var home3_110	"What have you helped FC learn: numbers"
rename b3p714b	home3_111
label var home3_111	"What have you helped FC learn: alphabet"
rename b3p714c	home3_112
label var home3_112	"What have you helped FC learn: colors"
rename b3p714d	home3_113
label var home3_113	"What have you helped FC learn: shapes and sizes"
rename b3pfa09	home3_114
label var home3_114	"Mother introduces interviewer to child"
rename b3pfb02	home3_115
label var home3_115	"Home decor"
rename b3pfb03	home3_116
label var home3_116	"Child friendly home"
rename b3pfb05	home3_117
label var home3_117	"Interpersonal space"

forvalues i = 115/117 {
	replace home3_`i' = (home3_`i' - 1)/2
}

rename b3p707r	home3_118
label var home3_118	"In the past month how many times have you: take child on outing (2/month)"
recode home3_118 (5 6 = 0) (2 3 4 = 1)
rename b3p707m	home3_119
label var home3_119	"In the past month how many times have you: take child with you to a religious service"
rename b3p707s	home3_120
label var home3_120	"In the past month how many times have you: take child to museum"
recode home3_120 (6 = 0) (2 3 4 5 = 1)
rename b3p707q	home3_121
label var home3_121	"In the past month how many times have you: try to tease child to get him/her to laugh"

foreach i of numlist 104 105 119 121 {
	recode home3_`i' (1 = 5) (2 = 4) (4 = 2) (5 = 1) (6 = 0)
	replace home3_`i' = home3_`i'/5
}

rename b4pb04	home4_101
label var home4_101	"How many children's books does FC own?"
replace home4_101 = (home4_101 - 1)/3
rename b4p716	home4_102
label var home4_102	"Have you started teaching Child the alphabet"
rename b4p717	home4_103
label var home4_103	"How much choice is Child allowed in deciding what foods he/she eats at breakfast and lunch"
recode home4_103 (1 = 3) (3 = 1) (4 = 0)
replace home4_103 = home4_103/3
rename b4p718	home4_104
label var home4_104	"In the past year have you or any other family member taken or arranged to take child to any type of museum"
rename b4pf01	home4_105
label var home4_105	"Child has toys that teach colors, sizes and shapes"
rename b4pf02	home4_106
label var home4_106	"Child has three or more puzzles"
rename b4pf03	home4_107
label var home4_107	"Child has use of a record player at home and at least five children's records on tape"
rename b4pf04	home4_108
label var home4_108	"Child has toys or games permitting free expression"
rename b4pf05	home4_109
label var home4_109	"Child has toys or games necessitating refined movements"
rename b4pf06	home4_110
label var home4_110	"Child has toys or games facilitating learning numbers"
rename b4pf07	home4_111
label var home4_111	"Child has at least ten children's books"
rename b4pf08	home4_112
label var home4_112	"Child has toys that teach the names of animals"
rename b4pf09	home4_113
label var home4_113	"Child has a real or toy musical instrument"
rename b4pf10	home4_114
label var home4_114	"At least 10 books appropriate for adults are visible in the house/apartment"

forvalues i = 105/114 {
	recode home4_`i' (2 = .)
}

rename b4pf11	home4_115
label var home4_115	"Parent teaches child simple verbal manners"
rename b4pf14	home4_116
label var home4_116	"When speaking of child, caregiver's voice conveys positive feeling"
rename b4pf15	home4_117
label var home4_117	"Child's art work is displayed someplace in the house"
recode home4_117 (2 = .)

rename b5p467	home5_101
label var home5_101	"How many children's books does FC own?"
replace home5_101 = 1 if home5_101 >= 3
replace home5_101 = 1 if home5_101 >= 0 & home5_101 <= 2

rename b5pfa0f	home5_102
label var home5_102	"Parent uses some term of endearment when talking to child at least twice"
rename b5pfa0i	home5_103
label var home5_103	"Parent shows some positive emotional responses to praise of child by visitor"
rename b5pfa10b	home5_104
label var home5_104	"Parent initiated verbal exchanges with visitor"
rename b5pfa10c	home5_105
label var home5_105	"Parent conversed freely and easily"
rename b5pfa10d	home5_106
label var home5_106	"Parent appears to readily understand the interviewer's questions"
rename b5pfa11a	home5_107
label var home5_107	"Parent does not scold/criticize Child more than once"
rename b5pfa13a	home5_108
label var home5_108	"Parent does not slap or spank child during visit"
rename b5pfa14a	home5_109
label var home5_109	"Parent does not shout at child during visit"
rename b5pfa15a	home5_110
label var home5_110	"Parent does not express annoyance/hostility toward child"

forvalues i = 107/110 {
	recode home5_`i' (1 = 0) (0 = 1)
}

rename b5pfb06f	home5_111
label var home5_111	"House is not overly noisy – from noise inside the house"
rename b5pfb06g	home5_112
label var home5_112	"House is not overly noisy – from noise outside the house"
rename b5pfb06h	home5_113
label var home5_113	"There are no obvious sings of recent alcohol/drug consumption"
rename b5pfb09a	home5_114
label var home5_114	"Condition of most housing in the face block"
rename b5pfb09c	home5_115
label var home5_115	"Is there garbage in the street"
rename b5pfb09d	home5_116
label var home5_116	"Are there drug-related paraphernalia, condoms, beer, liquor containers in the street"

forvalues i = 114/116 {
	recode home5_`i' (1 = 3) (3 = 1) (4 = 0)
	replace home5_`i' = home5_`i'/3
}

rename b5pfb09e	home5_117
label var home5_117	"Volume of traffic on face-block"
recode home5_117 (1 = .) (2 = 4) (4 = 2) (5 = 1) (6 = 0)
replace home5_117 = home5_117/4

rename b5pfb09f	home5_118
label var home5_118	"Are there children playing on the sidewalks"
replace home5_118 = (home5_118 - 1)/2
rename b5pfb09g	home5_119
label var home5_119	"Is there hostile activity in the street"
recode home5_119 (1 = 3) (3 = 1) (4 = 0)
replace home5_119 = home5_119/3
rename b5pfb09h	home5_120
label var home5_120	"How did you feel parking/walking to the house"
recode home5_120 (1 = 4) (2 = 3) (3 = 2) (4 = 1) (5 = 0)
replace home5_120 = home5_120/4

rename home1_*	home14_*
rename home2_*	home24_*
rename home3_*	home36_*
rename home4_*	home48_*
rename home5_*	home120_*

keep id home*_*

* Rename so that variable numbering is in _n order

forvalues i = 6/14 {
	local newi = `i' - 1
	rename home36_`i' home36_`newi'
}

forvalues i = 72/98 {
	local newi = `i' - 58
	rename home36_`i' home36_`newi'
}

forvalues i = 101/121 {
	local newi = `i' - 60
	rename home36_`i' home36_`newi'
}

forvalues i = 72/97 {
	local newi = `i' - 66
	rename home48_`i' home48_`newi'
}

forvalues i = 99/117 {
	local newi = `i' - 67
	rename home48_`i' home48_`newi'
}

rename home120_5	home120_1

forvalues i = 72/82 {
	local newi = `i' - 70
	rename home120_`i'	home120_`newi'
}

forvalues i = 98/120 {
	local newi = `i' - 85
	rename home120_`i'	home120_`newi'
}

* Recode: home14_72-home14_74 complemented (OR)
gen home14_727374 = .
replace home14_727374 = 0 if home14_72 == 0 | home14_73 == 0 | home14_74 == 0
replace home14_727374 = 1 if home14_72 == 1 | home14_73 == 1 | home14_74 == 1

* Recode: home36_52-home36_53 complemented (AND)
gen home36_5253 = .
replace home36_5253 = 0 if home36_52 == 0 | home36_53 == 0
replace home36_5253 = 1 if home36_52 == 1 & home36_53 == 1

* Recode missings
* (Note: will kill values above 1 for now, though this kills many continuous variables)

foreach v of varlist home*_* {
	replace `v' = . if `v' < 0 | `v' > 1
}

cd "$data_home"
save ehs-home-item, replace

* ----------------------------------- *
* Infant Health and Development Program

cd "$data_ihdp"
use "merge-ihdp.dta", clear

rename ihdp	id

foreach num of numlist 1/45 {
	rename va`num'_f22	home12_`num'
	recode home12_`num' (2 = 0)
}

foreach num of numlist 1/55 {
	rename v`num'_f56	home36_`num'
}

#delimit ;
keep id
home12_*
home36_*
;
#delimit cr

cd "$data_home"
save ihdp-home-item, replace

* --------- *
* Abecedarian

cd "$data_abc"
use "append-abccare.dta", clear

* Recode 2 to 0

local age0to3	6 18 30
foreach age of local age0to3 {
	foreach n of numlist 1/45 {
		replace hs`age'i`n' = 0 if hs`age'i`n' > 1 & !missing(hs`age'i`n')
		rename hs`age'i`n'	home`age'_`n'
	}
}

local age3to6	42 54
foreach age of local age3to6 {
	foreach n of numlist 1/80 {
		replace hs`age'i`n' = 0 if hs`age'i`n' > 1 & !missing(hs`age'i`n')
		rename hs`age'i`n'	home`age'_`n'
	}
}

foreach n of numlist 1/85 {
	replace hsepi`n' = 0 if hsepi`n' > 1 & !missing(hsepi`n')
	rename hsepi`n'	home96_`n'
}

#delimit ;
keep id
treat
home6_*
home18_*
home30_*
home42_*
home54_*
home96_*
;
#delimit cr

cd "$data_home"
save abc-home-item, replace
