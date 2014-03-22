package com.caseystella.ds.nlp;

/**
 * Created by cstella on 3/21/14.
 */
public enum SentimentClass {
    VERY_NEGATIVE(0)
   , NEGATIVE(1)
   , NEUTRAL(2)
   , POSITIVE(3)
   , VERY_POSITIVE(4)
    ;
    private int index = -1;
    SentimentClass(int idx)
    {
        index = idx;
    }
    public int getIndex() { return index;}
    public static SentimentClass getSpecific(int sentimentClass)
    {
        return SentimentClass.values()[sentimentClass];
    }

    public static SentimentClass getGeneral(int sentimentClass)
    {
        //remove the extreme cases
        if(sentimentClass == 0) sentimentClass = 1;
        if(sentimentClass == 4) sentimentClass = 3;
        return SentimentClass.values()[sentimentClass];
    }
}
