function [lD, S, ST] = prob_lexsub( trD, teD, varargin )
% PROB_LEXSUB Probabilistic Lexical Substitution

p = create_parser();
parse(p, varargin{:});
params = p.Results;

K = params.K;
minSimilarity = params.MinSimilarity;
substThresh = params.SubstitutionThreshold;
frequencyCoefficient = params.FrequencyCoefficient;

% Get words that are in test set but not in trainign set
teV = teD.V(teD.Vi~=0);
trV = trD.V(trD.Vi~=0);

% Mapping of words in Test/Training to w2v-Vocabulary
teVi = teD.Vi(teD.Vi~=0);
trVi = trD.Vi(trD.Vi~=0);

trF = trD.termFrequencies();
% teF = teD.termFrequencies();
trF = trF.Frequency(trD.Vi~=0,:);

% Find out how often words of test occur in training
[~,iA,iB] = intersect(teVi, trVi);
F = ones(numel(teVi),1);
F(iA) = trF(iB);

% For words with frequencies less than substThresh we want to find
% substitutes
o = find(F <= substThresh);
oF = F(o);
oteVi = teVi(o);
oteV  = teV(o);

% Word2Vec Model
m = trD.m;

% Calculate distances from oteV to trV
ref   = m.X(trVi,:);
query = m.X(oteVi,:);

[nns, dist] = knnsearch(ref, query, 'k', K, 'distance', 'cosine');

Fnns = reshape(trF(nns(:)), size(nns));

dist = 1 - dist;
dist(Fnns < oF.*frequencyCoefficient) = 0;
dist(dist <= minSimilarity) = 0;

probs = dist;

dontSubstitute = sum(dist,2) == 0;

% Sort candidates by dist * frequency descending
[sprobs, pii] = sort(probs, 2, 'descend');

% Apply sorting order to nns
I = repmat((1:size(pii,1)), size(pii,2), 1);
pii = pii';

sii = sub2ind(size(nns), I(:), pii(:));
substCandidates = transpose(reshape(nns(sii), size(nns,2), size(nns,1)));
frequenciesSubstCandidates = transpose(reshape(Fnns(sii), size(Fnns,2), size(Fnns,1)));

S = substCandidates(:,1);
FS = frequenciesSubstCandidates(:,1);

ST = table(teV(o(~dontSubstitute)), trV(S(~dontSubstitute)), sprobs(~dontSubstitute,1), oF(~dontSubstitute), FS(~dontSubstitute), ...
               'VariableNames', {'OrigV', 'SubstV', 'Dist', 'OrigF', 'SubstF'});
           
teV(o) = trV(S);
teV(o(dontSubstitute)) = oteV(dontSubstitute);

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
addParameter(p, 'FrequencyCoefficient', 1.3, @(x) x > 0);

    function b = is_pos_integer(x)
        b = isscalar(x) && x >= 1 && floor(x) == x;
    end
end

