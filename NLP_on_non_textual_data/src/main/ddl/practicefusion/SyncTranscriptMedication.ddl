drop table if exists practice_fusion_raw.SyncTranscriptMedication;
create external table practice_fusion_raw.SyncTranscriptMedication(
  TranscriptMedicationGuid string,
  TranscriptGuid string,
  MedicationGuid string,
  OrderBy int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncTranscriptMedication'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncTranscriptMedication;
create table practice_fusion.SyncTranscriptMedication 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncTranscriptMedication'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncTranscriptMedication;
