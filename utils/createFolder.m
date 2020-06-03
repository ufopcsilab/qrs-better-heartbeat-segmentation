function createFolder(output_folder)
    [stat, ~]=fileattrib(output_folder);

    if ~(stat == 1)
        mkdir(output_folder);
    end

end
