function plotIMDB(imdb, beats, sizeBeat, beatsInfo)
    close all;
    minBeats = 12;
    if size(beats, 1) == 1 && size(beats, 2) ~= minBeats || size(beats, 2) == 1 && size(beats, 1) ~= minBeats
        error(['It is necessary exactly ' num2str(minBeats) ' beats']);
    end
    cont = 1;
    lin = 4;
    col = 3;
    for i = 1:lin
        for j = 1:col
            subplot(lin, col, cont);
            plot(1:sizeBeat, imdb.images.data(1, :, beats(cont)));
            title(beatsInfo{beats(cont)});
            cont = cont + 1;
        end
    end

end
