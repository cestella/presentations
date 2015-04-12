#!/bin/bash 
set -e

INPUT_RXN_DIR=/etl/ds/rxnorm/input
OUTPUT_RXN_DIR=/etl/ds/rxnorm/output

hadoop fs -rm -r -skipTrash $INPUT_RXN_DIR && hadoop fs -mkdir -p $INPUT_RXN_DIR

hadoop fs -mkdir -p $INPUT_RXN_DIR/rxnsat && hadoop fs -mkdir -p $OUTPUT_RXN_DIR/rxnsat
hadoop fs -put data/rxnorm/RXNSAT.RRF $INPUT_RXN_DIR/rxnsat
hive < ddl/rxnorm/rxnsat.ddl

hadoop fs -mkdir -p $INPUT_RXN_DIR/rxnconso && hadoop fs -mkdir -p $OUTPUT_RXN_DIR/rxnconso
hadoop fs -put data/rxnorm/RXNSAT.RRF $INPUT_RXN_DIR/rxnconso
hive < ddl/rxnorm/rxnconso.ddl
