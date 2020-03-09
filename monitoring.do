*	Name: monitoring.do
*	Date Created: 
*	Date Last Modified: 
*	Created by: Arsène ZONGO B. M., azongo@poverty-action.org
*	Last modified by: Arsène ZONGO B. M., azongo@poverty-action.org
*	Input: csv, labeldatetime.do
*	Output: 
*	
*	Purpose: Provide close monitoring on :
*				- data collection's statistics /by day, by enumetor, /by team, /by type of interviews (completed, absence and refusal)
*				- graph the data collection's statistics /by day, /by team, /by type of interviews (completed, absence and refusal)
*				- field work time monitoring
*				- missing survey by ZD (jump or queue)
*				- ZDs completion informations

***********
* initialisation
    version 16
    clear all
    cls
    set more off
    cap log close
    set maxvar 30000

***********
* monitoring 1
    global day "20200308"
    global t0 "07mars2019 00:00:00"
    global t1 "07mars2019 00:00:00" //for global zd tpr
    global t2 "08mar2020 10:00:00" //for global zd tpr
    global s1 "07mars2019 00:00:00" //for the monitoring window
    global s2 "08mar2020 10:00:00" //for the monitoring window
	
	
***********
* set the user
  global user az //sk el
  
  if "${user}" == "az" {
	global root "X:/Dropbox"
  }
  if "${user}" == "sk" {
	global root "X:/Dropbox"
  }
  if "${user}" == "el" {
	global root "X:/Dropbox"
  }

***
* global
  global csvfile "SEDRI W1 - Enquête RM - VF_WIDE.csv"
  global data_clean "sedri_w1_indiv_survey__03022020.dta"
  global path_data "${root}/SEDRI_CI/05_intervention/02_PovertyMeasurement/05_SurveyData/02_data/04_rawdata"
  global path_data_clean "${root}/SEDRI_CI/07_questionnairesanddata/02_individualsurvey/02_datamanagement/01_data/05_cleandata"
  global path_output "${root}/SEDRI_CI/05_intervention/02_PovertyMeasurement/05_SurveyData/02_data/08_monitoring"
  global sampl "preloadindiv_RM_selected.csv"
  global path_sampl "${root}//SEDRI_CI/05_intervention/02_PovertyMeasurement/05_SurveyData/02_data/02_preparedofile"


* new folder for new day
  cap mkdir "${path_output}/${day}" //folder : day

* working directory
  cd "${path_output}/${day}"

  
***
* use directly data clean
  * use "${path_data_clean}/${data_clean}", clear

* data raw
  insheet using "${path_data}/${csvfile}", names clear
  
  * this is a change
  e

* create temporary variables
  cap gen q4_3_byenum = .
  cap gen q4_5_byenum = .
  
* convert id variables in string
  tostring uniq_indiv_id_csv, format("%15.0f") replace //13 digits (1+9+3)
  * tostring uniq_id_csv, format("%10.0f") replace //10 digits (1+9)
  * tostring uniq_hh_id_csv, format("%13.0f") replace //13 digits (1+9+3)

* respondant names
  gen var44 = " "
  gen var45 = " DIT "
  egen respname = concat(in0 var44 in1 var45 in2)
  
* replacement
  * do "${path_output}/../02_do/02_cleaning_do/02_subdofiles_cleaning/replacement.do"
  
  
* dates
  do "${path_data}/../07_hfc/02_dofiles/datestc.do"

* label
  * do "X:/Dropbox/SEDRI_CI/07_questionnairesanddata/02_individualsurvey/02_datamanagement/03_hfc/label.do"



* data period
    keep if submissiondatetc >= tc(${t0}) & submissiondatetc <= tc(${t2})
    * keep if starttimetc >= tc(${s1}) & starttimetc <= tc(${s2})

***
* temp : test bi9_zd

 tab bi6, miss
	
***
* checking versions
  tostring formdef_version, format("%15.0f") gen(formdef_version_s) //15 digits (1+9+3+2)
  tab formdef_version_s starttimetd


***
* cleaning the observations for stats
* interviews' status
  tab bi16, missing
  tab starttimetd bi16, missing


***
* tpr : all the observations
  keep if submissiondatetc >= tc(${t0}) & submissiondatetc <= tc(${t2})

  
***
* global statistics
  
  tab _zd_clean starttimetd, miss

  
  
  
  

  
  
  
  
  
*****
* 3. tpr : monitoring window only


* monitoring the enumerators' work timing

* preserve 4
  preserve
  
  keep if starttimetc >= tc(${s1}) & starttimetc < tc(${s2})

  * stats by enumerators
    bysort starttimetd bi10_1 bi10_2 : egen nbenq_byenum = total(bi16 == 1)
    bysort starttimetd bi10_1 bi10_2 : egen nbref_byenum = total(bi16 == 0)
	bysort starttimetd bi10_1 bi10_2 : egen nbtype1_byenum = total(respo_type == 1)
	bysort starttimetd bi10_1 bi10_2 : egen nbtype2_byenum = total(respo_type == 2)
	bysort starttimetd bi10_1 bi10_2 : egen nbtype3_byenum = total(respo_type == 3)
    bysort starttimetd bi10_1 bi10_2 : gen nbenqrefabs_byenum = nbenq_byenum + nbref_byenum //+ nbabs_byenum
	
	* stat 1
	gen v441 = "dont"
	gen v442 = "refus;"
	gen v443 = "sont des répondants de type 1, "
	gen v444 = "sont des répondants de type 2, et "
	gen v445 = "sont des répondants de type 3"

	gen stat1 = nbenqrefabs_byenum v441 nbref_byenum v442 ///
	nbtype1_byenum v443 ///
	nbtype2_byenum v444 ///
	nbtype3_byenum v445__just_to_dee
	
	* syfs
	
	
	
	
	
* stats durations
	 * avg duration
    bysort starttimetd bi10_1 bi10_2: egen avg_durationtype1 = mean(_durtot_mod_all) if respo_type == 1
    bysort starttimetd bi10_1 bi10_2: egen avg_durationtype1 = mean(_durtot_mod_all) if respo_type == 2
    bysort starttimetd bi10_1 bi10_2: egen avg_durationtype1 = mean(_durtot_mod_all) if respo_type == 3
	
  * min duration
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = min(_durtot_mod_all) if respo_type == 1
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = min(_durtot_mod_all) if respo_type == 2
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = min(_durtot_mod_all) if respo_type == 3

  * max duration
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = max(_durtot_mod_all) if respo_type == 1
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = max(_durtot_mod_all) if respo_type == 2
    bysort starttimetd bi10_1 bi10_2: egen min_durationtype1 = max(_durtot_mod_all) if respo_type == 3
	
	
* first starttime and last endtime survey  by date by enumerator
    bysort starttimetd bi10_1 bi10_2 : egen starttimetc_min_byenum = min(speedcheckstarttc)
    bysort starttimetd bi10_1 bi10_2 : egen endtimetc_max_byenum  = max(speedcheckendtc)
    format starttimetc_min_byenum endtimetc_max_byenum  %tc
    gen durationonfield = (endtimetc_max_byenum - starttimetc_min_byenum) / 3600
	
	
	gen v693 = "Première enquête a bebuté à"
	gen v694 = ", et la dernière enquête finie à "
	
	egen stat3 = conact(v693 starttimetc_min_byenum v694 endtimetc_max_byenum)
	

* tag and reduce to enumerator
    egen tag = tag(starttimetd bi10_1 bi10_2)
    keep if tag == 1

* by enum by date
    bysort bi10_2 : egen nbenq_total_byenum = total(nbenq_byenum)
	
	

	
		
   
* labels
    label variable starttimetd "Date"
    label variable starttimetc_min_byenum "Debut - premier ménage"
    label variable endtimetc_max_byenum "Fin - dernier ménage"
    label variable nbenq_byenum "Enq. compl."
    // label variable nbabs_byenum "Absence"
    label variable nbref_byenum "Refus"
    label variable nbenq_total_byenum "Total Enq. compl."
    label variable starttimetd_string "Date"
   
* export : *_byenum
    global othervars nbenq_total_byenum durationonfield starttimetd_string //nbenqrefabs_byenum
    keep starttimetd sup_name bi10_1 enum_name bi10_2 starttimetc_min_byenum endtimetc_max_byenum ///
	nbenq_byenum nbref_byenum ${othervars} nbenqrefabs_byenum //nbabs_byenum
    order starttimetd sup_name bi10_1 enum_name bi10_2 starttimetc_min_byenum endtimetc_max_byenum ///
	nbenq_byenum nbref_byenum ${othervars} nbenqrefabs_byenum //nbabs_byenum
    sort starttimetd bi10_1 bi10_2
    export excel "${path_output}/${day}/monitoring_${day}.xlsx", sheet("3. enqueteur") firstrow(varlabels) sheetmodify


***********
* monitoring the team' work time and performances
    egen tagenum = tag(starttimetd bi10_1 bi10_2)
    bysort starttimetd bi10_1 : egen nbenum_byteam = total(tagenum)
    bysort starttimetd bi10_1 : egen nbenq_byteam = total(nbenq_byenum)
    bysort starttimetd bi10_1 : egen nbref_byteam = total(nbref_byenum)
    // bysort starttimetd bi10_1 : egen nbabs_byteam = total(nbabs_byenum)
    bysort starttimetd bi10_1 : gen nbenqrefabs_byteam = nbenq_byteam + nbref_byteam //+ nbabs_byteam
    gen avgenq_hj = nbenq_byteam / nbenum_byteam
    // gen avgabs_hj = nbabs_byteam / nbenum_byteam
    gen avgref_hj = nbref_byteam / nbenum_byteam

* first and last survey starttime by date by enumerator
    bysort starttimetd bi10_1 : egen starttimetc_min_byteam = min(starttimetc_min_byenum)
    bysort starttimetd bi10_1 : egen endtimetc_max_byteam  = max(endtimetc_max_byenum)
    format starttimetc_m* endtimetc_max_byteam %tc

* tag li19
    egen tag = tag(starttimetd bi10_1)
    keep if tag == 1

* by team by date
    bysort bi10_1 : egen nbenq_total_byteam = total(nbenq_total_byenum)

* labels
    label variable starttimetd "Date"
    label variable starttimetc_min_byteam "Debut - premier ménage"
    label variable endtimetc_max_byteam "Fin - dernier ménage"
    label variable nbenq_byteam "Enq. compl."
    // label variable nbabs_byteam "Absence"
    label variable nbref_byteam "Refus"
    label variable nbenq_total_byteam "Total Enq. compl."

* export : *_byteam
  global othervars nbenq_total_byteam starttimetd_string //nbenqrefabs_byteam
  keep starttimetd sup_name bi10_1 starttimetc_min_byteam endtimetc_max_byteam nbenq_byteam nbref_byteam ${othervars} avg* //nbabs_byteam 
  order starttimetd sup_name bi10_1 starttimetc_min_byteam endtimetc_max_byteam nbenq_byteam nbref_byteam ${othervars} avg* //nbabs_byteam 
  sort starttimetd bi10_1
  export excel "${path_output}/${day}/monitoring_${day}.xlsx", sheet("4. equipe") firstrow(varlabels) sheetmodify

* sort for bunus
  sort sup_name bi10_1 starttimetd nbenq_byteam avg*
  order sup_name bi10_1 starttimetd nbenq_byteam avg*
  export excel "${path_output}/${day}/monitoring_${day}.xlsx", sheet("5. bonus") firstrow(varlabels) sheetmodify


***********
* graph the teams' performances (by completed survey, absence and refusal)

    * create teamid
    gen teamid = bi10_1
	
	if "${day}" != "all" { //avgabs_hj
	  * graph 1 : by team by completed survey, absence and refusal
        graph bar avgenq_hj avgref_hj, over(teamid, gap(*0.01) label(labsize(tiny))) over(starttimetd_string, gap(*0.3) label(labsize(tiny) angle(0))) asyvars blabel(bar, format(%0.0f) size(large)) ///
        ytitle("Moyenne par enqueteur par jour") legend(order(1 "Enq. compl." 2 "Refus")) ///
        yline(2, lcolor(green)) yscale(range(0(0.5)3)) ylabel(0(0.5)3, labsize(medium)) stack /// //legend(off) labgap(0cm),
        bar(1, fcolor(green) lcolor(none) lwidth(none)) bar(2, fcolor(red) fintensity(inten80) lcolor(none) lwidth(none)) ///
        title("Statistiques : moyenne par enqueteur par jour")
        graph export "${path_output}/${day}/monitoring_${day}__graph_1.png", replace width(3600) height(1200)
	}

	* graph 2 : overall by completed survey, absence and refusal //nbabs_byteam
    graph bar (sum) nbenq_byteam nbref_byteam, over(starttimetd_string, gap(*1.5) label(labsize(tiny) angle(0))) asyvars blabel(bar, format(%1.0f) size(tiny)) /// //over(li19) 
    ytitle("Nombre d'enquêtes (compl. + ref.)") legend(order(1 "Enq. compl." 2 "Refus")) ///
    yline(60, lcolor(green)) yscale(range(0(5)70)) ylabel(0(5)70, labsize(medium)) stack /// //legend(off)
    bar(1, fcolor(green)) bar(2, fcolor(red) fintensity(inten80) lcolor(none)) ///
    title("Total : nombre d'enquêtes (compl. + ref.)")
    graph export "${path_output}/${day}/monitoring_${day}__graph_2.png", replace width(3600) height(1200)

* restore 4
  restore


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  


****
* 3. missing interviews

* data all
  * the running one
 
* drop if duplicates
  bysort uniq_indiv_id_csv : gen temp_dup = _N
  tab temp_dup
  drop if temp_dup > 1
    
* save temp
  tempfile surveydata_nodup_all
  save `surveydata_nodup_all'
  
* individual survey preload 
  * import excel using "${path_sampl}/${sampl}", first clear
  insheet using "${path_preload}/${preload}", clear
  
* convert the id variable in string
  tostring uniq_hh_id_csv, format("%13.0f") replace
  tostring uniq_indiv_id_csv, format("%15.0f") replace
  
* rename
  rename (rural uniq_hh_id_csv__replacement1 uniq_hh_id_csv__replacement2 uniq_hh_id_csv__replacement3) (rural_listing uniq_hh_id_csv__r1 uniq_hh_id_csv__r2 uniq_hh_id_csv__r3)
  
* save temp
  tempfile preload
  save `preload'


****
* individual survey sample
  import excel using "${path_sampl}/${sampl}", first clear
* convert the id variable in string
  tostring uniq_hh_id_csv, format("%13.0f") replace
  tostring uniq_indiv_id_csv, format("%15.0f") replace
  
* add ls to say this is a variable from the listing
  local all_vars _all
  foreach vv of varlist _all {
    if ("`vv'" != "uniq_indiv_id_csv" & "`vv'" != "uniq_hh_id_csv" & "`vv'" != "uniq_id_csv" & "`vv'" != "sousprefname" & "`vv'" != "_quart_village_name") {
	   rename `vv' `vv'_listing
	}
  }

* save the tracking sample in .dta
  * save "${path_sampl}/tracking_20191128.dta"
* merge sample with the raw data
  merge 1:1 uniq_indiv_id_csv using `surveydata_nodup_all', ///
  force keepusing(bi10_1 sup_name bi10_2 enum_name *tc *td gps* bi6 respname bi16 bi13 bi14 bi15 bi21 bi22 bi13 bi14 bi15 in29 in30 in31 end8 _rural formdef_version key  _quartier_village_code_9d _l_li6 sousprefname _quart_village_name)
  tab _rural, mis

* rename merging status
  rename _merge mergestatus
  
* merge now with preload to have the rural dummy
  merge 1:1 uniq_indiv_id_csv using `preload', ///
  force keepusing(rural)
  * the good rural variable is called rural_listing
  
* tag rm experiment
  gen vt_209 = substr(uniq_indiv_id_csv, 11, 3)
  gen li10_hh_index = real(vt_209)
  gen is_rm = (li10_hh_index >= 200)
  gen is_not_rm = (li10_hh_index < 200)
  bysort uniq_id_csv : egen total_is_rm = total(is_rm)
  bysort uniq_id_csv : egen total_is_not_rm = total(is_not_rm)

* started zds and villages
  * number of surveys by zd village
    bysort uniq_id_csv (uniq_indiv_id_csv) : egen nb_obs_byzd = total(mergestatus == 3)
  
  * dummy for started zds and villages
    gen zdstarted = (nb_obs_byzd > 0)
	
* missing surveys within the started zds and villages
  gen hhidmissing1 = (zdstarted == 1 & mergestatus == 1)
  gen hhidmissing2 = (zdstarted == 0 & mergestatus == 1)
  

* the team assigned to each missing survey
  bysort uniq_id_csv (uniq_indiv_id_csv) : egen temp_v4499 = total(bi10_1)
  replace bi10_1 = temp_v4499/nb_obs_byzd if missing(bi10_1)

* missing survey in rural teams : team 1 and team 2
  gen hhidmissing1_team12 = (hhidmissing1 == 1 & (bi10_1 == 1 | bi10_1 == 2))
  gen hhidmissing2_team12 = (hhidmissing2 == 1 & (bi10_1 == 1 | bi10_1 == 2))

* number of missing
  bysort uniq_id_csv (uniq_indiv_id_csv) : egen hhidmissing1_nb_byzd = total(hhidmissing1 == 1)
  bysort uniq_id_csv (uniq_indiv_id_csv) : egen hhidmissing2_nb_byzd = total(hhidmissing2 == 1)

* zd started and incomplete
  gen zdincompl = (hhidmissing1_nb_byzd > 0)

* labels
* none

* order
  order sousprefname _quart_village_name ///
  starttimetc speedcheckstarttc speedcheckendtc submissiondatetc ///
  bi10_1 sup_name bi10_2 enum_name ///
  uniq_indiv_id_csv respname uniq_id_csv _zd_clean_listing ///
  end8 nb_obs_byzd ///
  zdstarted zdincompl hhidmissing1 hhidmissing2 hhidmissing1_nb_byzd hhidmissing2_nb_byzd total_is_rm is_rm total_is_not_rm is_not_rm ///
  gps* ///
  rural_listing ///
  formdef_version key

  keep sousprefname _quart_village_name ///
  starttimetc speedcheckstarttc speedcheckendtc submissiondatetc ///
  bi10_1 sup_name bi10_2 enum_name ///
  uniq_indiv_id_csv respname uniq_id_csv _zd_clean_listing ///
  end8 nb_obs_byzd ///
  zdstarted zdincompl hhidmissing1 hhidmissing2 hhidmissing1_nb_byzd hhidmissing2_nb_byzd total_is_rm is_rm total_is_not_rm is_not_rm ///
  gps* ///
  rural_listing  _quartier_village_code_9d _l_li6 ///
  formdef_version key mergestatus

* export
  export excel "${path_output}/${day}/monitoring_${day}.xlsx", ///
  sheet("13. missing interviews") firstrow(varlabels) sheetmodify  
  
 
  
  
*****
* statistics : non rm only

* preserve 5
  preserve

* keep rm observations only
  keep if is_rm == 0
  
* tag each zd or village
  egen tag_zd_village = tag(uniq_id_csv)

* total: number of zd and village in each sous-prefecture
  bysort sousprefname : egen nb_zd_bysp = total(tag_zd_village == 1 & rural_listing == 0)
  bysort sousprefname : egen nb_village_bysp = total(tag_zd_village == 1 & rural_listing == 1)
  
* started: number of zd and village in each sous-prefecture
  bysort sousprefname : egen zd_started = total(tag_zd_village == 1  & zdstarted == 1 & rural_listing == 0)
  bysort sousprefname : egen village_started = total(tag_zd_village == 1  & zdstarted == 1 & rural_listing == 1)
   
* missing: number of zd and village in each sous-prefecture
  gen zd_missing = nb_zd_bysp - zd_started
  gen village_missing = nb_village_bysp - village_started
  
* total: sample size (nb of respondants) of each sous-prefecture
  bysort sousprefname : gen nb_bysp = _N
* total: number of completed survey in each sous-prefecture
  bysort sousprefname : egen nb_obs_bysp = total(mergestatus == 3)
* total: number of missing survey in each sous-prefecture 
  bysort sousprefname : egen nb_miss_bysp = total(mergestatus == 1) 

* tag the sp
  egen tag = tag(sousprefname)
  keep if tag == 1

* percentages
  gen freq_obs_bysp = nb_obs_bysp / nb_bysp
  gen freq_miss_bysp = nb_miss_bysp / nb_bysp

* disp
  tabdisp sousprefname, cellvar(zd_missing village_missing freq_obs_bysp freq_miss_bysp zd_started)
 

* order
  order sousprefname zd_missing village_missing nb_miss_bysp freq_miss_bysp ///
  nb_bysp nb_obs_bysp freq_obs_bysp ///
  nb_zd_bysp nb_village_bysp zd_started village_started

* keep
  keep sousprefname zd_missing village_missing nb_miss_bysp freq_miss_bysp ///
  nb_bysp nb_obs_bysp freq_obs_bysp ///
  nb_zd_bysp nb_village_bysp zd_started village_started

* export
  export excel "${path_output}/${day}/monitoring_${day}.xlsx", ///
  sheet("14. statistics - non rm") firstrow(varlabels) sheetmodify

* restore
  restore
  
  
  
  
*****
* statistics : rm only

* preserve 6
  preserve

* keep rm observations only
  keep if is_rm == 1
  
* tag each zd or village
  egen tag_zd_village = tag(uniq_id_csv)

* total: number of zd and village in each sous-prefecture
  bysort sousprefname : egen nb_zd_bysp = total(tag_zd_village == 1 & rural_listing == 0)
  bysort sousprefname : egen nb_village_bysp = total(tag_zd_village == 1 & rural_listing == 1)
  
* started: number of zd and village in each sous-prefecture
  bysort sousprefname : egen zd_started = total(tag_zd_village == 1  & zdstarted == 1 & rural_listing == 0)
  bysort sousprefname : egen village_started = total(tag_zd_village == 1  & zdstarted == 1 & rural_listing == 1)
   
* missing: number of zd and village in each sous-prefecture
  gen zd_missing = nb_zd_bysp - zd_started
  gen village_missing = nb_village_bysp - village_started
  
* total: sample size (nb of respondants) of each sous-prefecture
  bysort sousprefname : gen nb_bysp = _N
* total: number of completed survey in each sous-prefecture
  bysort sousprefname : egen nb_obs_bysp = total(mergestatus == 3)
* total: number of missing survey in each sous-prefecture 
  bysort sousprefname : egen nb_miss_bysp = total(mergestatus == 1) 

* tag the sp
  egen tag = tag(sousprefname)
  keep if tag == 1

* percentages
  gen freq_obs_bysp = nb_obs_bysp / nb_bysp
  gen freq_miss_bysp = nb_miss_bysp / nb_bysp

* disp
  tabdisp sousprefname, cellvar(zd_missing village_missing freq_obs_bysp freq_miss_bysp zd_started)

* order
  order sousprefname zd_missing village_missing nb_miss_bysp freq_miss_bysp ///
  nb_bysp nb_obs_bysp freq_obs_bysp ///
  nb_zd_bysp nb_village_bysp zd_started village_started

* keep
  keep sousprefname zd_missing village_missing nb_miss_bysp freq_miss_bysp ///
  nb_bysp nb_obs_bysp freq_obs_bysp ///
  nb_zd_bysp nb_village_bysp zd_started village_started

* export
  export excel "${path_output}/${day}/monitoring_${day}.xlsx", ///
  sheet("15. statistics - rm") firstrow(varlabels) sheetmodify

* restore
  restore

e






* table the statistics by enumerator
  tab _zd_clean bi10_2, miss
  bysort uniq_indiv_id_csv: gen dupp = 1 if _N > 2 
  














