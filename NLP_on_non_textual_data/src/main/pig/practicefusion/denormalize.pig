register 'ndc.py' using jython as ndc;
DEFINE HCatLoader org.apache.hive.hcatalog.pig.HCatLoader();

vitals = load 'practice_fusion.synctranscript' using HCatLoader;

vitals_height = foreach vitals generate transcriptguid as transcriptid
                                      , patientguid as patientid
                                      , 'vitals' as data_type
                                      , 'height' as name
                                      , height as value
                                      , 'in' as uom
                                      , 'numeric' as value_type
                                      , '' as metadata
                                      ;
vitals_weight = foreach vitals generate transcriptguid as transcriptid
                                      , patientguid as patientid
                                      , 'vitals' as data_type
                                      , 'weight' as name
                                      , weight as value
                                      , 'lb' as uom
                                      , 'numeric' as value_type
                                      , '' as metadata
                                      ;
vitals_bmi = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'bmi' as name
                                   , bmi as value
                                   , 'lb/in^2' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;
vitals_bp_systolic = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'bp_systolic' as name
                                   , systolicbp as value
                                   , 'mm hg' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;

vitals_bp_diastolic = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'bp_diastolic' as name
                                   , diastolicbp as value
                                   , 'mm hg' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;

vitals_resp = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'resp_rate' as name
                                   , respiratoryrate as value
                                   , 'breaths/s' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;
vitals_hr = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'heart_rate' as name
                                   , heartrate as value
                                   , 'beats/s' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;

vitals_temp = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'vitals' as data_type
                                   , 'temp' as name
                                   , temperature as value
                                   , 'degrees farenheit/centigrade' as uom
                                   , 'numeric' as value_type
                                   , '' as metadata
                                   ;
vitals_speciality = foreach vitals generate transcriptguid as transcriptid
                                   , patientguid as patientid
                                   , 'provider' as data_type
                                   , 'specialty' as name
                                   , physicianspecialty as value
                                   , 'n' as uom
                                   , 'categorical' as value_type
                                   , '' as metadata
                                   ;


allergy = load 'practice_fusion.syncallergy' using HCatLoader;
allergy_link = load 'practice_fusion.synctranscriptallergy' using HCatLoader;

allergy_j = join allergy by allergyguid, allergy_link by allergyguid;

allergy_reaction = foreach allergy_j generate allergy_link::transcriptguid as transcriptid
                                             , patientguid as patientid
                                             , 'allergy' as data_type
                                             , CONCAT('reaction/', reactionname) as name
                                             , severityname as value
                                             , 'n' as uom
                                             , 'categorical' as value_type
                                             , '' as metadata
                                             ;
allergy_drug_name = foreach allergy_j generate allergy_link::transcriptguid as transcriptid
                                             , patientguid as patientid
                                             , 'rx' as data_type
                                             , '' as name
                                             , ndc.convert_ndc(medicationndccode) as value
                                             , 'ndc' as uom
                                             , 'categorical' as value_type
                                             , '' as metadata
                                             ;

dx = load 'practice_fusion.syncdiagnosis' using HCatLoader;
dx_link = load 'practice_fusion.synctranscriptdiagnosis' using HCatLoader;

dx_j= join dx by diagnosisguid, dx_link by diagnosisguid;

dx_diag = foreach dx_j generate dx_link::transcriptguid as transcriptid
                                  , patientguid as patientid
                                  , 'dx' as data_type
                                  , icd9code as name
                                  , '' as value
                                  , 'n' as uom
                                  , 'categorical' as value_type
                                  , '' as metadata
                                  ;

rx = load 'practice_fusion.syncmedication' using HCatLoader;
rx_link = load 'practice_fusion.synctranscriptmedication' using HCatLoader;

rx_j= join rx by medicationguid, rx_link by medicationguid;

rx_med = foreach rx_j generate rx_link::transcriptguid as transcriptid
                             , patientguid as patientid
                             , 'rx' as data_type
                             , '' as name
                             , ndc.convert_ndc(ndccode) as value
                             , 'ndc' as uom
                             , 'categorical' as value_type
                             , '' as metadata
                             ;


lab_result = load 'practice_fusion.synclabresult' using HCatLoader;
lab_panel = load 'practice_fusion.synclabpanel' using HCatLoader;
lab_obs = load 'practice_fusion.synclabobservation' using HCatLoader;

lab_r_p_j = join lab_result by labresultguid, lab_panel by labresultguid;
lab_int_proj = foreach lab_r_p_j generate lab_result::transcriptguid as transcriptguid
                                        , lab_result::patientguid as patientguid
                                        , lab_panel::labpanelguid as labpanelguid
                                        ;
lab_r_p_o_j = join lab_int_proj by labpanelguid, lab_obs by labpanelguid;
lab_all_proj = foreach lab_r_p_o_j generate transcriptguid as transcriptid
                                          , patientguid as patientid
                                          , 'lab' as data_type
                                          , hl7identifier as name
                                          , observationvalue as value
                                          , units as uom
                                          , 'mixed/numeric' as value_type
                                          , abnormalflags as metadata
                                          ;

processed = union vitals_height
                , vitals_weight
                , vitals_bmi
                , vitals_bp_systolic
                , vitals_bp_diastolic
                , vitals_resp
                , vitals_hr
                , vitals_temp
                , vitals_speciality
                , allergy_reaction
                , allergy_drug_name
                , dx_diag
                , rx_med
                , lab_all_proj
                ;

rmf practice_fusion/denormalized
STORE processed into 'practice_fusion/denormalized' using PigStorage('\t');

--split processed into numeric if (double)value is not null, non_numeric otherwise;


--rmf practice_fusion/intermediate_raw
--STORE processed into 'practice_fusion/intermediate_raw' using PigStorage('\t');
--
--processed_test_filt = filter processed by (double)value is not null;
--rmf practice_fusion/intermediate_test
--STORE processed_test_filt into 'practice_fusion/intermediate_test' using PigStorage('\t');
--
