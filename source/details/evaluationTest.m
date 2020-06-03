function evaluationTest(net, testData, recordsName, dataDetails, outputPath)
    net.layers(end) = []; % remove the loss layer
    outputPath = addSlash(outputPath);
    if dataDetails.saveErrors
        outputErrorPath = [outputPath 'errors/'];
    end

    dataDetails.getWaveFunction = prepareMatFileToRun(dataDetails.getWaveFunction);

    tpPan = 0;
    fpPan = 0;
    fnPan = 0;
    tnPan = 0;
    tpCNN = 0;
    fpCNN = 0;
    fnCNN = 0;
    tnCNN = 0;
    rightSignals = [];
    wrongFnSignals = [];
    wrongFpSignals = [];

    for k=1:length(recordsName)
        fprintf('--------------------------------------------------------------------------------------------------\n');
        fprintf('Record: %s\n', recordsName{k});

        fprintf('\tRunning the Pan Tompkin algorithm...\n');
        [r, in, delay] = panTompkin(double(testData.(['record_' num2str(k)]).ecgSignal), dataDetails.freqSample, 0);
        in = in(in > dataDetails.sizeBeat & in < (size(testData.(['record_' num2str(k)]).ecgSignal, 1) - dataDetails.sizeBeat));
        [rPeaks, in] =  filterPan(testData.(['record_' num2str(k)]).rPeaks, testData.(['record_' num2str(k)]).typeSignal, in, delay);

        [tp, fp, fn, tn, ~, ~] = getMetrics(testData.(['record_' num2str(k)]).ecgSignal, rPeaks, in, delay, false, recordsName{k}, outputErrorPath, dataDetails.sizeBeat);
        tpPan = tpPan + tp;
        fpPan = fpPan + fp;
        fnPan = fnPan + fn;
        tnPan = tnPan + tn;

        fprintf('\tRunning CNN to evaluate the Pan Tompkin detection...\n');
        inEvaluated = evaluateQRS(net, testData.(['record_' num2str(k)]).ecgSignal, in, testData.(['record_' num2str(k)]).imageMean, dataDetails.getWaveFunction, dataDetails);
        [tp, fp, fn, tn, rs, wsFn, wsFp] = getMetrics(testData.(['record_' num2str(k)]).ecgSignal, rPeaks, inEvaluated, delay, dataDetails.saveErrors, recordsName{k}, outputErrorPath, dataDetails.sizeBeat);
        tpCNN = tpCNN + tp;
        fpCNN = fpCNN + fp;
        fnCNN = fnCNN + fn;
        tnCNN = tnCNN + tn;
        rightSignals = [rightSignals; rs];
        wrongFnSignals = [wrongFnSignals; wsFn];
        wrongFpSignals = [wrongFpSignals; wsFp];
        plotMeanBeats(rs, wsFn, wsFp, dataDetails.sizeBeat, ['Ind' recordsName{k}], outputPath);
        plotWrongBeats(wsFn, dataDetails.sizeBeat, ['Ind' recordsName{k} 'Fn'], outputPath);
        plotWrongBeats(wsFp, dataDetails.sizeBeat, ['Ind' recordsName{k} 'Fp'], outputPath);
    end

    fprintf('\n\n--------------------------------------------------------------------------------------------------\n');

    fprintf('\n\nFinal result:\n');
    accuracy = [(tpPan + tnPan)/(tpPan + tnPan + fpPan + fnPan) (tpCNN + tnCNN)/(tpCNN + tnCNN + fpCNN + fnCNN)];
    specificity = [tnPan/(tnPan + fpPan) tnCNN/(tnCNN + fpCNN)];
    sensitivity = [tpPan/(tpPan + fnPan) tpCNN/(tpCNN + fnCNN)]; % the same of recall
    positive_prediction = [tpPan/(tpPan + fpPan) tpCNN/(tpCNN + fpCNN)]; % precision
    fscore = [2 * (sensitivity(1) * positive_prediction(1))/(sensitivity(1) + positive_prediction(1)) ...
              2 * (sensitivity(2) * positive_prediction(2))/(sensitivity(2) + positive_prediction(2))];

    print_int_with_color('\t                   True-positive:', tpPan, tpCNN, false);
    print_int_with_color('\t                  False-positive:', fpPan, fpCNN, true);
    print_int_with_color('\t                  False-negative:', fnPan, fnCNN, true);
    print_float_with_color_percent('\t         Sensitivity [recall   ]:', sensitivity(1) * 100, sensitivity(2) * 100, false);
    print_float_with_color_percent('\t Positive prediciton [precision]:', positive_prediction(1) * 100, positive_prediction(2) * 100, false);
    print_float_with_color('\t                         F-Score:', fscore(1), fscore(2), false);

    plotMeanBeats(rightSignals, wrongFnSignals, wrongFpSignals, dataDetails.sizeBeat, 'All', outputPath);
    plotWrongBeats(wrongFnSignals, dataDetails.sizeBeat, 'AllFn', outputPath);
    plotWrongBeats(wrongFpSignals, dataDetails.sizeBeat, 'AllFp', outputPath);
end

function print_int_with_color(string_to_print, value1, value2, inverted)
    if ~inverted
        if value1 > value2
            fprintf([string_to_print ' %7d |\33[91m %7d\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print ' %7d |\33[93m %7d\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print ' %7d |\33[94m %7d\33[0m\n'], value1, value2);
        end
    else
        if value1 > value2
            fprintf([string_to_print ' %7d |\33[94m %7d\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print ' %7d |\33[93m %7d\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print ' %7d |\33[91m %7d\33[0m\n'], value1, value2);
        end
    end
end

function print_float_with_color(string_to_print, value1, value2, inverted)
    if ~inverted
        if value1 > value2
            fprintf([string_to_print '  %6.2f |\33[91m  %6.2f\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print '  %6.2f |\33[93m  %6.2f\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print '  %6.2f |\33[94m  %6.2f\33[0m\n'], value1, value2);
        end
    else
        if value1 > value2
            fprintf([string_to_print '  %6.2f |\33[94m  %6.2f\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print '  %6.2f |\33[93m  %6.2f\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print '  %6.2f |\33[91m  %6.2f\33[0m\n'], value1, value2);
        end
    end
end

function print_float_with_color_percent(string_to_print, value1, value2, inverted)
    if ~inverted
        if value1 > value2
            fprintf([string_to_print ' %6.2f%% |\33[91m %6.2f%%\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print ' %6.2f%% |\33[93m %6.2f%%\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print ' %6.2f%% |\33[94m %6.2f%%\33[0m\n'], value1, value2);
        end
    else
        if value1 > value2
            fprintf([string_to_print ' %6.2f%% |\33[94m %6.2f%%\33[0m\n'], value1, value2);
        elseif value1 == value2
            fprintf([string_to_print ' %6.2f%% |\33[93m %6.2f%%\33[0m\n'], value1, value2);
        else
            fprintf([string_to_print ' %6.2f%% |\33[91m %6.2f%%\33[0m\n'], value1, value2);
        end
    end
end

function [response]=evaluateQRS(net, ecgSignal, qrsDetected, meanVal, getWaveFunction, details)
    global dataSize
    response = [];
    for i = 1:size(qrsDetected, 2)
        wave = feval(getWaveFunction, ecgSignal, qrsDetected(i), details.halfSizeBeat, details.sizeBeat, meanVal, 'Testing ...');
        hb = 256 * reshape(wave, dataSize(1), dataSize(2), dataSize(3), []);
        res = vl_simplenn(net, hb) ;
        scores = squeeze(gather(res(end).x));
        [bestScore, predictClass] = max(scores);
        if predictClass == 1 % 1 == QRS detected
            response = [response qrsDetected(i)];
        end
    end
end

function [responseGT, responsePan] = filterPan(rPeaks, typeSignal, in, delay)
    tolerance = 3;
    idsGT = ones(size(rPeaks, 1), size(rPeaks, 2));
    idsPan = ones(size(in, 1), size(in, 2));
    jj = 1;
    for i = 1:size(in, 2)
        ini = in(i);
        for j = jj:size(rPeaks, 1)
            fprintf('\n\t%6d\t-\t%6d %6d - %s\t', i, ini, rPeaks(j), typeSignal(j));
            if typeSignal(j) ~= 'N'
                idsGT(j) = 0;
            end
            % True Positive - the rPeak is somewhere between the aceptable window and only accept the normal signals
            if ini - delay - tolerance < rPeaks(j) < ini + delay + tolerance
                if typeSignal(j) ~= 'N'
                    fprintf('Eliminating')
                    idsPan(i) = 0;
                end
                jj = j + 1;
                break
            end
        end
    end
    fprintf('\n');
    responseGT = rPeaks(boolean(idsGT));
    responsePan = in(boolean(idsPan));
end

% um com a média dos batimentos: instancias que acertamos e que erramos
% e outro, plotoando todos os batimentos que agente erra no mesmo gráfico

function plotMeanBeats(rightBeats, wrongFnBeats, wrongFpBeats, sizeBeat, extraInfo, outputPath)
    close all;
    h1 = figure;
    meanRightBeats = mean(rightBeats);
    meanWrongFnBeats = mean(wrongFnBeats);
    meanWrongFpBeats = mean(wrongFpBeats);
    plot(1:sizeBeat, meanRightBeats, ...
         1:sizeBeat, meanWrongFnBeats, ...
         1:sizeBeat, meanWrongFpBeats);
    % title('Mean of the right detected and wrong detected beats');
    axis([0 sizeBeat -0.1 1.1]);
    legend('Right detected beats', 'False negative detected beats', 'False positive detected beats')
    print(h1, [outputPath extraInfo 'Right-Wrong-mean-beats.png'], '-dpng');
    % savefig(h1, [outputPath record '_FP(' num2str(a(i)) ').fig']);
end

function plotWrongBeats(wrongBeats, sizeBeat, extraInfo, outputPath)
    close all;
    h1 = figure;
    for i = 1:size(wrongBeats, 1)
        hold on
        plot(1:sizeBeat, wrongBeats(i, :));
    end
    % title('Mean of the right detected and wrong detected beats');
    axis([0 sizeBeat -0.1 1.1]);
    print(h1, [outputPath extraInfo 'Wrong-beats.png'], '-dpng');
    % savefig(h1, [outputPath record '_FP(' num2str(a(i)) ').fig']);
end
