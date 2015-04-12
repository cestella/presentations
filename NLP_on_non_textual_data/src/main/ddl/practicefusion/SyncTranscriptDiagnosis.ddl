drop table if exists practice_fusion_raw.SyncTranscriptDiagnosis;
create external table practice_fusion_raw.SyncTranscriptDiagnosis(
  TranscriptDiagnosisGuid string,
  TranscriptGuid string,
  DiagnosisGuid string,
  OrderBy int
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncTranscriptDiagnosis'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncTranscriptDiagnosis;
create table practice_fusion.SyncTranscriptDiagnosis 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncTranscriptDiagnosis'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncTranscriptDiagnosis;
