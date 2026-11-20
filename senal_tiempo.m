% =========================================================================
% FIGURA 2: Señal en el tiempo de «avanza», «retrocede», «izquierda» y «derecha»
% =========================================================================
clear; clc; close all;

comandos = {'avanza', 'retrocede', 'izquierda', 'derecha'};
archivos = {'avanza.wav', 'retrocede.wav', 'izquierda.wav', 'derecha.wav'};

figure('Color', 'w', 'Name', 'Figura 2 - Señales en el tiempo', 'Position', [100, 100, 1000, 700]);

for k = 1:length(comandos)
    cmd = comandos{k};
    archivo = archivos{k};
    
    if exist(archivo, 'file')
        % Cargar grabación propia
        [x, fs] = audioread(archivo);
        if size(x, 2) > 1
            x = mean(x, 2); % Convertir a mono si es estéreo
        end
        x = double(x(:));
    else
        % -- Alternativa si aún no tienes el archivo .wav de ese comando --
        % Descomenta las siguientes líneas para grabar desde el micrófono:
        % fs = 16000;
        % fprintf('Pronuncia "%s" al terminar el aviso...\n', cmd);
        % pause(0.5);
        % recObj = audiorecorder(fs, 16, 1);
        % recordblocking(recObj, 1.5);
        % x = getaudiodata(recObj);
        % audiowrite(archivo, x, fs);
        
        % Señal sintética provisional solo para probar el layout si falta el archivo
        warning('No se encontró %s. Se genera señal provisional de prueba.', archivo);
        fs = 16000;
        t_tmp = (0:round(1.2*fs)-1)' / fs;
        env = exp(-((t_tmp - 0.55)/0.18).^2);
        x = env .* (0.6*sin(2*pi*(160 + 25*k)*t_tmp) + 0.35*sin(2*pi*(520 + 60*k)*t_tmp)) + 0.02*randn(size(t_tmp));
    end
    
    % Centrar señal y normalizar amplitud al rango [-1, 1]
    x = x - mean(x);
    max_val = max(abs(x));
    if max_val > 0
        x_norm = x / max_val;
    else
        x_norm = x;
    end
    
    % Vector de tiempo en segundos
    t = (0:length(x_norm)-1) / fs;
    
    % Subgráfica por comando
    subplot(2, 2, k);
    plot(t, x_norm, 'LineWidth', 1.0);
    grid on;
    xlim([0, t(end)]);
    ylim([-1.05, 1.05]);
    xlabel('Tiempo (s)');
    ylabel('Amplitud normalizada');
    title(sprintf('Comando «%s» (f_s = %d Hz)', cmd, fs));
end

sgtitle('Figura 2. Señal en el tiempo de los comandos de voz normalizados');