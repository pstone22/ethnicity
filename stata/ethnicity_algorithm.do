/******************************************************************************/
/* This do file assumes that you have already imported the raw data .txt      */
/* files from CPRD and saved them in Stata format.                            */
/******************************************************************************/

//Open Observation file (with essential variables only - it's a very large file)
**NOTE: the Observation file will almost certainly be in a multiple parts,    **
**        you will need to loop through each part to obtain all data.         **
**        We have assumed a single file here to keep this example as concise  **
**        as possible                                                         **
use pracid patid obsdate medcodeid using 1_formatted_data/Observation

//Remove codes without a date (can't use these)
drop if obsdate == .

//Merge with ethnicity codelist
merge m:1 medcodeid using codelists/ethnicity, nogenerate keep(match)

//Restrict to necessary variables only
keep pracid patid obsdate medcodeid eth5

//Rename obsdate to make it clearer that it's date of ethnicity
rename obsdate eth5_date

//Compress (reduce file size) and save ethnicity events
save 3_builds/eth5, replace


//Open patient file
use 1b_formatted_data/Patient, clear

//Generate ethnicity category (using preserve-restore to save having to open file again)
preserve
	//Restrict to patient ID only and merge with all ethnicity codes, keeping only the matches
	keep pracid patid
	merge 1:m pracid patid using 3_builds/eth5  //all ethnicity codes in Observation file
	keep if _merge == 3
	drop _merge medcodeid
	
	//Check label categories and generate individual variables for each ethnicity
	label list eth5
	generate byte white = 1 if eth5 == 1
	generate byte south_asian = 1 if eth5 == 2
	generate byte black = 1 if eth5 == 3
	generate byte other = 1 if eth5 == 4
	generate byte mixed = 1 if eth5 == 5

	//Get date of each patient's most recent code for each ethnicity category
	by pracid patid: egen white_recent = max(eth5_date) if white == 1
	by pracid patid: egen south_asian_recent = max(eth5_date) if south_asian == 1
	by pracid patid: egen black_recent = max(eth5_date) if black == 1
	by pracid patid: egen other_recent = max(eth5_date) if other == 1
	by pracid patid: egen mixed_recent = max(eth5_date) if mixed == 1
	format %td *_recent
	
	//Generate total number of codes for each ethnicity for each patient and when it was last recorded
	collapse (sum) white_count = white ///
			south_asian_count = south_asian ///
			black_count = black ///
			other_count = other ///
			mixed_count = mixed ///
		(max) white_recent south_asian_recent black_recent other_recent mixed_recent, ///
		by(pracid patid)
	
	//Reshape to long format so each patient has a line for each ethnicity
	//with a count and last recorded date
	reshape long @count @recent, i(pracid patid) j(eth) string

	//Make a new ethnicity variable
	//**The order below ensures most common category from census is used in case 
	//**two categories are equally common and recorded on same day
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
	
	//Sort by patient, ethnicity count (highest first),
	//ethnicity record date (most recent first),
	//and ethnicity category in order defined above
	gsort pracid patid -count -recent ethnicity
	
	//Keep first row for each patient
	by pracid patid: keep if _n == 1
	
	//Restrict to necessary variables only (patient ID and ethnicity category)
	keep pracid patid ethnicity

	//Save to a tempfile
	tempfile ethnicity
	save `ethnicity'
restore  //back to Patient file

//Merge in ethnicity tempfile we created in preserve-restore block
merge 1:1 pracid patid using `ethnicity', nogenerate

//Add a label for missing data
recode ethnicity (. = 99)
label define ethnicity 99 "Missing", add

//Tabulate to confirm it worked
tab ethnicity, missing