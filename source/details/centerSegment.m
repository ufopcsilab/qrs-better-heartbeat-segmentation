function center = centerSegment(recordedSignal, center, halfSizeBeat, sizeBeat)
    startPoint = center - halfSizeBeat - 1;
    wave = recordedSignal(startPoint:startPoint + sizeBeat-1);
    [greatestPoint, position] = max(scores);
    return ...
end
