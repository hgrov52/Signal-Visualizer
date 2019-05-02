% Copyright 2016 - 2016 The MathWorks, Inc.
function r = find_pth_bessel_root(k, p)

% a dummy way of finding the root, just get a small interval where the root is
X=0.5:0.5:(10*p+1); Y = besselj(k, X);
[a, b] = find_nthroot(X, Y, p);

X=a:0.01:b; Y = besselj(k, X);
[a, b] = find_nthroot(X, Y, 1);

X=a:0.0001:b; Y = besselj(k, X);
[a, b] = find_nthroot(X, Y, 1);

r=(a+b)/2;
end