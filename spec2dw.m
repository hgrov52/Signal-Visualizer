%% Usage: spec2dw(filespec, offset, nfft, winlen, wintype,
%%                     [lowfreq, [highfreq, [weight, [comment, [options]]]]])
%%
%% spec2dw plots a 2D magnitude spectrum of an audio signal. The following
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
%%          wav filespec: spec2dw({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: spec2dw({'test.raw', 44100, 'short'}, ...);
%%
%%          If the additional parameters are given, default sampling
%%          rate (44100) and sample encoding ('short') are used.
%%
%% offset is a time offset (in seconds) from the start
%%        of the soundfile.
%%
%% nfft specifies the number of FFT points. The value must be a power of 2.
%%
%% winlen is the length of the analysis window in samples.
%%
%% wintype specifies the window type. Wintype may be one of 'hanning',
%%         'hamming', or 'rectangle'. Spec2dw compensates for the average
%%         signal amplitude lost by windowing for each window type. The
%%         compensation may be omitted with the 'nowincomp' option (see 'options').
%%
%% lowfreq is the low frequency limit of the spectrogram plot. Default is 0.
%%
%% highfreq is the high frequency limit of the spectrogram plot.
%%          Default s samplingrate/2.
%%
%% weight is a weighting function coefficient for adjusting high frequency
%%        responce of the STFT plot. The weighting function is linear
%%        where magnitude at DC frequency is multiplied by 1 and magnitude
%%        at Nyquist frequency is multiplied by weight. Default is 1.
%%        
%%
%% comment is a string to be printed at the end of the plot title
%%
%% options is a string of comma separated keywords.
%%         Accepted keywords are:
%%            'magdb'          Print magnitude in decibels.
%%            'logfreq'        Logarithmic frequency axis.
%%            'commentonly'    Print only the comment text on title.
%%            'notitle'        Don't print plot title.
%%            'spline'         Produce a smooth FFT plot through
%%                             spline interpolation.
%%            'splineplus'     As above, but actual FFT points are
%%                             also displayed as '+' characters.
%%            'nowincomp'      Do not perform window gain compensation.
%%
%%         Spaces are not allowed in the options string.

function spec2dw(filespec, toffset, nfft, winlen,
		  wintype, lowfreq, highfreq, weight, comment, options)

% Get soundfile data and filespec parameters
[ay, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec, toffset, 0, nfft);

if (chanspec > nchans)
    error('spec2dw: channel number out of range');
endif
nsams = nfft;
if (nchans > 1)
    nsamsread = length(ay);
else
    nsamsread = length(ay);
endif
if (nsams > nsamsread)
%    audio = zeros(nsams, 1);
%    audio(1:nsamsread) = ay(:, chanspec);
    audio = zeros(nfft, 1);
    audio(1:nsamsread) = ay(1:nfft, chanspec);
else
    audio = ay(1:nfft, chanspec);
endif

if (nargin < 9)
    if (nargin < 8)
	if (nargin < 7)
	    if (nargin < 6)
		lowfreq = 0;
	    endif
	    highfreq = 1000000;
	endif
	weight = 1;
    endif
    comment = '';
endif

if (ischar(wintype) == 0)
    error('spec2dw: illegal wintype');
endif

o_magdb = 0;
o_logfreq = 0;
o_commentonly = 0;
o_notitle = 0;
o_spline = 0;
o_splineplus = 0;
o_nowincomp = 0;

titlefontsize = 10;

if (nargin == 10)
    if (ischar(options) == 0)
	error('spec2dw: illegal argument type');
    endif
    opts = strsplit(options, ', *', 'delimitertype', 'regularexpression');
    opts = opts';
    nopts = rows(opts);
    for n = 1 : nopts
	s = deblank(opts(n, :));
	if (strcmp(s, 'magdb') == 1)
	    o_magdb = 1;
	elseif (strcmp(s, 'logfreq') == 1)
	    o_logfreq = 1;
	elseif (strcmp(s, 'commentonly') == 1)
	    o_commentonly = 1;
	elseif (strcmp(s, 'spline') == 1)
	    o_spline = 1;
	elseif (strcmp(s, 'splineplus') == 1)
	    o_splineplus = 1;
	elseif (strcmp(s, 'notitle') == 1)
	    o_notitle = 1;
	elseif (strcmp(s, 'nowincomp') == 1)
	    o_nowincomp = 1;
	else
	    error('spec2dw: illegal option');
	endif
    endfor
endif

% old_amr=automatic_replot;
% automatic_replot=0;

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

nffto2 = nfft / 2;
if (winlen > nfft)
    winlen = nfft;
endif

xres = fs / 2 / winlen;
foffset = lowfreq/xres;
fhigh = highfreq/xres;

if (strcmp(wintype, 'hamming'))
    winfun = hamming(winlen);
elseif (strcmp(wintype, 'hanning'))
    winfun = hanning(winlen);
else
    winfun = ones(winlen, 1);
endif

waudio = zeros(nfft, 1);
waudio(1:winlen) = audio(1:winlen) .* winfun;
yf = fft(waudio);

% FFT normalization and Window function compensation:
if (o_nowincomp == 1)
    y = abs(yf(1:nffto2)) / nffto2;       # Without window compensation
else
    y = abs(yf(1:nffto2)) / (nffto2 * mean(winfun));
endif

if weight ~= 1
    ax = linspace(1, weight, nffto2)';
    y = y .* ax;
endif

if (o_magdb == 1)
    y = 20 * log10(y);
endif
x = linspace(0, fs/2, nffto2);

newplot();

if (o_logfreq == 1)
    if (lowfreq <= 0)
	warning('spec2dw: lowfreq must be > 0 for logarithmic frequency plot.');
	warning('Forcing lowfreq to 1.');
	lowfreq = 1;
    endif
    if (o_spline || o_splineplus)
	xi = [0 : 1 : (fs/2)-1];
	yi = abs(interp1(x, y, xi, 'spline'));
	hold('on');
	semilogx(xi, yi, 'linewidth', 1.0, 'color', 'black');
	if (o_splineplus)
	    semilogx(x, y, '+', 'markersize', 1.5, 'color', [0.2, 0.2, 0.2]);
	endif
	hold('off');
    else
	semilogx(x, y, 'linewidth', 1.0, 'color', 'black');
    endif
else
    if (o_spline || o_splineplus)
	xi = [0 : 1 : (fs/2)-1];
	yi = abs(interp1(x, y, xi, 'spline'));
	hold('on');
	# plot(xi, yi);
	plot(xi, yi, 'linewidth', 1.0, 'color', 'black');
	if (o_splineplus)
%	    plot(x, y, '^');
	    plot(x, y, '^', 'markersize', 1.5, 'color', [0.2, 0.2, 0.2]);
%	    plot(x, y, '+', 'color', [0.2, 0.2, 0.2]);
	endif
	hold('off');
    else
	plot(x, y, 'linewidth', 1.5, 'color', 'black');
    endif
endif

grid('on');
axis([lowfreq highfreq]);

if (o_commentonly)
    title(comment);
elseif (o_notitle)
    title('');
else
    title(sprintf(strcat('Spec2dw plot %s, file: %s, \nsampling rate: %g Hz ',
    'time offset: %g s, FFT points: %d, window length: %d, type: %s,\n',
    'frequency range: %g..%g Hz, HF weight: %g. %s'),
	    strftime("%Y-%m-%d %T", localtime(time())), fname, fs, toffset,
	    nfft, winlen, wintype, lowfreq, highfreq, weight, comment),
	    'fontsize', titlefontsize
    );
endif

xlabel('Frequency (Hz)', 'fontsize', titlefontsize);
if (o_magdb == 1)
    ylabel('Magnitude (dB)', 'fontsize', titlefontsize);
else
    ylabel('Magnitude', 'fontsize', titlefontsize);
endif

% hold('off');

endfunction
