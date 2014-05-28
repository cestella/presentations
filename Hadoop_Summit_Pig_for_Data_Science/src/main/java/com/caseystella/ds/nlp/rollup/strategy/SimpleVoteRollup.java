package com.caseystella.ds.nlp.rollup.strategy;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.ISentimentRollup;
import com.caseystella.ds.nlp.rollup.Sentence;

import java.util.EnumMap;
import java.util.List;

/**
 * Created by cstella on 3/25/14.
 */
public class SimpleVoteRollup implements ISentimentRollup
{

    @Override
    public SentimentClass apply(List<Sentence> input)
    {
        EnumMap<SentimentClass, Integer> sentimentMap = new EnumMap<SentimentClass, Integer>(SentimentClass.class);
        for(SentimentClass sentimentClass : SentimentClass.values())
        {
            sentimentMap.put(sentimentClass, 0);
        }
        for(Sentence in : input)
        {

            Integer cnt = sentimentMap.get(in.getSentiment());
            if(cnt == null)
            {
                cnt = 0;
            }
            sentimentMap.put(in.getSentiment(), cnt + 1);
        }
        SentimentClass dominantClass = null;
        int maxCnt = -1;
        for(SentimentClass sentimentClass : SentimentClass.values())
        {
            if(dominantClass == null || sentimentMap.get(sentimentClass) > maxCnt)
            {
                maxCnt = sentimentMap.get(sentimentClass);
                dominantClass = sentimentClass;
            }
        }
        return dominantClass;
    }
}
