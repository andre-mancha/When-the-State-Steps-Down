
# Packages Required -------------------------------------------------------

rm(list = ls())

Packages <- c("dplyr", "ggplot2", "readxl", "readr","ggpubr","tidyverse","purrr","gtools","collapse","formattable","lfe","did","geosphere",
              "tidygeocoder","sf","raster","geobr","stringr","lwgeom","plyr","tidyr","sp","rgeos","zoo","reshape2","vroom","basedosdados","plm")

lapply(Packages, library, character.only = TRUE)

# Import SIM data ---------------------------------------------------------

# Set your working directory
setwd("YOUR DIRECTORY HERE")

# Inform your project in Google Cloud
set_billing_id("YOUR PROJECT HERE")

# Query to download daily homicides for all Brazilian States
query <- "SELECT * FROM `basedosdados.br_ms_sim.microdados` WHERE ano in (2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020) AND 
causa_basica in ('X850','X851','X852','X853','X854','X855','X856','X857','X858','X859','X860','X861','X862','X863','X864','X865','X866','X867','X868','X869','X870','X871','X872','X873','X874','X875','X876','X877','X878','X879','X880','X881','X882','X883','X884','X885','X886','X887','X888','X889','X890','X891','X892','X893','X894','X895','X896','X897','X898','X899','X900','X901','X902','X903','X904','X905','X906','X907','X908','X909','X910','X911','X912','X913','X914','X915','X916','X917','X918','X919','X920','X921','X922','X923','X924','X925','X926','X927','X928','X929','X930','X931','X932','X933','X934','X935','X936','X937','X938','X939','X940','X941','X942','X943','X944','X945','X946','X947','X948','X949','X950','X951','X952','X953','X954','X955','X956','X957','X958','X959','X960','X961','X962','X963','X964','X965','X966','X967','X968','X969','X970','X971','X972','X973','X974','X975','X976','X977','X978','X979','X980','X981','X982','X983','X984','X985','X986','X987','X988','X989','X990','X991','X992','X993','X994','X995','X996','X997','X998','X999','Y000','Y001','Y002','Y003','Y004','Y005','Y006','Y007','Y008','Y009','Y010','Y011','Y012','Y013','Y014','Y015','Y016','Y017','Y018','Y019','Y020','Y021','Y022','Y023','Y024','Y025','Y026','Y027','Y028','Y029','Y030','Y031','Y032','Y033','Y034','Y035','Y036','Y037','Y038','Y039','Y040','Y041','Y042','Y043','Y044','Y045','Y046','Y047','Y048','Y049','Y050','Y051','Y052','Y053','Y054','Y055','Y056','Y057','Y058','Y059','Y060','Y061','Y062','Y068','Y069','Y070','Y071','Y072','Y073','Y078','Y079','Y080','Y081','Y082','Y083','Y084','Y085','Y086','Y087','Y088','Y089','Y090','Y091','Y092','Y093','Y094','Y095','Y096','Y097','Y098','Y099','Y350','Y351','Y352','Y353','Y354','Y355','Y356','Y357','Y360','Y361','Y362','Y363','Y364','Y365','Y366','Y367','Y368','Y369','Y369')"

df <- read_sql(query)

# Merge with Strikes Data (DIEESE) -----------------------------------------------------

strikes <- read_excel("strikes.xlsx",col_types = c("text", "text", "numeric", "date", "numeric"))

strikes$city <- NULL # all strikes are registered at the state level
strikes$...9 <- NULL
strikes$...10 <- NULL
strikes$d <- NULL # using the colune check after confirming all records provided by DIEESE
strikes$link <- NULL
strikes <- unique(strikes) # remove duplicates
strikes <- spread(strikes,key = "class",value = "check") # reshape the dataset to merge with SIM data

strikes$militar[is.na(strikes$militar)] <- 0
strikes$civil[is.na(strikes$civil)] <- 0

# Merge SIM and Strikes ---------------------------------------------------

df <- left_join(df, strikes, by = c("sigla_uf" = "UF","data_obito"="strike"))

pm_strikes <- subset(df, df$militar==1)
civil_strikes <- subset(df,df$civil==1)
pm_civil_strikes <- subset(df,df$civil==1 & df$militar==1)


# Organizing the Data -----------------------------------------------------

# Aggregate at the Municipality Level

# Creating Demographic Variables
df$homicides <- 1 
df$homicides_men <- ifelse(df$sexo==1,1,0)
df$homicides_nonwhite <-ifelse(df$raca_cor!= 1,1,0)
df$homicides_young <- ifelse(df$idade<=15,1,0)
df$homicides_adult <- ifelse(df$idade>15&df$idade<=25,1,0)
df$homicides_adult2 <- ifelse(df$idade>25&df$idade<=45,1,0)
df$homicides_old <- ifelse(df$idade>45,1,0)
df$homicides_street <- ifelse(df$local_ocorrencia==4,1,0)
df$homicides_house <- ifelse(df$local_ocorrencia==3,1,0)
df$homicides_hospitals <- ifelse(df$local_ocorrencia==1|df$local_ocorrencia==2,1,0)

df$causa2 <- substr(df$causa_basica,1,3)
df$homicides_firearms <- ifelse(df$causa2=="X93"|df$causa2=="X94"|df$causa2=="X95",1,0)
df$homicides_white_arms <- ifelse(df$causa2=="X99",1,0)
df$homicides_agression <- ifelse(df$causa2=="Y04",1,0)
df$homicides_rape <- ifelse(df$causa2=="Y05",1,0)
df$homicides_car <- ifelse(df$causa2=="Y03",1,0)
df$homicides_law <- ifelse(df$causa2=="Y35",1,0)

base <- ddply(df, .(ano, data_obito, id_municipio_ocorrencia,sigla_uf), summarise, daily_homicides=sum(homicides),daily_homicides_men=sum(homicides_men),daily_homicides_nw=sum(homicides_nonwhite),daily_homicides_young=sum(homicides_young),daily_homicides_street=sum(homicides_street),daily_homicides_firearms=sum(homicides_firearms),daily_homicides_white_arms=sum(homicides_white_arms),daily_homicides_agression=sum(homicides_agression),daily_homicides_rape=sum(homicides_rape))
base <- left_join(base, strikes, by = c("sigla_uf" = "UF","data_obito"="strike"))

base$city_code <- substr(base$id_municipio_ocor,1,6)
base$id_municipio_ocorrencia <- as.numeric(base$id_municipio_ocorrencia)

# export to csv
write.csv2(base,"Daily_Homicides.csv")

# Aggregate at the State Level

base2 <- ddply(df, .(ano, data_obito,sigla_uf), summarise, daily_homicides=sum(homicides),daily_homicides_men=sum(homicides_men),daily_homicides_nw=sum(homicides_nonwhite),daily_homicides_young=sum(homicides_young),daily_homicides_adult=sum(homicides_adult),daily_homicides_old=sum(homicides_old),daily_homicides_street=sum(homicides_street),daily_homicides_house=sum(homicides_house),daily_homicides_hospitals=sum(homicides_hospitals),daily_homicides_firearms=sum(homicides_firearms),daily_homicides_white_arms=sum(homicides_white_arms),daily_homicides_agression=sum(homicides_agression),daily_homicides_car=sum(homicides_car),daily_homicides_law=sum(homicides_law),daily_homicides_rape=sum(homicides_rape))

base2 <- left_join(base2, strikes, by = c("sigla_uf" = "UF","data_obito"="strike","ano=ano"))

# export to csv
write.csv2(base2,"Daily_Homicides_UF.csv")


# Traffic Accidents ---------------------------------------------------------

# Query for deaths in traffic accidents
query <- "SELECT * FROM `basedosdados.br_ms_sim.microdados` WHERE ano in (2000,2001,2002,2003,2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020) AND 
causa_basica in ('V010','V011','V019','V020','V021','V029','V030','V031','V039','V040','V041','V049','V050','V051','V059','V060','V061','V069','V090','V091','V092','V093','V099','V100','V101','V102','V103','V104','V105','V109','V110','V111','V112','V113','V114','V115','V119','V120','V121','V122','V123','V124','V125','V129','V130','V131','V132','V133','V134','V135','V139','V140','V141','V142','V143','V144','V145','V149','V150','V151','V152','V153','V154','V155','V159','V160','V161','V162','V163','V164','V165','V169','V170','V171','V172','V173','V174','V175','V179','V180','V181','V182','V183','V184','V185','V189','V190','V191','V192','V193','V194','V195','V196','V198','V199','V200','V201','V202','V203','V204','V205','V209','V210','V211','V212','V213','V214','V215','V219','V220','V221','V222','V223','V224','V225','V229','V230','V231','V232','V233','V234','V235','V239','V240','V241','V242','V243','V244','V245','V249','V250','V251','V252','V253','V254','V255','V259','V260','V261','V262','V263','V264','V265','V269','V270','V271','V272','V273','V274','V275','V279','V280','V281','V282','V283','V284','V285','V289','V290','V291','V292','V293','V294','V295','V296','V298','V299','V300','V301','V302','V303','V304','V305','V306','V307','V309','V310','V311','V312','V313','V314','V315','V316','V317','V319','V320','V321','V322','V323','V324','V325','V326','V327','V329','V330','V331','V332','V333','V334','V335','V336','V337','V339','V340','V341','V342','V343','V344','V345','V346','V347','V349','V350','V351','V352','V353','V354','V355','V356','V357','V359','V360','V361','V362','V363','V364','V365','V366','V367','V369','V370','V371','V372','V373','V374','V375','V376','V377','V379','V380','V381','V382','V383','V384','V385','V386','V387','V389','V390','V391','V392','V393','V394','V395','V396','V398','V399','V400','V401','V402','V403','V404','V405','V406','V407','V409','V410','V411','V412','V413','V414','V415','V416','V417','V419','V420','V421','V422','V423','V424','V425','V426','V427','V429','V430','V431','V432','V433','V434','V435','V436','V437','V439','V440','V441','V442','V443','V444','V445','V446','V447','V449','V450','V451','V452','V453','V454','V455','V456','V457','V459','V460','V461','V462','V463','V464','V465','V466','V467','V469','V470','V471','V472','V473','V474','V475','V476','V477','V479','V480','V481','V482','V483','V484','V485','V486','V487','V489','V490','V491','V492','V493','V494','V495','V496','V498','V499','V500','V501','V502','V503','V504','V505','V506','V507','V509','V510','V511','V512','V513','V514','V515','V516','V517','V519','V520','V521','V522','V523','V524','V525','V526','V527','V529','V530','V531','V532','V533','V534','V535','V536','V537','V539','V540','V541','V542','V543','V544','V545','V546','V547','V549','V550','V551','V552','V553','V554','V555','V556','V557','V559','V560','V561','V562','V563','V564','V565','V566','V567','V569','V570','V571','V572','V573','V574','V575','V576','V577','V579','V580','V581','V582','V583','V584','V585','V586','V587','V589','V590','V591','V592','V593','V594','V595','V596','V598','V599','V600','V601','V602','V603','V604','V605','V606','V607','V609','V610','V611','V612','V613','V614','V615','V616','V617','V619','V620','V621','V622','V623','V624','V625','V626','V627','V629','V630','V631','V632','V633','V634','V635','V636','V637','V639','V640','V641','V642','V643','V644','V645','V646','V647','V649','V650','V651','V652','V653','V654','V655','V656','V657','V659','V660','V661','V662','V663','V664','V665','V666','V667','V669','V670','V671','V672','V673','V674','V675','V676','V677','V679','V680','V681','V682','V683','V684','V685','V686','V687','V689','V690','V691','V692','V693','V694','V695','V696','V698','V699','V700','V701','V702','V703','V704','V705','V706','V707','V709','V710','V711','V712','V713','V714','V715','V716','V717','V719','V720','V721','V722','V723','V724','V725','V726','V727','V729','V730','V731','V732','V733','V734','V735','V736','V737','V739','V740','V741','V742','V743','V744','V745','V746','V747','V749','V750','V751','V752','V753','V754','V755','V756','V757','V759')"

df2 <- read_sql(query)

# Creating Dependent Variables to the Falsification Test
df2$homicides_transito <- 1
df2$causa2 <- substr(df2$causa_basica,1,3)
df2$homicides_pedestres <- ifelse(df2$causa2=="V01"|df2$causa2=="V02"|df2$causa2=="V03"|df2$causa2=="V04"|df2$causa2=="V05"|df2$causa2=="V06"|df2$causa2=="V09",1,0)
df2$homicides_ciclistas <- ifelse(df2$causa2=="V10"|df2$causa2=="V11"|df2$causa2=="V12"|df2$causa2=="V13"|df2$causa2=="V14"|df2$causa2=="V15"|df2$causa2=="V16"|df2$causa2=="V17"|df2$causa2=="V18",1,0)
df2$homicides_motociclistas <- ifelse(df2$causa2=="V20"|df2$causa2=="V21"|df2$causa2=="V22"|df2$causa2=="V23"|df2$causa2=="V24"|df2$causa2=="V25"|df2$causa2=="V26"|df2$causa2=="V27"|df2$causa2=="V28",1,0)

base3 <- ddply(df2, .(data_obito,sigla_uf), summarise, homicides_transito=sum(homicides_transito), homicides_pedestres=sum(homicides_pedestres), homicides_ciclistas=sum(homicides_ciclistas), homicides_motociclistas=sum(homicides_motociclistas))

# export to csv
write.csv2(base3,"Transito.csv")


