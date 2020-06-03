% digite para rodar na linha de comando:
% nohup matlab -nodesktop -nosplash -r 'mainCYBHi(100, true, true)' > ./results/saida_CNN.txt </dev/null &
%
% autor: Eduardo Luz (eduluz@gmail.com)
%        Pedro Silva (pedroh21.silva@gmail.com)

function framework(dataDetailsFile, loadDatasetFile, evaluationTestFile, randomSeed, isToDeleteIntermediateNetFiles, trainDetailsFile, setupNetFile, resultDir)

    global dataSize

    addImportantPaths();

    rand('seed', randomSeed);
    randn('state', randomSeed);
    rand('state', randomSeed);
    fprintf('Used random seed: %d\n', randomSeed);

    dataDetails = feval(prepareMatFileToRun(dataDetailsFile));
    trainDetails = feval(prepareMatFileToRun(trainDetailsFile));
    % Validate all training details before continue
    checkTrainDetails(trainDetails);
    trainOpts = fillTrainOpts(resultDir, trainDetails);
    createFolder(trainOpts.expDir);
    dataSize = trainDetails.dataSize;

    fprintf('*** Settuping training workspace\n');
    setupMatConvNet(trainDetails.matConvNetPath, 'useGpu', true); % start

    net = feval(prepareMatFileToRun(setupNetFile), trainDetails);
    vl_simplenn_display(net, 'inputSize', [trainDetails.dataSize 1]);

    lastNet = [trainOpts.expDir '/net-epoch-' num2str(trainOpts.numEpochs) '.mat'];
    if ~doesPathExist(lastNet)
        fprintf('*** Starting loading training/validation dataset\n');
        [imdb, ~] = feval(prepareMatFileToRun(loadDatasetFile), true, dataDetails);
        fprintf('*** Starting training\n');
        [net ~] = cnn_train(net, imdb, @getBatch, trainOpts);
        clear imdb;
    else
        fprintf('*** Loading final trained model\n');
        net = load(lastNet);
        net = net.net;
    end

    deleteIntermeditaeNetFiles(isToDeleteIntermediateNetFiles, trainOpts);

    fprintf('*** Starting loading test dataset\n');
    [testData extraInfo] = feval(prepareMatFileToRun(loadDatasetFile), false, dataDetails);

    fprintf('*** Starting evaluation on test images\n');
    feval(prepareMatFileToRun(evaluationTestFile), net, testData, extraInfo, dataDetails, trainOpts.expDir);

end

function deleteIntermeditaeNetFiles(isToDeleteIntermediateNetFiles, trainOpts)
    if isToDeleteIntermediateNetFiles
        fprintf('*** Deleting intermediate network files\n');
        for i = 1:trainOpts.numEpochs-1
            net_name_file = [addSlash(trainOpts.expDir) 'net-epoch-' num2str(i) '.mat'];
            if doesPathExist(net_name_file)
                delete(net_name_file);
            end
        end
    end
end

function checkTrainDetails(trainDetails)
    if length(trainDetails.dataSize) ~= 3
        error('The data size must have length equal to 3 (three).');
    end
    % Need more checks
end

function trainOpts = fillTrainOpts(resultDir, details)
    trainOpts.gpus = details.gpus;
    trainOpts.expDir = resultDir;
    trainOpts.plotDiagnostics = true;
    trainOpts.continue = details.continue;
    trainOpts.errorFunction = details.errorFunction;
    trainOpts.batchSize = details.batchSize;
    trainOpts.learningRate = details.learningRate;
    trainOpts.numEpochs = length(details.learningRate);
end

% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
    global dataSize
    im = imdb.images.data(:, :, batch);
    im = single(256 * reshape(im, dataSize(1), dataSize(2), dataSize(3), []));
    labels = imdb.images.label(1, batch);
end
