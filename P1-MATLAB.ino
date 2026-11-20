#include <WiFi.h>
#include <PubSubClient.h>

// Configuración de Red WiFi (Modifica con tus datos)
const char* ssid = "Abcde";
const char* password = "12345678";

// Configuración del Servidor MQTT
const char* mqtt_server = "broker.emqx.io";
const char* topicName = "voice/control";

WiFiClient espClient;
PubSubClient client(espClient);

// Definición de pines para los motores según tus indicaciones
// Motor Derecho
const int derIN1 = 5;
const int derIN2 = 18;

// Motor Izquierdo
const int izqIN1 = 19;
const int izqIN2 = 21;

// Función para detener ambos motores
void detenerMotores() {
  digitalWrite(derIN1, LOW);
  digitalWrite(derIN2, LOW);
  digitalWrite(izqIN1, LOW);
  digitalWrite(izqIN2, LOW);
  Serial.println("Motores detenidos.");
}

// Función para avanzar
void avanzar() {
  Serial.println("Acción: AVANZANDO (2 segundos)");
  digitalWrite(derIN1, HIGH);
  digitalWrite(derIN2, LOW);
  digitalWrite(izqIN1, HIGH);
  digitalWrite(izqIN2, LOW);
  
  delay(2000); // Mantiene el movimiento por 2 segundos
  detenerMotores();
}

// Función para retroceder
void retroceder() {
  Serial.println("Acción: RETROCEDIENDO (2 segundos)");
  digitalWrite(derIN1, LOW);
  digitalWrite(derIN2, HIGH);
  digitalWrite(izqIN1, LOW);
  digitalWrite(izqIN2, HIGH);
  
  delay(2000); // Mantiene el movimiento por 2 segundos
  detenerMotores();
}

void izquierda() {
  Serial.println("Acción: RETROCEDIENDO (2 segundos)");
  digitalWrite(derIN1, HIGH);
  digitalWrite(derIN2, LOW);
  digitalWrite(izqIN1, LOW);
  digitalWrite(izqIN2, LOW);
  
  delay(2000); // Mantiene el movimiento por 2 segundos
  detenerMotores();
}

void derecha() {
  Serial.println("Acción: RETROCEDIENDO (2 segundos)");
  digitalWrite(derIN1, LOW);
  digitalWrite(derIN2, LOW);
  digitalWrite(izqIN1, HIGH);
  digitalWrite(izqIN2, LOW);
  
  delay(2000); // Mantiene el movimiento por 2 segundos
  detenerMotores();
}

// Callback que se ejecuta al recibir un mensaje MQTT
void callback(char* topic, byte* payload, unsigned int length) {
  String mensaje = "";
  for (unsigned int i = 0; i < length; i++) {
    mensaje += (char)payload[i];
  }
  
  mensaje.trim(); // Limpiar espacios o saltos de línea extra
  Serial.print("Mensaje MQTT recibido: ");
  Serial.println(mensaje);

  // Compara si recibe "1" o "avanza"
  if (mensaje == "1" || mensaje == "avanza") {
    avanzar();
  } 
  // Compara si recibe "2" o "retrocede"
  else if (mensaje == "2" || mensaje == "retrocede") {
    retroceder();
  }
  else if (mensaje == "3" || mensaje == "derecha") {
    derecha();
  }
  else if (mensaje == "4" || mensaje == "izquierda") {
    izquierda();
  }
}

// Función de reconexión MQTT automática
void reconnect() {
  while (!client.connected()) {
    Serial.print("Intentando conexión MQTT...");
    // ID único para el cliente ESP32
    if (client.connect("ESP32RobotVoiceReceiver")) {
      Serial.println("¡Conectado!");
      client.subscribe(topicName);
    } else {
      Serial.print("Fallo, rc=");
      Serial.print(client.state());
      Serial.println(" Reintentando en 5 segundos...");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  // Configurar pines de motores como salidas
  pinMode(derIN1, OUTPUT);
  pinMode(derIN2, OUTPUT);
  pinMode(izqIN1, OUTPUT);
  pinMode(izqIN2, OUTPUT);

  detenerMotores();

  // Conexión a la red WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi conectado con éxito.");

  // Configurar servidor MQTT
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
}