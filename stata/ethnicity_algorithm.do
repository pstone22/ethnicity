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

	gsort pracid patid eth5_date

	label list eth5
	drop if eth5 == 6  //"Not stated" isn't useful
	generate byte white = 1 if eth5 == 1
	generate byte south_asian = 1 if eth5 == 2
	generate byte black = 1 if eth5 == 3
	generate byte other = 1 if eth5 == 4
	generate byte mixed = 1 if eth5 == 5

	//Date of most recent code for each ethnicity category
	by pracid patid: egen white_recent = max(eth5_date) if white == 1
	by pracid patid: egen south_asian_recent = max(eth5_date) if south_asian == 1
	by pracid patid: egen black_recent = max(eth5_date) if black == 1
	by pracid patid: egen other_recent = max(eth5_date) if other == 1
	by pracid patid: egen mixed_recent = max(eth5_date) if mixed == 1
	format %td *_recent

	collapse (sum) white_count = white ///
			south_asian_count = south_asian ///
			black_count = black ///
			other_count = other ///
			mixed_count = mixed ///
		(max) white_recent south_asian_recent black_recent other_recent mixed_recent, ///
		by(pracid patid)
		
	reshape long @count @recent, i(pracid patid) j(eth) string

	//Make a new ethnicity variable
	//The order below ensures most common category from census is
	//used in case of two categories being equally common and recorded on same day
	generate byte ethnicity = .
	label define ethnicity 1 "White" 2 "South Asian" 3 "Black" 4 "Mixed" 5 "Other"
	label values ethnicity ethnicity
	replace ethnicity = 1 if eth == "white_"
	replace ethnicity = 2 if eth == "south_asian_"
	replace ethnicity = 3 if eth == "black_"
	replace ethnicity = 4 if eth == "mixed_"
	replace ethnicity = 5 if eth == "other_"
	tab ethnicity eth, missing
	drop eth

	gsort pracid patid -count -recent ethnicity

	by pracid patid: keep if _n == 1

	keep pracid patid ethnicity
	tempfile ethnicity
	save `ethnicity'
restore
merge 1:1 pracid patid using `ethnicity', nogenerate
recode ethnicity (. = 99)
label define ethnicity 99 "Missing", add
tab ethnicity, missing
