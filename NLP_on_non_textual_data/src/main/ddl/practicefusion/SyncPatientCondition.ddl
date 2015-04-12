drop table if exists practice_fusion_raw.SyncPatientCondition;
create external table practice_fusion_raw.SyncPatientCondition(
  PatientConditionGuid string,
  PatientGuid string,
  ConditionGuid string,
  CreatedYear string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncPatientCondition'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncPatientCondition;
create table practice_fusion.SyncPatientCondition 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncPatientCondition'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncPatientCondition;
