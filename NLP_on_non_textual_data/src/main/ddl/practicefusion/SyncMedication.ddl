drop table if exists practice_fusion_raw.SyncMedication;
create external table practice_fusion_raw.SyncMedication(
  MedicationGuid string,
  PatientGuid string,
  NdcCode string,
  MedicationName string,
  MedicationStrength string,
  Schedule string,
  DiagnosisGuid string,
  UserGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncMedication'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncMedication;
create table practice_fusion.SyncMedication 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncMedication'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncMedication;
