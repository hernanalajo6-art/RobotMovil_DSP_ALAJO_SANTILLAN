% =========================================================================
% FIGURA 4: (a) Energía en corto tiempo de «izquierda» con umbral e
%               instantes de inicio/fin;
%           (b) ERO (FIR pasa altas 3,5 kHz) frente a energía total
% =========================================================================
clear; clc; close all;

archivo = 'izquierda.wav';

% 1. Cargar grabación propia de «izquierda» (o señal provisional si aún no existe)
if exist(archivo, 'file')
    [x, fs] = audioread(archivo);
    if size(x, 2) > 1
        x = mean(x, 2);
    end
    x = double(x(:));
else
    warning('No se encontró %s. Se genera señal provisional de prueba.', archivo);
    fs = 16000;
    t_tmp = (0:round(1.3*fs)-1)' / fs;
    % Simulación con componente sonora + componente fricativa de alta frecuencia (/s/ o /z/)
    env_voz = exp(-((t_tmp - 0.65)/0.18).^2);
    env_fric = exp(-((t_tmp - 0.50)/0.045).^2);
    x = env_voz .* (0.55*sin(2*pi*240*t_tmp) + 0.30*sin(2*pi*820*t_tmp)) ...
      + env_fric .* (0.28*filter([1 -1], 1, randn(size(t_tmp)))) ...
      + 0.012*randn(size(t_tmp));
end

% Eliminar offset DC y normalizar amplitud
x = x - mean(x);
if max(abs(x)) > 0
    x = x / max(abs(x));
end

% 2. Diseño del filtro FIR pasa altas a fc = 3.5 kHz con ventana Hamming
fc = 3500;                          % Frecuencia de corte (Hz)
orden_fir = 64;                     % Orden par del filtro FIR Tipo I
Wn = fc / (fs / 2);                 % Frecuencia normalizada de Nyquist
b_fir = fir1(orden_fir, Wn, 'high', hamming(orden_fir + 1));

% Filtrar la señal con fase cero (filtfilt) para alinear exactamente en el tiempo
x_ero = filtfilt(b_fir, 1, x);

% 3. Cálculo de Energía en Corto Tiempo (tramas de 25 ms, 50% solapamiento, Hamming)[cite: 1]
dur_trama = 0.025;                  % 25 ms[cite: 1]
N_trama = round(dur_trama * fs);    % 400 muestras a 16 kHz
salto = round(0.5 * N_trama);       % 50% de solapamiento (200 muestras)[cite: 1]
win = hamming(N_trama, 'periodic'); % Ventana Hamming[cite: 1]

num_tramas = floor((length(x) - N_trama) / salto) + 1;
E_total = zeros(num_tramas, 1);
E_ero = zeros(num_tramas, 1);
t_tramas = zeros(num_tramas, 1);

for m = 1:num_tramas
    idx_ini = (m - 1) * salto + 1;
    idx_fin = idx_ini + N_trama - 1;
    
    trama_tot = x(idx_ini:idx_fin) .* win;
    trama_alt = x_ero(idx_ini:idx_fin) .* win;
    
    E_total(m) = sum(trama_tot .^ 2);
    E_ero(m)   = sum(trama_alt .^ 2);
    t_tramas(m) = ((idx_ini + idx_fin) / 2) / fs; % Tiempo central de cada trama (s)
end

% 4. Determinación del umbral adaptativo a partir del piso de ruido inicial
tramas_ruido = max(1, min(6, floor(0.15 * num_tramas))); % Primeros ~150 ms de silencio
ruido_medio = mean(E_total(1:tramas_ruido));
ruido_std   = std(E_total(1:tramas_ruido));
umbral = ruido_medio + 4 * ruido_std;
% Respaldo en caso de silencio digital perfecto (std = 0)
if umbral <= 0 || umbral > 0.25 * max(E_total)
    umbral = 0.08 * max(E_total);
end

% Detectar instantes de inicio y fin de actividad vocal
activas = find(E_total > umbral);
if ~isempty(activas)
    t_inicio = t_tramas(activas(1));
    t_fin    = t_tramas(activas(end));
else
    t_inicio = t_tramas(1);
    t_fin    = t_tramas(end);
end

% 5. Graficar Figura 4 (Panel a y Panel b)
figure('Color', 'w', 'Name', 'Figura 4 - Energía en Corto Tiempo y ERO', 'Position', [100, 100, 1050, 680]);

% --- PANEL (a): Energía en corto tiempo con umbral e inicio/fin ---
subplot(2, 1, 1);
plot(t_tramas, E_total, 'b-', 'LineWidth', 1.4); hold on;
yline(umbral, 'r--', 'LineWidth', 1.3);
xline(t_inicio, 'g-.', 'LineWidth', 1.4);
xline(t_fin, 'm-.', 'LineWidth', 1.4);
grid on;
xlim([0, length(x)/fs]);
xlabel('Tiempo (s)');
ylabel('Energía E(m)');
title('(a) Energía en corto tiempo de «izquierda» con umbral e instantes de inicio/fin');
legend('Energía total E(m)', ...
       sprintf('Umbral = %.4f', umbral), ...
       sprintf('Inicio = %.3f s', t_inicio), ...
       sprintf('Fin = %.3f s', t_fin), ...
       'Location', 'northeast');

% --- PANEL (b): ERO (FIR pasa altas 3.5 kHz) frente a energía total ---
subplot(2, 1, 2);
E_total_norm = E_total / max(E_total + eps);
E_ero_norm   = E_ero / max(E_ero + eps);

plot(t_tramas, E_total_norm, 'b-', 'LineWidth', 1.4); hold on;
plot(t_tramas, E_ero_norm, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 1.4);
grid on;
xlim([0, length(x)/fs]);
ylim([0, 1.08]);
xlabel('Tiempo (s)');
ylabel('Energía normalizada');
title('(b) Energía de altas frecuencias ERO (FIR pasa altas 3,5 kHz) frente a energía total');
legend('Energía total (normalizada)', 'Parámetro ERO > 3,5 kHz (normalizada)', 'Location', 'northeast');

sgtitle('Figura 4. Análisis de energía en corto tiempo y parámetro ERO para «izquierda»');