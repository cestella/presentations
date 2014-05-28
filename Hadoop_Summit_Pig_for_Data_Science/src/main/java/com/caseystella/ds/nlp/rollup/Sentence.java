package com.caseystella.ds.nlp.rollup;

import com.caseystella.ds.nlp.SentimentClass;

import java.util.EnumMap;

/**
 * Created by cstella on 3/25/14.
 */
public class Sentence {
    private EnumMap<SentimentClass, Double> sentimentProbabilities;
    private String sentence;
    private SentimentClass sentimentClass;

    public Sentence( double[] sentimentProbabilities
                   , String sentence
                   , SentimentClass sentimentClass
                   )
    {
        this.sentence = sentence;
        this.sentimentClass = sentimentClass;
        this.sentimentProbabilities = new EnumMap<SentimentClass, Double>(SentimentClass.class);
        for(int i = 0;i < sentimentProbabilities.length;++i)
        {
            this.sentimentProbabilities.put(SentimentClass.values()[i], sentimentProbabilities[i]);
        }
    }

    public String getSentence() { return sentence;}
    public EnumMap<SentimentClass, Double> getSentimentProbabilities() { return sentimentProbabilities;}
    public SentimentClass getSentiment() { return sentimentClass;}
}
