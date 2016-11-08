# -*- coding: utf-8 -*-
from utils.utils import Timer, replace_umlauts
import time
import nltk
# from tabulate import tabulate
# import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import csv
import re
from nltk.corpus import stopwords
from gensim.models.word2vec import Word2Vec
from collections import Counter, defaultdict
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.ensemble import ExtraTreesClassifier
from sklearn.naive_bayes import BernoulliNB, MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score
from sklearn.cross_validation import cross_val_score
from sklearn.cross_validation import StratifiedShuffleSplit

from tabulate import tabulate
from sklearn.cross_validation import StratifiedShuffleSplit


class MeanEmbeddingVectorizer(object):
    def __init__(self, word2vec):
        self.word2vec = word2vec
        self.dim = len(word2vec.itervalues().next())

    def fit(self, X, y):
        return self

    def transform(self, X):
        return np.array([
                            np.mean([self.word2vec[w] for w in words if w in self.word2vec]
                                    or [np.zeros(self.dim)], axis=0)
                            for words in X
                            ])

class TfidfEmbeddingVectorizer(object):
    def __init__(self, word2vec):
        self.word2vec = word2vec
        self.word2weight = None
        self.dim = len(word2vec.itervalues().next())

    def fit(self, X, y):
        tfidf = TfidfVectorizer(analyzer=lambda x: x)
        tfidf.fit(X)
        # if a word was never seen - it must be at least as infrequent
        # as any of the known words - so the default idf is the max of 
        # known idf's
        max_idf = max(tfidf.idf_)
        self.word2weight = defaultdict(
            lambda: max_idf,
            [(w, tfidf.idf_[i]) for w, i in tfidf.vocabulary_.items()])
        return self

    def transform(self, X):
        return np.array([
                np.mean([self.word2vec[w] * self.word2weight[w]
                         for w in words if w in self.word2vec] or
                        [np.zeros(self.dim)], axis=0)
                for words in X
            ])



# Load word2vec model


model_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/de/model/01/my.model"
#model_path = "/home/echobot/ram/my.model"
with Timer('Loading model from %s' % model_path):
    model = Word2Vec.load_word2vec_format(model_path, binary=True)

    w2v = {w: vec for w,vec in zip(model.index2word, model.syn0)}

# Create Pipeline for preprocessing with tf-idf
# Load and preproocess dataset
dataset_path = "/media/echobot/Volume/home/simon/uni/masterarbeit/data/business_signals_samples/fuehrungswechsel.txt"
labels_path  = dataset_path + '.labels'
dataset_path += ".corpus"

with open(dataset_path, 'r') as f:
    X = [line.split() for line in f]

with open(labels_path, 'r') as f:
    y = [line for line in f]

X = np.array(X)
y = np.array(y)

# Benchmark

with Timer('Benchmark ...'):
    def benchmark(model, X, y, n):
        test_size = 1 - (n / float(len(y)))
        scores = []
        for train, test in StratifiedShuffleSplit(y, n_iter=5, test_size=test_size):
            X_train, X_test = X[train], X[test]
            y_train, y_test = y[train], y[test]
            scores.append(accuracy_score(model.fit(X_train, y_train).predict(X_test), y_test))
        return np.mean(scores)

    etree_w2v_tfidf = Pipeline([
        ("word2vec vectorizer", TfidfEmbeddingVectorizer(w2v)),
        ("extra trees", ExtraTreesClassifier(n_estimators=200))])

    etree_w2v = Pipeline([
        ("word2vec vectorizer", MeanEmbeddingVectorizer(w2v)),
        ("extra trees", ExtraTreesClassifier(n_estimators=200))])

    mult_nb = Pipeline([("count_vectorizer", CountVectorizer(analyzer=lambda x: x)), ("multinomial nb", MultinomialNB())])
    bern_nb = Pipeline([("count_vectorizer", CountVectorizer(analyzer=lambda x: x)), ("bernoulli nb", BernoulliNB())])
    mult_nb_tfidf = Pipeline([("tfidf_vectorizer", TfidfVectorizer(analyzer=lambda x: x)), ("multinomial nb", MultinomialNB())])
    bern_nb_tfidf = Pipeline([("tfidf_vectorizer", TfidfVectorizer(analyzer=lambda x: x)), ("bernoulli nb", BernoulliNB())])
    # SVM - which is supposed to be more or less state of the art
    # http://www.cs.cornell.edu/people/tj/publications/joachims_98a.pdf
    svc = Pipeline([("count_vectorizer", CountVectorizer(analyzer=lambda x: x)), ("linear svc", SVC(kernel="linear"))])
    svc_tfidf = Pipeline([("tfidf_vectorizer", TfidfVectorizer(analyzer=lambda x: x)), ("linear svc", SVC(kernel="linear"))])


    all_models = [
        # ("mult_nb", mult_nb),
        # ("mult_nb_tfidf", mult_nb_tfidf),
        # ("bern_nb", bern_nb),
        # ("bern_nb_tfidf", bern_nb_tfidf),
        ("svc", svc),
        ("svc_tfidf", svc_tfidf),
        # ("glove_small", etree_glove_small),
        # ("glove_small_tfidf", etree_glove_small_tfidf),
        # ("glove_big", etree_glove_big),
        # ("glove_big_tfidf", etree_glove_big),
        ("w2v", etree_w2v),
        ("w2v_tfidf", etree_w2v_tfidf),
    ]
    scores = sorted([(name, cross_val_score(model, X, y, cv=5).mean())
                     for name, model in all_models],
                    key=lambda (_, x): -x)

    from tabulate import tabulate
    print tabulate(scores, floatfmt=".4f", headers=("model", 'score'))

    train_sizes = [10, 40, 160, 300, 500, 1000]
    table = []
    for name, model in all_models:
        for n in train_sizes:
            table.append({'model': name,
                          'accuracy': benchmark(model, X, y, n),
                          'train_size': n})
    df = pd.DataFrame(table)
    print str(table)

