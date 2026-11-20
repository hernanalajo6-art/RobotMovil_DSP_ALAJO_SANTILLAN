%% Reconocimiento de Voz y Envío por MQTT
clc;
clear;
close all;

% 1. Configuración del Cliente MQTT en MATLAB
% Asegúrate de usar un broker accesible (por ejemplo, el público de EMQX)
brokerAddress = "tcp://broker.emqx.io";
topicName = "voice/control";

try
    % Crear cliente MQTT (requiere versiones recientes de MATLAB con MQTT Toolbox)
    mqttClient = mqttclient(brokerAddress, "ClientID", "MatlabVoiceControlClient");
    disp("Conectado exitosamente al Broker MQTT.");
catch exception
    disp("Error al conectar con el broker MQTT: ");
    disp(exception.message);
end

a = [0.1 -0.95];
b = [1 -0.99];

% Cargar y procesar patrones de referencia
[av, ~] = audioread('avanza.wav');
av = filter(a, b, av);
av = (av - min(av)) / (max(av) - min(av));
V_av = abs(fft(av));

[re, ~] = audioread('retrocede.wav');
re = filter(a, b, re);
re = (re - min(re)) / (max(re) - min(re));
V_re = abs(fft(re));

% Ajustar longitudes para la comparación vectorial
min_len = min([length(V_av), length(V_re)]);
V_av = V_av(1:min_len);
V_re = V_re(1:min_len);

disp('--- SISTEMA DE RECONOCIMIENTO DE VOZ LISTO ---');
disp('Diga "Avanza" o "Retrocede" después de presionar ENTER...');

% Crear la ventana de figura para las gráficas
figure(1);
set(gcf, 'Position', [100, 100, 800, 600]);

% Bucle de escucha continua
while true
    input('Presione ENTER y hable (o Ctrl+C para salir)...');
    
    Fs = 44100;
    t = 2;
    v_rec = audiorecorder(Fs, 16, 1);
    
    disp('>>> GRABANDO... Habla ahora.');
    recordblocking(v_rec, t);
    audio_in = getaudiodata(v_rec);
    disp('<<< Fin de grabación. Procesando...');
    
    % Filtrado y Normalización de la señal de entrada en el tiempo
    audio_filtrado = filter(a, b, audio_in);
    audio_norm = (audio_filtrado - min(audio_filtrado)) / (max(audio_filtrado) - min(audio_filtrado));
    
    % Transformada de Fourier (FFT)
    V_in = abs(fft(audio_norm));
    V_in_trunc = V_in(1:min_len);
    
    % Cálculo de error absoluto medio frente a los patrones
    err_av = mean(abs(V_av - V_in_trunc));
    err_re = mean(abs(V_re - V_in_trunc));
    
    [~, index] = min([err_av, err_re]);
    
    % --- SECCIÓN DE GRÁFICAS ---
    clf(1); % Limpiar la figura en cada iteración para actualizarla
    
    % Subplot 1: Señal de audio normalizada en el dominio del tiempo
    subplot(2, 1, 1);
    plot(audio_norm, 'b', 'LineWidth', 1.2);
    title('Señal de Entrada en el Dominio del Tiempo (Filtrada y Normalizada)', 'FontSize', 11);
    xlabel('Muestras');
    ylabel('Amplitud');
    grid on;
    
    % Subplot 2: Transformada de Fourier (FFT) en el dominio de la frecuencia
    subplot(2, 1, 2);
    plot(V_in, 'r', 'LineWidth', 1.2);
    title('Transformada de Fourier (FFT) de la Señal de Entrada', 'FontSize', 11);
    xlabel('Frecuencia (Bins)');
    ylabel('Magnitud');
    grid on;
    % ---------------------------
    
    % Salida directa en el Command Window y visualización de resultados
    if index == 1
        disp('Comando detectado: AVANZA');
        fprintf('1\n'); % Manda un 1 al Command Window
        write(mqttClient, topicName, "1");
    else
        disp('Comando detectado: RETROCEDE');
        fprintf('2\n'); % Manda un 2 al Command Window
        write(mqttClient, topicName, "2");
    end
    
    disp('---------------------------------------------');
end

