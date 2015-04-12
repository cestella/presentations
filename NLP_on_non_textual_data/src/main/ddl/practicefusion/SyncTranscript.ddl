drop table if exists practice_fusion_raw.SyncTranscript;
create external table practice_fusion_raw.SyncTranscript(
  TranscriptGuid string,
  PatientGuid string,
  VisitYear string,
  Height string,
  Weight string,
  BMI string,
  SystolicBP string,
  DiastolicBP string,
  RespiratoryRate string,
  HeartRate string,
  Temperature string,
  PhysicianSpecialty string,
  UserGuid string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncTranscript'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncTranscript;
create table practice_fusion.SyncTranscript 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncTranscript'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncTranscript;
