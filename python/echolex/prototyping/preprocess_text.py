# -*- coding: utf-8 -*-
import csv

import nltk
import re

import numpy as np
from gensim.models import Word2Vec
from nltk.corpus import stopwords

from utils.utils import replace_umlauts, Timer


with Timer('Preprocessing evaluation dataset ...'):
    filename = 'keyword_extraction.txt'
    dataset_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/data/business_signals_samples/" + filename
    with open(dataset_path, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        X = [s for s in f]

    punctuation_tokens = ['.', '..', '...', ',', ';', ':', '(', ')', '"', '\'', '[', ']', '{', '}', '?', '!', '-', u'–', '+', '*', '--', '\'\'', '``']
    punctuation = '?.!/;:()&+'

    stop_words = [replace_umlauts(token) for token in stopwords.words('german')]

    Xt = []
    for sentence in X:
        sentence = (sentence.decode('utf-8'))
        words = nltk.word_tokenize(sentence)
        words = [x for x in words if x not in punctuation_tokens]
        words = [re.sub('[' + punctuation + ']', '', x) for x in words]
        words = [x for x in words if x not in stop_words]
        words = [replace_umlauts(x) for x in words]
        Xt.append(words)

    model_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/data/de/model/01/my.model"
    # model_path = "/home/echobot/ram/my.model"
    with Timer('Loading model from %s' % model_path):
        model = Word2Vec.load_word2vec_format(model_path, binary=True)

    X = Xt
    vocab = {w for sentence in Xt for w in sentence}
    vocab = set(model.index2word) & vocab

    X = [[w for w in sentence if w in vocab] for sentence in X]

    X = np.array(X)

    with open(dataset_path+".corpus", 'w+') as f:
        writer = csv.writer(f, delimiter=" ")
        for s in X:
            writer.writerow([w.encode('utf-8') for w in s])