package com.caseystella.ds.nlp.rollup.strategy;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.ISentimentRollup;
import com.caseystella.ds.nlp.rollup.Sentence;

import java.util.List;

/**
 * Created by cstella on 3/25/14.
 */
public class AverageProbabilitiesRollup  implements ISentimentRollup {

    @Override
    public SentimentClass apply(List<Sentence> input)
    {
        double[] weights = new double[] {1, 1, 1, 1, 1};
        double[] probs = new double[SentimentClass.values().length];
        SentimentClass dominantClass = null;
        int idx = 0;
        for(Sentence inputSentence : input)
        {
            if(idx++ < input.size() / 2) continue;
            for(int i = 0;i < probs.length;++i)
            {
                probs[i] += weights[i] * inputSentence.getSentimentProbabilities().get(SentimentClass.values()[i]);
            }
        }
        double max = -1;
        for(int i = 0;i < probs.length;++i)
        {
            if(probs[i] > max)
            {
                max = probs[i];
                dominantClass = SentimentClass.values()[i];
            }
        }
        return dominantClass;
    }
}
