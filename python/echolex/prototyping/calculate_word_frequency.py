import csv

import nltk
import re

import numpy as np
from gensim.models import Word2Vec
from nltk.corpus import stopwords

from utils.utils import replace_umlauts, Timer

wordfrequencies = {}

with open('/media/echobot/Volume/home/simon/uni/masterarbeit/data/de/corpus/news.2013.de.shuffled.corpus.bigram') as f:
    print("Reading corpus and counting words...")
    num_lines = 36218033;
    current_line = 1;
    for line in f:
        if current_line % 100000 == 0:
            print("Line %d / %d" % (current_line, num_lines))
        words = line.split();
        for word in words:
            if not wordfrequencies.has_key(word):
                wordfrequencies[word] = 0;

            wordfrequencies[word] += 1
        current_line += 1

print("Saving word frequencies...")
with open('wordfrequencies_bigrams.csv', 'wb') as csv_file:
    writer = csv.writer(csv_file)
    for key, value in wordfrequencies.items():
        writer.writerow([key, value])







