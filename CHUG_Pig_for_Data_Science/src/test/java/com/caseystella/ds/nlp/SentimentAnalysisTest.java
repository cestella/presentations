package com.caseystella.ds.nlp;

import com.caseystella.ds.util.ReservoirSampler;
import com.google.common.base.Splitter;
import com.google.common.collect.Iterables;
import edu.stanford.nlp.io.IOUtils;
import edu.stanford.nlp.util.StringUtils;
import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.util.EnumMap;
import java.util.List;

/**
 * Created by cstella on 3/21/14.
 */
public class SentimentAnalysisTest
{
    private static Iterable<String> readFile(String filename) throws IOException {
        return Splitter.on('\n').split(IOUtils.slurpFile(filename));
    }
    private static int[][] initializeConfusionMatrix()
    {
        int numClasses = SentimentClass.values().length;
        int[][] confusionMatrix = new int[numClasses][numClasses];
        for(int i = 0;i < numClasses;++i)
        {
            for(int j = 0;j < numClasses;++j)
            {
                confusionMatrix[i][j] = 0;
            }
        }
        return confusionMatrix;
    }

    @Test
    public void testIMDBSentimentAnalysis() throws Exception
    {
        int[][] confusionMatrix  = initializeConfusionMatrix();
        int totalNumDocs = 100;
        ReservoirSampler<String> positiveReservoir = new ReservoirSampler<String>(totalNumDocs/2);
        for(String doc : readFile("src/main/data/pos.dat"))
        {
            positiveReservoir.sample(doc);
        }
        int docId = 0;
        for(SentimentClass sentimentClass : Iterables.transform( positiveReservoir.getSamples()
                                                               , SentimentAnalyzer.INSTANCE
                                                               )
            )
        {
            docId++;
            if(docId % 10 == 0) System.out.print(".");
            if(docId % 100 == 0) System.out.print("\n");
            confusionMatrix[SentimentClass.POSITIVE.getIndex()][sentimentClass.getIndex()]++;
        }

        ReservoirSampler<String> negativeReservoir = new ReservoirSampler<String>(totalNumDocs/2);
        for(String doc : readFile("src/main/data/neg.dat"))
        {
            negativeReservoir.sample(doc);
        }

        for(SentimentClass sentimentClass : Iterables.transform( negativeReservoir.getSamples()
                                                               , SentimentAnalyzer.INSTANCE
                                                               )
            )
        {
            docId++;
            if(docId % 10 == 0) System.out.print(".");
            if(docId % 100 == 0) System.out.print("\n");
            confusionMatrix[SentimentClass.NEGATIVE.getIndex()][sentimentClass.getIndex()]++;
        }
        SentimentClass[] classes = SentimentClass.values();
        int numErrors = 0;
        for(int i = 1;i < 4;++i)
        {
            for(int j = 1;j < 4;++j)
            {
                if(i != j)
                {
                   numErrors += confusionMatrix[i][j];
                }
               System.out.println(classes[i] + ", " + classes[j] + " => " + confusionMatrix[i][j]) ;
            }
        }
        double accuracy = (1.0*(totalNumDocs - numErrors))/totalNumDocs;
        System.out.println("Accuracy: " + accuracy);
        Assert.assertTrue(accuracy > .7);
    }
}
