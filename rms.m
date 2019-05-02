%% Usage: y = rms(x)
%%
%% rms returns the Root Mean Square (RMS) value of the supplies vector x

function y = rms(x)

if (nargin != 1)
   error("rms: illegal amount of parameters");
endif

y = 0;
len = length(x);
y = sqrt(sum(x .* x) / len);

endfunction
