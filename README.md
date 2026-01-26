# How to retrieve ethnicity from UK primary care data

## Problem
- CPRD data = expensive
- this method = free alternative

## Ethnicity codelist creation

```mermaid
flowchart TD
A(1. Search for pre-existing ethnicity codelists) --> B(2. Compare codelists)
B --> C(3. Harmonise codelists)
C --> D(4. Amalgamated codelist screen)
D --> E(5. SNOMED CT synonym search)
E --> F(6. Export codelist)
```

### 1. Search for pre-existing ethnicity codelists
| Codelist Repository                                                   | Search Strategy      | Search Results | Suitable Codelists | Clinical Terminology             | Suitable Codelist URLs                                                                                                                                                            |
| --------------------------------------------------------------------- | -------------------- | -------------- | ------------------ | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [HDR UK Phenotype Library](https://phenotypes.healthdatagateway.org/) | "ethnicity"          | 23             | 0                  | N/A                              | N/A                                                                                                                                                                               |
| [LSHTM Data Compass](https://datacompass.lshtm.ac.uk/)                | "ethnicity codelist" | 8              | 3                  | CPRD Aurum MedCodeID (SNOMED CT) | <ol><li>https://datacompass.lshtm.ac.uk/id/eprint/2102/</li><li>https://datacompass.lshtm.ac.uk/id/eprint/2414/</li><li>https://datacompass.lshtm.ac.uk/id/eprint/4214/</li></ol> |
| [OpenCodelists](https://www.opencodelists.org/)                       | "ethnicity"          | 68             | 1                  | SNOMED CT                        | https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/                                                                                             |

### 2. Compare codelists
| Ethnicity codelist                                                                                               | Clinical terminology             | No. of codes | Ethnicity categories                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ---------------------------------------------------------------------------------------------------------------- | -------------------------------- | ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [LSHTM 2102](https://datacompass.lshtm.ac.uk/id/eprint/2102/)                                                    | CPRD Aurum MedCodeID (SNOMED CT) | 263          | 5-category ethnicity:<ol><li>White</li><li>South Asian</li><li>Black</li><li>Other</li><li>Mixed</li><li>Not Stated</li></ol>16-category ethnicity:<ol><li>British</li><li>Irish</li><li>Other White</li><li>White and Black Caribbean</li><li>White and Black African</li><li>White and Asian</li><li>Other Mixed</li><li>Indian</li><li>Pakistani</li><li>Bangladeshi</li><li>Other Asian</li><li>Caribbean</li><li>African</li><li>Other Black</li><li>Chinese</li><li>Other ethnic group</li><li>Not Stated</li></ol>                                                                                                                                                                                                                                                                                                                                                   |
| [LSHTM 2414](https://datacompass.lshtm.ac.uk/id/eprint/2414/)                                                    | CPRD Aurum MedCodeID (SNOMED CT) | 263          | None provided                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| [LSHTM 4212](https://datacompass.lshtm.ac.uk/id/eprint/4214/)                                                    | CPRD Aurum MedCodeID (SNOMED CT) | 290          | 5-category ethnicity:<ol><li>White</li><li>South Asian</li><li>Black</li><li>Other</li><li>Mixed</li><li>Not Stated</li></ol>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| [OpenCodelists ethnicity](https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/) | SNOMED CT                        | 599          | 5-category ethnicity:<ol><li>White</li><li>Mixed</li><li>Asian or Asian British</li><li>Black or Black British</li><li>Chinise or Other Ethnic Groups</li></ol>16-category ethnicity:<ol><li>White: British</li><li>White: Irish</li><li>White: Any other White background</li><li>Mixed: White and Black Caribbean</li><li>Mixed: White and Black African</li><li>Mixed: White and Asian</li><li>Mixed: Any other mixed background</li><li>Asian or Asian British: Indian</li><li>Asian or Asian British: Pakistani</li><li>Asian or Asian British: Bangladeshi</li><li>Asian or Asian British: Any other Asian background</li><li>Black or Black British: Caribbean</li><li>Black or Black British: African</li><li>Black or Black British: Any other Black background</li><li>Other Ethnic Groups: Chinese</li><li>Other Ethnic Groups: Any other ethnic group</li></ol> |

The [OpenCodelists codelist](https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/) appears to be the most comprehensive and includes a [GitHub discussion around the included terms and justification for the classifications](https://github.com/opensafely/codelist-development/issues/126).

### 3. Harmonise codelists
- Removed "Not Stated" ethnicity category from codelists that included it as it is not useful
- Recoded the [OpenSafely codelist](https://www.opencodelists.org/codelist/opensafely/ethnicity-snomed-0removed/2e641f61/) to use the same categories as the LSHTM codelists
  ```stata
  recode eth5 (2 = 5) (3 = 2) (4 = 3) (5 = 4)
  ```
- Checked for conflicts and chose most appropriate ethnicity category

### 4. Amalgamated codelist screen
- Changed the category for 26 codes where it seemed another ethnicity category was more appropriate. See [log file](stata/ethnicity.log) for exact changes.

### 5. SNOMED CT synonym search
- Found 12 new synonymous codes
- Removed one new synoynm code for being too vague, leaving 11 new codes in total

### 6. Export codelist
- **The final codelist including the codes, terms, ethnicity category, and source of each code can be found [here](stata/ethnicity.csv).**
- Uses the [2001 Census ethnic groupings](https://www.ethnicity-facts-figures.service.gov.uk/style-guide/ethnic-groups/#2001-census):
  - 5-category ethnicity (eth5) labelled as:
    1. White
    1. South Asian
    1. Black
    1. Other
    1. Mixed
  - 16-category ethnicit (eth16) labelled as:
    1. British
    1. Irish
    1. Other White
    1. White and Black Caribbean
    1. White and Black African
    1. White and Asian
    1. Other Mixed
    1. Indian
    1. Pakistani
    1. Bangladeshi
    1. Other Asian
    1. Caribbean
    1. African
    1. Other Black
    1. Chinese
    1. Other ethnic group
- Stata do file to create the ethnicity codelist can be found [here](stata/ethnicity.do).


## Ethnicity codelist use

```mermaid
flowchart TD
A[Ethnicity codelist] --> B(Merge codelist with CPRD Aurum Observation file to get list of ethnicity records)
B --> C(Merge list of ethnicity records with CPRD Aurum Patient file)
C --> D(For each person calculate frequency of each of the 5 high-level ethnic groupings)
D -->|Select ethnicity| E{Does someone have one ethnic group recorded more commonly than any other?}
E -->|Yes| F[Person's ethnicity = most **common** recorded ethnic category]
E -->|No| G[Person's ethnicity = most **recent** recorded ethnic category]
```

1. First merge the [ethnicity codelist](stata/ethnicity.csv) with the CPRD Aurum Observation file and keep all resulting matches to generate a long file of all ethnicity codes for patients in your cohort.
2. Merge the long file of all ethnicity codes with the CPRD Aurum Patient file, keeping matches.
3. Determine most commonly recorded ethnic category for each individual with *no limitation* on date (can be recorded in past or future).
4. If an individual has 2 or more ethnic groups recorded with the same frequency, the most recently recorded ethnicity is chosen (even if different from most common groups), otherwise the most commonly recorded ethnicity is selected as the persons ethicity (similar to [CPRD's method](https://www.cprd.com/sites/default/files/2025-09/CPRD_EthnicityRecord_Documentation_v1.2.pdf))

### Considerations
- Does having no limitation on date of ethnicity record seem acceptable? Can mean we effectively end up looking into the future, but allows for more complete data. **Similar to using IMD variable**
- Does choosing most recent ethnicity (with assumption that most recent is probably most accurate) seem reasonable even if it differs from the most commonly recorded ethnicities? **No, will change this**

### Differences from [CPRD's algorithm](https://www.cprd.com/sites/default/files/2025-09/CPRD_EthnicityRecord_Documentation_v1.2.pdf)
- **change method to replicate exactly CPRD so we get same ethnicity every run of algorithm**
- No HES data (primary care data only)
- Different codelist (I am guessing [this](https://static-content.springer.com/esm/art%3A10.1186%2Fs12963-023-00302-0/MediaObjects/12963_2023_302_MOESM3_ESM.docx) is CPRD's codelist (from [Shiekh et al., 2023](https://doi.org/10.1186/s12963-023-00302-0)) but categorisation is not included)
- It's not clear from how CPRD have described it, but I think CPRD choose most recent of the most commonly recorded ethnicities
- Where there are multiple ethnicities with the same frequency and most recent date, CPRD choose the ethnicity that occurs most frequently in the 2021 England and Wales census. I'm not sure I agree with this and therefore haven't implemented this, which means Stata will choose one at random in my method, meaning that different counts could be obtained each time the algorithm is run.
- CPRD choose the second most commonly recorded ethnic group if "Other" is the most frequently recorded ethnic group. I have not done this because I don't think it is a reasonable thing to do at all.

### Implications of algorithm
- mention about timeframe (all data used)
- will need to think about how to use variable dependent on whether exposure or covariate, esp wrt missing data

### Data completeness
Ethnicity completeness was >80% for a cohort of people with severe mentall illness and a cohort of people with dementia

### Example Stata code
Do file available [here](stata/ethnicity_algorithm.do).
```stata
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
```
