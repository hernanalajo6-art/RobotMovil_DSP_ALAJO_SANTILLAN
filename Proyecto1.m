clear, clc

brokerAddress = "tcp://broker.emqx.io";
topic_pub = "mi_banda/respuesta";   

mqClient = mqttclient(brokerAddress, Port=1883);

if mqClient.Connected
    fprintf('Conectado exitosamente al broker %s\n', brokerAddress);
else
    error('No se pudo conectar al broker MQTT');
end

fprintf('\n========================================\n');
fprintf(' PRUEBA DE COMUNICACIÓN MQTT CON ESP32\n');
fprintf(' Escribe "1" para ENCENDER el LED.\n');
fprintf(' Escribe "0" para APAGAR el LED.\n');
fprintf(' Escribe "salir" para terminar.\n');
fprintf('========================================\n\n');

while true
    comando = input('Ingresa el comando (1, 0 o salir): ', 's');
    comando = strtrim(comando);
    
    if strcmpi(comando, "salir")
        fprintf('Cerrando conexión MQTT...\n');
        break;
    elseif strcmpi(comando, "1") || strcmpi(comando, "0")
        write(mqClient, topic_pub, comando);
        fprintf('[MQTT] Comando "%s" enviado a la ESP32.\n\n', comando);
    else
        fprintf('[AVISO] Comando no válido. Escribe 1, 0 o salir.\n\n');
    end
end