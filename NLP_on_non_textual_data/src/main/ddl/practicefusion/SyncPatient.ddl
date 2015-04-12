drop table if exists practice_fusion_raw.SyncPatient;
create external table practice_fusion_raw.SyncPatient(
  PatientGuid string,
  DMIndicator int,
  Gender string,
  YearOfBirth string,
  State string,
  PracticeGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncPatient'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncPatient;
create table practice_fusion.SyncPatient 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncPatient'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncPatient;
