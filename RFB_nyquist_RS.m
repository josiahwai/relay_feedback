close all; clear all; clc;

%% Get true transfer function
make_G_true;
% K = 1;
% T = 0.1;
% D = 0.001;
% s = tf('s');
% G_true = (K/(1+T*s))*exp(-D*s);

%% Choose noise power
NoisePower = 0;%0.000000001;

%% Simulate
Tsim = 10;
sim('RFB_parasitic_method',Tsim)
clearvars -except u y G_true P1D

%% Analysis

% Choose number of frequencies to be included from data
NumOfFreqs = 5;

% filter and FFT input and measurements
t = u.time;
ts = mean(diff(t));
U = u.data;
Y = sgolayfilt(y.data, 3, 101);

[FTY, MFTY, f] = fft_time(Y, ts)
[FTY, MFTY, f] = fft_time(U, ts)




% Define analysis variables from sim variables
t = u.time;
U = u.data(1:length(t));
Y = y.data(1:length(t));
Y = sgolayfilt(Y,3,101);

% Compute FFTs
Ts = mean(diff(y.time));      % Sample time
Fs = 1/Ts;                    % Sampling frequency
L = length(y.data);           % Length of signal

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
FTY = fft(Y,NFFT)/L;
FTU = fft(U,NFFT)/L;

NumUniquePts = ceil((NFFT+1)/2);

FTY_unique = FTY(1:NumUniquePts);
FTU_unique = FTU(1:NumUniquePts);

f = Fs/2*linspace(0,1,NumUniquePts)';

% Compute signal amplitudes (power)
MFTY    = 2*abs(FTY);
MFTY(1) = MFTY(1)/2;
MFTY    = MFTY(1:NumUniquePts);

MFTU = 2*abs(FTU);
MFTU(1) = MFTU(1)/2;
MFTU    = MFTU(1:NumUniquePts);





% Find fundamental frequency and harmonics
[MFTY_MAX,ind_MFTY_MAX] = max(MFTY);
%fundamental:
f_fundamental = f(ind_MFTY_MAX);
%harmonics:
f_for_TFest = (f_fundamental/2:f_fundamental/2:NumOfFreqs*f_fundamental/2)';

%find value of FFTs at all harmonics, BUT MAKE SURE ITS A PEAK
ind = 1;
f_horizon = 1;
for ii = 1:length(f_for_TFest)
     [AbsMinDif_f,f_index(ii)] = min(abs(f_for_TFest(ii)-f));
     
    %if this condition is met, we found an harmonic 
    if (AbsMinDif_f < f_horizon)   
       %now we have to make sure its a peak, not the side of a peak
       [~,lb_index] = min( abs((f(f_index(ii))-1) -f));
       [~,ub_index] = min( abs((f(f_index(ii))+1) -f));
       
      [pks(ind), ind_pks(ind)] = max(abs(FTY_unique(lb_index:ub_index)));
        
       index(ii) =  lb_index+ind_pks(ind)-1;
       FTU_TF_est(ind,1) = FTU_unique(index(ii));
       FTY_TF_est(ind,1) = FTY_unique(index(ii));
       
       f_YU(ind,1)       = f(index(ii));
       TF_YU(ind,1)      = FTY_TF_est(ind,1) / FTU_TF_est(ind,1) ;
       ind = ind+1;
    end    
end



% Calculate steady state gain
SSgain = trapz(Y)/trapz(U);

% Add steady state gain if not added by default
if (sum(f_YU == 0) == 0)
    TF_YU = [SSgain; TF_YU];
    f_YU  = [0; f_YU];
end
f_YU_rad = 2 * pi .* f_YU;

% Create FRD object for sysID
TF = frd(TF_YU,f_YU_rad);


%% plots
figure(1)
% Plot time-domain signal
ax(1) = subplot(221);
plot(t, Y);
grid on
ylabel('Amplitude'); xlabel('Time (secs)');
title('Response (Y) time signal');
ylim([1.2*min(Y) 1.2*max(Y)])

fx(1) = subplot(222);
% Plot single-sided amplitude spectrum.
plot(f,MFTU) 
grid on
hold on
scatter(f_YU(2:end),MFTU(index),'r', 'filled')
title('Single-Sided Amplitude Spectrum of u(t)')
xlabel('Frequency (Hz)')
ylabel('|U(f)|')
xlim([0 f_YU(end)+50])
legend('Amplitude FFT\_U ','selected points')

% Plot time-domain signal
ax(2) = subplot(223);
plot(t, U);
grid on
ylabel('Amplitude'); xlabel('Time (secs)');
title('Relay (u) time signal');
ylim([1.2*min(U) 1.2*max(U)])

fx(2) = subplot(224);
% Plot single-sided amplitude spectrum.
plot(f,MFTY) 
grid on
hold on
scatter(f_YU(2:end),MFTY(index),'r', 'filled')
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
xlim([0 f_YU(end)+50])
legend('Amplitude FFT\_Y ','selected points')

linkaxes(ax,'x')
linkaxes(fx,'x')

figure(2)
scatter(real(TF_YU),imag(TF_YU),'r','filled')
grid on
hold on
nyquist(G_true)
% nyquist(P1D)
%nyquist(tf1)

figure
plot(t,Y)
hold on
grid on
plot(t,sgolayfilt(Y,3,101),'LineWidth',2)
