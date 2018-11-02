# master-thesis
Code for Master Thesis "Improving Text Classification with Lexical Substitution and Word Embeddings"

# Description

Text Classification  is the task of automatically assigning textual data to a set of predefined classes.
Besides being an intensively researched topic, TC and its applications are widely spread among every area of industry.
Nowadays, the underlying algorithms for TC are mainly founded on machine learning techniques.  
Typically, the predictive power of machine learning based classifiers is heavily dependent on the quantity and quality of data 
used for training. 
However, this requires gathering labeled data, which is a time- and resource-intensive process that has to be manually performed 
by human domain experts.
In many real-word scenarios, this fact represents a significant limitation to TC effectiveness. 
Therefore, in this work we propose a method to improve text classification accuracy despite the scarcity of pre-classified textual data. 
For this purpose, we contribute a novel semantic-distributional word distance measure that can be used in connection with clustering algorithms, 
to extract a semantically enriched and lower dimensional term feature space. Our distance measure is theoretically founded on
Bayesian Hypothesis Testing and combines semantic information provided by word embeddings
with distributional information tied to the specific underlying classification task. We evaluate our method with state-of-the-art 
classifiers such as Multinomial Naive Bayes and Support Vector Machines. As opposed to previous 
attempts of term clustering, our method achieves improvements 
in text classification accuracy in all the datasets evaluated. 
