// Ethnicity (most common category in record)
//============================================

//Generate list of recorded ethnicities
use 1b_formatted_data/Observation, clear

merge m:1 medcodeid using codelists/ethnicity
keep if _merge == 3
drop _merge

save 3_builds/eth5

//Add ethnicity to patient record
use 1b_formatted_data/Patient, clear

preserve
	keep pracid patid
	merge 1:m pracid patid using 3_builds/eth5  //all ethnicity codes in Observation file
	keep if _merge == 3
	drop _merge medcodeid

	label list eth5
	drop if eth5 == 6  //"Not stated" isn't useful
	
	//Generate binary variables for each of the 5 ethnicity groups
	generate byte white = 1 if eth5 == 1
	generate byte south_asian = 1 if eth5 == 2
	generate byte black = 1 if eth5 == 3
	generate byte other = 1 if eth5 == 4
	generate byte mixed = 1 if eth5 == 5

	//Generate count for each of the ethnicity categories
	by pracid patid: egen white_total = count(white)
	by pracid patid: egen sa_total = count(south_asian)
	by pracid patid: egen black_total = count(black)
	by pracid patid: egen other_total = count(other)
	by pracid patid: egen mixed_total = count(mixed)
	
	//Limit to one row per perseon, keeping the most recent ethnicity code
	gsort pracid patid -eth5_date
	by pracid patid: keep if _n == 1
	
	//Generate variable for the count of most commonly recorded ethnicity/ies
	egen highestcount = rowmax(white_total sa_total black_total other_total mixed_total)

	//Generate new ethnicity variable which takes most commonly recorded ethnicity
	generate byte ethnicity = .
	label values ethnicity eth5
	replace ethnicity = 1 if white_total == highestcount & highestcount ! = 0
	replace ethnicity = 2 if sa_total == highestcount & highestcount ! = 0
	replace ethnicity = 3 if black_total == highestcount & highestcount ! = 0
	replace ethnicity = 4 if other_total == highestcount & highestcount ! = 0
	replace ethnicity = 5 if mixed_total == highestcount & highestcount ! = 0

	//If 2 or more groups have same frequency, choose most recent ethnicity code
	generate byte samecount_count = 0
	foreach var of varlist white_total sa_total black_total other_total mixed_total {
		
		replace samecount_count = samecount_count + 1 ///
			if `var' == highestcount & highestcount ! = 0
	}
	replace ethnicity = eth5 if samecount_count > 1

	keep pracid patid ethnicity
	tempfile ethnicity
	save `ethnicity'
restore
merge 1:1 pracid patid using `ethnicity', nogenerate
recode ethnicity (. = 99)
label define eth5 99 "Missing", add
tab ethnicity, missing