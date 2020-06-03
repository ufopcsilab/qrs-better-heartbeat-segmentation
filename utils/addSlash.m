function response = addSlash(string)

    if string(end) ~= '/'
        response = [string '/'];
    else
        response = string;
    end

end
