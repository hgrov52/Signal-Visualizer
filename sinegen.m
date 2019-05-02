%% Usage: sinegen(filespec, samplerate, level, seconds, freq)
%%
%% sinegen generates wav file with a sine wave at specified 
%% 	level. Output can be used for e.g. as a test signal to 
%% 	various audio measurements.
%%
%% filespec   specifies the input sound file name. Must contain at 
%%            least 2 seconds of sine wave processed through system 
%%            under test.
%%
%% samplerate specifies the sample rate of the output wave form.
%%
%% level      specifies the level in dB of the generated sine wave.
%%            Defined as negative value starting from 0.
%%
%% seconds    specifies the length of the generated wave form in 
%%            seconds
%%
%% freq       spoecifies the frequency of the generated wave form.

function sinegen(filespec, samplerate, level, seconds, freq)

start = 0:samplerate - 1;

sine = 10^(level / 20) * sin(start * freq * (2*pi) / samplerate);

result = sine;

for i=1:seconds
	result = [result, sine];
endfor

wavwrite(result', samplerate, 16, filespec);

endfunction
