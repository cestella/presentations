drop table if exists practice_fusion_raw.SyncDiagnosis;
create external table practice_fusion_raw.SyncDiagnosis(
  DiagnosisGuid string,
  PatientGuid string,
  ICD9Code string,
  DiagnosisDescription string,
  StartYear string,
  StopYear string,
  Acute int,
  UserGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncDiagnosis'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncDiagnosis;
create table practice_fusion.SyncDiagnosis 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncDiagnosis'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncDiagnosis;
