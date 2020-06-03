function [recordedSignal, rPeaks, typeSignal, meanVal] = loadIndividual(dbPath, recordName, details)
    % Load the individual data.
    data = load([addSlash(dbPath) 'cybhi/' recordName]);
    anno = load([addSlash(dbPath) 'annotations/' recordName]);

    % Load the individual data.
    recordedSignal = data.ecg';
    % Apply filter, if necessary
    if details.withFilteringData
        recordedSignal = filtfilt(details.bpFilt, recordedSignal);
    end
    recordedSignal = single(recordedSignal);
    meanVal = mean(recordedSignal);

    % Eliminate the peaks that does not fit the size beat used
    rPeaks = anno.r_x(anno.r_x> details.halfSizeBeat)';
    rPeaks = rPeaks(rPeaks < size(recordedSignal, 1) - details.halfSizeBeat);
    typeSignal = char(ones(1, max(size(rPeaks))) + 77);
end
