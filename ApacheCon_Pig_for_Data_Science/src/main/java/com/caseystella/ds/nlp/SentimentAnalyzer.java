package com.caseystella.ds.nlp;

import com.caseystella.ds.nlp.rollup.Sentence;
import com.caseystella.ds.nlp.rollup.SentimentRollup;
import com.google.common.base.Function;
import edu.stanford.nlp.ie.machinereading.structure.AnnotationUtils;
import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.sentiment.SentimentCoreAnnotations;
import edu.stanford.nlp.trees.Tree;
import edu.stanford.nlp.util.CoreMap;
import edu.stanford.nlp.util.logging.RedwoodConfiguration;
import org.ejml.simple.SimpleMatrix;

import java.util.*;

/**
 * Created by cstella on 3/21/14.
 */
public enum SentimentAnalyzer implements Function<String, SentimentClass> {
    INSTANCE;

    @Override
    public SentimentClass apply(String document)
    {
        // shut off the annoying intialization messages
        Properties props = new Properties();
        //specify the annotators that we want to use to annotate the text.  We need a tokenized sentence with POS tags to extract sentiment.
        //this forms our pipeline
        props.setProperty("annotators", "tokenize, ssplit, parse, sentiment");
        StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
        Annotation annotation = pipeline.process(document);
        List<Sentence> sentences = new ArrayList<Sentence>();
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
            SentimentClass sentimentClass = SentimentClass.getSpecific(sentimentClassIdx);

            double[] probs = new double[SentimentClass.values().length];
            {
                SimpleMatrix mat = RNNCoreAnnotations.getPredictions(sentimentTree);
                for(int i = 0;i < SentimentClass.values().length;++i)
                {
                    probs[i] = mat.get(i);
                }
            }
            String sentenceStr = AnnotationUtils.sentenceToString(sentence).replace("\n", "");
            sentences.add(new Sentence(probs, sentenceStr, sentimentClass));
        }


        return SentimentRollup.WILSON_SCORE.apply(sentences);
    }
}
