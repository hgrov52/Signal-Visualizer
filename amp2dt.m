%% Usage: amp2dt(filespec, offset, duration [, windur [, comment [, options]]])
%%
%% amp2dt plots the RMS and peak amplitude graphs of an audio signal.
%%
%% NOTE: amp2dt is an experimental function which contains several caveats.
%%         The function will be updated in future Spectutils versions.
%%
%% The following parameters are accepted:
%%
%% filespec specifies a sound file name and optional parameters.
%%          Filespec may be either a string specifying a soundfile
%%          name or a cell containing a file name and additional
%%          parameters in the form {soundfile, param1, param2, ...}
%%
%%          There, soundfile specifies the input soundfile name
%%          (as a string). Wav and raw (headerless mono) files
%%          are supported. The file name extension ('.wav' or '.raw')
%%          determines the interpretation of the additional parameters.
%%
%%          For wav files, param1 is a channel index number (1, 2, etc.)
%%          of the audio channel to be analyzed from a multichannel
%%          soundfiles. For stereo files, for example,
%%          1 means left channel and 2 means right channel. If param1
%%          is omitted, default channel index (1) is used. Example
%%          wav filespec: amp2dt({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: amp2dt({'test.raw', 44100, 'short'}, ...);
%%
%%          If the additional parameters are given, default sampling
%%          rate (44100) and sample encoding ('short') are used.
%%
%% offset is a time offset (in seconds) from the start
%%        of the soundfile
%%
%% duration is the duration (in seconds) of the oscillogram
%%
%% windur is the duration (in seconds) of the amplitude measurement window.
%%          Default is 0.05 (50 ms).
%%
%% comment is a string to be printed at the end of the plot title
%%
%% options is a string of comma separated keywords.
%%         Accepted keywords are:
%%            'ampdb'          Plot amplitude in decibels
%%            'rmsonly'        Plot only the RMS level graph.
%%            'peakonly'       Plot only the peak level graph.
%%            'peaktopeak'     Plot the positive to negative peak to peak level.
%%            'commentonly'    Print only the comment text as title.
%%            'notitle'        Don't print title.
%%            'spline'         Produce a smooth signal plot through
%%                             spline interpolation.
%%            'splineplus'     As above, but actual signal samples are
%%                             also displayed as '+' characters.

function amp2dt(filespec='ex1.wav', toffset=0, dur=2, windur=2, comment, options)

if (nargin > 6)
    error('amp2dt: too many arguments');
elseif (nargin < 3)
    %error('amp2dt: too few arguments');
end

if (nargin == 3)
    windur = 0.05;	# 50 ms default window
end

% Get soundfile data and filespec parameters
lookahead = toffset - windur;
if (lookahead < 0)
[ay, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec,
%							0, dur+windur-lookahead);
							toffset, dur+windur);
else
[ay, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec,
							toffset, dur+windur);
end

if (chanspec > nchans)
    error('amp2dt: channel number out of range');
end
nsams = dur * fs;
if (nchans > 1)
    nsamsread = length(ay);
else
    nsamsread = length(ay);
end
if (nsams > nsamsread)
    audio = zeros(nsams, 1);
    audio(1:nsamsread) = ay(:, chanspec);
else
    audio = ay(:, chanspec);
end

titlefontsize = 10;

% Parse options
o_ampdb = o_spline = o_splineplus = o_commentonly = o_notitle = 0;
o_rmsonly = o_peakonly = o_peaktopeak = 0;
if (nargin < 5)
    comment = '';
end
if (nargin < 6)
    options = '';
elseif (nargin == 6)
    if (!ischar(options))
	error('amp2dt: illegal options parameter.');
    end
    opts = strsplit(options, ', *', 'delimitertype', 'regularexpression');
    opts = opts';
    nopts = rows(opts);
    for n = 1 : nopts
        s = deblank(opts(n, :));
        if (strcmp(s, 'ampdb') == 1)
            o_ampdb = 1;
        elseif (strcmp(s, 'rmsonly') == 1)
            o_rmsonly = 1;
        elseif (strcmp(s, 'peakonly') == 1)
            o_peakonly = 1;
        elseif (strcmp(s, 'peaktopeak') == 1)
            o_peaktopeak = 1;
        elseif (strcmp(s, 'spline') == 1)
            o_spline = 1;
        elseif (strcmp(s, 'splineplus') == 1)
            o_splineplus = 1;
        elseif (strcmp(s, 'commentonly') == 1)
            o_commentonly = 1;
        elseif (strcmp(s, 'notitle') == 1)
            o_notitle = 1;
        else
            error('amp2dt: illegal option');
        end
    end
end

% Calculate RMS and plot

winlen = windur * fs;
nysams = nsamsread / winlen;
y = zeros(nysams, 1);
yp = zeros(nysams, 1);
j = 1;
for i = 1:nysams
    y(i) = rms(audio(j:j+winlen-1));
    yp(i) = max(abs(audio(j:j+winlen-1)));
    ypp(i) = max(audio(j:j+winlen-1));
    ypn(i) = min(audio(j:j+winlen-1));
    j = i * winlen;
end
x = linspace(toffset, toffset+dur, nysams);

if (o_ampdb == 1)
    y = 20 * log10(y);
    yp = 20 * log10(yp);
end

newplot();

if (o_spline || o_splineplus)
    xi = [toffset : 1/(fs*20) : toffset+dur];
    yi = interp1(x, y, xi, 'spline');
    hold('on');
    plot(xi, yi, 'linewidth', 1.5, 'color', 'black');
    if (o_splineplus)
	plot(x, y, '+', 'color', [0.2, 0.2, 0.2]);
    end 
    hold('off');
else
    if (o_peakonly)
	    plot(x, yp, 'linewidth', 1.5, 'color', 'red', ';Peak;');
    elseif (o_rmsonly)
	plot(x, y, 'linewidth', 1.5, 'color', 'black', ';RMS;');
    elseif (o_peaktopeak)
	plot(x, ypp, 'linewidth', 1.5, 'color', 'black',
	    x, ypn, 'linewidth', 1.5, 'color', 'black');
    else
	plot(x, y, 'linewidth', 1.5, 'color', 'black', ';RMS;',
	    x, yp, 'linewidth', 1.5, 'color', 'red', ';Peak;');
    end
end

if (o_notitle)
    title('');
elseif (o_commentonly)
    title(comment);
else
    title(sprintf('Amp2dt plot %s, file: %s, sampling rate: %g Hz\n%s',
	 strftime('%Y-%m-%d %T', localtime(time())), fname, fs, comment),
	 'fontsize', titlefontsize);
end

xlabel('Time (s)', 'fontsize', titlefontsize);
if (o_ampdb == 1)
    ylabel('Amplitude (dB)', 'fontsize', titlefontsize);
else
    ylabel('Amplitude', 'fontsize', titlefontsize);
end

% grid('on');

endfunction
