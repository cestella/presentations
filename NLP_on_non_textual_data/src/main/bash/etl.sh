#!/bin/bash
pushd etl/practicefusion
#pig -useHCatalog ./ndc_to_rxnorm.pig && \
#pig -useHCatalog ./denormalize.pig && \
#pig ./group_values.pig && \
#pig -useHCatalog ./enrich_rxnorm.pig && \
#pig -useHCatalog ./enrich_generalize.pig && \
#pig -param min_drug=10 -param input=grouped -param output=sentences_ndc to_sentences.pig && \
#pig -param min_drug=20 -param input=rxnorm_normalized -param output=sentences_rxnorm to_sentences.pig && \
pig -param min_drug=10 -param input=nlp_normalized -param output=sentences_nlp to_sentences.pig 
popd
