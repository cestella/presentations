#!/bin/bash
pushd ipython
IPYTHON_OPTS="notebook --ip='*'" pyspark --master yarn-client[3]
