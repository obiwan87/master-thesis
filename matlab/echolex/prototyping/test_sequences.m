
%seq = Sequence(ExcludeWords('MinCount', 1, 'MaxCount', Inf), GlobalLexicalKnnSubstitution('K', 30));
%input = W;
%seq.execute(input);

%grid = GridFactory.createGrid('pipeline.preprocessing.ExcludeWords', 'MinCount', [2 3 4], 'MaxCount', [100 200]);

% one Fork
p1 = { pipeline.DummyStep('1'), pipeline.DummyStep('2'), {pipeline.DummyStep('f1'), pipeline.DummyStep('f2'), pipeline.DummyStep('f3')}', pipeline.DummyStep('3')};

% two forks
p2 = { pipeline.DummyStep('1'), pipeline.DummyStep('2'),  {{pipeline.DummyStep('f11'), pipeline.DummyStep('f12'), pipeline.DummyStep('f13') }', { pipeline.DummyStep('f21'), pipeline.DummyStep('f22')}', pipeline.DummyStep('3')}};

% fork in fork
p3 = {  pipeline.DummyStep('1'), ...
             { ...
                 {pipeline.DummyStep('f1'), ...                 
                     {  ...                 
                        pipeline.DummyStep('f1f1'); ...
                        pipeline.DummyStep('f1f2')  ...                    
                     }
                 }; ...                 
                 pipeline.DummyStep('f2') ...
             }, ...
        pipeline.DummyStep('final')...
     };
    
p = p2;
P = pipeline.Pipeline(p{:});
P.execute('Dummy Session', D);
% Sequence ( p, Fork({p1,p2,p3}, 
% for i=1:size(P.ExecutionPaths, 1)
%     p = func.foldr(P.ExecutionPaths(i,:), '', @(x,y) [y.Name ' -> ' x]);
%     fprintf('%s\n',p);
% end