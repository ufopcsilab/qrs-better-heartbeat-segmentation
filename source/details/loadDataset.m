function [data extraInfo] = loadCYBHiDataset(isTrain, details)

    details.loadIndividualFunction = prepareMatFileToRun(details.loadIndividualFunction);
    details.getRecordsFunction = prepareMatFileToRun(details.getRecordsFunction);

    if isTrain
        details.halfSizeBeat = round(details.sizeBeat/2);
        details.annoQRSLabel = 1;
        details.annoFreeLabel = 2;
        details.dbpath = addSlash(details.dbpath);
        details.getWaveFunction = prepareMatFileToRun(details.getWaveFunction);
        records = feval(details.getRecordsFunction, details.recordsTrainCode);

        count = 1;

        % Initializing the structs with dump info
        data.images.data = [];
        extraInfo{1} = '';

        fprintf('\tStarting extraction...\n');

        for i=1:length(records)
            fprintf('\t\tRECORD (%d): %s\n', i, records{i});
            [recordedSignal, rPeaks, typeSignal, meanVal] = feval(details.loadIndividualFunction, details.dbpath, records{i}, details);
            rPeaks = rPeaks(typeSignal == 'N'); % Get only the normal beats
            % Validation peaks are the 70% final records
            validationPeaks = [rPeaks(rPeaks >= round(0.70 * size(recordedSignal, 1))); size(recordedSignal, 1)];
            for j = 1:size(validationPeaks, 1) - 1
                [data, count, extraInfo] = addWindow(validationPeaks, recordedSignal, j, count, meanVal, 2, details, data, extraInfo);
            end
            % Train peaks are the 70% initial records
            trainPeaks = [rPeaks(rPeaks < round(0.70 * size(recordedSignal, 1))); validationPeaks(1)];
            for j = 1:size(trainPeaks, 1) - 1
                [data, count, extraInfo] = addWindow(trainPeaks, recordedSignal, j, count, meanVal, 1, details, data, extraInfo);
            end
            if strcmp(getMyHostName(), 'g7')   % Batch size
                break
            end
        end
        fprintf('\n\tData info:\n\tCLASS 1 [QRS]: %d\n\tCLASS 2 [NO ]: %d\n\n', sum(data.images.label == 1), sum(data.images.label == 2));
    else
        data = [];
        extraInfo = [];
        records = feval(details.getRecordsFunction, details.recordsTestCode);
        for k=1:length(records)
            data.(['record_' num2str(k)]) = [];
            [ecgSignal, rPeaks, typeSignal, imageMean] = feval(details.loadIndividualFunction, details.dbpath, records{k}, details);
            data.(['record_' num2str(k)]).ecgSignal = ecgSignal;
            data.(['record_' num2str(k)]).rPeaks = rPeaks;
            data.(['record_' num2str(k)]).typeSignal = typeSignal;
            data.(['record_' num2str(k)]).imageMean = imageMean;
            extraInfo = [extraInfo {records{k}}];
            if strcmp(getMyHostName(), 'g7')   % Batch size
                if k == 3
                    break
                end
            end
        end
    end
end

function [imdb, count, beatsInfo] = addWindow(r_peaks, recordedSignal, i, count, meanVal, beatSet, details, imdb, beatsInfo)
    for j = r_peaks(i) - 15 : 5 : r_peaks(i) + 15
        [response, imdb, beatsInfo] = addWave(recordedSignal, j, meanVal, count, details.annoQRSLabel, details, false, false, ...
                                                    ['QRS - Deslocado ' num2str(j) ' (' num2str(j - r_peaks(i)) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end
    end

    if details.dataAugmentation
        % Attenuate P wave
        [response, imdb, beatsInfo] = addWave(recordedSignal, r_peaks(i), meanVal, count, details.annoQRSLabel, details, true, false, ...
                                              ['QRS - Atenua onda P (' num2str(r_peaks(i)) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end
        % Attenuate T wave
        [response, imdb, beatsInfo] = addWave(recordedSignal, r_peaks(i), meanVal, count, details.annoQRSLabel, details, false, true, ...
                                              ['QRS - Atenua onda T (' num2str(r_peaks(i)) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end

        % Gain 80%
        [response, imdb, beatsInfo] = addWave(recordedSignal * 0.80, r_peaks(i), meanVal, count, details.annoQRSLabel, details, false, false, ...
                                              ['QRS - Ganho 80% (' num2str(r_peaks(i)) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end

        % Gain 60%
        [response, imdb, beatsInfo] = addWave(recordedSignal * 0.60, r_peaks(i), meanVal, count, details.annoQRSLabel, details, false, false, ...
                                              ['QRS - Ganho 60% (' num2str(r_peaks(i)) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end

    end

    for startPoint = r_peaks(i) + details.shiftPeak:details.shiftWave:min(r_peaks(i + 1) - details.sizeBeat, size(recordedSignal, 1))
        [response, imdb, beatsInfo] = addWave(recordedSignal, startPoint + details.halfSizeBeat, meanVal, count, details.annoFreeLabel, details, ...
                                              false, false, ['Sem QRS detectado (' num2str(startPoint + details.halfSizeBeat) ')'], beatSet, imdb, beatsInfo);
        if response
            count = count + 1;
        end
    end
end

function [response, imdb, beatsInfo] = addWave(recordedSignal, center, meanVal, count, label, details, attenuatePWave, attenuateTWave, beatInfo, beatSet, imdb, beatsInfo)
    try
        wave = feval(details.getWaveFunction, recordedSignal, center, details.halfSizeBeat, details.sizeBeat, meanVal, beatInfo);
        if attenuatePWave
            % x = 360*msPWave/1000 = msPWave * 1, i.e. atenuate the first 150 ms to kill the P wave = 150 * 1 = 150
            attenuate = round(0.36 * details.msPWave);
            wave(1:attenuate) = 0.3 * wave(1:attenuate);
        elseif attenuateTWave
            % x = FreqSample*msTWave/360 = msTWave * 0.36, i.e. atenuate the last 400 ms to kill the T wave = 400 * 0.36 = 144
            attenuate = round(0.36 * details.msTWave);
            wave(details.sizeBeat - attenuate:details.sizeBeat) = 0.3 * wave(details.sizeBeat - attenuate:details.sizeBeat);
        end
        imdb.images.data(1, :, count) = wave';
        imdb.images.label(:, count) = label;
        imdb.images.set(count) = beatSet;
        imdb.images.id(count) = count;
        beatsInfo{count} = beatInfo;
        response = true;
    catch
        % fprintf('Error with this wave\n');
        response = false;
    end
end

% https://blogs.mathworks.com/loren/2009/05/05/nice-way-to-set-function-defaults/
