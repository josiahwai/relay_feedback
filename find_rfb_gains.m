% Given a time history of input u and measurement y, find the relay
% feedback gains at various frequencies. Filters the FFT of u and y 
% based on 3 criteria below to find a set of frequencies to evaluate at. 
%
% Returns: G_pts, f_pts the gains and frequencies [Hz] and FFT parameters

function [G_pts, f_pts, ipks, f, Y, U, Ay, Au] = find_rfb_gains(u_data, y_data, ts, nfreqs)

% FFT transform
[Y,Ay,f] = fft_time(y_data, ts);
[U,Au,f] = fft_time(u_data, ts);

% Find fundamental frequency and harmonics
[~,i] = max(Ay);
ff = f(i);     % fundamental freq
f_max = nfreqs*ff / 2;
f_harmonics = (0.5*ff: 0.5*ff: f_max)';


fwindow = 1; % search within fwindow Hz to find the peak
ipks = [];

for i = 1:length(f_harmonics)
  isearch = find( abs(f-f_harmonics(i)) < fwindow);
  [~,k] = max( Ay( isearch));
  ipks(i) = isearch(k);
end
  
% Find gains
f_pts = f(ipks)';
G_pts = Y(ipks) ./ U(ipks);

% Add a point for the zero frequency (steady-state gains)
Kp = trapz(y_data) / trapz(u_data);
G_pts = [Kp; G_pts];
f_pts = [0; f_pts];




















