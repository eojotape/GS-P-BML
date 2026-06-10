#include <Servo.h>

// =============================================
// BRAÇO ROBÓTICO - CONTROLE VIA MONITOR SERIAL
// Comandos: U (subir), D (descer), O (abrir garra), C (fechar garra)
// Servo 1 (pino 9)  → dedo esquerdo
// Servo 2 (pino 10) → dedo direito (espelhado)
// LED    (pino 13)  → acende quando a garra está fechada
//
// POSIÇÕES DOS SERVOS:
// ┌─────────────┬───────────┬───────────┐
// │ Estado      │ Servo 1   │ Servo 2   │
// ├─────────────┼───────────┼───────────┤
// │ Garra aberta│    45°    │   135°    │
// │ Garra fechada│  115°    │    65°    │
// │ Braço cima  │   150°    │    30°    │
// │ Braço baixo │    30°    │   150°    │
// └─────────────┴───────────┴───────────┘
// =============================================

Servo servoEsq;
Servo servoDir;

const int PINO_SERVO_ESQ = 9;
const int PINO_SERVO_DIR = 10;
const int PINO_LED       = 13;

// Garra
const int ESQ_ABERTO  = 45;
const int ESQ_FECHADO = 115;
const int DIR_ABERTO  = 135;
const int DIR_FECHADO = 65;

// Posição vertical
const int POS_CIMA   = 150;
const int POS_CENTRO = 90;
const int POS_BAIXO  = 30;

bool garraFechada = false;
int posVertical = POS_CENTRO;

void abrirGarra() {
  int passos = abs(ESQ_FECHADO - ESQ_ABERTO);
  for (int i = 0; i <= passos; i++) {
    servoEsq.write(ESQ_FECHADO - i);
    servoDir.write(DIR_FECHADO + i);
    delay(10);
  }
  garraFechada = false;
  digitalWrite(PINO_LED, LOW);
}

void fecharGarra() {
  int passos = abs(ESQ_FECHADO - ESQ_ABERTO);
  for (int i = passos; i >= 0; i--) {
    servoEsq.write(ESQ_FECHADO - i);
    servoDir.write(DIR_FECHADO + i);
    delay(10);
  }
  garraFechada = true;
  digitalWrite(PINO_LED, HIGH);
}

void moverVertical(int destino) {
  int passo = (destino > posVertical) ? 1 : -1;

  while (posVertical != destino) {
    posVertical += passo;

    int offsetEsq = garraFechada ? ESQ_FECHADO : ESQ_ABERTO;
    int offsetDir = garraFechada ? DIR_FECHADO : DIR_ABERTO;

    int angEsq = offsetEsq + (posVertical - POS_CENTRO);
    int angDir = offsetDir - (posVertical - POS_CENTRO);

    angEsq = constrain(angEsq, 10, 170);
    angDir = constrain(angDir, 10, 170);

    servoEsq.write(angEsq);
    servoDir.write(angDir);
    delay(15);
  }
}

void setup() {
  Serial.begin(9600);

  servoEsq.attach(PINO_SERVO_ESQ);
  servoDir.attach(PINO_SERVO_DIR);
  pinMode(PINO_LED, OUTPUT);

  servoEsq.write(ESQ_ABERTO);
  servoDir.write(DIR_ABERTO);
  posVertical = POS_CENTRO;
  digitalWrite(PINO_LED, LOW);

  Serial.println("=== BRACO ROBOTICO ESPACIAL ===");
  Serial.println("Comandos:");
  Serial.println("  U -> Subir  | Servo1: 150 graus | Servo2: 30 graus");
  Serial.println("  D -> Descer | Servo1:  30 graus | Servo2: 150 graus");
  Serial.println("  O -> Abrir  | Servo1:  45 graus | Servo2: 135 graus");
  Serial.println("  C -> Fechar | Servo1: 115 graus | Servo2:  65 graus");
  Serial.println("Digite um comando e pressione Enter:");
}

void loop() {
  if (Serial.available() > 0) {
    char comando = Serial.read();

    if (comando == '\n' || comando == '\r' || comando == ' ') return;

    comando = toupper(comando);

    switch (comando) {

      case 'U':
        Serial.println(">> Subindo...");
        Serial.println("   Servo1: 150 graus | Servo2: 30 graus");
        moverVertical(POS_CIMA);
        Serial.println("   Braco no topo.");
        break;

      case 'D':
        Serial.println(">> Descendo...");
        Serial.println("   Servo1: 30 graus | Servo2: 150 graus");
        moverVertical(POS_BAIXO);
        Serial.println("   Braco em baixo.");
        break;

      case 'O':
        if (garraFechada) {
          Serial.println(">> Abrindo garra...");
          Serial.println("   Servo1: 45 graus | Servo2: 135 graus");
          abrirGarra();
          Serial.println("   Garra aberta. LED apagado.");
        } else {
          Serial.println("   Garra ja esta aberta.");
        }
        break;

      case 'C':
        if (!garraFechada) {
          Serial.println(">> Fechando garra...");
          Serial.println("   Servo1: 115 graus | Servo2: 65 graus");
          fecharGarra();
          Serial.println("   Garra fechada. LED aceso.");
        } else {
          Serial.println("   Garra ja esta fechada.");
        }
        break;

      default:
        Serial.print(">> Comando desconhecido: ");
        Serial.println(comando);
        Serial.println("   Use U, D, O ou C");
        break;
    }
  }
}
