drop table if exists practice_fusion_raw.SyncLabPanel;
create external table practice_fusion_raw.SyncLabPanel(
  PanelName string,
  LabPanelGuid string,
  LabResultGuid string,
  ObservationYear string,
  Status string
) 
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
location '/etl/ds/practice_fusion/input/SyncLabPanel'
tblproperties ("skip.header.line.count"="1");

drop table if exists practice_fusion.SyncLabPanel;
create table practice_fusion.SyncLabPanel 
stored as orc 
location '/etl/ds/practice_fusion/output/SyncLabPanel'
tblproperties ("orc.compress"="SNAPPY")
as
select * 
from practice_fusion_raw.SyncLabPanel;
