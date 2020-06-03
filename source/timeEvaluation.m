% digite para rodar na linha de comando:
% nohup matlab -nodesktop -nosplash -r 'mainCYBHi(100, true, true)' > ./results/saida_CNN.txt </dev/null &
%
% autor: Eduardo Luz (eduluz@gmail.com)
%        Pedro Silva (pedroh21.silva@gmail.com)

function timeEvaluation(useCpu)

    addImportantPaths();
    addpath('./details/');

    fprintf('*** Settuping training workspace\n');
    dataDetails = [];
    dataDetails.dataSize =[1 300 1];          % Load CN data
    dataDetails.matConvNetPath = '../../../MatConvNet';
    dataDetails.numClass = 2;

    setupMatConvNet(dataDetails.matConvNetPath, 'useGpu', true); % start
    
    net = load('results/saida4972_details-mit-mitDetails_details-loadDataset_details-evaluationTest_details-setupNet_details-trainDetails.log_dir/net-epoch-1.mat');
    net = net.net;
    if (useCpu)
        net = vl_simplenn_move(net, 'cpu');
        fprintf('\tNow is CPU\n');
    end
    net.layers(end) = []; % remove the loss layer
    vl_simplenn_display(net, 'inputSize', [dataDetails.dataSize 1]);

    ecgSignal = im2single(zeros(1, 300));
    
    totalTime = 0;

    fprintf('*** Starting time evaluation\n');
    for index = 1:100
        tic;
        evalQRS(net, ecgSignal, dataDetails.dataSize);
        timeLapsed = toc; 
        totalTime = totalTime + timeLapsed;
        fprintf('\tTime wasted: %f\n', timeLapsed);
    end
    fprintf('Time total wasted: %f\n', totalTime);
    
end

function evalQRS(net, ecgSignal, dataSize)
    hb = 256 * reshape(ecgSignal, dataSize(1), dataSize(2), dataSize(3), []);
    res = vl_simplenn(net, hb) ;
    scores = squeeze(gather(res(end).x));
    [bestScore, predictClass] = max(scores);
end
