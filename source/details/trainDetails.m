function conf = trainDetails()
    conf = [];
    conf.gpus = [1];
    conf.numClass = 2;                 % Number of classes
    conf.continue = true ;             % Continue train or not
    conf.dataSize =[1 300 1];          % Load CN data
    conf.plotDiagnostics = true;       % If show plot diagnotics (true for yer)
    conf.errorFunction = 'multiclass'; % Which type of error function
    if strcmp(getMyHostName(), 'g7')   % Batch size
        conf.batchSize = 250;
        conf.matConvNetPath = '../../../MatConvNet';
    else
        conf.batchSize = 5000;
        conf.matConvNetPath = '../matConvNet/';
    end
    % Learning rate during training
    if strcmp(getMyHostName(), 'g7')   % Batch size
        conf.learningRate = [0.01];
    else
        conf.learningRate = [0.01 * ones(1,3) 0.005 * ones(1, 7) 0.001 * ones(1,10) 0.0001 * ones(1,10)];
    end
end
