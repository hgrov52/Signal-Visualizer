% Copyright 2016 - 2016 The MathWorks, Inc.
function [a, b] = find_nthroot(X, Y, n)
l=0;
m=length(X);
for i=1:(m-1)
    if ( Y(i) >= 0  && Y(i+1) <= 0 ) || ( Y(i) <= 0 && Y(i+1) >= 0 )
        l=l+1;
    end
    if l==n
        a=X(i); b=X(i+1);
        return;
    end
end
disp('Root not found!');
end