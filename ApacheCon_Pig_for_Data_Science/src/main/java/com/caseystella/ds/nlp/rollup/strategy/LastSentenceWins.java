package com.caseystella.ds.nlp.rollup.strategy;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.ISentimentRollup;
import com.caseystella.ds.nlp.rollup.Sentence;

import java.util.List;

/**
 * Created by cstella on 3/26/14.
 */
public class LastSentenceWins implements ISentimentRollup{

    @Override
    public SentimentClass apply(List<Sentence> input) {
        return input.get(input.size() - 1).getSentiment();
    }
}
