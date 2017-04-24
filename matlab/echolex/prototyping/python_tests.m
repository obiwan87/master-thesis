bigramFinder = py.nltk.collocations.BigramCollocationFinder.from_words(words, int32(4));
bestBigrams = bigramFinder.nbest(@py.echolex.bridge2matlab.bigram_assoc_measures.raw_freq, int32(10));

for i=1:py.len(bestBigrams)
    bigram = bestBigrams(i);
end