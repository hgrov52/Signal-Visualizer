%% Usage: [data, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec, offset, duration [[, nsams], noffset])
%%
%% spureadsf is a Spectutils subroutine for reading audio samples
%%   from a sound file. The following
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
%%          wav filespec: spec3dw({'test.wav', 2}, ...);
%%
%%          Raw files are assumed to be headerless monophonc files.
%%          Here, param1, specifies the sampling rate and param2
%%          specifies the sample encoding format. Supported formats are
%%          'short' (16-bit integer), 'float' (32-bit floating point),
%%          and 'double' (64-bit floating point). Example:
%%          raw filespec: spec3dw({'test.raw', 44100, 'short'}, ...);
%%
%%          If the additional parameters are given, default sampling
%%          rate (44100) and sample encoding ('short') are used.
%%
%% offset is a time offset (in seconds) from the start
%%        of the soundfile
%%
%% duration is the duration (in seconds) of the spectrogram
%%
%% nsams is an optional parameter for specifying number of samples to be
%%          read in addition to the amount specified with duration (see above).
%%          nsams can be used instead of duration by setting duration to 0.
%%
%% noffset is a negative sample offset, which is subtracted from the
%%          regular offset parameter (see above). Noffset has a similar
%%          purpose for setting the starting point for the read signal
%%          as nsams has for setting the duration. If (regular) offset is
%%          zero, the result returned in data will start with zero value
%%          samples.

% TODO: Add proper support for noffset

function [audata, fs, nchans, nsamsread, chanspec, fname] = spureadsf(filespec, toffset, dur, samdur, noffset)

if (nargin < 3 || nargin > 5)
    error('spureadsf: illegal amount of arguments');
endif

% Check filespec for data type and soundfile format
if (iscell(filespec) == 1)
    fname = filespec{1};
else
    fname = filespec;
endif
if (ischar(fname) == 0)
    error('spureadsf: illegal soundfile name');
endif
if (nargin < 5)
    noffset = 0;
endif

fnameparts = char(strsplit(fname, '.'));
nparts = rows(fnameparts);
s = deblank(fnameparts(nparts, :));
if (strcmp(s, 'wav') == 1)
    iswavfile = 1;
elseif (strcmp(s, 'raw') == 1)
    iswavfile = 0;
    # Set fs and format to default values:
    fs = 44100;
    format = 'short';
else
    printf('Fext: %s\n', s);
    error('spureadsf: unsupported soundfile format');
endif

% Process soundfile
if (iswavfile == 1)
    if (iscell(filespec))
	specsize = size(filespec)(2);
	if (specsize >= 2)
	    chanspec = filespec{2};
	else
	    chanspec = 1;
	endif
    else
	chanspec = 1;
    endif

    info = audioinfo(fname);
    nfilesams = info.TotalSamples;
    nchans = info.NumChannels;
    fs = info.SampleRate;
    nbits = info.BitsPerSample;
%    [nfilesams, nchans] = wavread(fname, 'size');
%    [ya, fs, nbits] = wavread(fname, 0);
%    [nfilesams, nchans] = wavread(fname, 'size');
%    sizespec = wavread(fname, 'size');
%    nfilesams = sizespec(1);
%    nchans = sizespec(2);
    firstsam = round(toffset * fs) + 1;
    if (nargin == 3)
	samdur = floor(dur * fs) + noffset;
    elseif (nargin == 4 && dur > 0)
	samdur = samdur + floor(dur * fs) + noffset;
    endif
    lastsam = firstsam + samdur - 1;
    if (firstsam > nfilesams)
	error('spureadsf: Read start point is beyond soundfile end point.');
    endif
    if (lastsam > nfilesams)
	warning('spureadsf: Sample range is beyond soundfile end point.');
	lastsam = nfilesams;
    endif
    audata = audioread(fname, [firstsam, lastsam]);
    nsamsread = length(audata); # Does this work with multichannel files???
    if (chanspec > nchans)
	error('spec3dw: channel number out of range');
    endif
else
    if (iscell(filespec))
	specsize = size(filespec)(3);
	if (specsize >= 2)
	    fs = filespec{2};
	    if (specsize >= 3)
		format = filespec{3};
	    endif
	endif
    endif
    nchans = chanspec = 1;

    if (strcmp(format, 'short'))
	samsize = 2;
    elseif (strcmp(format, 'float'))
	samsize = 4;
    elseif (strcmp(format, 'double'))
	samsize = 8;
    else
	error('spec3dw: unsupported sample format');
    endif

    offset = round(toffset * fs);
    samoffset = offset * samsize;
    if (nargin == 3)
	samdur = floor(dur * fs);
    elseif (nargin == 4 && dur > 0)
	samdur = samdur + floor(dur * fs);
    endif

    fid = fopen(fname, 'rb');
    fseek(fid, samoffset, SEEK_SET);
    [audata, nsamsread] = fread(fid, samdur, format);
    fclose(fid);

    if (nsamsread < samdur)
	warning('spec3dw: input file too short!');
    endif

    if (strcmp(format, 'short'))
	audata = audata / 32768.0;
    endif
endif

endfunction
