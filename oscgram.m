%% Usage: oscgram(filespec, offset, duration [, comment [, options]])
%%
%% oscgram plots an oscillogram of an audio signal. The following
%%   parameters are accepted:
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
%%          wav filespec: oscgram({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: oscgram({'test.raw', 44100, 'short'}, ...);
%%
%%          If the additional parameters are given, default sampling
%%          rate (44100) and sample encoding ('short') are used.
%%
%% offset is a time offset (in seconds) from the start
%%        of the soundfile
%%
%% duration is the duration (in seconds) of the oscillogram
%%
%% comment is a string to be printed at the end of the plot title
%%
%% options is a string of comma separated keywords.
%%         Accepted keywords are:
%%            'revphase'       Plot the signal in reverse phase.
%%            'commentonly'    Print only the comment text as title.
%%            'notitle'        Don't print title.
%%            'spline'         Produce a smooth signal plot through
%%                             spline interpolation.
%%            'splineplus'     As above, but actual signal samples are
%%                             also displayed as '+' characters.
%%
%%         Spaces are not allowed in the options string.

function oscgram(filespec='ex1.wav', toffset=0, dur=3, comment="", options)

if (nargin > 5)
    error('oscgram: too many arguments');
end

% Get soundfile data and filespec parameters
[ay, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec, toffset, dur);

if (chanspec > nchans)
    error('oscgram: channel number out of range');
end
if (nchans > 1)
    nsamsread = length(ay);
else
    nsamsread = length(ay);
end
nsams = dur * fs;
if (nsams > nsamsread)
    audio = zeros(nsams, 1);
    audio(1:nsamsread) = ay(:, chanspec);
else
    audio = ay(:, chanspec);
end

titlefontsize = 10;

% Parse options
o_revphase = o_spline = o_splineplus = o_commentonly = o_notitle = 0;
if (nargin < 4)
    comment = '';
end
if (nargin < 5)
    options = '';
elseif (nargin == 5)
    if (!ischar(options))
	error('oscgram: illegal options parameter.');
    end
    opts = strsplit(options, ', *', 'delimitertype', 'regularexpression');
    opts = opts';
    nopts = rows(opts);
    for n = 1 : nopts
        s = deblank(opts(n, :));
        if (strcmp(s, 'revphase') == 1)
            o_revphase = 1;
        elseif (strcmp(s, 'spline') == 1)
            o_spline = 1;
        elseif (strcmp(s, 'splineplus') == 1)
            o_splineplus = 1;
        elseif (strcmp(s, 'commentonly') == 1)
            o_commentonly = 1;
        elseif (strcmp(s, 'notitle') == 1)
            o_notitle = 1;
        else
            error('oscgram: illegal option');
        end
    end
end

% Plot
x = linspace(toffset, toffset+dur, nsams);

if (o_revphase)
    audio *= -1;
end

newplot();

if (o_spline || o_splineplus)
    xi = [toffset : 1/(fs*20) : toffset+dur];
    yi = interp1(x, audio, xi, 'spline');
    hold('on');
    plot(xi, yi, 'linewidth', 1.0, 'color', 'black');
    if (o_splineplus)
	plot(x, audio, '+', 'color', [0.2, 0.2, 0.2]);
    end 
    hold('off');
else
    plot(x, audio, 'linewidth', 1.0, 'color', 'black');
end

if (o_notitle)
    title('');
elseif (o_commentonly)
    title(comment);
else
    title(sprintf('Oscgram plot %s, file: %s, sampling rate: %g Hz\n%s',
	 strftime('%Y-%m-%d %T', localtime(time())), fname, fs, comment),
	 'fontsize', titlefontsize);
end

xlabel('Time (s)', 'fontsize', titlefontsize);
ylabel('Amplitude', 'fontsize', titlefontsize);

% grid('on');

end
