#!/bin/bash 
set -e
INPUT_PF_DIR=/etl/ds/practice_fusion/input
OUTPUT_PF_DIR=/etl/ds/practice_fusion/output
hadoop fs -rm -r -skipTrash $INPUT_PF_DIR && hadoop fs -mkdir -p $INPUT_PF_DIR
for i in $(ls data/practicefusion/training_*.csv);do
  DIR=$(basename $i | sed 's/training_//g' | sed 's/test_//g' | sed 's/.csv//g')
  echo "making $DIR"
  hadoop fs -mkdir -p $INPUT_PF_DIR/$DIR
  hadoop fs -mkdir -p $OUTPUT_PF_DIR/$DIR
done
for i in $(ls data/practicefusion/*Sync*);do
  DIR=$(basename $i | sed 's/training_//g' | sed 's/test_//g' | sed 's/.csv//g')
  echo "putting $DIR"
  hadoop fs -put $i $INPUT_PF_DIR/$DIR
done
for i in $(ls data/practicefusion/training_*.csv);do
  DIR=$(basename $i | sed 's/training_//g' | sed 's/test_//g' | sed 's/.csv//g')
  echo "ingesting $DIR"
  hive < ddl/practicefusion/$DIR.ddl
done


