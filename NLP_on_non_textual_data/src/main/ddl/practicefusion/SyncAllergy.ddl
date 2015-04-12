drop table if exists practice_fusion_raw.SyncAllergy;
create external table practice_fusion_raw.SyncAllergy(
  AllergyGuid string,
  PatientGuid string,
  AllergyType string,
  StartYear int,
  ReactionName string,
  SeverityName string,
  MedicationNDCCode string,
  MedicationName string,
  UserGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncAllergy'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncAllergy;
create table practice_fusion.SyncAllergy 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncAllergy'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncAllergy;
