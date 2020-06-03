function wave = getWave(recordedSignal, center, halfSizeBeat, sizeBeat, meanVal, extraInfo)
    startPoint = center - halfSizeBeat - 1;
    fprintf('\t\t\t%30s\tStart point: %6d\t\tEnd point: %6d\n', extraInfo, startPoint, startPoint + sizeBeat-1);
    rawWave = recordedSignal(startPoint:startPoint + sizeBeat-1);
    wave = interp1(1:length(rawWave), rawWave, 1:2780/1000:length(rawWave))';
    wave = wave(1:300);
    wave = wave - meanVal;
    wave = wave + abs(min(wave));
    wave = wave/std(wave);
    wave = wave/max(wave);
    wave = im2single(wave);
end
