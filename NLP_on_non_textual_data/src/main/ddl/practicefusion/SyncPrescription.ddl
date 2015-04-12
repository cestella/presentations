drop table if exists practice_fusion_raw.SyncPrescription;
create external table practice_fusion_raw.SyncPrescription(
  PrescriptionGuid string,
  PatientGuid string,
  MedicationGuid string,
  PrescriptionYear string,
  Quantity string,
  NumberOfRefills string,
  RefillAsNeeded int,
  GenericAllowed int,
  UserGuid string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncPrescription'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncPrescription;
create table practice_fusion.SyncPrescription
stored as orc
location '/etl/ds/practice_fusion/output/SyncPrescription'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncPrescription;
