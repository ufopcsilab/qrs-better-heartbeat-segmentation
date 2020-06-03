function details = cybhi()
    details.dbpath = '../../datasets/MIT/';
    details.sizeBeat = 300;
    details.halfSizeBeat = round(details.sizeBeat/2);
    details.freqSample = 360;
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
    details.getWaveFunction = './details/getWave.m';
    details.loadIndividualFunction = './details/mit/loadIndividual.m';
    details.getRecordsFunction = './details/mit/getRecordsMIT.m';
    details.recordsTrainCode = 7;
    details.recordsTestCode = 6;

end
