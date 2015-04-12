drop table if exists rxnorm.rxnsat_raw;

create external table rxnorm.rxnsat_raw(
   rxcui            string,
   lui              string,
   sui              string,
   rxaui            string,
   stype            string,
   code             string,
   atui             string,
   satui            string,
   atn              string,
   sab              string,
   atv              string,
   suppress         string,
   cvf              string
) row format delimited fields terminated by '|'
location '/etl/ds/rxnorm/input/rxnsat';

drop table if exists rxnorm.rxnsat;
create table rxnorm.rxnsat
stored as orc
location '/etl/ds/rxnorm/output/rxnsat'
tblproperties ("orc.compress"="SNAPPY")
as
select *
from rxnorm.rxnsat_raw;
