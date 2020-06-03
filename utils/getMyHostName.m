function name = getMyHostName()
    name = char(java.net.InetAddress.getLocalHost.getHostName);
end
