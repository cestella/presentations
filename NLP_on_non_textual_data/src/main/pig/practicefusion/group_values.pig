register 'annotation.py' using jython as util;

register /usr/hdp/current/pig-client/lib/datafu.jar

define Quartile datafu.pig.stats.Quantile( '0.0','0.25','0.5','0.75','1.0');

processed = load 'practice_fusion/denormalized' using PigStorage('\t') as ( transcriptid:chararray
                                                                          , patientid:chararray
                                                                          , data_type:chararray
                                                                          , name:chararray
                                                                          , value:chararray
                                                                          , uom:chararray
                                                                          , value_type:chararray
                                                                          , metadata:chararray
                                                                          );
processed_ext = foreach processed generate transcriptid
                                         , patientid
                                         , data_type
                                         , name
                                         , value
                                         , uom
                                         , value_type
                                         , metadata
                                         , (double)value as numeric_value
                                         ;

split processed_ext into numeric_raw if numeric_value is not null and (value_type == 'numeric' or value_type == 'mixed/numeric'), non_numeric otherwise;

--rmf debug/numeric_raw
--store numeric_raw into 'debug/numeric_raw' using PigStorage('\t');
--
numeric = foreach numeric_raw generate data_type as data_type
                                     , name as name
                                     , (double)value as value;

numeric_g = group numeric by (data_type, name);
numeric_quartiles = foreach numeric_g {
  sorted = order numeric by value;
  generate group.$0 as data_type
         , group.$1 as name
         , Quartile(sorted.value) as quartiles;
}
numeric_j = join numeric_raw by (data_type, name), numeric_quartiles by (data_type, name);

numeric_agg = foreach numeric_j generate transcriptid
                                         , patientid
                                         , numeric_raw::data_type as data_type
                                         , numeric_raw::name as name
                                         , util.annotate(numeric_raw::numeric_value, numeric_quartiles::quartiles) as value
                                         , uom
                                         , value_type
                                         , metadata
                                         ;
non_numeric_agg = foreach non_numeric generate transcriptid
                                         , patientid
                                         , data_type
                                         , name
                                         , value
                                         , uom
                                         , value_type
                                         , metadata
                                         ;

rmf debug/non_numeric
store non_numeric_agg into 'debug/non_numeric' using PigStorage('\t');


OUT = union numeric_agg, non_numeric_agg;

rmf practice_fusion/grouped
store OUT into 'practice_fusion/grouped' using PigStorage('\t');
