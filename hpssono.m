%% Usage: hpssono(filespec, offset, duration, nfft, winlen, wintype, wininc,
%%            [lowfreq, [highfreq, [weight, [comment, [options, [scale]]]]]])
%%
%% hpssono plots a 3D spectrogram of an audio signal. The following
%%         parameters are accepted:
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
%%          wav filespec: hpssono({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: hpssono({'test.raw', 44100, 'short'}, ...);
%%
%%          If the additional parameters are given, default sampling
%%          rate (44100) and sample encoding ('short') are used.
%%
%% offset is a time offset (in seconds) from the start
%%        of the soundfile.
%%
%% duration is the duration (in seconds) of the spectrogram.
%%
%% nfft specifies the number of FFT points. The value must be a power of 2.
%%
%% winlen is the length of the analysis window in samples.
%%
%% wintype specifies the window type. Wintype may be one of 'hanning',
%%         'hamming', or 'rectangle'.
%%
%% wininc is the number of samples between the starting points of
%%        consecutive windows.
%%
%% lowfreq is the low frequency limit of the spectrogram plot. Default is 0.
%%
%% highfreq is the high frequency limit of the spectrogram plot.
%%          Default = 20000.
%%
%% weight is a weighting function coefficient for adjusting high frequency
%%        responce of the STFT plot. The weighting function is linear
%%        where magnitude at DC frequency is multiplied by 1 and magnitude
%%        at Nyquist frequency is multiplied by weight. Default is 1.
%%        
%%
%% comment is a string to be printed at the end of the plot title
%%
%% options is a string of comma separated keywords. Accepted
%%         keywords are:
%%         'magdb' (print magnitude in decibels),
%%         'logfreq' (logarithmic frequency axis),
%%         'revfreq' (reversed frequency axis),
%%         'commentonly' (print only the comment text as the title)
%%         'notitle' (omit plot title),
%%         'nowincomp' (do not perform window amplitude loss compensation).
%%         Spaces are not allowed in the options string.
%%
%% scale is an optional parameter for the 'sonogram' option for
%%         scaling the low and high limits of the color/grayscale
%%         range. Scale is specified as a vector in the form
%%         [lowscale highscale]. Default values are 0.0001 and 0.02
%%         for linear (i.e. default) magnitude plots and 0.05 and 0.9
%%         for logarithmic magnitude plots (specified with the 'magdb'
%%         option).
%%
%% Examples:
%%
%% hpssono('test.wav', 1.5, 0.5, 1024, 1024, 'hanning', 512, 20, 20000,
%%            1, 'This is a test.', 'logfreq,magdb');
%%
%% hpssono({'test.raw', 96000, 'float'}, 1.5, 0.5, 1024, 1024, 'hanning',
%%            512, 20, 20000, 10, 'This is another test.');
%%
%% hpssono({'test.wav', 2}, 0, 5, 1024, 1024, 'hanning',
%%            512, 20, 20000, 10, 'Sonogram of right channel', 'Comment text.');

function hpssono(filespec='song.wav', toffset=0, dur=3, nfft=2048, winlen=32, wintype='hanning', wininc=512,
			lowfreq=0, highfreq=20000, weight=1, comment, options, scale=4)

% Get soundfile data and filespec parameters
[ay, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec, toffset, dur, nfft);

if (chanspec > nchans)
    error('spec2dw: channel number out of range');
endif
nsams = dur * fs + nfft;
if (nchans > 1)
    nsamsread = length(ay);
else
    nsamsread = length(ay);
endif
if (nsams > nsamsread)
    audio = zeros(nsams, 1);
    audio(1:nsamsread) = ay(1:nsamsread, chanspec);
else
    audio = ay(1:nsamsread, chanspec);
endif

% Check amount of optional arguments
if (nargin < 13)
    if (nargin < 12)
	if (nargin < 11)
	    if (nargin < 10)
		if (nargin < 9)
		    if (nargin < 8)
			lowfreq = 0;
		    endif
		    highfreq = 1000000;
		endif
		weight = 1;
	    endif
	    comment = '';
	endif
	options = '';
    endif
    scale = 0;
endif

% Check validity of arguments and parse the options string
if (ischar(wintype) == 0)
    error("hpssono: illegal wintype");
endif

o_magdb = 0;
o_logfreq = 0;
o_revfreq = 0;
o_commentonly = 0;
o_notitle = 0;
o_sonogram = 1;
o_nowincomp = 0;

titlefontsize = 10;

if (nargin >= 12)
    if (ischar(options) == 0)
        error('hpssono: illegal argument type');
    endif
    opts = strsplit(options, ', *', 'delimitertype', 'regularexpression');
    nopts = rows(opts);
    for n = 1 : nopts
        s = deblank(opts(n, :));
        if (strcmp(s, 'magdb') == 1)
            o_magdb = 1;
        elseif (strcmp(s, 'logfreq') == 1)
            o_logfreq = 1;
        elseif (strcmp(s, 'revfreq') == 1)
            o_revfreq = 1;
        elseif (strcmp(s, 'commentonly') == 1)
            o_commentonly = 1;
        elseif (strcmp(s, 'notitle') == 1)
            o_notitle = 1;
        elseif (strcmp(s, 'nowincomp') == 1)
            o_nowincomp = 1;
        else
            error('hpssono: illegal option');
        endif
    endfor
endif


if (o_magdb)
    lowscale = 0.5;
    highscale = 0.9;
else
    lowscale = 0.0001;
    highscale = 0.02;
endif

if (nargin == 13)
    if (isvector(scale) == 0)
        error('hpssono: illegal argument type');
    endif
    if (length(scale) != 2)
        error('hpssono: illegal scale vector size');
    endif
    lowscale = scale(1);
    highscale = scale(2);
endif

% Prepare for FFT
if (lowfreq < 0)
    lowfreq = 0;
endif
if (highfreq > fs/2)
    highfreq = fs/2;
endif
if (lowfreq >= highfreq)
    lowfreq = 0;
    highfreq = fs/2;
endif
if (wininc < 1)
    wininc = 1;
endif

loopCount = floor((dur * fs) / wininc);
xres = fs / 2 / winlen;
foffset = lowfreq/xres;
fhigh = highfreq/xres;

nffto2 = nfft / 2;

% FFT and postprocessing
z = stft(audio, winlen, wininc, nffto2, wintype) / nffto2;

% HPS processing
% z = z';
for i = 1:columns(z);
    z(:, i) = hps(z(:, i), weight);
endfor
% z = z';

if 0
if weight ~= 1
    ax = linspace(1, weight, nffto2)';
    nz = size(z, 2);
    for n = 1:nz
	z(:, n) = z(:, n) .* ax;
    end
endif
endif

if (o_magdb == 1)
    z = 20 * log10(z);
endif

% Plotting

cz = columns(z);
rz = rows(z);
x = linspace(toffset, toffset+dur, cz)';
y = linspace(0, fs/2, rz)';

[xx, yy] = meshgrid(x, y);

if (o_sonogram)
    maxz = max(max(z));
    minz = min(min(z));
    diffz = maxz - minz;
    imagesc(x, y, z, [diffz*lowscale+minz diffz*highscale+minz]);
    colormap(flipud(gray));
else
    mesh(xx, yy, z);
endif;

if (o_commentonly == 1)
    title(comment);
elseif (o_notitle == 1)
    title('');
else
    title(sprintf(strcat( '',
	    'Hpssono plot %s, file: %s, sampling rate: %g Hz,\n',
	    'FFT points: %d, window length: %d, type: %s, increment: %d,\n',
	    'frequency range: %g..%g Hz, HF weight: %g. %s',
	    '' ),
	    strftime("%Y-%m-%d %T", localtime(time())), fname, fs,
	    nfft, winlen, wintype, wininc, lowfreq, highfreq, weight, comment),
	    'fontsize', titlefontsize);
endif
if (o_logfreq == 1)
    if (lowfreq <= 0)
        warning('hpssono: lowfreq must be > 0 for logarithmic frequency plot');
        warning('Forcing lowfreq to 1.');
	lowfreq = 1;
    endif
    set(gca(), 'yscale', 'log');
else
    set(gca(), 'yscale', 'linear');
endif

set(gca(), 'ydir', 'reverse');
set(gca(), 'ylim', [lowfreq, highfreq]);

ylabel('Frequency (Hz)', 'fontsize', titlefontsize);
xlabel('Time (s)', 'fontsize', titlefontsize);
if (o_magdb == 1)
    zlabel('Magnitude (dB)', 'fontsize', titlefontsize);
else
    zlabel('Magnitude', 'fontsize', titlefontsize);
endif

if (o_revfreq == 1 && o_sonogram == 0)
    axis('xy');
endif
if (o_revfreq == 0 && o_sonogram == 1)
    axis('xy');
endif

% set(get(gca,'zLabel'),'rotation', 90.0);

% view(-75, 30);
% colormap(gray*0);

% hold('off');

endfunction
