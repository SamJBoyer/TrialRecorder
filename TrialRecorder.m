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
pyenv('Version', 'C:\Users\ReHAB-Dev\anaconda3\envs\HQ\python.exe');
redis = py.importlib.import_module('redis');
r = redis.Redis(pyargs('host', '172.23.201.226', 'port', 6379, 'password', 'oogert', 'decode_responses', true));
%set up the cerebus sdk
sdkPath = 'C:\Program Files\Blackrock Microsystems\Cerebus Central Suite';
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
cbmex('system', 'reset')

save_path = 'C:\Users\ReHAB-Dev\Desktop\TrialRecorderDump\data';
cbmex('trialconfig', 1)

%monitor the redis server  
is_recording = false; 
while true
    pause(0.1);
    % testing reset [a, b, c] = cbmex('trialdata', 1)
    % testing reset t = cbmex('time', 'samples')
    values = r.xrevrange("RECORDERFLAG", "+", "-", py.int(1));  % Correct count argument as an integer
    %check if the response is empty 
    if isempty(values)
        disp('no value')
        continue;
    end
    
    flag = PyToMat(values);
    if isempty(values)
        continue;
    end 
    if flag == "START"

        if is_recording == true
            disp('recording ongoing')
            continue;
        else
            disp('starting file recording')
            cbmex('fileconfig', save_path, 'buh buh BUH!', 1);
            is_recording = true;
        end
    elseif flag == "STOP"
        if is_recording == false
            disp('recording halted')
            continue; 
        else
            disp('stopping file recording')
            cbmex('fileconfig', save_path, '', 0);
            is_recording = false; 
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