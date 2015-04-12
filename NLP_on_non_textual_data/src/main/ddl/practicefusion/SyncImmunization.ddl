drop table if exists practice_fusion_raw.SyncImmunization;
create external table practice_fusion_raw.SyncImmunization(
  ImmunizationGuid string,
  PatientGuid string,
  VaccineName string,
  AdministeredYear string,
  CvxCode string,
  UserGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncImmunization'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncImmunization;
create table practice_fusion.SyncImmunization 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncImmunization'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncImmunization;
