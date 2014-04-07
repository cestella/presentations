
-- load the predictions from the last step
PREDICTED_SENTIMENT = LOAD '$input/sentiment' using PigStorage('\u0001') as ( predicted_sentiment:chararray
																			, true_sentiment:chararray
                                                                            , document:chararray
                                                                            );
-- Group the sentiment by distinct pairs of (true_sentiment, predicted sentiment)
-- These form cells in our confusion matrix
SENTIMENT_G = group PREDICTED_SENTIMENT by (true_sentiment, predicted_sentiment);

-- Now, count the number of docs that fit within each pair
CONFUSION = foreach SENTIMENT_G generate group, COUNT(PREDICTED_SENTIMENT);

-- I now have counts for each cell of the confusion matrix; just output it in pipe-separated form.
rmf $input/confusion
STORE CONFUSION INTO '$input/confusion' using PigStorage('|');
