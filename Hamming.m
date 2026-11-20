% 1. Cargar grabación propia (ajusta el nombre del archivo si es necesario)
[x, fs] = audioread('avanza.wav'); %[cite: 2]
if size(x, 2) > 1
    x = mean(x, 2); % Convertir a mono si es estéreo
end

% 2. Extraer una trama de 25 ms (400 muestras a 16 kHz) desde una zona con voz
dur_trama = 0.025; % 25 ms[cite: 1]
N_trama = round(dur_trama * fs); % 400 muestras a 16000 Hz
idx_inicio = round(0.4 * length(x)); % Ajustar según dónde inicie la palabra
trama = x(idx_inicio : idx_inicio + N_trama - 1);

% 3. Aplicar ventana rectangular y ventana Hamming
w_rect = rectwin(N_trama);
w_hamm = hamming(N_trama);

trama_rect = trama .* w_rect;
trama_hamm = trama .* w_hamm;

% 4. Calcular FFT (ej. NFFT = 1024) y eje de frecuencias hasta fs/2
NFFT = 1024;
mag_rect = abs(fft(trama_rect, NFFT));
mag_hamm = abs(fft(trama_hamm, NFFT));

f = (0:NFFT/2-1) * (fs / NFFT);
mag_rect_half = mag_rect(1:NFFT/2);
mag_hamm_half = mag_hamm(1:NFFT/2);

% 5. Graficar comparación
figure('Color', 'w');
plot(f, mag_rect_half, 'LineWidth', 1.2); hold on;
plot(f, mag_hamm_half, 'LineWidth', 1.4);
grid on;
xlim([0, fs/2]);
xlabel('Frecuencia (Hz)');
ylabel('Magnitud |X(f)|');
title('FFT de una trama de 25 ms: Ventana Rectangular vs. Hamming');
legend('Ventana Rectangular', 'Ventana Hamming', 'Location', 'northeast');