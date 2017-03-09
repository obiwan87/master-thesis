ngramFinder = BigramFinder.fromDocumentSet(W);
BW = ngramFinder.generateNgramsDocumentSet('student_t', 100);
P = sequence(WordCountMatrix('KeepUnigrams', true));

p = pipeline(P);
p.execute(BW);