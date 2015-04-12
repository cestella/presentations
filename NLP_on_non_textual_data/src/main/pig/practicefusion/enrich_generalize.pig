register 'drug.py' using jython as drug;

DEFINE HCatLoader org.apache.hive.hcatalog.pig.HCatLoader();

processed = load 'practice_fusion/grouped' using PigStorage('\t') as ( transcriptid:chararray
                                                                     , patientid:chararray
                                                                     , data_type:chararray
                                                                     , name:chararray
                                                                     , value:chararray
                                                                     , uom:chararray
                                                                     , value_type:chararray
                                                                     , metadata:chararray
                                                                     );
split processed into drugs if uom == 'ndc', non_drugs otherwise;

SYNCMED = load 'practice_fusion.syncmedication' using HCatLoader;
ndc_to_name = foreach SYNCMED generate ndccode as ndc
                                     , drug.drug_name(medicationname) as name
                                     ;
ndc_dist = distinct ndc_to_name;
ndc_map = filter ndc_dist by SIZE(name) > 0;

DRUGS_J = join drugs by value, ndc_map by ndc;
drugs_agg = foreach DRUGS_J generate transcriptid
                                   , patientid
                                   , data_type
                                   , '' as name
                                   , ndc_map::name as value
                                   , 'custom' as uom
                                   , value_type
                                   , metadata
                                   ;

U = union drugs_agg, non_drugs;
OUT = filter U by name is not null and name != 'NULL';

rmf practice_fusion/nlp_normalized
store OUT into 'practice_fusion/nlp_normalized' using PigStorage('\t');
