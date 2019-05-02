% Copyright 2016 - 2016 The MathWorks, Inc.
function main_bessel(fig,R,Theta,struct_piece0, struct_piece1, struct_piece2,amp_max,cmap, style)
%Amplitude = average amplitude of sound during this time slice
%Low = average coefficient of low frequencies
%Mid = average coefficient of medium frequencies
%High = average coefficient of high frequencies
if ~ishandle(fig)
    return;
end


k_vals = 0:10;
p_vals = 1:10;
% k-th asimuthal number and bessel function (number of petals)
% p-th bessel root (number of ripples)
t = pi/2;

amp0 = 4*struct_piece0.Amplitude/amp_max;
k0 = k_vals(min(floor(length(k_vals)*(struct_piece0.Low+struct_piece0.High)/amp_max)+1, length(k_vals)));
p0 = p_vals(min(floor(length(p_vals)*struct_piece0.Mid/amp_max)+1, length(p_vals)));
if k0>6 && p0==1
    k0=6;
end
q0=find_pth_bessel_root(k0, p0);
z0=amp0*sin(q0*t)*besselj(k0, q0*R).*cos(k0*Theta);

amp1 = 4*struct_piece1.Amplitude/amp_max;
k1 = k_vals(min(floor(length(k_vals)*(struct_piece1.Low+struct_piece1.High)/amp_max)+1, length(k_vals)));
p1 = p_vals(min(floor(length(p_vals)*struct_piece1.Mid/amp_max)+1, length(p_vals)));
if k1>6 && p1==1
    k1=6;
end
q1=find_pth_bessel_root(k1, p1);
z1=amp1*sin(q1*t)*besselj(k1, q1*R).*cos(k1*Theta);

amp2 = 4*struct_piece2.Amplitude/amp_max;
k2 = k_vals(min(floor(length(k_vals)*(struct_piece2.Low+struct_piece2.High)/amp_max)+1, length(k_vals)));
p2 = p_vals(min(floor(length(p_vals)*struct_piece2.Mid/amp_max)+1, length(p_vals)));
if k2>6 && p2==1
    k2=6;
end
q2=find_pth_bessel_root(k2, p2);
z2=amp2*sin(q2*t)*besselj(k2, q2*R).*cos(k2*Theta);

%N=1000;

colormap(cmap(floor(1:1/4*length(cmap)+min(1,struct_piece1.Amplitude/amp_max)*3/4*length(cmap)),:));
[al,el] = view;
if strcmp(style, 'spin')
    view([al+.1,el+.1]);
elseif strcmp(style, 'profile')
    view([al+.1,0]);
end
fig.ZData=(z0+z1+z2)/3;
drawnow limitrate;
end