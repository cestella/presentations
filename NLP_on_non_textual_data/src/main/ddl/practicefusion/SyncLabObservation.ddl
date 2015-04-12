drop table if exists practice_fusion_raw.SyncLabObservation;
create external table practice_fusion_raw.SyncLabObservation(
  HL7Identifier string,
  HL7Text string,
  LabObservationGuid string,
  LabPanelGuid string,
  HL7CodingSystem string,
  ObservationValue string,
  Units string,
  ReferenceRange string,
  AbnormalFlags string,
  ResultStatus string,
  ObservationYear string,
  UserGuid string,
  IsAbnormalValue int
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncLabObservation'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncLabObservation;
create table practice_fusion.SyncLabObservation 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncLabObservation'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncLabObservation;
