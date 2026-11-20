%% Grabación de Patrones de Voz (Avanza / Retrocede)
clc;
clear;
close all;

disp('--- CONFIGURACIÓN DE PATRONES DE VOZ ---');
disp('Ingrese 1 para grabar: AVANZA');
disp('Ingrese 2 para grabar: RETROCEDE');
z = input('Seleccione la opción deseada: ');

Fs = 44100; % Frecuencia de muestreo
t = 2;      % Tiempo de grabación en segundos
v = audiorecorder(Fs, 16, 1);

switch z
    case 1
        disp('Iniciando grabación de "AVANZA". Hable ahora...');
        recordblocking(v, t);
        yy = getaudiodata(v);
        sound(yy, Fs);
        audiowrite('avanza.wav', yy, Fs);
        disp('¡Archivo "avanza.wav" guardado con éxito!');
        
    case 2
        disp('Iniciando grabación de "RETROCEDE". Hable ahora...');
        recordblocking(v, t);
        yy = getaudiodata(v);
        sound(yy, Fs);
        audiowrite('retrocede.wav', yy, Fs);
        disp('¡Archivo "retrocede.wav" guardado con éxito!');
    case 3
        disp('Iniciando grabación de "Izquierda". Hable ahora...');
        recordblocking(v, t);
        yy = getaudiodata(v);
        sound(yy, Fs);
        audiowrite('izquierda.wav', yy, Fs);
        disp('¡Archivo "Izquierda.wav" guardado con éxito!');
    case 4
        disp('Iniciando grabación de "Derecha". Hable ahora...');
        recordblocking(v, t);
        yy = getaudiodata(v);
        sound(yy, Fs);
        audiowrite('derecha.wav', yy, Fs);
        disp('¡Archivo "Derecha.wav" guardado con éxito!');
    otherwise
        disp('Opción no válida.');
end