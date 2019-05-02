% Copyright 2016 - 2016 The MathWorks, Inc.

function [data, limit] = analyzeWaveform(wav, Fs,timestep)
% Length of song in seconds
duration = length(wav)/Fs;

data = repmat(struct('Time',0 , 'Amplitude',0 , 'Low',0 , 'Mid', 0, 'High', 0,'BPM',0),uint32([1 duration/timestep]));

frame = 1;
limit = 0;
for t = timestep/2:timestep:duration-timestep/2
    % get the slice of the waveform surrounding time t
    first = max(floor((t-20*timestep/2)*Fs),1);
    last  = min(ceil((t+20*timestep/2)*Fs), length(wav));
    range = first:last;
    slice = wav(range);
    
    % smooth the amplitude of the waveform by scaling with a normal
    % distribution centered at t
    stddev = (last-first)/6;
    a = sqrt(2*pi)*stddev;
    scale = a*normpdf(range,median(range),(last-first)/6);
    slice = scale' .* slice;
    
    
    % record the time for each frame
    data(frame).Time = t;
    
    % record the average amplitude
    data(frame).Amplitude = sum(abs(bandPass(slice, Fs, 27.5, 1760)));
    
    % record the amplitude of lows, mids, and highs
    data(frame).Low = sum(abs(bandPass(slice, Fs, 27.5, 110)));
    data(frame).Mid = sum(abs(bandPass(slice, Fs, 110, 440)));
    data(frame).High = sum(abs(bandPass(slice, Fs, 440, 1760)));
    
    frame = frame + 1;
end

% Put all of the values into a single array and compute what value will
% contain 99% of the data
concatenation = zeros([1 4*length(data)]);
for i = 1:length(data)
    concatenation(i) = data(i).Amplitude;
    concatenation(i+length(data)) = data(i).Low;
    concatenation(i+2*length(data)) = data(i).Mid;
    concatenation(i+3*length(data)) = data(i).High;
    
end
limit = prctile(concatenation,99);
end
