drop table if exists practice_fusion_raw.SyncCondition;
create external table practice_fusion_raw.SyncCondition(
  ConditionGuid string,
  Code string,
  Name string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncCondition'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncCondition;
create table practice_fusion.SyncCondition 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncCondition'
tblproperties ("orc.compress"="SNAPPY")
as
select ConditionGuid
     , Code
     , Name 
from practice_fusion_raw.SyncCondition;
