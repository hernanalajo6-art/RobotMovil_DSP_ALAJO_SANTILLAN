% =========================================================================
% FIGURA 7: Densidad Espectral de Potencia (pwelch) del ruido de motores
% =========================================================================
clear; clc; close all;

% 1. Cargar grabación propia del ruido de motores SIN voz (ajusta nombre/fs)
% Si ya tienes un archivo .wav grabado con los motores encendidos sin hablar:
[x_ruido, fs] = audioread('ruido_motores_sin_voz.wav');

% -- Alternativa: grabar directamente desde el micrófono conectado a tu PC --
% fs = 16000;
% duracion_seg = 3;
% disp('Enciende los motores (sin hablar). Grabando ruido...');
% recObj = audiorecorder(fs, 16, 1);
% recordblocking(recObj, duracion_seg);
% x_ruido = getaudiodata(recObj);
% audiowrite('ruido_motores_sin_voz.wav', x_ruido, fs);
% disp('Grabación finalizada.');

% Convertir a canal mono si es estéreo
if size(x_ruido, 2) > 1
    x_ruido = mean(x_ruido, 2);
end
x_ruido = double(x_ruido(:));

% Eliminar componente DC (offset) antes del análisis espectral
x_ruido = x_ruido - mean(x_ruido);

% 2. Parámetros de ventaneo coherentes con el diseño (25 ms, Hamming, 50% solapamiento)
dur_trama = 0.025;                  % 25 ms
nperseg = round(dur_trama * fs);    % 400 muestras a 16000 Hz
noverlap = round(0.5 * nperseg);    % 50% de solapamiento (200 muestras)
nfft = 1024;                        % Tamaño de FFT
win = hamming(nperseg, 'periodic'); % Ventana Hamming[cite: 1]

% 3. Calcular Densidad Espectral de Potencia con el método de Welch
[pxx, f] = pwelch(x_ruido, win, noverlap, nfft, fs);

% 4. Graficar PSD en dB/Hz
figure('Color', 'w', 'Name', 'Figura 7 - Ruido de Motores (pwelch)');
plot(f, 10*log10(pxx + eps), 'LineWidth', 1.4);
grid on;
xlim([0, fs/2]);
xlabel('Frecuencia (Hz)');
ylabel('Densidad Espectral de Potencia (dB/Hz)');
title('Figura 7. Densidad espectral (pwelch) del ruido de los motores sin voz');