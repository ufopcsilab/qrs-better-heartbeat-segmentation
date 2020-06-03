function details = cybhi()
    details.dbpath = '../../datasets/CYBHi/';
    details.sizeBeat = 833;
    details.halfSizeBeat = round(details.sizeBeat/2);
    details.freqSample = 1000;
    details.dataAugmentation = true;
    details.msPWave = 375;
    details.msTWave = 375;
    details.shiftPeak = 50;
    details.shiftWave = 5;
    details.withFilteringData = false;
    % details.bpFilt = designfilt('bandpassfir', 'FilterOrder', preprocessDetails.filterOrder, ...
    %                             'CutoffFrequency1', preprocessDetails.lowCutoffFrequency, ...
    %                             'CutoffFrequency2', preprocessDetails.highCutoffFrequency, 'SampleRate', details.freqSample);
    details.saveErrors = true;
    details.getWaveFunction = './details/getWaveDownSampling.m';
    details.loadIndividualFunction = './details/cybhi/loadIndividual.m';
    details.getRecordsFunction = './details/cybhi/getRecordsCYBHi.m';
    details.recordsTrainCode = 2;
    details.recordsTestCode = 3;

end
