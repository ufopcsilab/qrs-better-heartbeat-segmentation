function [tp, fp, fn, tn] = calculateMetrics(rPics, indexOfRWaves, signalSize)

        i = 1;
        j = 1;
        tp = 0;
        fp = 0;
        fn = 0;

        while (i < size(rPics, 1) + 1 && j < size(indexOfRWaves, 2) + 1)
            if abs(rPics(i) - indexOfRWaves(j)) < 4
                tp = tp + 1;
                i = i + 1;
                j = j + 1;
            else
                if rPics(i) < indexOfRWaves(j)
                    i = i + 1;
                    fn = fn + 1;
                else
                    j = j + 1;
                    fp = fp + 1;
                end
            end
        end

        fp = fp + size(indexOfRWaves, 2) - j + 1;
        fn = fn + size(rPics, 1) - i + 1;
        tn = signalSize - tp + fp;

end
