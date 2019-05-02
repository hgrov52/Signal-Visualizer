% Copyright 2016 - 2016 The MathWorks, Inc.
% Draw callback function
function update_figure(audioplay,~,fig, R, Theta, timestart, timestep, audioIR, audiomax,cmap, rotate)
timeelapsed = (rem(now,1) - timestart)*24*3600;  % convert to seconds
audioindex = time_to_index(timeelapsed, timestep);
if ~ishandle(fig)
    stop(audioplay);
    return;
end
if audioindex <= length(audioIR)
    frame1 = audioIR(audioindex);
    frame0 = audioIR(max(0,time_to_index(timeelapsed - 1/30,timestep)));
    frame2 = audioIR(min(length(audioIR),time_to_index(timeelapsed + 1/30,timestep)));
    main_bessel(fig,R, Theta, frame0, frame1, frame2, audiomax,cmap, rotate);
end
end