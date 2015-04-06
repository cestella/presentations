set hive.exec.dynamic.partition.mode=nonstrict;
SET hive.execution.engine=tez;
SET hive.optimize.sort.dynamic.partition=true;
use open_payments;
DROP TABLE IF EXISTS general_raw;
CREATE EXTERNAL TABLE general_raw (
  General_Transaction_ID STRING,
  Program_Year STRING,
  Payment_Publication_Date STRING,
  Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name STRING,
  Covered_Recipient_Type STRING,
  Teaching_Hospital_ID STRING,
  Teaching_Hospital_Name STRING,
  Physician_Profile_ID STRING,
  Physician_First_Name STRING,
  Physician_Middle_Name STRING,
  Physician_Last_Name STRING,
  Physician_Name_Suffix STRING,
  Recipient_Primary_Business_Street_Address_Line1 STRING,
  Recipient_Primary_Business_Street_Address_Line2 STRING,
  Recipient_City STRING,
  Recipient_State STRING,
  Recipient_Zip_Code STRING,
  Recipient_Country STRING,
  Recipient_Province STRING,
  Recipient_Postal_Code STRING,
  Physician_Primary_Type STRING,
  Physician_Specialty STRING,
  Physician_License_State_code1 STRING,
  Physician_License_State_code2 STRING,
  Physician_License_State_code3 STRING,
  Physician_License_State_code4 STRING,
  Physician_License_State_code5 STRING,
  Product_Indicator STRING,
  Name_of_Associated_Covered_Drug_or_Biological1 STRING,
  Name_of_Associated_Covered_Drug_or_Biological2 STRING,
  Name_of_Associated_Covered_Drug_or_Biological3 STRING,
  Name_of_Associated_Covered_Drug_or_Biological4 STRING,
  Name_of_Associated_Covered_Drug_or_Biological5 STRING,
  NDC_of_Associated_Covered_Drug_or_Biological1 STRING,
  NDC_of_Associated_Covered_Drug_or_Biological2 STRING,
  NDC_of_Associated_Covered_Drug_or_Biological3 STRING,
  NDC_of_Associated_Covered_Drug_or_Biological4 STRING,
  NDC_of_Associated_Covered_Drug_or_Biological5 STRING,
  Name_of_Associated_Covered_Device_or_Medical_Supply1 STRING,
  Name_of_Associated_Covered_Device_or_Medical_Supply2 STRING,
  Name_of_Associated_Covered_Device_or_Medical_Supply3 STRING,
  Name_of_Associated_Covered_Device_or_Medical_Supply4 STRING,
  Name_of_Associated_Covered_Device_or_Medical_Supply5 STRING,
  Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name STRING,
  Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID STRING,
  Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State STRING,
  Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country STRING,
  Dispute_Status_for_Publication STRING,
  Total_Amount_of_Payment_USDollars DOUBLE,
  Date_of_Payment STRING,
  Number_of_Payments_Included_in_Total_Amount INT,
  Form_of_Payment_or_Transfer_of_Value STRING,
  Nature_of_Payment_or_Transfer_of_Value STRING,
  City_of_Travel STRING,
  State_of_Travel STRING,
  Country_of_Travel STRING,
  Physician_Ownership_Indicator STRING,
  Third_Party_Payment_Recipient_Indicator STRING,
  Name_of_Third_Party_Entity_Receiving_Payment_or_Transfer_of_Value STRING,
  Charity_Indicator STRING,
  Third_Party_Equals_Covered_Recipient_Indicator STRING,
  Contextual_Information STRING,
  Delay_in_Publication_of_General_Payment_Indicator STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
STORED AS TEXTFILE
LOCATION '/etl/ds/open_payments/general/raw'
tblproperties ("skip.header.line.count"="1")
;

drop table if exists open_payments.general;
create table open_payments.general ( physician_id string
                                   , payer string
                                   , amount double
                                   , physician_specialty string)
PARTITIONED BY (reason string)
stored as orc
LOCATION '/etl/ds/open_payments/general/post'
tblproperties ( "orc.compress"="SNAPPY"
              , "orc.compress.size"="8192"
);

INSERT OVERWRITE TABLE open_payments.general PARTITION(reason)
select Physician_Profile_ID as physician_id
     , Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name as payer
     , Total_Amount_of_Payment_USDollars  as amount
     , Physician_Specialty as physician_specialty
     , regexp_replace(Nature_of_Payment_or_Transfer_of_Value, '[ ,]+', '_') as reason
from open_payments.general_raw
where LENGTH(Nature_of_Payment_or_Transfer_of_Value) > 3 
  and LENGTH(Physician_Profile_ID) > 3 
  and LENGTH(Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name) > 3;
