package com.caseystella.ds.nlp.rollup.strategy;

import com.caseystella.ds.nlp.SentimentClass;
import com.caseystella.ds.nlp.rollup.ISentimentRollup;
import com.caseystella.ds.nlp.rollup.Sentence;

import java.util.List;

/**
 * Implementation of the Wilson Score pulled from http://stackoverflow.com/questions/4260836/c-sharp-from-ruby-wilson-score
 * and ported to Java.
 *
 */
public class WilsonScore implements ISentimentRollup{

    private static double pnormaldist(double qn)
    {
        double[] b = { 1.570796288, 0.03706987906, -0.8364353589e-3, -0.2250947176e-3,
                0.6841218299e-5, 0.5824238515e-5, -0.104527497e-5,
                0.8360937017e-7, -0.3231081277e-8, 0.3657763036e-10,
                0.6936233982e-12 };

        if (qn < 0.0 || 1.0 < qn)
            return 0.0;

        if (qn == 0.5)
            return 0.0;

        double w1 = qn;
        if (qn > 0.5)
            w1 = 1.0 - w1;
        double w3 = -Math.log(4.0 * w1 * (1.0 - w1));
        w1 = b[0];
        int i = 1;
        for (; i < 11; i++)
            w1 += b[i] * Math.pow(w3, i);

        if (qn > 0.5)
            return Math.sqrt(w1 * w3);
        return -Math.sqrt(w1 * w3);
    }

    public static double ci_lower_bound(int pos, int n, double power)
    {
        if (n == 0)
            return 0.0;
        double z = pnormaldist(1 - power / 2);
        double phat = 1.0 * pos / n;
        return (phat + z * z / (2 * n) - z * Math.sqrt((phat * (1 - phat) + z * z / (4 * n)) / n)) / (1 + z * z / n);
    }
    @Override
    public SentimentClass apply(List<Sentence> input) {
        int n = input.size();
        int pos = 0;
        for(Sentence s : input)
        {
            if(s.getSentiment().getIndex() >= 2)
            {
                pos++;
            }
        }
        double score = ci_lower_bound(pos, n, 0.975);
        if(score > .42) return SentimentClass.POSITIVE;
        else return SentimentClass.NEGATIVE;
    }
}
