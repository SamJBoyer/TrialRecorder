% Initialize connection to Blackrock system
%cbmex('open', 2, 'inst-addr', '192.168.137.34', 'inst-port', 51001);
cbmex('open', 2, 'inst-addr', '192.168.137.34', 'inst-port', 51001);
%cbmex('open')
channel_count = 256;
sample_rate_setting = 5;

for i = 1:channel_count
    cbmex('config', i, 'smpgroup', sample_rate_setting)
end 


trail_length=5;
current_time=tic;

cbmex('trialconfig',1)

while (trail_length > toc(current_time))
    pause(1)
    [event_data,time,cont] = cbmex('trialdata',1)
end 