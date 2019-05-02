% Copyright 2016 - 2016 The MathWorks, Inc.

prompt = 'What song from the Songs folder would you like to play? ';
f = input(prompt,'s');
if isempty(f)
    f = 'song.wav';
end
audiodatavar = 'audiodata';
fsvar = 'fs';
audioIRvar = 'audioIR';
audiomaxvar = 'audiomax';
T = 30;
timestep = 1/240;
% Generate IR or load from save file
fname = strsplit(f,'.');
fmat = [strjoin(fname(1:max(length(fname)-1,1))) '.mat'];
fmatpath = ['src/' fmat];

if ~exist(fmatpath,'file')
    % read file and generate IR
    if length(fname)==1
        ext = input('What is this song''s file extension? .', 's');
        f = [f '.' ext];
    end
    try
        disp('Analyzing file');
        [audiodata,fs] = audioread(['Songs/' f]);
        [audioIR,audiomax]= analyzeWaveform(audiodata(:,1),fs,timestep);
        save(fmatpath,audiodatavar,fsvar,audioIRvar,audiomaxvar);
    catch
        error('Problem loading song');
    end
else
    disp('Loading analysis of file');
    load(fmatpath,audiodatavar,fsvar,audioIRvar,audiomaxvar);
end
% If audio not loaded at this point, throw error
if ~exist(audiodatavar,'var') || ~exist(fsvar,'var') || ...
        ~exist(audioIRvar,'var') || ~exist(audiomaxvar,'var')
    error('Problem loading song');
end
% Set up figure
close all;
cmap = input('What colormap from ColorMaps do you prefer? [seashore]/rainbow/fire/ice/dusk/dawn? ','s');
if isempty(cmap) || strcmp(cmap, 'seashore')
    cmap = 'ColorMaps/seashore_cmap';
elseif strcmp(cmap, 'rainbow')
    cmap = 'ColorMaps/liz_rainbow';
elseif strcmp(cmap, 'fire')
    cmap = 'ColorMaps/fire';
elseif strcmp(cmap, 'ice')
    cmap = 'ColorMaps/ice';
elseif strcmp(cmap, 'dusk')
    cmap = 'ColorMaps/dusk';
elseif strcmp(cmap, 'dawn')
    cmap = 'ColorMaps/dawn';
else
    cmap = ['ColorMaps/' cmap];
end
c = load(cmap);
names = fieldnames(c);
cmap = c.(names{1})/255;

style = input('Would style of visualization do you prefer? [default]/spin/profile? ','s');
if isempty(style) || strcmp(style, 'default')
    style = 'default';
elseif strcmp(style, 'spin')
    style = 'spin';
elseif strcmp(style, 'profile')
    style = 'profile';
else
    disp('Invalid input. Using default style.');
    style = 'default';
end

N=100;
R1=linspace(0.0, 1.0, N);
Theta1=linspace(0.0, 2*pi, N);
[R, Theta]=meshgrid(R1, Theta1);
X=R.*cos(Theta);
Y=R.*sin(Theta);
colormap(cmap(floor(1:1/4*length(cmap)),:));
fig = surf(X,Y,zeros(size(X)));
shading interp;
if strcmp(style, 'profile')
    angle = 0;
else
    angle = 42;
end
view(108,angle);
axis([-1, 1, -1, 1, -1, 1]);
axis off;
drawnow
% Set up timer
tperiod = round(1.0/T, 3);
% Start playback
audioplay = audioplayer(audiodata,fs);
timestart = rem(now,1); % fractional time
audioplay.TimerPeriod = tperiod;
audioplay.StartFcn = {@update_figure, fig, R, Theta, timestart, timestep, audioIR, audiomax,cmap, style};
audioplay.TimerFcn = {@update_figure, fig, R, Theta, timestart, timestep, audioIR, audiomax,cmap, style};
play(audioplay);