// Take log

clear all
log close _all

// Set the path of working directory
global pwd "/Users/ito_hiroki/03.Work/YNU/Replication Review/Toriyabe_and_Kawaguchi/measuring-skilluse-piaac-main"
do "${pwd}/do-file/config.do"
local dofile_name "clean_piaac"


use "${path_data}/until_898.dta"

// Normalization
qui gen lit = .
qui gen num = .
qui gen ict = .
foreach v of varlist lit num ict {
	qui gen work`v' = .
	qui gen home`v' = .
}

forvalues i = 1(1)31 {
	foreach v of varlist lit num {
		qui sum skill_`v' if (country==`i')
		qui replace `v' = (skill_`v' - r(mean))/r(sd) if (country==`i')
		qui sum skilluse_`v' if (country==`i')
		qui replace work`v' = (skilluse_`v' - r(mean))/r(sd) if (country==`i')
		qui sum skillusedaily_`v' if (country==`i')
		qui replace home`v' = (skillusedaily_`v' - r(mean))/r(sd) if (country==`i')
	}
}

forvalues i = 1(1)31 {
	qui sum skill_ps if (country==`i')
	qui replace ict = (skill_ps - r(mean))/r(sd) if (country==`i')
	qui sum skilluse_ict if (country==`i')
	qui replace workict = (skilluse_ict - r(mean))/r(sd) if (country==`i')
	qui sum skillusedaily_ict if (country==`i')
	qui replace homeict = (skillusedaily_ict - r(mean))/r(sd) if (country==`i')
}


// Wage: Continuous Value
gen wage = earnhr

forvalues i = 1(1)31 {
	_pctile wage if(country==`i'), nq(100)
	replace wage = . if(country==`i') & (wage<=r(r1) | wage>=r(r99))
}

gen lwage = ln(wage)

// Other Variables
gen age60 = 0
replace age60 = 1 if (age>=60 & age<1000)

gen agegroup0 = 0
gen agegroup1 = 0
gen agegroup2 = 0
gen agegroup3 = 0
gen agegroup4 = 0

replace agegroup0 = 1 if (inlist(1, age16_19, age20_24)==1) 
replace agegroup1 = 1 if (inlist(1, age25_29, age30_34)==1) 
replace agegroup2 = 1 if (inlist(1, age35_39, age40_44, age45_49)==1) 
replace agegroup3 = 1 if (inlist(1, age50_54, age55_59)==1) 
replace agegroup4 = 1 if (age60_65==1)

gen female_chldrn = female * num_chldrn
gen female_spouse = female * spouse

gen spouse_regular = (j_q02c==1) if (j_q02c~=.)

gen female_spreg = female * spouse_regular

gen work_flag = .
replace work_flag = 1 if (c_q01a==1|c_q01b==1)|(c_q01c==1)
replace work_flag = 2 if (c_q08a==1&c_q08b==1)
replace work_flag = 3 if (c_q08a==1&c_q08b==2)
replace work_flag = 4 if (c_q08a==2)
/*
	1 <- currently work
	2 <- currently not work, but worked during last 12 months
	3 <- currently not work and not work during last 12 months, but has work experience
	4 <- no work experience
	"work_flag" corresponds to C_D09 in questionare.
*/

gen work = work_flag
replace work = 0 if (inlist(work_flag, 2, 3, 4)==1)

// gen drop_flag = 0
// replace drop_flag = 1 if (c_q07==4|c_q07==7)
// * We will exclude students and permanently disabled people from sample. 
//
// drop country
// egen country = group(cntryid)
// label define country 1 "Austria"
// label define country 2 "Belgium", add
// label define country 3 "Canada", add
// label define country 4 "Chile", add
// label define country 5 "Cyprus", add
// label define country 6 "Czech", add
// label define country 7 "Denmark", add
// label define country 8 "Estonia", add
// label define country 9 "Finland", add
// label define country 10 "France", add
// label define country 11 "Germany", add
// label define country 12 "Greece", add
// label define country 13 "Ireland", add
// label define country 14 "Israel", add
// label define country 15 "Italy", add
// label define country 16 "Japan", add
// label define country 17 "Korea", add
// label define country 18 "Lithuania", add
// label define country 19 "Netherlands", add
// label define country 20 "New Zealand", add
// label define country 21 "Norway", add
// label define country 22 "Poland", add
// label define country 23 "Russian Federation", add
// label define country 24 "Singapore", add
// label define country 25 "Slovak Republic", add
// label define country 26 "Slovenia", add
// label define country 27 "Spain", add
// label define country 28 "Sweden", add
// label define country 29 "Turkey", add
// label define country 30 "United Kingdom", add
// label define country 31 "United States", add
// label value country country
//	
// // Sample restriction
// qui drop if (inlist(1,age16_19,age20_24,age60_65)==1)
// qui drop if (country==23)
// qui drop if (drop_flag==1)
// capture qui tab country, gen(cfe)
//
// // Other outcomes regarding  skill use at work place
//
// // Clean Germany data
// foreach i in 11 12 13 {
// 	foreach j in A B C D E F G {
// 		local k = strlower("`j'")
// 		capture replace d_q`i'`k' = d_q`i'`j' if (country==11)
// 	}
// }
//
// forvalues i = 1(1)9 {
// 	foreach j in A B C D E F G {
// 		local k = strlower("`j'")
// 		capture replace f_q0`i'`k' = f_q0`i'`j' if (country==11)
// 	}
// }
//
// foreach i in 2 {
// 	foreach j in A B C D E F G {
// 		local k = strlower("`j'")
// 		capture replace g_q0`i'`k' = g_q0`i'`j' if (country==11)
// 	}
// }
//
// sum d_q1?? f_q0?? g_q02? if (country==11)
//
// // Make variables to use IRT
//
// // Task discretion at work
// local num = 1
// foreach j in a b c d {
// 	gen q_taskdisc`num' = d_q11`j'
// 	local num = `num' + 1
// }
//
// gen taskdisc_flag = 0
// gen taskdisc_flag_temp = 0
// forvalues i = 1(1)4 {
// 	replace taskdisc_flag_temp = taskdisc_flag_temp + 1 if (q_taskdisc`i'==.)
// }
// replace taskdisc_flag = 1 if (taskdisc_flag_temp==4)
// drop taskdisc_flag_temp
//
// // Learning at work
// local num = 1
// foreach j in a b c {
// 	gen q_learning`num' = d_q13`j'
// 	local num = `num' + 1
// }
//
// gen learning_flag = 0
// gen learning_flag_temp = 0
// forvalues i = 1(1)3 {
// 	replace learning_flag_temp = learning_flag_temp + 1 if (q_learning`i'==.)
// }
// replace learning_flag = 1 if (learning_flag_temp==3)
// drop learning_flag_temp
//
// // Influence at work
// gen q_influence1 = f_q02b
// gen q_influence2 = f_q02c
// gen q_influence3 = f_q02e
// gen q_influence4 = f_q03b
// gen q_influence5 = f_q04a
// gen q_influence6 = f_q04b
//
// gen influence_flag = 0
// gen influence_flag_temp = 0
// forvalues i = 1(1)6 {
// 	replace influence_flag_temp = influence_flag_temp + 1 if (q_influence`i'==.)
// }
// replace influence_flag = 1 if (influence_flag_temp==6)
// drop influence_flag_temp
//
// // Writing skill at work
// local num = 1
// foreach j in a b c d {
// 	gen q_workwrite`num' = g_q02`j'
// 	local num = `num' + 1
// }
//
// gen workwrite_flag = 0
// gen workwrite_flag_temp = 0
// forvalues i = 1(1)4 {
// 	replace workwrite_flag_temp = workwrite_flag_temp + 1 if (q_workwrite`i'==.)
// }
// replace workwrite_flag = 1 if (workwrite_flag_temp==4)
// drop workwrite_flag_temp
//
// // Subjective skill-use measure
// local num = 1
// foreach j in a b c {
// 	gen q_sbjctv_skilluse`num' = d_q12`j'
// 	local num = `num' + 1
// }
//
// // Make IRT scores
// local ntaskdisc = 4
// local nlearning = 3
// local ninfluence = 6
// local nworkwrite = 4
//
// foreach var in irt_taskdisc irt_learning irt_influence irt_workwrite {
// 	gen `var' = .
// }
//
// save "${path_data}/until_1128.dta", replace
//
// forvalues i = 1(1)31 {
// 	display "**** Country `i' ****"
// 	if (`i'~=23) {
// 		foreach var in taskdisc learning influence workwrite {
// 			qui irt gpcm q_`var'1-q_`var'`n`var'' if (country==`i')
// 			qui predict `var'_`i' if (country==`i'), latent
// 			qui replace `var'_`i' = . if (`var'_flag==1)
// 			qui replace irt_`var' = `var'_`i' if (country==`i')
// 			qui drop `var'_`i'
//			
// 			display "IRT `var' was done"
// 		}
// 	}
// 	else {
// 		display "Skipped"
// 	}
// 	display ""
// }
//
// // Check the correlation with the imputed variables in PIAAC
// corr taskdisc irt_taskdisc
// corr learnatwork irt_learning
// corr influence irt_influence
// corr writwork irt_workwrite
//
// // 4-digit occupation label
// do "${path_do}/common/label_occup4digit.do"
//
// // Occupation of the low skilled by gender
// tab isco08_c if (work==1)&(female==0)&(lit<-1), sort
// tab isco08_c if (work==1)&(female==1)&(lit<-1), sort
//
//
// // Merge country-level data
// merge m:1 cntryid using "${path_data}/inst.dta", keep(3) nogen
// save "${path_data}/piaac_main.dta", replace
//
// log close
