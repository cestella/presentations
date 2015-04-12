add jar ./csv-serde-1.1.2-0.11.0-all.jar;
drop table if exists practice_fusion_raw.SyncSmokingStatus;
create external table practice_fusion_raw.SyncSmokingStatus(
  SmokingStatusGuid string,
  Description string,
  NISTcode int
) row format serde 'com.bizo.hive.serde.csv.CSVSerde'
location '/etl/ds/practice_fusion/input/SyncSmokingStatus'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncSmokingStatus;
create table practice_fusion.SyncSmokingStatus 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncSmokingStatus'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncSmokingStatus;
