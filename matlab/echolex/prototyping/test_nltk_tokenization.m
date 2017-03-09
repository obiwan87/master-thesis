

sentence_detector = py.nltk.data.load('tokenizers/punkt/german.pickle');
tokens = sentence_detector.tokenize('Hallo, ich bin Müller. Wie geht es dir?')
py.nltk.word_tokenize('Hallo, mein Name ist Max')