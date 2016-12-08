% p1 = sequence(pipeline.DummyStep('1'), pipeline.DummyStep('2'), fork(pipeline.DummyStep('f1'), pipeline.DummyStep('f2')), pipeline.DummyStep('3'));
% P = pipeline.Pipeline(p1);
% P.execute('Dummy Sessions', D);
% 
% p2 = sequence(pipeline.DummyStep('1'), fork(pipeline.DummyStep('f1'), pipeline.DummyStep('f2')), fork(pipeline.DummyStep('ff1'), pipeline.DummyStep('ff2')), pipeline.DummyStep('3'));
% P = pipeline.Pipeline(p2);
% P.execute('Dummy Sessions', D);
% 
% % 1, f((1,2),2), f(1,2), 3
% p3 = sequence(pipeline.DummyStep('1'), fork(sequence(pipeline.DummyStep('fs1'), pipeline.DummyStep('fs2')), pipeline.DummyStep('f2')), fork(pipeline.DummyStep('ff1'), pipeline.DummyStep('ff2')), pipeline.DummyStep('3'));
% P = pipeline.Pipeline(p3);
% P.execute('Dummy Sessions', D);
% 
p4 = sequence(pipeline.DummyStep('1'), fork(sequence(pipeline.DummyStep('fs1'), pipeline.DummyStep('fs2')), fork(sequence(nop(), pipeline.DummyStep('f2f1')), sequence(nop(), pipeline.DummyStep('f2f2')))), fork(pipeline.DummyStep('ff1'), pipeline.DummyStep('ff2')), pipeline.DummyStep('3'));
P = pipeline.Pipeline(p4);
R = ExperimentReport(0,'dummy', 'dummy exp', 'test');
P.execute(D, R);

%p5 = sequence(GlobalLexicalKnnSubstitution('K', 10), TfIdf(), SVMClassifier('KFold', 10) );
%P = pipeline.Pipeline(p5);
%
%P.execute('Dummy Sessions', W, R1);