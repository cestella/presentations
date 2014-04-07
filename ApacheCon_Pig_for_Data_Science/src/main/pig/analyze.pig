REGISTER ./ApacheCon_Pig_for_Data_Science-1.0-SNAPSHOT.jar

-- Set split combination to false, because we want as many mappers as possible
-- since we are CPU-bound as opposed to IO bound
set pig.splitCombination false


DEFINE SENTIMENT_ANALYSIS com.caseystella.ds.pig.ANALYZE_SENTIMENT;

-- Load the positive sentiments, one doc per line
DOCUMENTS_POS = LOAD '$input/input/pos.dat' using PigStorage('\u0001') as (document:chararray);
-- Use the simplistic sampler to give me 4% of the data in a sample
-- NOTE: In production, I'd obviously not work on a sample. ;)
DOCUMENTS_POS_SAMPLE = SAMPLE DOCUMENTS_POS .04;

-- do the same thing for negative docs
DOCUMENTS_NEG = LOAD '$input/input/neg.dat' using PigStorage('\u0001') as (document:chararray);
DOCUMENTS_NEG_SAMPLE = SAMPLE DOCUMENTS_NEG .04;

-- Before I merge the samples together, I want to ensure that I note the true sentiment
NEG_DOCS_WITH_SENTIMENT = foreach DOCUMENTS_NEG_SAMPLE generate 'NEGATIVE' as true_sentiment
							      , document as document;
POS_DOCS_WITH_SENTIMENT = foreach DOCUMENTS_POS_SAMPLE generate 'POSITIVE' as true_sentiment
							      , document as document;

-- Union the relations together
DOCS_WITH_SENTIMENT = UNION NEG_DOCS_WITH_SENTIMENT, POS_DOCS_WITH_SENTIMENT;

--Generate the predicted sentiment.  Now I have a document, true sentiment and predicted sentiment
-- I'm all ready to compute the confusion matrix
PREDICTED_SENTIMENT = foreach DOCS_WITH_SENTIMENT generate SENTIMENT_ANALYSIS(document) as predicted_sentiment
                              						         , true_sentiment
						                                       , document;
rmf $input/sentiment
STORE PREDICTED_SENTIMENT INTO '$input/sentiment' using PigStorage('\u0001');
