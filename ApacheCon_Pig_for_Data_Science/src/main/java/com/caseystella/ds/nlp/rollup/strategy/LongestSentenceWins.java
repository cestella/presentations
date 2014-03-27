package com.caseystella.ds.nlp.rollup.strategy;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.ISentimentRollup;
import com.caseystella.ds.nlp.rollup.Sentence;

import java.util.List;

/**
 * Created by cstella on 3/26/14.
 */
public class LongestSentenceWins implements ISentimentRollup {

    @Override
    public SentimentClass apply(List<Sentence> input) {
        int length = 0;
        Sentence actualSentence = null;
        for(Sentence in : input)
        {
            if(in.getSentence().length() > length)
            {
                actualSentence = in;
            }
        }
        return actualSentence.getSentiment();
    }
}
