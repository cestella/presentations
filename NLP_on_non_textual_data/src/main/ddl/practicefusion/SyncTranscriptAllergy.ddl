drop table if exists practice_fusion_raw.SyncTranscriptAllergy;
create external table practice_fusion_raw.SyncTranscriptAllergy(
  TranscriptAllergyGuid string,
  TranscriptGuid string,
  AllergyGuid string,
  DisplayOrder string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncTranscriptAllergy'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncTranscriptAllergy;
create table practice_fusion.SyncTranscriptAllergy 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncTranscriptAllergy'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncTranscriptAllergy;
