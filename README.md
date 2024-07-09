This is a public version of the replication package for the paper "When the State steps down: reduced police surveillance and gang related deaths in Brazil".

# Table of Contents

1. Data sources, collection and cleaning
2. State Level Analysis
3. Case Study

## Data sources, collection and cleaning
> [!IMPORTANT]
> The data collection can take from hour to days depending on the computational performance of each user. Hence, for the reader interesting only in the coding, all files are available at [Bases](Bases)

* [Violent Deaths](Scrapping/DataSUS/Code.R) dowloads data on homicides released by the Ministry of Health (SIM-DataSUS) using the API ["Base dos Dados"](https://basedosdados.org/dataset/5beeec93-cbf3-43f6-9eea-9bee6a0d1683?table=e9bf5a22-ae7b-4078-b5ff-7f383d38a33a). It also downloads the deaths caused by traffic accdidents used as falsification test in the empirical analysis.
> [!WARNING]
> To use the API "Base dos Dados" it is necessary a Google Cloud account.

* [Strikes of Police Forces](Scrapping/DIEESE/strikes.xlsx) shows all ocurrences of police force strikes in Brazil from 2000 to 2020. (Scrapping/DIEESE/militar.pdf) and (Scrapping/DIEESE/civil.pdf) show the original files obtained from the report ["Balanço das Greves - DIEESE"]([https://www.dieese.org.br/balancodasgreves/2024/estPesq109Greves.pdf](https://www.dieese.org.br/sitio/buscaDirigida?comboBuscaDirigida=TEMA%7Chttp%3A%2F%2Fwww.dieese.org.br%2F2012%2F12%2Fdieese%23T356954348))
 
* [Criminal Records (Download)](Scrapping/Criminal_Justice/TJCeara.py) code to search cases filled in the state judiciary. The outputs are html files with the results of the search for each individual.
  
* [Criminal Records (Cleaning)](Scrapping/Criminal_Justice/Code.R) read the pages downloaded from the state judiciary and creates an indicator for crime engagement (e.g. sentencing for robberies, drug trafficking, etc.). I test four different specifications to track suspected criminals.

* [Detailed Criminal data for Ceará](Scrapping/SSPDS-CE) shows the detailed data on Homicides, Robberies and Other Crimes at the security area ("AIS") level for the state of Ceará. Most files were published in the [state security secretary website](https://www.sspds.ce.gov.br/estatisticas-2-3/). I manually converted these files to excel and consolidate it in the spreadsheet (Bases/Painel.xlsx) with the indicator for possible criminal association.

    
