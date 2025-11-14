# Regulador de Luz – PIC16F887  
Trabajo Práctico Final ED2  

Sistema de regulación de luz con control automático/manual utilizando un sensor LDR, comunicación UART con LabView y control PWM mediante el microcontrolador **PIC16F887**.
Vale aclarar que es un simple modelo capaz de escalarse a no solo el control de un LED sino a una lámpara halógena o incluso a una lámpara calórica para la crianza de polluelos de engorde (idea inspiracional del trabajo).

---

## 📷 Vista General del Proyecto

Este repositorio contiene:

- Código ensamblador (`TP_FINAL.asm`)
- Código en hexadecimal (`TP_FINAL.hex`)
- Programa de LabVIEW para el control manual via UART (`TP_FINAL_control_manual.vi`)
- Programa de Proteus con simulación del circuito (`TP_FINAL_simulación.pdsprj`)
- Video del circuito funcionando en modo manual (`Modo manual.mp4`)
- Video del circuito funcionando en modo automático  (`Modo automático.mp4`)
- Diagrama de bloques del funcionamiento
- Documentación para instalar, compilar y usar el sistema

---

## 🧩 Diagrama de Bloques Simple
<img width="471" height="449" alt="image" src="https://github.com/user-attachments/assets/76736bcd-b568-4b37-966b-8f580782db4e" />

---

## 💡 Diagrama Esquemático
<img width="835" height="413" alt="image" src="https://github.com/user-attachments/assets/bf546c05-5b5e-4a5b-a63b-2dc20c8f2ecb" />

---

## 📸 Fotografía del Circuito
<img width="955" height="666" alt="image" src="https://github.com/user-attachments/assets/dc7348cd-cde0-4346-aca1-7056597df4ce" />

---

## 📋 Descripción General

Este sistema regula el nivel de luz mediante:

- **Modo Automático:**  
  El PIC lee el nivel del sensor LDR por ADC y ajusta el PWM automáticamente.

- **Modo Manual:**  
  El usuario envía un valor mediante LabVIEW por UART  para fijar directamente el ciclo de trabajo del PWM.

El cambio entre modos se realiza con una **interrupción externa INT (RB0)**.
Además se implementa **interrupción del ADC, interrupción de la comunicación UART e interrupción de TMR0**

---

## 🔧 Hardware Necesario

- PIC16F887  (debe tener un bootloader cargado ya en el PIC, puede ser cargado a tráves de un PICkit)
- LDR
- Resistencias (10kΩ)
- Capacitores (22pF)
- Transistor NPN
- Cristal de cuarzo de 4MHz
- Pulsadores o Botones
- Protoboard (recomendación)
- LED o lámpara apta para PWM  
- Fuente 5V   
- Conexión UART USB-TTL a PC

---

## 🔌 Conexiones Principales

| Pin PIC | Función | Descripción |
|--------|---------|-------------|
| RA0/AN0 | ADC IN | Entrada analógica del LDR |
| RC2/CCP1 | PWM OUT | Control de brillo |
| RC6/TX | UART TX | PIC → PC |
| RC7/RX | UART RX | PC → PIC |
| RB0/INT | Interrupción externa | Cambia entre modo auto/manual |
| VDD/VSS | Alimentación | 5V |

---

## 🛠️ Cómo Compilar y Programar

### 1️⃣ Instalar herramientas  

**Softwares usados:**  

- MPLAB X IDE: `v5.35`  
- MPASM Assembler: `v5.87`
- LabVIEW: `v2025 Q3 (64-bit) `
- Proteus: `v8.11`
- AN1310: `v1.05`

---

### 4️⃣ ¿Cómo cargar el programa .hex al PIC?

- Conectar el puerto serie del PC al PIC (USB-TTL)
- Abrir el AN1310
- Configurar el COM correcto y Bootloader Baud Rate (19200 bps recomendados)
- Forzar entrada a modo bootloader en el PIC
  Pulsá el botón Break/Reset Application Firmware y luego el botón Bootloader Mode
- Abrir el archivo .hex y escribirlo
  Open → seleccioná tu archivo.hex. y uego pulsá el botón de programar/escribir (ícono flecha roja hacia abajo)
- Pulsa Run Mode (botón verde) y listo

---

## ⚙️ Configuración del Sistema

### ✔ Configuración del ADC

- Canal AN0  
- Justificado a la izquierda  
- Se usa solo ADRESH (8 bits)  
- Conversión disparada cada 5ms por TMR0  

### ✔ Configuración UART

- **Baud Rate:** 9600 bps  
- BRGH = 1  
- SPBRG = 25 (a 4 MHz, ~9615 bps)
- RX habilitado permanentemente  
- Cada byte recibido actualiza el duty manual

### ✔ Configuración del PWM (CCP1 – RC2)

- Frecuencia ≈ 500 Hz  
- PR2 = 124  
- Prescaler = 16  
- Solo se usa CCPR1L (8 bits)

### ✔ Timer0

- Preload = `0xED`  
- Interrupción cada ≈ 5ms  
- Se usa para:  
  - disparar el ADC  
  - generar retardos  
  - control periódico

### ✔ Interrupción externa (RB0)

- Flanco ascendente  
- Alterna el valor de `modo` (0 = manual, 1 = auto)

---

## 🖥️ Interfaz LabVIEW

El panel mostrado en el repositorio permite:

- Configurar el VISA resource name (puerto COM ) -> **Paso que debo realizar obligatoriamente**
- Enviar un valor PWM manual por medio de una perilla
- Observar que porcentaje de brillo enviamos:
                                            - valor numérico
                                            - medidor de intensidad de color
                                            - gráfica que muestra los valores previos
  
---

## 📝 Notas Útiles para Quien Quiera Usar el Proyecto

- El código está comentado y de manera fácil de comprender.  
- Existe la posibilidad de que haya un pequeño rebote en el RB0.
- El modo programado por default es el manual.
- El efecto del modo automático se aprecia mejor en un ambiente con poca luz, acercando y alejando una linterna sobre el LDR.
- Es recomendable colocar alejados el LED y el LDR en la Protoboard para que no se afecten.
- Revisar que la configuración de registros sea correcta, ya que en otros PIC pueden existir los registros pero que se encuentren en otro banco.

---

## 👥 Integrantes

- **Pedro Caldera**  
- **Ignacio Ariel Leguizamón**

---

## 📚 Documentación Recomendada

- Datasheet PIC16F887
- Datasheet de componentes

---

**Fin del README.**
