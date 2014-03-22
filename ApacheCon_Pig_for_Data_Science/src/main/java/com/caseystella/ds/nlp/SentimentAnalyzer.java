package com.caseystella.ds.nlp;

import com.google.common.base.Function;
import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.sentiment.SentimentCoreAnnotations;
import edu.stanford.nlp.trees.Tree;
import edu.stanford.nlp.util.CoreMap;
import edu.stanford.nlp.util.logging.RedwoodConfiguration;

import java.util.EnumMap;
import java.util.Map;
import java.util.Properties;

/**
 * Created by cstella on 3/21/14.
 */
public enum SentimentAnalyzer implements Function<String, SentimentClass> {
    INSTANCE;

    @Override
    public SentimentClass apply(String document)
    {
        // shut off the annoying intialization messages
        RedwoodConfiguration.empty().capture(System.err).apply();
        Properties props = new Properties();
        //specify the annotators that we want to use to annotate the text.  We need a tokenized sentence with POS tags to extract sentiment.
        //this forms our pipeline
        props.setProperty("annotators", "tokenize, ssplit, parse, sentiment");
        StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
        Annotation annotation = pipeline.process(document);
        EnumMap<SentimentClass, Integer> sentimentCount = new EnumMap<SentimentClass, Integer>(SentimentClass.class);
        /*
         * We're going to iterate over all of the sentences and extract the sentiment.  We'll adopt a majority rule policy
         */
        for( CoreMap sentence : annotation.get(CoreAnnotations.SentencesAnnotation.class))
        {
            //for each sentence, we get the sentiment annotation
            //this comes in the form of a tree of annotations
            Tree sentimentTree = sentence.get(SentimentCoreAnnotations.AnnotatedTree.class);
            //Letting CoreNLP roll up the sentiment for us
            int sentimentClassIdx = RNNCoreAnnotations.getPredictedClass(sentimentTree);
            //now we add to our list of sentences and sentiments
            SentimentClass sentimentClass = SentimentClass.getGeneral(sentimentClassIdx);

            Integer classCount = sentimentCount.get(sentimentClass);
            if(classCount == null)
            {
                classCount = 0;
            }
            sentimentCount.put(sentimentClass, classCount+1);
        }
        SentimentClass ret = null;
        int maxCount = -1;
        for(Map.Entry<SentimentClass, Integer> entry : sentimentCount.entrySet())
        {
            if(ret == null || entry.getValue() > maxCount)
            {
                ret = entry.getKey();
                maxCount = entry.getValue();
            }
        }

        return ret;
    }
}
