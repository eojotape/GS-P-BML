# 🦾 Garra Robótica para Microgravidade

Projeto de braço robótico controlado via Monitor Serial, desenvolvido para simular operações de manipulação em ambiente de microgravidade (Indústria Espacial). O sistema utiliza dois servomotores SG90 que atuam em conjunto como uma pinça, além de um LED de status que indica o estado da garra.

---

## 👥 Integrantes

| Nome | RM |
|---|---|
| João Pedro de Albuquerque Oliveira | 551579 |
| Pedro Augusto Carneiro Barone Bomfim | 99781 |
| Matheus Augusto Santos Rego | 551466 |

---

## 🔗 Simulador

Acesse o circuito simulado no Wokwi:
**https://wokwi.com/projects/466397213339113473**

---

## 🕹️ Guia de Operação

### Como abrir o Monitor Serial
1. Abra o projeto no link do Wokwi acima
2. Clique em **"Start Simulation"**
3. Clique no ícone do **Monitor Serial** na barra inferior
4. Certifique-se que o baud rate está configurado em **9600**
5. Digite um dos comandos abaixo e pressione **Enter**

### Comandos disponíveis

| Comando | Ação | Servo 1 (pino 9) | Servo 2 (pino 10) | LED |
|---|---|---|---|---|
| `U` | Subir o braço | 150° | 30° | — |
| `D` | Descer o braço | 30° | 150° | — |
| `O` | Abrir a garra | 45° | 135° | Apaga |
| `C` | Fechar a garra | 115° | 65° | Acende 🟢 |

> **Observação:** Os dois servos sempre se movem simultaneamente e em direções opostas, simulando o mecanismo de pinça real da garra. O LED verde acende quando a garra está fechada (objeto capturado) e apaga quando está aberta.

### Exemplo de sequência de operação
```
C   → fecha a garra
U   → sobe o braço com objeto capturado
D   → desce o braço
O   → abre a garra, soltando o objeto
```

---

## ⚙️ Especificações Técnicas

### Pinagem do Arduino

| Pino | Componente | Função |
|---|---|---|
| 9 | Servo 1 (SG90) | Dedo esquerdo da garra |
| 10 | Servo 2 (SG90) | Dedo direito da garra (espelhado) |
| 13 | LED verde | Status da garra |
| 5V | VCC dos servos | Alimentação |
| GND | GND comum | Terra compartilhado |

### Tensão configurada
- **Simulador (Wokwi):** alimentação dos servos via pino 5V do Arduino
- **Hardware físico:** fonte de bancada externa configurada para **5V**, com GND comum ao Arduino, para evitar sobrecarga na placa

### Software de Modelagem
As peças 3D foram modeladas no **Fusion 360** / **AutoCAD**, com design funcional para encaixe dos servomotores SG90 de 9g, incluindo os seguintes componentes:
- Placa base com furos de fixação
- Elos da garra (dedos)
- Yoke deslizante
- Horn excêntrico
- Pinos e arruelas/espaçadores

---

## 🛠️ Como reproduzir o projeto

1. Clone este repositório
2. Abra o arquivo `/src/sketch.ino` na **Arduino IDE**
3. Acesse o simulador pelo link do Wokwi
4. Inicie a simulação e use os comandos via Monitor Serial
