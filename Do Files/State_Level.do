*********************************************************************************
*                 REPLICATION PACKAGE - STATE LEVEL                 *
********************************************************************************


* Setting Working Directories
clear all

global data "G:\Meu Drive\PhD\Tese - Capítulo 1\Replication Package\Bases"

global outputs "G:\Meu Drive\PhD\Tese - Capítulo 1\Replication Package\Outputs"


* Install packages and scheme for plots
ssc install reghdfe, replace
ssc install ftools, replace
ssc install schemepack, replace
ssc install ppmlhdfe, replace
ssc install coefplot, replace
ssc install  did_multiplegt_dyn, replace 
set scheme white_tableau


******************************* State Approach *******************************************

// Data Previously dowloaded from SIM-DATASUS 
use "$data\Daily_Homicides_UF.dta"


***** Prepare the Panel for the analysis *****

duplicates drop id_states date, force // double check for duplicates
xtset id_states date
drop if date==.

tsfill, full // balancing the panel for the analysis
xtdescribe 

*** labeling variable ***
label variable daily_homicides "Daily Homicides"
label variable daily_homicides_men "Men"
label variable daily_homicides_nw "Non White"
label variable daily_homicides_young "Under 15"
label variable daily_homicides_adult1 "15-25"
label variable daily_homicides_adult2 "25-45"
label variable daily_homicides_old "45+"
label variable daily_homicides_street "Streets"
label variable daily_homicides_house "Houses"
label variable daily_homicides_hospitals "Hospitals"
label variable daily_homicides_firearms "Firearms"
label variable daily_homicides_white_arms "Weapons"
label variable daily_homicides_car "Crash"
label variable daily_homicides_law "Law & Order"
label variable daily_homicides_agression "Body Injuries"


* Replacing NAs with zeros to keep tha panel balanced *

// Gender and Race variables to explore heterogeneity
gen daily_homicides_women = daily_homicides - daily_homicides_men
gen daily_homicides_white = daily_homicides - daily_homicides_nw

foreach v of varlist daily_homicides_women daily_homicides_white daily_homicides daily_homicides_adult1 daily_homicides_adult2 daily_homicides_men daily_homicides_agression daily_homicides_car daily_homicides_firearms daily_homicides_hospitals daily_homicides_house daily_homicides_law daily_homicides_men daily_homicides_nw daily_homicides_old daily_homicides_rape daily_homicides_street daily_homicides_white_arms daily_homicides_young {

replace `v'=0 if `v'==.

}


// Additional Variables to the Heterogeneity Analysis
gen daily_homicides_gender_others = daily_homicides - daily_homicides_men - daily_homicides_women 
gen daily_homicides_race_others = daily_homicides - daily_homicides_nw - daily_homicides_white
gen daily_homicides_location_others = daily_homicides - daily_homicides_street - daily_homicides_house - daily_homicides_hospitals
gen daily_homicides_age_others = daily_homicides - daily_homicides_young - daily_homicides_adult1- daily_homicides_adult2 - daily_homicides_old


* Descriptive Statistics *
ttest daily_homicides, by(militar)	
ttest daily_homicides, by(civil)	
ttest daily_homicides_men, by(militar)	
ttest daily_homicides_women, by(militar)	
ttest daily_homicides_firearms, by(militar)	
ttest daily_homicides_white_arms, by(militar)	
ttest daily_homicides_agression, by(militar)	
ttest daily_homicides_car, by(militar)	
ttest daily_homicides_law, by(militar)
ttest daily_homicides_street, by(militar)
ttest daily_homicides_hospitals, by(militar)
ttest daily_homicides_house, by(militar)
ttest daily_homicides_young, by(militar)
ttest daily_homicides_adult1, by(militar)
ttest daily_homicides_adult2, by(militar)
ttest daily_homicides_old, by(militar)
				

******** Dummy Variables to each State where a Strike has ocurred **********

// List of States
local estados AL AM BA CE ES MA PA PB PE PI PR RN RO RR SC SE TO

// Loop for creating the dummies
foreach uf in `estados' {
    gen militar_`uf' = (sigla_uf == "`uf'" & militar == 1)
}


label variable militar_AL "Alagoas"
label variable militar_AM "Amazonas"
label variable militar_BA "Bahia"
label variable militar_CE "Ceará"
label variable militar_ES "Espírito Santo"
label variable militar_MA "Maranhão"
label variable militar_PA "Pará"
label variable militar_PB "Paraíba"
label variable militar_PE "Pernambuco"
label variable militar_PI "Piauí"
label variable militar_PR "Paraná"
label variable militar_RN "Rid Grande do Norte"
label variable militar_RO "Rondônia"
label variable militar_RR "Roraima"
label variable militar_SC "Santa Catarina"
label variable militar_SE "Sergipe"
label variable militar_TO "Tocantins"

******** TWFE Estimates **********

bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Gender_UF.xls", replace ctitle(Baseline) label

estimates store total

* Gender Block *
qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_men militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Gender_UF.xls", append ctitle(Men) label

estimates store men

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_women militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Gender_UF.xls", append ctitle(Women) label

estimates store women

* Race Block *
qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_white militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Race_UF.xls", replace ctitle(White) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_nw militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Race_UF.xls", append ctitle(Non White) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_race_others militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Race_UF.xls", append ctitle(NA) label


* Age Block * 
qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_young militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Age_UF.xls", replace ctitle(Under 15) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_adult1 militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Age_UF.xls", append ctitle(15-25) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_adult2 militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Age_UF.xls", append ctitle(25-45) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_old militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Age_UF.xls", append ctitle(Over 45) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_age_others militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Age_UF.xls", append ctitle(NA) label


* Location Block *
qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_street militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Location_UF.xls", replace ctitle(Streets) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_house militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Location_UF.xls", append ctitle(House) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_hospitals militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Location_UF.xls", append ctitle(Hospitals) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_location_others militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_Location_UF.xls", append ctitle(NA) label


* Weapon Block *
qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_firearms militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_weapon_UF.xls", replace ctitle(Firearms) label

estimates store firearms

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_white_arms militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_weapon_UF.xls", append ctitle(Cold arms) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_agression militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_weapon_UF.xls", append ctitle(Body Injuries) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_car militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_weapon_UF.xls", append ctitle(Car Crash) label

qui bootstrap, rep(999) cl(id_states) idcl(new_id_states) group(id_states): reghdfe daily_homicides_law militar civil, a(id_states ano month weekday) vce(cl id_states)
outreg2 using "$outputs\tab_weapon_UF.xls", append ctitle(State Forces) label


*** Coefplot Baseline ***

coefplot total, bylabel(Total) || men, bylabel(Homicides - Men) || women, bylabel(Homicides - Women) ||, drop(_cons) xline(0) ciopts(recast(rcap)) byopts(row(1) xrescale)

graph export "$outputs\fig_main_results.jpg", as(jpg) name("Graph") quality(100) replace



*** Hetereogeneity by state ***

reghdfe daily_homicides militar_AL militar_AM militar_BA militar_CE militar_ES militar_MA militar_PA militar_PB militar_PE militar_PI militar_PR militar_RN militar_RO militar_RR militar_SC militar_SE militar_TO civil, a(id_states ano month weekday) vce(cl id_states)
estimates store strike_uf
outreg2 using "$outputs\tab_UF.xls", replace ctitle(Baseline) label

reghdfe daily_homicides_men militar_AL militar_AM militar_BA militar_CE militar_ES militar_MA militar_PA militar_PB militar_PE militar_PI militar_PR militar_RN militar_RO militar_RR militar_SC militar_SE militar_TO civil, a(id_states ano month weekday) vce(cl id_states)
estimates store strike_uf_men
outreg2 using "$outputs\tab_UF.xls", append ctitle(Men) label

reghdfe daily_homicides_women militar_AL militar_AM militar_BA militar_CE militar_ES militar_MA militar_PA militar_PB militar_PE militar_PI militar_PR militar_RN militar_RO militar_RR militar_SC militar_SE militar_TO civil, a(id_states ano month weekday) vce(cl id_states)
estimates store strike_uf_women
outreg2 using "$outputs\tab_UF.xls", append ctitle(Women) label

reghdfe daily_homicides_firearms militar_AL militar_AM militar_BA militar_CE militar_ES militar_MA militar_PA militar_PB militar_PE militar_PI militar_PR militar_RN militar_RO militar_RR militar_SC militar_SE militar_TO civil, a(id_states ano month weekday) vce(cl id_states)
estimates store strike_uf_firearms
outreg2 using "$outputs\tab_UF.xls", append ctitle(Women) label

// Coefplot - Strikes by UF

coefplot strike_uf, bylabel(Total)||strike_uf_men, bylabel(Homicides - Men)||strike_uf_women, bylabel(Homicides - Women)||, drop(_cons civil) xline(0, lpattern(dash))  ciopts(recast(rcap)) byopts(row(1) xrescale) order(militar_BA militar_CE militar_PA militar_ES militar_PE militar_RN militar_AM militar_SC militar_PB militar_MA militar_RR militar_PI militar_TO militar_AL militar_RO militar_SE militar_PR)

graph export "$outputs\results_uf.jpg", as(jpg) name("Graph") quality(100) replace


**** PLACEBO TEST - TRAFFIC ACCIDENTS ****

// Data Previously dowloaded from SIM-DATASUS 
merge m:m sigla_uf date using "$data\Transito.dta"

drop if _merge==2
replace homicides_transito =0 if homicides_transito ==.
replace homicides_pedestres =0 if homicides_pedestres ==.
replace homicides_ciclistas =0 if homicides_ciclistas ==.
replace homicides_motociclistas =0 if homicides_motociclistas ==.
drop _merge

qui reghdfe homicides_transito militar civil, absorb(id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\placebo_traffic.xls", replace ctitle(Traffic Accident) label 

qui reghdfe homicides_pedestres militar civil, absorb(id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\placebo_traffic.xls", append ctitle(Pedestres) label 

qui reghdfe homicides_ciclistas militar civil, absorb(id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\placebo_traffic.xls", append ctitle(Ciclistas) label 

qui reghdfe homicides_motociclistas militar civil, absorb(id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\placebo_traffic.xls", append ctitle(Motociclistas) label 



**** Testing strike lenght heterogeneity ****

// Data manually organized from the pdf Balanço das Greves (DIEESE)
merge m:m sigla_uf date using "$data\timing_strikes.dta"

drop if _merge==2
replace time_short =0 if time_short==.
replace time_medium =0 if time_medium==.
replace time_longer =0 if time_longer ==.
drop _merge




**** ROBUSTNESS: Poisson Estimates ****
qui ppmlhdfe daily_homicides militar civil, absorb(id_states ano month weekday) irr vce(cluster id_states)
outreg2 using "$outputs\poisson.xls", replace ctitle(Total) label 

qui ppmlhdfe daily_homicides_men militar civil, absorb(id_states ano month weekday) irr vce(cluster id_states)
outreg2 using "$outputs\poisson.xls", append ctitle(Men) label 

qui ppmlhdfe daily_homicides_women militar civil, absorb(id_states ano month weekday) irr vce(cluster id_states)
outreg2 using "$outputs\poisson.xls", append ctitle(Woen) label 



**************************** EVENT STUDY ******************************

// Clarke and Tapia-Schythe (2021)

// Baseline - All States

*** Total Homicides ***
qui eventdd daily_homicides i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides") xlabel(-15(3)15) leg(off))
graph export "$outputs\es_baseline.jpg", as(jpg) name("Graph") quality(100) replace


*** Strike Length***
qui eventdd daily_homicides i.id_states##c.ano, hdfe timevar(time_short) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides") xlabel(-15(3)15))
graph export "$outputs\es_short_strikes.jpg", as(jpg) name("Graph") quality(100) replace

qui eventdd daily_homicides i.id_states##c.ano, hdfe timevar(time_medium) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides") xlabel(-15(3)15))
graph export "$outputs\es_medium_strikes.jpg", as(jpg) name("Graph") quality(100) replace

qui eventdd daily_homicides i.id_states##c.ano, hdfe timevar(time_longer) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides") xlabel(-15(3)15))
graph export "$outputs\es_long_strikes.jpg", as(jpg) name("Graph") quality(100) replace


*** MEN ***
qui eventdd daily_homicides_men i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides") xlabel(-15(3)15))
graph export "$outputs\es_deaths_men.jpg", as(jpg) name("Graph") quality(100) replace


*** WOMEN ***
qui eventdd daily_homicides_women i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides")xlabel(-15(3)15))
graph export "$outputs\es_deaths_women.jpg", as(jpg) name("Graph") quality(100) replace


*** Non White ***
qui eventdd daily_homicides_nw i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides")xlabel(-15(3)15))
graph export "$outputs\es_race.jpg", as(jpg) name("Graph") quality(100) replace


*** Street ***
qui eventdd daily_homicides_street i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides")xlabel(-15(3)15))
graph export "$outputs\es_deaths_streets.jpg", as(jpg) name("Graph") quality(100) replace


*** Firearms ***
qui eventdd daily_homicides_firearms i.id_states##c.ano, hdfe timevar(timetothreat) ci(rcap) cluster(id_states) absorb(i.id_states i.ano i.month i.weekday) inrange lags(15) leads(15) noline graph_op(ytitle("Daily Homicides")xlabel(-15(3)15))
graph export "$outputs\es_firearms.jpg", as(jpg) name("Graph") quality(100) replace

// Event Study by States

// List of States
local estados AL AM BA CE ES MA PA PB PE PI PR RN RO RR SC SE TO


*** Total Homicides ***
foreach uf in `estados' {
    * Executa o event study para o estado atual
    eventdd daily_homicides if sigla_uf == "`uf'", ///
        hdfe timevar(timetothreat) ci(rcap) ///
        absorb(i.ano i.month i.weekday) ///
        inrange lags(15) leads(15) noline ///
        graph_op(ytitle("Daily Homicides") xlabel(-15(3)15) ///
                 title("Daily Homicides `uf'") legend(off))
    
    * Exporta o gráfico para o estado atual
    graph export "$outputs/es_`uf'.jpg", as(jpg) name("Graph") quality(100) replace
}




****** (Robustness) Testing the French Estimator ******

did_multiplegt_dyn daily_homicides id_states date militar, effects(7) placebo(7) normalized trends_lin save_results("$outputs\did_multiplegt_dyn.dta")


***** (Robustness) Municipality Level *****

clear

// Data Previously dowloaded from SIM-DATASUS 
use "$data\Daily_Homicides.dta"


duplicates drop id date, force
encode id_ocorrencia_municipio, gen (id_city)
encode sigla_uf, gen (id_states)
xtset id_city date

label variable daily_homicides "Daily Homicides"
label variable daily_homicides_men "Men"
label variable daily_homicides_nw "Non White"
label variable daily_homicides_young "Under 25"
label variable daily_homicides_street "Streets"
label variable daily_homicides_firearms "Firearms"
label variable daily_homicides_white_arms "Weapons"
label variable daily_homicides_agression "Body Injuries"



**** CITY HETEROGENEITY ****

qui reghdfe daily_homicides militar civil, absorb(id_city id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\reg_cities.xls", replace ctitle(Baseline) label 


/// Greater than 500k pop.
preserve

keep if d_500k==1

qui reghdfe daily_homicides militar civil, absorb(id_city id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\reg_cities.xls", append ctitle(> 500k) label 

restore


/// Greater than 100k pop.
preserve

keep if d_100_500k==1

qui reghdfe daily_homicides militar civil, absorb(id_city id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\reg_cities.xls", append ctitle(100-500k) label 

restore


/// Lower than 100k pop.
preserve

drop if d_capital==1
drop if d_500k==1
drop if d_100_500k==1

qui reghdfe daily_homicides militar civil, absorb(id_city id_states ano month weekday) vce(cluster id_states)
outreg2 using "$outputs\reg_cities.xls", append ctitle(< 100k) label 

restore

