package com.caseystella.ds.nlp.rollup.util;

import com.caseystella.ds.nlp.SentimentClass;
import com.google.common.base.Function;
import com.google.common.base.Joiner;
import com.google.common.collect.Iterables;
import edu.stanford.nlp.ie.machinereading.structure.AnnotationUtils;
import edu.stanford.nlp.ling.CoreAnnotations;
import edu.stanford.nlp.neural.rnn.RNNCoreAnnotations;
import edu.stanford.nlp.pipeline.Annotation;
import edu.stanford.nlp.pipeline.StanfordCoreNLP;
import edu.stanford.nlp.sentiment.SentimentCoreAnnotations;
import edu.stanford.nlp.trees.Tree;
import edu.stanford.nlp.util.CoreMap;
import org.ejml.simple.SimpleMatrix;

import java.io.*;
import java.util.*;

/**
 * Created by cstella on 3/24/14.
 */
public class GenerateTrainingData
{

    private static List<Map.Entry<String, String>> getSentiment(StanfordCoreNLP pipeline, String document)
    {
        List<Map.Entry<String, String>> ret = new ArrayList<Map.Entry<String, String>>();


        Annotation annotation = pipeline.process(document);
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
            List<Double> probs = new ArrayList<Double>();
            {
                SimpleMatrix mat = RNNCoreAnnotations.getPredictions(sentimentTree);
                for(int i = 0;i < SentimentClass.values().length;++i)
                {
                    probs.add(mat.get(i));
                }
            }
            String sentenceStr = AnnotationUtils.sentenceToString(sentence).replace("\n", "");
            ret.add(new AbstractMap.SimpleEntry<String, String>(sentenceStr, sentimentClass + "," + Joiner.on(';').join(probs)));
        }
        return ret;
    }

    public static void write(StanfordCoreNLP pipeline, String inputFile, String outputFile) throws IOException
    {
        BufferedReader reader = new BufferedReader(new FileReader(new File(inputFile)));
        PrintWriter writer = new PrintWriter(new File(outputFile));
        String line =null;
        int cnt = 0;
        while( (line = reader.readLine()) != null)
        {
            cnt++;
            if(cnt % 10 == 0)
            {
                System.out.print(".");
            }
            if(cnt % 100 == 0)
            {
                System.out.println("");
            }
            Iterable<String> lines = Iterables.transform(getSentiment(pipeline, line)
                    , new Function<Map.Entry<String, String>, String>()
            {
                @Override
                public String apply(Map.Entry<String, String> input) {
                    return input.getKey() + "\u0002" + input.getValue();
                }
            });
            String outLine = Joiner.on('\u0001').join(lines);
            writer.println(outLine);
        }
        writer.flush();
        writer.close();
    }

    public static void main(String ... argv) throws IOException
    {
        Properties props = new Properties();
        //specify the annotators that we want to use to annotate the text.  We need a tokenized sentence with POS tags to extract sentiment.
        //this forms our pipeline
        props.setProperty("annotators", "tokenize, ssplit, parse, sentiment");
        StanfordCoreNLP pipeline = new StanfordCoreNLP(props);
        String baseDir = argv[0];
        System.out.println("Processing POS");
        write(pipeline, baseDir + "/pos.dat", baseDir + "/pos.out");

        System.out.println("Processing NEG");
        write(pipeline, baseDir + "/neg.dat", baseDir + "/neg.out");        }
}
