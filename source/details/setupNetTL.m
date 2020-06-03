function net = setupNetTL(details)
    if strcmp(getMyHostName(), 'g7')
        net = load('I do not have this model local') ;
    else
        net = load('results/saida100_details-mit-mitDetails_details-loadDataset_details-evaluationTest_details-setupNet_details-trainDetails.log_dir/net-epoch-30.mat') ;
    end
    net = net.net;

    vl_simplenn_display(net, 'inputSize', [details.dataSize details.batchSize]);

    addAgainLayers(net, details.numClass);

end

function net = addAgainLayers(net, numClass)
    f=1/100;
    % remove 3 layers from the VGG
    net.layers(end) = []; % remove the loss layer
    net.layers(end) = []; % remove the dropout layer
    net.layers(end) = []; % remove the FC layer

    % FC2
    net.layers{end+1} = struct('type', 'conv', 'name', 'FC2',...
                               'filters', f*randn(1,1,4096,numClass, 'single'), ...
                               'biases', zeros(1, numClass, 'single'), ...
                               'stride', 1, ...
                               'filtersLearningRate', 4, ...
                               'pad', 0);

    %net.layers{end+1} = struct('type', 'relu', 'name', 'FC2');

    % Dropout de 50%
    net.layers{end+1} = struct('type', 'dropout','name', 'DROP12','rate', 0.1);

    % softmax
    net.layers{end+1} = struct('type', 'softmaxloss');
end
