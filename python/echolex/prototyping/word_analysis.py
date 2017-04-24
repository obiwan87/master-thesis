# -*- coding: utf-8 -*-
import csv

import nltk
import re

import numpy as np
from sklearn.neighbors import NearestNeighbors
from gensim.models import Word2Vec


from utils.utils import replace_umlauts, Timer

from utils.utils import raw_freq

model_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/de/model/01/my.model"
model = Word2Vec.load_word2vec_format(model_path, binary=True)
w2v = {w: vec for w,vec in zip(model.index2word, model.syn0)}

with Timer('Loading model from %s' % model_path):
    model = Word2Vec.load_word2vec_format(model_path, binary=True)

dataset_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/data/business_signals_samples/fuehrungswechsel.txt"
dataset_path += ".corpus"

with open(dataset_path, 'r') as f:
    W = [w.decode('utf-8') for line in f for w in line.split()]
    X = [w2v[w] for sentence in W for w in W]
    V = {w.decode for w in W}

X = np.array(X)

# with Timer("Calculating nearest neighbors... "):
#     nbrs = NearestNeighbors(n_neighbors=5, algorithm='ball_tree').fit(V)
#     distances, indices = nbrs.kneighbors(X)
#
#     print distances
#     print indices
