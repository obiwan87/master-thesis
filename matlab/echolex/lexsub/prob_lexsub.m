function [lD, S, ST] = prob_lexsub( trD, teD, varargin )
% PROB_LEXSUB Probabilistic Lexical Substitution

% (1)   Possibility to define a test-training split and lexically substitute
% (1.1) test words to training words
% (1.2) training words to a smaller set of words

% Two Modi of substituting: online, batch
% Difference:
% Online:
% Do not consider frequencies of the test set, i.e. each word with
% frequency >= 1 has frequency 1
% Batch:
% Consider also frequencies of test set.

% Implement online first, i.e. replace only words that are in test set but
% not in training set

% Extract frequencies such that,
% (1) if a word is not contained in training set it has the frequency 0
% (2)

p = create_parser();
parse(p, varargin{:});
params = p.Results;

K = params.K;
minSimilarity = params.MinSimilarity;
%substThres = params.SubstitutionThreshold;

% Get words that are in test set but not in trainign set
teV = teD.V(teD.Vi~=0);
trV = trD.V(trD.Vi~=0);

% Mapping of words in Test/Training to w2v-Vocabulary
teVi = teD.Vi(teD.Vi~=0);
trVi = trD.Vi(trD.Vi~=0);
% 
% trF = trD.termFrequencies();
% % teF = teD.termFrequencies();
% trF = trF.Frequency(trD.Vi~=0,:);
% 
% % Find out how often words of test occur in training
% [~,iA,iB] = intersect(teVi, trVi);
% F = zeros(numel(trVi,1));
% F(iA) = trF(iB);
% 
% % For words with frequencies less than substThresh we want to find
% % substitutes
% o = F <= substThres;
% 
% % Just to make clear that we don't need this anymore
% % Aand it has nothing to do with iA later
% clear iA 

% [o]nly [te]st [v]ocabulary (OOV words)
[oteVi, iA] = setdiff(teVi, trVi);
oteV = teV(iA);

% Word2Vec model
m = trD.m;

% Calculate distances from oteV to trV
ref   = m.X(trVi,:);
query = m.X(oteVi,:);

[nns, dist] = knnsearch(ref, query, 'k', K, 'distance', 'cosine');


dist = 1 - dist;
dist(dist <= minSimilarity) = 0;

probs = dist;

dontSubstitute = sum(dist,2) == 0;

% Sort candidates by dist * frequency descending
pii = sorti(probs, 2, 'descend');

% Apply sorting order to nns
I = repmat((1:size(pii,1)), size(pii,2), 1);
pii = pii';

sii = sub2ind(size(nns), I(:), pii(:));
substCandidates = transpose(reshape(nns(sii), size(nns,2), size(nns,1)));

S = substCandidates(:,1);
teV(iA) = trV(S);
teV(iA(dontSubstitute)) = oteV(dontSubstitute);

ST = [oteV teV(iA)];

lV = teD.V;
lV(teD.Vi ~= 0) = teV;

teD.terms2Indexes();
lT = cellfun(@(x) lV(x)', teD.I, 'UniformOutput', false);
lD = io.Word2VecDocumentSet(m, lT, teD.Y);
end


function p = create_parser()
p = inputParser;
p.KeepUnmatched = true;

% Algorithm Parameters
addParameter(p, 'K', 10, @is_pos_integer);
addParameter(p, 'MinSimilarity', 0, @(x) x > 0);
addParameter(p, 'SubstitutionThreshold', 5, @(x) x > 0);
addParameter(p, 'FrequencyCoeffiecient', 1.3, @(x) x > 0);

    function b = is_pos_integer(x)
        b = isscalar(x) && x >= 1 && floor(x) == x;
    end
end

