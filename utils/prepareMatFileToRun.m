function response = prepareMatFileToRun(matlabFile, details)
    % adding the path of the matlab file ang getting the data from it
    addpath(addSlash(fileparts(matlabFile)));
    matlabFile = myReplace(matlabFile, addSlash(fileparts(matlabFile)), '');
    response = myReplace(matlabFile, '.m', '');
end
