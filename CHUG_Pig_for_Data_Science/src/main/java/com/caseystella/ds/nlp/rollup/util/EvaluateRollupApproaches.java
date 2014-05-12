package com.caseystella.ds.nlp.rollup.util;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.Sentence;
import com.caseystella.ds.nlp.rollup.SentimentRollup;
import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * This is a utility that is intended to evaluate rollup approaches from some pre-processed data.
 */
public class EvaluateRollupApproaches
{
    private static class Document
    {
        List<Sentence> sentences;
        SentimentClass actualSentiment;
    }
    private static void addFile(File inputFile, List<Document> documents, SentimentClass actualSentiment) throws IOException {
        BufferedReader reader = new BufferedReader(new FileReader(inputFile));
        for(String line = null; (line = reader.readLine()) != null;)
        {
            Iterable<String> sentences = Splitter.on('\u0001').split(line);
            Document document = new Document();
            document.actualSentiment = actualSentiment;
            document.sentences = new ArrayList<Sentence>();
            for(String sentenceStr : sentences)
            {
                Iterable<String> split = Splitter.on('\u0002').split(sentenceStr);
                String content = Iterables.getFirst(split, "");
                Iterable<String> tmpStr= Splitter.on(',').split(Iterables.getLast(split, ""));
                SentimentClass sentenceClass = SentimentClass.valueOf(Iterables.getFirst(tmpStr, ""));
                Iterable<String> probsStr = Splitter.on(';').split(Iterables.getLast(tmpStr, ""));
                double[] probs = new double[SentimentClass.values().length];
                int i = 0;
                for(String probStr : probsStr)
                {
                    probs[i++] = Double.parseDouble(probStr);
                }

                Sentence sentence = new Sentence(probs, content, sentenceClass);
                document.sentences.add(sentence);
            }
            documents.add(document);
        }
    }

    public static void evaluate(SentimentRollup rollup, List<Document> documents )
    {
        int numSentiments = SentimentClass.values().length;
        int [][] errorClasses = new int[numSentiments][numSentiments];
        for(Document document : documents)
        {
            SentimentClass actual = document.actualSentiment;
            SentimentClass predicted = SentimentClass.getGeneral(rollup.apply(document.sentences).getIndex());

            errorClasses[actual.getIndex()][predicted.getIndex()]++;
        }

        int n = 0;
        int correct = 0;
        for(int i = 0;i < SentimentClass.values().length;++i)
        {
            for(int j = 0;j < SentimentClass.values().length;++j)
            {
                if(i == j)
                {
                    correct += errorClasses[i][j];
                }
                n += errorClasses[i][j];
                if(errorClasses[i][j] == 0)
                {
                    continue;
                }
                System.out.println(SentimentClass.values()[i] + "," + SentimentClass.values()[j] + " => " + errorClasses[i][j]);
            }
        }
        System.out.println("Accuracy: " + (1.0*correct) / n);
    }

    public static void main(String... argv) throws IOException {
        File baseDir = new File(argv[0]);
        List<Document> documents = new ArrayList<Document>();
        addFile(new File(baseDir, "pos.out"), documents, SentimentClass.POSITIVE);
        addFile(new File(baseDir, "neg.out"), documents, SentimentClass.NEGATIVE);
        for(SentimentRollup rollup : SentimentRollup.values())
        {
            System.out.println("EVALUATING " + rollup);
            evaluate(rollup, documents);
            System.out.println("");
        }
    }
}
