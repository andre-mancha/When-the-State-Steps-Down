This is the public version of the replication package for the paper "When the State Steps Down: Reduced Police Surveillance and Gang-Related Deaths in Brazil."

# Table of Contents

1. Data sources
2. State Level Analysis
3. Case Study

## Data sources, collection and cleaning
> [!IMPORTANT]
> Please note that data collection can take from a few hours to several days, depending on the computational performance. For readers interested only in the coding, all files are readily available at [Bases](Bases).

> [!WARNING]
> To use the "Base dos Dados" API, you will need a Google Cloud account and must set up a billing project.

* [Violent Deaths:](Scrapping/DataSUS/Code.R) this code dowloads data on homicides released by the Ministry of Health (SIM-DataSUS) using the API ["Base dos Dados"](https://basedosdados.org/dataset/5beeec93-cbf3-43f6-9eea-9bee6a0d1683?table=e9bf5a22-ae7b-4078-b5ff-7f383d38a33a). It also downloads the deaths caused by traffic accdidents used as falsification test in the empirical analysis.

* [Strikes of Police Forces:](Scrapping/DIEESE/strikes.xlsx) this file shows all ocurrences of police force strikes in Brazil from 2000 to 2020 that I manually consolidate in a spreadsheet. [Militar.pdf](Scrapping/DIEESE/militar.pdf) and [Civil.pdf](Scrapping/DIEESE/civil.pdf) are the original files obtained from the report ["Balanço das Greves - DIEESE"]([https://www.dieese.org.br/balancodasgreves/2024/estPesq109Greves.pdf](https://www.dieese.org.br/sitio/buscaDirigida?comboBuscaDirigida=TEMA%7Chttp%3A%2F%2Fwww.dieese.org.br%2F2012%2F12%2Fdieese%23T356954348))
 
* [Criminal Records (Download):](Scrapping/Criminal_Justice/TJCeara.py) this code searches for cases filed in the state judiciary. The outputs are HTML files containing the search results for each individual.
  
* [Criminal Records (Cleaning):](Scrapping/Criminal_Justice/Code.R) The code reads the html pages downloaded from the state judiciary and creates an indicator for criminal engagement (e.g., sentencing for robberies, drug trafficking, etc.). I test four different specifications to track suspected criminals.

* [Detailed Criminal data for Ceará:](Scrapping/SSPDS-CE) shows the detailed data on Homicides, Robberies and Other Crimes at the security area ("AIS") level for the state of Ceará. The files were dowloaded from the [state security secretary website](https://www.sspds.ce.gov.br/estatisticas-2-3/). I manually converted these files to excel and consolidate it in the spreadsheet [Painel.xlsx](Bases/Painel.xlsx) with the indicator for possible criminal association.

## State Level Analysis
- [The effect of police strikes in Brazilian states](State_Level.do): this code performs all empirical analysis for the effect of police strikes across Brazilian states, including tables and figures for the mains results and robustness tests.
  - **Inputs:** Daily_Homicides.dta, Daily_Homicides_UF.dta, Transito.dta, and timing_strikes.dta. All files available at [Bases](Bases) 
  - **Outputs:** tab_Gender_UF.xls, tab_Race_UF.xls, tab_Age_UF.xls, tab_Location_UF.xls, tab_weapon_UF.xls, tab_UF.xls, placebo_traffic.xls, reg_cities.xls, poisson.xls, fig_main_results.jpg, results_uf.jpg, es_baseline.jpg, es_short_strikes.jpg, es_medium_strikes.jpg, es_long_strikes.jpg, es_deaths_men.jpg, es_deaths_women.jpg, es_race.jpg, es_deaths_streets.jpg, es_firearms.jpg, es_`uf'.jpg, and did_multiplegt_dyn.dta

## Case Study
- [The effect of police strikes across Gang Turgs ins Ceará](Code_Ceara.do): this code performs all empirical analysis for the effect of police strikes across gang turfs in Ceará, including tables and figures for the mains results and robustness tests.
  - **Inputs:** Painel.xlsx, Gang_Turfs.xlsx, CVP.xlsx, and DataSUS_Ceara.xlsx All files available at [Bases](Bases) 
  - **Outputs:** table_ceara.xlsx, table_ceara2.xls, table_ceara3.xls, table_ceara4.xls, random_treat_ceara.xls, cvp.xls, gang_districts.png, gang_districts_pop.png, coefplot_top_quartile.png, trends_top_quartile.png, coefplot_median.png, trends_median.png, coefplot_top_quartile2.png, trends_top_quartile2.png, coefplot_median2.png, trends_median2.png, trends_placebo.png, event_study_AIS.png, did_multiplegt_dyn_ceara.png, and Comparative_Strikes.png 


