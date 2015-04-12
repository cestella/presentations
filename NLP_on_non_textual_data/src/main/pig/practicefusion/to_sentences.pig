register 'annotation.py' using jython as util;

register /usr/hdp/current/pig-client/lib/datafu.jar

processed = load 'practice_fusion/$input' using PigStorage('\t') as ( transcriptid:chararray
                                                                    , patientid:chararray
                                                                    , data_type:chararray
                                                                    , name:chararray
                                                                    , value:chararray
                                                                    , uom:chararray
                                                                    , value_type:chararray
                                                                    , metadata:chararray
                                                                    );
split processed into drugs_raw if data_type == 'rx', non_drugs otherwise;
drugs = foreach drugs_raw generate value;
drugs_grp = group drugs by value;
drugs_cnt = foreach drugs_grp generate group as value, COUNT(drugs) as cnt;
drugs_valid = filter drugs_cnt by cnt > $min_drug;
--drugs_valid = filter drugs_cnt by cnt > 90;
drugs_j = join drugs_valid by value, drugs_raw by value;
drugs_final = foreach drugs_j generate drugs_raw::transcriptid as transcriptid
                                     , drugs_raw::patientid as patientid
                                     , drugs_raw::data_type as data_type
                                     , drugs_raw::name as name
                                     , drugs_raw::value as value
                                     , drugs_raw::uom as uom
                                     , drugs_raw::value_type as value_type
                                     , drugs_raw::metadata as metadata
                                     ;
processed_final = union non_drugs, drugs_final;

STRS = foreach processed_final generate transcriptid
                                , patientid
                                , util.row_to_string(data_type, name, value) as str
                                ;

STRS_G = group STRS by (transcriptid, patientid);

OUT = foreach STRS_G {
  AGG = foreach STRS generate str;
  generate util.group_to_string(AGG) as str;
}

rmf practice_fusion/$output
store OUT into 'practice_fusion/$output' using PigStorage('\t');
