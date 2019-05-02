%% Usage: thdn(inputfile, frequency)
%%
%% thdn calculates the total harmonic distortion plus noise (THD+N) value
%% from the input signal. Result is displayed in decibels.
%%
%% The input signal must contain at least 2 seconds of sine wave at frequency 
%% specified as parameter to this function. thdn will calculate 1 
%% second long fft starting from 0.5 seconds from the start of the sound file.
%% This means that input frequency can be specified/generated with the accuracy 
%% of 1 Hz between 1 Hz and the Nyquist frequency.
%%
%% inputfile specifies the input sound file name. Must contain at 
%%           least 2 seconds of sine wave processed through system 
%%           under test.
%%
%% frequency specifies the frequency of the sine wave in inputfile.

function result = thdn(inputfile, frequency)

[nfilesams, nchans] = wavread(inputfile, "size");

[tulos, samplerate, bits] = wavread(inputfile);

% take only 1 channel
if (nfilesams(2) == 1)
	audio = tulos;
else
	audio = tulos(:, nfilesams(2));
endif

kekkuli = fft(audio(samplerate/2:(samplerate/2 + samplerate - 1)));

yeah = abs(kekkuli(1:(samplerate/2))) / (samplerate / 2);

total_power = 0;
nosine_power = 0;

for i=2:samplerate/2
	total_power = total_power + yeah(i)^2;
endfor

% remove sine, take dc into account
yeah(frequency+1) = 0;

for i=2:samplerate/2
	nosine_power = nosine_power + yeah(i)^2;
endfor

% these are power values, no need to multiply by 20 
result = 10 * log10(nosine_power ./ total_power);

endfunction
