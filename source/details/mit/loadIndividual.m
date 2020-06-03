function [recordedSignal, rPeaks, typeSignal, meanVal] = loadIndividual(dbPath, recordName, details)

    data = load([addSlash(dbPath) recordName]);

    % Load the individual data.
    recordedSignal = data.individual.signal_r(:, 1);
    % Apply filter, if necessary
    if details.withFilteringData
        recordedSignal = filtfilt(details.bpFilt, recordedSignal);
    end
    meanVal = mean(recordedSignal);

    % Eliminate the peaks that does not fit the size beat used
    rPeaks = data.individual.anno_anns(data.individual.anno_anns > details.sizeBeat & data.individual.anno_anns < size(recordedSignal, 1) - details.sizeBeat);
    typeSignal = data.individual.anno_type(data.individual.anno_anns > details.sizeBeat & data.individual.anno_anns < size(recordedSignal, 1) - details.sizeBeat);

end
