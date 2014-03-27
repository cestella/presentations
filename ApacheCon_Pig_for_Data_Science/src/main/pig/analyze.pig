REGISTER ./ApacheCon_Pig_for_Data_Science-1.0-SNAPSHOT.jar
set pig.splitCombination false

DEFINE SENTIMENT_ANALYSIS com.caseystella.ds.pig.ANALYZE_SENTIMENT;

DOCUMENTS_POS = LOAD '$input/input/pos.dat' using PigStorage('\u0001') as (document:chararray);
DOCUMENTS_POS_SAMPLE = SAMPLE DOCUMENTS_POS .04;
DOCUMENTS_NEG = LOAD '$input/input/neg.dat' using PigStorage('\u0001') as (document:chararray);
DOCUMENTS_NEG_SAMPLE = SAMPLE DOCUMENTS_NEG .04;

NEG_DOCS_WITH_SENTIMENT = foreach DOCUMENTS_NEG_SAMPLE generate 'NEGATIVE' as true_sentiment
							      , document as document;
POS_DOCS_WITH_SENTIMENT = foreach DOCUMENTS_POS_SAMPLE generate 'POSITIVE' as true_sentiment
							      , document as document;
DOCS_WITH_SENTIMENT = UNION NEG_DOCS_WITH_SENTIMENT, POS_DOCS_WITH_SENTIMENT;

PREDICTED_SENTIMENT = foreach DOCS_WITH_SENTIMENT generate SENTIMENT_ANALYSIS(document) as predicted_sentiment
                              						         , true_sentiment
						                                       , document;
rmf $input/sentiment
STORE PREDICTED_SENTIMENT INTO '$input/sentiment' using PigStorage('\u0001');
