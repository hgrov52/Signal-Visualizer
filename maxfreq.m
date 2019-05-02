%% Usage: maxfreq(inputfile)
%%
%% max level returns the maximum freq from fft spectrum in Hz
%%
%% The input signal must contain at least 2 seconds of sine wave at frequency 
%% specified as parameter to this function. maxlevel will calculate 1 
%% second long fft starting from 0.5 seconds from the start of the sound file.
%% This means that input frequency can be specified/generated with the accuracy 
%% of 1 Hz between 1 Hz and the Nyquist frequency.
%%
%% inputfile specifies the input sound file name. Must contain at 
%%           least 2 seconds of sine wave processed through system 
%%           under test.

function result = maxfreq(inputfile)

[tulos, samplerate, bits] = wavread(inputfile);

[nfilesams, nchans] = wavread(inputfile, "size");

% take only 1 channel
if (nfilesams(2) == 1)
	audio = tulos;
else
	audio = tulos(:, nfilesams(2));
endif

fft_result = fft(audio(samplerate/2:(samplerate/2 + samplerate - 1)));

% from dc to nyqvist
abs_result = abs(fft_result(2:(samplerate/2))) / (samplerate / 2);

[value, result] = max(20 * log10(abs_result));

endfunction
