function [tp, fp, fn, tn, rightBeats, wrongFnBeats, wrongFpBeats] = getMetrics(ecgSignal, rPeaks, in, delay, saveErrors, record, outputPath, sizeBeat)

    if nargin == 4
        saveErrors = false;
    end
    ii = 1;
    kkFn = 1;
    kkFp = 1;
    rightBeats = [];
    wrongFnBeats = [];
    wrongFpBeats = [];
    halfSizeBeat = round(sizeBeat / 2);

    tp = 0; fp = 0; fn = 0;
    tolerance = 3;
    % Discard first second and the last second
    rPeaks = rPeaks(rPeaks > sizeBeat & rPeaks < (size(ecgSignal, 1) - sizeBeat));
    in = in(in > sizeBeat & in < (size(ecgSignal, 1) - sizeBeat));
    jj = 1;
    for i = 1:size(in, 2)
        ini = in(i);
        flag = false;
        for j = jj:size(rPeaks, 1)
            % True Positive - the rPeak is somewhere between the aceptable window
            if ini - delay - tolerance < rPeaks(j) < ini + delay + tolerance
                flag = true;
                wave = getRawWave(ecgSignal, ini, halfSizeBeat, sizeBeat);
                rightBeats(ii, :, :) = wave;
                ii = ii + 1;
                break
            end
        end
        if flag % TP
            tp = tp + 1;
            in(i) = 0;
            rPeaks(j) = 0;
            jj = j + 1;
        end
    end
    fp = sum(in > 0);
    fn = sum(rPeaks > 0);
    tn = size(ecgSignal, 1) - tp + fp;


    a = in(in > 0);
    for i = 1:size(a, 2)
        close all;
        h1 = figure;
        try
            wave = getRawWave(ecgSignal, a(i), halfSizeBeat, sizeBeat);
            wrongFpBeats(kkFp, :, :) = wave;
            kkFp = kkFp + 1;
            if saveErrors
                plot(1:sizeBeat, wave);
                title(['IN (' record ') - FP (' num2str(a(i)) ')']);
                axis([0 sizeBeat -1 1]);
                % savefig(h1, [outputPath record '_FP(' num2str(a(i)) ').fig']);
                print(h1, [outputPath record '_FP(' num2str(a(i)) ').png'], '-dpng');
            end
        catch
        end
    end

    a = rPeaks(rPeaks > 0);
    for i = 1:size(a, 1)
        close all;
        h1 = figure;
        try
            wave = getRawWave(ecgSignal, a(i), halfSizeBeat, sizeBeat);
            wrongFnBeats(kkFn, :, :) = wave;
            kkFn = kkFn + 1;
            if saveErrors
                plot(1:sizeBeat, wave);
                title(['IN (' record ') - FN (' num2str(a(i)) ')']);
                axis([0 sizeBeat -1 1]);
                % savefig(h1, [outputPath record '_FN(' num2str(a(i)) ').fig']);
                print(h1, [outputPath record '_FN(' num2str(a(i)) ').png'], '-dpng');
            end
        catch
        end
    end
end
