function response = doesPathExist(desiredPath)
    [stat, ~]=fileattrib(desiredPath);
    if stat == 1
        response = true;
    else
        response = false;
    end
end
