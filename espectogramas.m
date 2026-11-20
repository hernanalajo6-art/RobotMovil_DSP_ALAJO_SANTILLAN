% =========================================================================
% FIGURA 3: (a) Espectrogramas de «izquierda» y «derecha»;
%           (b) |FFT| de los cuatro patrones de referencia
% =========================================================================
clear; clc; close all;

comandos = {'avanza', 'retrocede', 'izquierda', 'derecha'};
archivos = {'avanza.wav', 'retrocede.wav', 'izquierda.wav', 'derecha.wav'};

% Parámetros coherentes de trama, solapamiento y ventana (25 ms, Hamming, 50%)
dur_trama = 0.025;                  % 25 ms
solap_pct = 0.50;                   % 50 %
nfft = 1024;                        % Tamaño de FFT

% Cargar señales (o usar señal provisional si aún no existe algún .wav)
senales = cell(1, 4);
fs_ref = 16000;

for k = 1:4
    if exist(archivos{k}, 'file')
        [x, fs] = audioread(archivos{k});
        if size(x, 2) > 1
            x = mean(x, 2);
        end
        x = double(x(:));
        if fs ~= fs_ref
            x = resample(x, fs_ref, fs);
        end
    else
        % Señal provisional de prueba si falta algún archivo .wav
        warning('No se encontró %s. Se genera señal provisional de prueba.', archivos{k});
        t_tmp = (0:round(1.2*fs_ref)-1)' / fs_ref;
        env = exp(-((t_tmp - 0.55)/0.16).^2);
        f1 = 220 + 70*k;
        f2 = 750 + 180*k;
        f3 = 2400 + 350*k;
        x = env .* (0.55*sin(2*pi*f1*t_tmp) + 0.35*sin(2*pi*f2*t_tmp) + 0.20*sin(2*pi*f3*t_tmp)) ...
            + 0.015*randn(size(t_tmp));
    end
    
    % Eliminar offset DC y normalizar amplitud pico
    x = x - mean(x);
    if max(abs(x)) > 0
        x = x / max(abs(x));
    end
    senales{k} = x;
end

win_len = round(dur_trama * fs_ref);        % 400 muestras a 16 kHz
noverlap = round(solap_pct * win_len);      % 200 muestras
win = hamming(win_len, 'periodic');

% Crear figura dividida en Panel (a) izquierda y Panel (b) derecha
figure('Color', 'w', 'Name', 'Figura 3 - Espectrogramas y FFT de Referencia', 'Position', [80, 80, 1200, 680]);

% --- PANEL (a): Espectrogramas de «izquierda» (índice 3) y «derecha» (índice 4) ---
ax_a1 = subplot(2, 2, 1);
spectrogram(senales{3}, win, noverlap, nfft, fs_ref, 'yaxis');
title('(a1) Espectrograma: «izquierda»');
ylim([0, fs_ref/2000]); % En kHz (0 a 8 kHz)
colorbar;

ax_a2 = subplot(2, 2, 3);
spectrogram(senales{4}, win, noverlap, nfft, fs_ref, 'yaxis');
title('(a2) Espectrograma: «derecha»');
ylim([0, fs_ref/2000]); % En kHz (0 a 8 kHz)
colorbar;

% --- PANEL (b): |FFT| de los cuatro patrones de referencia ---
subplot(2, 2, [2, 4]);
hold on;
f_eje = (0:nfft/2-1) * (fs_ref / nfft);
estilos = {'-', '--', '-.', ':'};

for k = 1:4
    % Aplicar ventana Hamming sobre toda la señal normalizada para patrón de referencia
    x_win = senales{k} .* hamming(length(senales{k}), 'periodic');
    X_mag = abs(fft(x_win, nfft));
    X_mag_half = X_mag(1:nfft/2);
    % Normalizar magnitud máxima para comparar forma espectral
    if max(X_mag_half) > 0
        X_mag_half = X_mag_half / max(X_mag_half);
    end
    plot(f_eje, X_mag_half, 'LineStyle', estilos{k}, 'LineWidth', 1.3, 'DisplayName', comandos{k});
end

grid on;
xlim([0, fs_ref/2]);
ylim([0, 1.05]);
xlabel('Frecuencia (Hz)');
ylabel('|X(f)| normalizada');
title('(b) Magnitud de la FFT (|FFT|) de los cuatro patrones de referencia');
legend('Location', 'northeast');

sgtitle('Figura 3. (a) Espectrogramas de «izquierda» y «derecha»; (b) |FFT| de patrones de referencia');