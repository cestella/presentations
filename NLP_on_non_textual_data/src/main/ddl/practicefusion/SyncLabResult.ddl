drop table if exists practice_fusion_raw.SyncLabResult;
create external table practice_fusion_raw.SyncLabResult(
  LabResultGuid string,
  UserGuid string,
  PatientGuid string,
  TranscriptGuid string,
  PracticeGuid string,
  FacilityGuid string,
  ReportYear string,
  AncestorLabResultGuid string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncLabResult'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncLabResult;
create table practice_fusion.SyncLabResult 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncLabResult'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncLabResult;
