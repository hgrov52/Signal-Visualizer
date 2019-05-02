% Copyright 2016 - 2016 The MathWorks, Inc.

function out = bandPass(wav, Fs, lowerFreq, upperFreq)

L = length(wav);
a = fft(wav);

% Find the first and last indices for the input frequency range
first = floor(lowerFreq*L/Fs);
last = ceil(upperFreq*L/Fs);

% Protect against out of bounds
if first < 1
    first = 1;
end
if last > length(a)/2
    last = ceil(length(a)/2);
end

out = a(first:last)/length(a)*2;

end