package com.caseystella.ds.pig;

import com.caseystella.ds.nlp.SentimentAnalyzer;
import com.caseystella.ds.nlp.SentimentClass;
import edu.stanford.nlp.util.logging.RedwoodConfiguration;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

import java.io.IOException;

/**
 * A pig UDF which accepts a document and returns a sentiment class: Positive or Negative
 * The assumptions are that this document is a movie review and uses, under the hood, the
 * Stanford CoreNLP Sentiment classifier.
 */
public class ANALYZE_SENTIMENT extends EvalFunc<String>
{
    @Override
    public String exec(Tuple objects) throws IOException
    {
        //stop CoreNLP from printing to stdout
        RedwoodConfiguration.empty().capture(System.err).apply();
        //grab the document
        String document = (String)objects.get(0);
        if(document == null || document.length() == 0)
        {
            //if the document is malformed, return null, which is to say, we don't know how to
            //handle it
            return null;
        }
        //Call out to our handler that we wrote to do the sentiment analysis
        SentimentClass sentimentClass = SentimentAnalyzer.INSTANCE.apply(document);

        return sentimentClass == null?null: sentimentClass.toString();
    }
}
