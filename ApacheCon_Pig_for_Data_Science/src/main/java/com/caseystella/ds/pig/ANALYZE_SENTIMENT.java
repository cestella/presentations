package com.caseystella.ds.pig;

import com.caseystella.ds.nlp.SentimentAnalyzer;
import com.caseystella.ds.nlp.SentimentClass;
import org.apache.pig.EvalFunc;
import org.apache.pig.data.Tuple;

import java.io.IOException;

/**
 * Created by cstella on 3/21/14.
 */
public class ANALYZE_SENTIMENT extends EvalFunc<String>
{
    @Override
    public String exec(Tuple objects) throws IOException
    {
        String document = (String)objects.get(0);
        if(document == null || document.length() == 0)
        {
            return null;
        }
        SentimentClass sentimentClass = SentimentAnalyzer.INSTANCE.apply(document);
        return sentimentClass == null?null: sentimentClass.toString();
    }
}
