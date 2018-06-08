dataset_statistics = d([6 7 12 13],:);

sizes = [500 1000 1500 8500;
         500 1000 1500 2600;
         500 1000 1500 8500;
         500 1000 1500 8500];

for i=1:numel(public_datasets_training_validation)
    s = sizes(i,:);
    datatset = dataset_statistics(i,:);
    nonTest = datatset.docs - 1000;
    
    t = s ./ nonTest;
    c = sign(0.9 - double(t <= 1/2));
    t(t > 1/2) = 1 - t(t > 1/2);
    
    t = ceil(c.*t.^-1);
    trainSizes = zeros(size(t));
    testSizes = zeros(size(t));
    for j=1:numel(t)
        rng default
        cv = cvpartition(nonTest, 'Kfold', abs(t(j)));        
        if c(j) > 0
            trainSizes(j)  = round(mean(cv.TrainSize));
            testSizes(j) = round(mean(cv.TestSize));
        else
            testSizes(j)  = round(mean(cv.TrainSize));
            trainSizes(j) = round(mean(cv.TestSize));
        end
    end
    g = [t' trainSizes' testSizes'];
    
end