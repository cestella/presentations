drop table if exists practice_fusion_raw.SyncPatientSmokingStatus;
create external table practice_fusion_raw.SyncPatientSmokingStatus(
  PatientSmokingStatusGuid string,
  PatientGuid string,
  SmokingStatusGuid string,
  EffectiveYear string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncPatientSmokingStatus'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncPatientSmokingStatus;
create table practice_fusion.SyncPatientSmokingStatus 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncPatientSmokingStatus'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncPatientSmokingStatus;
