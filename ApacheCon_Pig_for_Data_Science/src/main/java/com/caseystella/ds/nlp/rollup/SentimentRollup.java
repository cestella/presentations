package com.caseystella.ds.nlp.rollup;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.strategy.*;

import java.util.List;

/**
 * Created by cstella on 3/25/14.
 */
public enum SentimentRollup implements ISentimentRollup {
     SIMPLE_VOTE(new SimpleVoteRollup())
    ,AVERAGE_PROBABILITIES(new AverageProbabilitiesRollup())
    , LAST_SENTENCE_WINS(new LastSentenceWins())
    , LONGEST_SENTENCE_WINS(new LongestSentenceWins())
    , WILSON_SCORE(new WilsonScore())
    ;

    private ISentimentRollup proxy;
    SentimentRollup(ISentimentRollup proxy) { this.proxy = proxy;}

    @Override
    public SentimentClass apply(List<Sentence> input) {
        return proxy.apply(input);
    }
}
