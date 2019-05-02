%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%% Usage: hps(fftvector, downsampling)
%%
%% hps calculates hps from fft vector produced by fft-function. Following
%%         parameters are accepted:
%%
%% fftvector specifies the output vector from fft
%%
%% downsampling specifies the amount of downsampling in the hps algorithm.

function result = hps(fftvector, downsampling)

if (nargin > 2)
   error("hps: too many parameters");
endif

result = fftvector;
fftvectorlen = length(fftvector);
temp = zeros(fftvectorlen, 1);

% Calculate the hps
for downsample = 2:(downsampling+2)
	temp(:) = 0;
	fftvector_index = 1;
	for temp_index = 1:(fftvectorlen/downsample)-1
		temp(temp_index) = sum(fftvector(fftvector_index:fftvector_index+downsample-1)) / downsample;
		fftvector_index += downsample;
	endfor
	result .*= temp; 
endfor

endfunction

