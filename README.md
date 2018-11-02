# master-thesis
Code for Master Thesis "Improving Text Classification with Lexical Substitution and Word Embeddings"

# Description

Text Classifcation is the task of automatically assigning textual data to a set of pre-
defned classes. Besides being an intensively researched topic, TC and its applications are
widely spread among every area of industry. Nowadays, the underlying algorithms for
TC are mainly founded on machine learning techniques. Typically, the predictive power
of machine learning based classifers is heavily dependent on the quantity and quality of
data used for training. However, this requires gathering labeled data, which is a time- and
resource-intensive process that has to be manually performed by human domain experts.
In many real-word scenarios, this fact represents a signifcant limitation to TC efective-
ness. Therefore, in this work we propose a method to improve text classifcation accuracy
despite the scarcity of pre-classifed textual data. For this purpose, we contribute a novel
semantic-distributional word distance measure that can be used in connection with clus-
tering algorithms, to extract a semantically enriched and lower dimensional term feature
space. Our distance measure is theoretically founded on Bayesian Hypothesis Testing and
combines semantic information provided by word embeddings with distributional
information tied to the specifc underlying classifcation task. We evaluate our method
with state-of-the-art classifers such as Multinomial Naive Bayes and Support Vector Ma-
chines. As opposed to previous attempts of term clustering, our method achieves
improvements in text classifcation accuracy in all the datasets evaluated.
