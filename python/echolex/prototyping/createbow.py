import gensim
import numpy as np
from __builtin__ import list
from gensim.corpora import Dictionary
import csv

path = "/media/echobot/Volume/home/simon/uni/masterarbeit/dewiki/corpus/"
corpus_filename =  "news.2013.de.shuffled.corpus"
corpus_path = path + corpus_filename

print("Copying sentences into memory... (fingers crossed)")
dictionary = Dictionary()
maxdoc = 2000000

with open(corpus_path, "r") as corpus_file:
    i = 0

    for line in corpus_file:
        # Print progress
        if i > 0 and (i % 10000) == 0:
            print(i)

        # If you wanna test something..
        if maxdoc > 0 and i >= maxdoc:
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