% ======================
% TIMETRACES AND SPECTRA
% ======================
figure

% Plot time-domain signal y
ax(1) = subplot(221);
hold on
plot(t, y.data, 'b');
plot(t, ydata, '--r');
grid on
ylabel('Amplitude'); 
xlabel('Time (secs)');
title('Response (Y) time signal');
ylim([1.2*min(y.data) 1.2*max(y.data)])
xlim([0 1])
legend('Measured', 'Sgolay filtered')

% Plot FFT y
fx(1) = subplot(222);
plot(f, Ay) 
grid on
hold on
scatter(f(ipks), Ay(ipks),'r', 'filled')
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
xlim([0 f(ipks(end)) * 2])
legend('Amplitude FFT\_Y ','selected points')
ylim([-.05 1.2]*max(Ay))


% Plot time-domain signal u
ax(2) = subplot(223);
plot(t, u.data);
grid on
ylabel('Amplitude'); 
xlabel('Time (secs)');
title('Relay (u) time signal');
ylim([1.2*min(u.data) 1.2*max(u.data)])
xlim([0 1])


% Plot single-sided amplitude spectrum.
fx(2) = subplot(224);
plot(f, Au) 
grid on
hold on
scatter(f(ipks), Au(ipks), 'r', 'filled')
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|U(f)|')
xlim([0 f(ipks(end))*2])
legend('Amplitude FFT\_U ','selected points')
ylim([-.05 1.2]*max(Au))

linkaxes(ax,'x')
linkaxes(fx,'x')

% ============
% NYQUIST PLOT
% ============
figure
hold on
nyquist(G_true, 'b')
nyquist(G_fit, 'r')
scatter( real(gains_rfb), imag(gains_rfb), 'r', 'filled')
legend('True Model', 'Fit Model', 'Measured Gains')
axis([-0.1439    1.0881   -0.7066    0.6430])










