register 'ndc.py' using jython as ndc;

register /usr/hdp/current/pig-client/lib/datafu.jar

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


RXN_CONSO = load 'rxnorm.rxnconso' using HCatLoader;
RXN_SAT = load 'rxnorm.rxnsat' using HCatLoader;
RXN_NDC = filter RXN_SAT by atn == 'NDC';
RX_J = join RXN_CONSO by rxcui, RXN_NDC by rxcui;
RX_LINK = foreach RX_J generate RXN_CONSO::rxcui as rxcui
                              , RXN_NDC::atv as ndc
                              , RXN_CONSO::str as name
                              ;
RX_G = group RX_LINK by (rxcui, ndc);
RX_MAP = foreach RX_G {
  NAMES = foreach RX_LINK generate name;
  NAME = limit NAMES 1;
  generate group.$0 as rxcui, ndc.convert_ndc(group.$1) as ndc, FLATTEN(NAME) as name;
}

DRUGS_J = join drugs by value, RX_MAP by ndc;
drugs_agg = foreach DRUGS_J generate transcriptid
                                   , patientid
                                   , data_type
                                   , '' as name
                                   , RX_MAP::rxcui as value
                                   , 'rxnorm' as uom
                                   , value_type
                                   , metadata
                                   ;

U = union drugs_agg, non_drugs;
OUT = filter U by name is not null and name != 'NULL';

rmf practice_fusion/rxnorm_normalized
store OUT into 'practice_fusion/rxnorm_normalized' using PigStorage('\t');
