import gensim
import numpy as np
from __builtin__ import list
from gensim.corpora import Dictionary
import csv

import codecs

# path = "/media/echobot/Volume/home/simon/uni/masterarbeit/dewiki/corpus/"
path = '/media/echobot/Volume/home/simon/uni/masterarbeit/data/de/corpus/echobot/corpus/'
corpus_filename =  "train-big.corpus.all"
corpus_path = path + corpus_filename

print("Copying sentences into memory... ")
dictionary = Dictionary()

maxdoc = 81556025*2; # Result of wc -l <source-file> ... *2 because of .bigram file

with codecs.open(corpus_path, "r") as corpus_file:
    i = 0

    for line in corpus_file:
        # Print progress
        if i > 0 and (i % 10000) == 0:
            print(i)

        # If you wanna test something..
        if 0 < maxdoc <= i:
            break

        sentence = [line.split()]
        dictionary.add_documents(sentence)
        i += 1

dictionary.filter_extremes()
print("Extracting terms...")
with open(path+'terms.csv','wb') as out:
    csvw = csv.writer(out)
    for item in dictionary.items():
        row = list()
        row.append(str(item[0]))
        row.append(item[1].encode('utf-8'));

        csvw.writerow(row)


print("Writing word-sentence Matrix ... ")
with open(path+'bow.imat.txt', 'wb') as out:
    with open(corpus_path, "r") as corpus_file:
        csvw = csv.writer(out)
        i = 0
        for line in corpus_file:
            sentence = line.split()
            bow = dictionary.doc2bow(sentence)
            for word in bow:
                csvw.writerow((word[0],i))

            # Print progress
            if i > 0 and (i % 10000) == 0:
                print(i)

            # If you wanna test something..
            if maxdoc > 0 and i >= maxdoc:
                break

            i += 1