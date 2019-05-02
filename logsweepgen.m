%% Usage: function logsweepgen(filespec, samplerate, level, seconds, start_freq, end_freq)
%%
%% sweepgen generates logarithmic sine sweep
%%
%% filespec   specifies the output sound file name.
%%
%% samplerate defines the sample rate of the sweep.
%%
%% level      is the level of the sweep in negative dB values 0 being full scale.
%%
%% seconds    specifies the length of the sweep in seconds.
%%
%% start_freq start frequency of the sweep.
%%
%% end_freq   end frequency of the sweep.

function logsweepgen(filespec='song.wav', samplerate=20000, level=10, seconds=5, start_freq=10, end_freq=10000)

if end_freq < start_freq
temp_freq = end_freq;
end_freq = start_freq;
start_freq = temp_freq;
reverse = 1;
else
reverse = 0;
endif

duration = seconds * samplerate;

base = (end_freq - start_freq) / start_freq;

result = 0:duration-1;

difference = (end_freq - start_freq) / duration;

%linear
%for i=1:duration
%	result(i) = 10^(level / 20) * sin(i * (start_freq + i * difference)/ samplerate);
%endfor

%logarithmic
for i=1:duration
	result(i) = 10^(level / 20) * sin(i * (start_freq * base^(i/duration))/ samplerate);
endfor

if reverse == 1
  result = fliplr(result);
endif

%finish the sweep with a short 10 step fadeout
ramp = [0:0.1:1];
ramp = fliplr(ramp);

for i=1:length(ramp)
	result(length(result) - length(ramp) + i) = result(length(result) - length(ramp) + i) * ramp(i);
endfor

wavwrite(result', samplerate, 16, filespec);

endfunction
