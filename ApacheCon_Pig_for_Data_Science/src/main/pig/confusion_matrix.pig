PREDICTED_SENTIMENT = LOAD '$input/sentiment' using PigStorage('\u0001') as ( predicted_sentiment:chararray
																									 , true_sentiment:chararray
                                                                            , document:chararray
                                                                            );
SENTIMENT_G = group PREDICTED_SENTIMENT by (true_sentiment, predicted_sentiment);
CONFUSION = foreach SENTIMENT_G generate group, COUNT(PREDICTED_SENTIMENT);
rmf $input/confusion
STORE CONFUSION INTO '$input/confusion' using PigStorage('|');
