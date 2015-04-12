register 'ndc.py' using jython as ndc;

DEFINE HCatLoader org.apache.hive.hcatalog.pig.HCatLoader();

RXN_CONSO = load 'rxnorm.rxnconso' using HCatLoader;
RXN_SAT = load 'rxnorm.rxnsat' using HCatLoader;
RXN_NDC = filter RXN_SAT by atn == 'NDC';
RX_J = join RXN_CONSO by rxcui, RXN_NDC by rxcui;
RX_LINK = foreach RX_J generate RXN_CONSO::rxcui as rxcui
                              , ndc.convert_ndc(RXN_NDC::atv) as ndc
                              ;
OUT = distinct RX_LINK;
rmf practice_fusion/ndc_to_rxnorm
store OUT into 'practice_fusion/ndc_to_rxnorm' using PigStorage('\t');
