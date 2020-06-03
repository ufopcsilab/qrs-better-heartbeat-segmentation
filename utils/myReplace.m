function nstr = myReplace(str, pattern, substr)
    try
        nstr = replace(str, pattern, substr);
    catch
        patternLen = length(pattern);
        detections = strfind(str, pattern);
        nstr = str;
        for ii = 1:length(detections)
            nstr = [nstr(1:detections(ii) - 1) substr nstr(detections(ii) + patternLen:end)];
        end
    end
end
