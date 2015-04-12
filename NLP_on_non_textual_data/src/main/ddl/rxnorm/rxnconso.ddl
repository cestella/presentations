drop table if exists rxnorm.rxnconso_raw;

create external table rxnorm.rxnconso_raw(
   rxcui             string,
   lat               string,
   ts                string,
   lui               string,
   stt               string,
   sui               string,
   ispref            string,
   rxaui             string,
   saui              string,
   scui              string,
   sdui              string,
   sab               string,
   tty               string,
   code              string,
   str               string,
   srl               string,
   suppress          string,
   cvf               string
) row format delimited fields terminated by '|'
location '/etl/ds/rxnorm/input/rxnconso';

drop table if exists rxnorm.rxnconso;
create table rxnorm.rxnconso
stored as orc
location '/etl/ds/rxnorm/output/rxnconso'
tblproperties ("orc.compress"="SNAPPY")
as
select *
from rxnorm.rxnconso_raw;
