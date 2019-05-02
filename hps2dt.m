%% Usage: hps2dt(filespec, offset, duration, nfft, winlen, wintype, wininc,
%%               [lowfreq, [highfreq, [downsampling, [comment, [options]]]]])
%%
%% hps2dt plots a 2D HPS plot of an audio signal with pitch and
%%         error estimates as a function of time. The following
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
%%          wav filespec: hps2dt({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: hps2dt({'test.raw', 44100, 'short'}, ...);
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
%% downsampling is the number of downsampling iterations in the HPS
%%              analysis. Default = 3.
%%
%% comment is a string to be printed at the end of the plot title.
%%
%% options is a string of comma separated keywords.
%%         Accepted keywords are:
%%            'logfreq'        Logarithmic frequency axis.
%%            'commentonly'    Print only the comment text on title.
%%            'notitle'        Don't print plot title.
%%
%%         Spaces are not allowed in the options string.

function hps2dt(filespec='ex1.wav', toffset=0, dur=3, nfft=1024, winlen=1024, wintype='hanning', wininc=512,
                lowfreq=200, highfreq=10000, downsampling=3, comment='example', options)

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
if (nargin < 12)
    if (nargin < 11)
	if (nargin < 10)
	    if (nargin < 9)
		if (nargin < 8)
		    lowfreq = 0;
		endif
		highfreq = fs/2;
	    endif
	    downsampling = 3;
	endif
	comment = '';
    endif
    options = '';
endif

% Check validity of arguments and parse the options string
if (ischar(wintype) == 0)
    error("hps2dt: illegal wintype");
endif

o_logfreq = 0;
o_interp = 0;
o_commentonly = 0;
o_notitle = 0;

titlefontsize = 10;

if (nargin == 12)
    if (ischar(options) == 0)
        error('hps2dt: illegal argument type');
    endif
    opts = strsplit(options, ', *', 'delimitertype', 'regularexpression');
    opts = opts';
    nopts = rows(opts);
    for n = 1 : nopts
        s = deblank(opts(n, :));
        if (strcmp(s, 'logfreq') == 1)
            o_logfreq = 1;
        elseif (strcmp(s, 'interp') == 1)
            o_interp = 1;
        elseif (strcmp(s, 'commentonly') == 1)
            o_commentonly = 1;
        elseif (strcmp(s, 'notitle') == 1)
            o_notitle = 1;
        else
            error('hps2dt: illegal option');
        endif
    endfor
endif

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
% xres = fs / 2 / winlen;
% foffset = lowfreq/xres;
% fhigh = highfreq/xres;

nffto2 = nfft / 2;
z = stft(audio, winlen, wininc, nffto2, wintype) / nffto2;

[rows, columns] = size(z);

hps_frequency = zeros(columns, 1);
hps_error = zeros(columns, 1);

first = 1;
if (o_interp)
    xi = [0 : 1 : fs/2];
endif

xs = linspace(toffset, fs/2, nffto2);

for i = 1 : columns
	hps_vector = hps(z(:,i), downsampling);
	if (o_interp)
	    yi = interp1(xs, hps_vector, xi, 'cubic');
	    [max_value, max_index] = max(yi);
	    hps_frequency(i) = (max_index-1) / length(yi) / 2 * fs;
	    if (first == 1)
	    first = 0;
		length(xs)
		length(hps_vector)
		length(xi)
		length(yi)
	    endif
	else
	    [max_value, max_index] = max(hps_vector);
	    hps_frequency(i) = ((max_index-1) / nffto2 / 2) * fs; # '-1' added.
	endif
	ts = sum(hps_vector);
	if (ts == 0)
		hps_error(i) = 1;
	else
		hps_error(i) = max(hps_vector) / sum(hps_vector);
	endif
endfor

me = median(hps_error);
median_err = me(1:1);

x = linspace(toffset, toffset+dur, i);
y_err = hps_error * (highfreq - lowfreq);

newplot();

if (o_logfreq)
    # semilogy(x, hps_frequency, 'k;pitch;', x, y_err, 'g;reliability;');
    semilogy(x, hps_frequency, 'linewidth', 1.5, 'color', 'black', ';Pitch;',
         x, y_err, 'linewidth', 1.5, 'color', 'blue', ';Reliability;');
else
    # plot(x, hps_frequency, 'k;Pitch;', x, y_err, 'g;Reliability;');
    plot(x, hps_frequency, 'linewidth', 1.5, 'color', 'black', ';Pitch;',
         x, y_err, 'linewidth', 1.5, 'color', 'blue', ';Reliability;');
endif
plot(x, hps_frequency, 'linestyle', '-');
% plot(x, y_err, 'linestyle', ':');

grid('on');
axis([toffset, toffset+dur, lowfreq, highfreq]);

if (o_commentonly == 1)
    title(comment);
elseif (o_notitle == 1)
    title('');
else
    title(sprintf(strcat('Hps2dt plot %s, file: %s, sampling rate: %g Hz,\n',
      'FFT points: %d, window length: %d, type: %s, increment: %d, ',
      'iterations: %g\nfrequency range: %g..%g Hz, median reliability: %g. %s'),
	    strftime('%Y-%m-%d %T', localtime(time())), fname, fs,
		nfft, winlen, wintype, wininc, downsampling, lowfreq,
		highfreq, median_err, comment),
	'fontsize', titlefontsize);
endif

xlabel('Time (s)', 'fontsize', titlefontsize);
ylabel('Pitch (Hz) / Reliability (0..1)', 'fontsize', titlefontsize);

grid('on');

endfunction
