#!/bin/bash
hadoop fs -rm -r -skipTrash /etl/ds/open_payments/general
hadoop fs -mkdir -p /etl/ds/open_payments/general/raw && \
hadoop fs -D fs.local.block.size=1000000 -put data/OPPR_ALL_DTL_GNRL_09302014.csv /etl/ds/open_payments/general/raw && \
hive < ddl/general.ddl
