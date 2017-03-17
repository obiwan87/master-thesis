classdef ProbabilisticLexicalSubstitution < LexicalSubstitutionPreprocessor
    %PROBABILISTICLEXICALSUBSTITUTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        K
        MaxIter
        SubstitutionThreshold
        MinSimilarity
    end
    
    methods
        function obj = ProbabilisticLexicalSubstitution(varargin)
            obj = obj@LexicalSubstitutionPreprocessor(varargin{:});
        end
        
        function r = doExecute(obj, ~, args)
            
            D = args.DocumentSet;
            
            % Only words that are contained in word2vec model
            Vi = D.Vi(D.Vi~=0);
            
            % For each of the words contained in word2vec model analyze
            % nearest neighbors and keep track of the substitutions in each
            % iteration
            LVi = zeros(numel(Vi),obj.MaxIter+1);
            LVi(:,1) = 1:numel(Vi);
            
            k = 1;
            
            TF = D.termFrequencies();
            
            F = TF.Frequency(D.Vi~=0,:);
            
            %% Step 1: Look for substitution candidates
            % WARNING: You're entering an index jungle %
            
            while k <= obj.MaxIter                
                [uV, ~, uVb] = unique(LVi(:,k));
                
                Fu = F(uV);
                
                %                  LVi                   uV
                % word2vec indices <-> document indices <-> NNs indices                
                wii = Vi(uV); %word2vec indices
                
                ref = D.m.X(wii,:); % reference subset of model
                query = D.m.X(wii,:); % query subset of model
                [nns, dists] = knnsearch(ref,query,'k', obj.K,'distance', 'cosine');
                probs = 1 - dists; % Interpret distances as probabilities p(w1|w2)
                clear distances
                for i=1:size(uV,1)
                    j = uV(i);
                    u = i == uVb;
                    f = Fu(nns(i,:)); % Frequencies of NNs of word w
                    
                    % Should we even consider a substitution?
                    if f(1) <= obj.SubstitutionThreshold
                        % Substitute only if p(w|D) <= p(w|s) * p(s|D)
                        P = probs(i,:)';
                        p = f .* P;
                        c = find((p > p(1)) & (P >= obj.MinSimilarity), 1, 'first');
                        
                        if ~isempty(c)
                            s = nns(i,c);
                            LVi(u,k+1) = uV(s);
                        else
                            LVi(u,k+1) = j;
                        end
                    else
                        LVi(u,k+1) = j;
                    end
                end
                
                %% Step 2: Solve transitive substitutions
                % Use a graph and its connected components to figure out
                % how many actual substitutions there are
                % An edge (w1,w2) represents the relationship "w1 is
                % substituted by w2"
                
                sources = unique(LVi(:,k));
                [ ~, iA ]= intersect( LVi(:,k), sources );
                targets = LVi(iA,k+1);
                
                edges = table(sources, targets, 'VariableNames', {'sources', 'targets'});
                edges = unique(edges);
                edges = table([edges.sources edges.targets], 'VariableNames', {'EndNodes'});
                sd = digraph(edges, 'OmitSelfLoops'); % substitution graph
                
                C = conncomp(sd, 'type', 'weak');
                cs = unique(C);
                nodesInComp = histc(C, cs);
                
                for i=1:numel(cs)
                    if nodesInComp(i) > 1
                        % Words in this conntected component
                        snodes = find(cs(i) == C);
                        tg = subgraph(sd, snodes);
                        [~,iA] = intersect(uV, snodes);
                        
                        % All nodes in this connected component
                        N = 1:numnodes(tg);
                        
                        % Navigate the graph one layer at a time
                        % A layer is the defined as
                        % L_j = {n \in TG.V | distance(n, root) = j };
                        % j = 1,...,J_max
                        
                        pathLengths = distances(tg, N, find(outdegree(tg) == 0));
                        [pathLengths, ii] = sort(pathLengths,'descend');
                        N = N(ii);
                        
                        % We to substitute words according to their
                        % frequencies before any substitution from the
                        % previous Layer.
                        
                        Fu_temp = Fu;
                        
                        L = pathLengths(1);
                        for kk=1:numel(N)
                            if L > pathLengths(kk)
                                %commit changes to frequency
                                Fu = Fu_temp;
                                L = pathLengths(kk);
                            end
                            
                            % Iterate through the sequence of substitutions
                            current = N(kk);
                            succ = successors(tg, current);
                            assert(numel(succ) <= 1);
                            
                            if ~isempty(succ)
                                d = 1 - pdist(ref(iA([current succ]),:),'cosine');
                                fprintf('%s (%.2f)|----%.2f---->|%s (%.2f) ', D.m.Terms{Vi(iA(current))}, Fu(iA(current)), d, D.m.Terms{Vi(iA(succ))}, Fu(iA(succ)));
                                
                                if Fu(iA(succ)) * d > Fu(iA(current))
                                    % Update frequency
                                    Fu_temp(iA(succ)) = d*Fu_temp(iA(current)) + Fu_temp(iA(succ));
                                    Fu_temp(iA(current)) = 0;
                                    LVi( LVi(:,k+1) == snodes(current),k+1) = snodes(succ);
                                    fprintf(' (s) ')
                                else
                                    fprintf(' (x) ')
                                end
                                fprintf('\n');                                
                            end
                        end
                        
                        LVi(snodes, k+1) = snodes(outdegree(tg) == 0);
                    end
                end
                F(uV) = Fu;
                k = k + 1;
                %LVi(:,k+1) = LVi(:,k); % copy to next iteration
            end
            %% Step 3: Substitute terms and create new corpus
            
            nZ = find(D.Vi ~= 0);
            S = 1:numel(D.V);
            S(nZ) = nZ(LVi(:,end));
            
            LI = cellfun(@(x) S(x), D.I, 'UniformOutput', false);
            LT = cellfun(@(x) D.V(x)', LI, 'UniformOutput', false);
            LD = io.Word2VecDocumentSet(D.m, LT, D.Y);
            LD.tfidf();
            
            r = struct('Out', LD);
            info = struct();
            info.vocSizeBefore = numel(D.V);
            info.vocSizeAfter = numel(LD.V);
            info.S = S;
            r.info = info;
            
        end
        
    end
    
    methods(Access=protected)
        
        function p = createPipelineInputParser(obj)
            p = createPipelineInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Pipeline Input (=Dataset)
            addRequired(p, 'DocumentSet', @(x) isa(x, 'io.Word2VecDocumentSet'));
        end
        
        function p = createConfigurationInputParser(obj)
            p = createConfigurationInputParser@pipeline.AtomicPipelineStep(obj);
            
            % Algorithm Parameters
            addParameter(p, 'K', 10, @is_pos_integer);
            addParameter(p, 'MaxIterations', 5, @is_pos_integer);
            addParameter(p, 'SubstitutionThreshold', Inf, @(x) x > 0);
            addParameter(p, 'MinSimilarity', 0, @(x) x > 0);
            
            function b = is_pos_integer(x)
                b = isscalar(x) && x >= 1 && floor(x) == x;
            end
        end
        
        function config(obj, args)
            config@pipeline.AtomicPipelineStep(obj, args);
            
            obj.K = args.K;
            obj.MaxIter = args.MaxIterations;
            obj.SubstitutionThreshold = args.SubstitutionThreshold;
            obj.MinSimilarity = args.MinSimilarity;
        end
        
    end
    
end