% Author: Sam Boyer
% Gmail: sam.james.boyer@gmail.com 
%
% This is a simple script that looks for the redis stream RECORDERFLAG
% and looks for the values 'START' or 'STOP' which it will use to start or
% stop the trial data recording through cbMEX. 
%
% The stream name must be RECORDERFLAG and the field must be FIELD! 

% Connect to Redis using Python from MATLAB
clearvars; 
clc; 
pyenv('Version', 'C:\Users\ReHAB-CNRA\anaconda3\envs\redis_test\python.exe');
redis = py.importlib.import_module('redis');
r = redis.Redis(pyargs('host', '192.168.7.15', 'port', 6379, 'decode_responses', true));
%set up the cerebus sdk
sdkPath = 'C:\Program Files\Blackrock Microsystems\Cerebus Central Suite 7.6.1';
addpath(sdkPath);

% Check if the connection is successful (ping the server)
if r.ping()
    disp('Connected to Redis server');
else
    error('Could not connect to Redis server');
end

%conver the python redis response to matlab 
function result = PyToMat(pyList)
    tuple = pyList{1};
    pyDict = tuple{2}; 
    result = string(pyDict{'FLAG'});
end 

%open instance of the cbsdk
cbmex('open');

%monitor the redis server  
is_recording = false; 
while true
    pause(0.1);
    values = r.xrange("RECORDERFLAG", "-", "+"); %needs to only read the first value 
    %check if the response is empty 
    if isempty(values)
        continue;
    end
    
    flag = PyToMat(values);
    if isempty(values)
        continue;
    end 
    if flag == "START"

        if is_recording == true
            continue;
        else
            cbmex('fileconfig', 'Desktop', 'buh buh BUH!', 1);
        end
    elseif flag == "STOP"
        if is_recording == false
            continue; 
        else
            cbmex('fileconfig', 'Desktop', '', 0);
        end 
    end
end 



%tic
% Define the stream name and a test value
%streamName = 'mystream';
%test_data = int16(zeros(1,307200));
%binary = typecast(test_data, 'uint8');
%testValue = py.dict(pyargs('field1',py.bytes(binary), 'field2', 'value2'));
%streamId = r.xadd(streamName, testValue);

%toc * 1000