# Trabajo-Final-ED2-Regulador-de-Luz
# REGULADOR DE NIVEL DE LUZ - PIC16F887

Proyecto en ensamblador para microcontrolador PIC16F887 que regula el nivel de luz usando un sensor (LDR) y control PWM.

## 📋 Descripción

Este proyecto lee el nivel de luz ambiente mediante un sensor LDR conectado al ADC del PIC16F887 y controla la intensidad de una fuente de luz mediante modulación por ancho de pulso (PWM).

## 🔧 Hardware Requerido

- Microcontrolador PIC16F887
- Sensor LDR (fotoresistor)
- LED o lámpara controlable por PWM
- Resistencias y componentes pasivos
- Fuente de alimentación (5V)
- Programador PICkit (o similar)

## 📁 Estructura del Proyecto

```
main.asm         - Código principal en ensamblador
README.md        - Este archivo
```

## 🔌 Conexiones Sugeridas

- **RA0/AN0**: Entrada analógica del sensor LDR
- **RC2/CCP1**: Salida PWM para control de luz
- **VDD/VSS**: Alimentación 5V

## 🛠️ Compilación y Programación

Este código **NO se puede compilar en Replit**. Necesitas usar herramientas específicas en tu computadora:

### Paso 1: Instalar Software
1. Descarga e instala [MPLAB X IDE](https://www.microchip.com/mplab/mplab-x-ide)
2. El ensamblador MPASM viene incluido con MPLAB X

### Paso 2: Crear Proyecto en MPLAB X
1. Abre MPLAB X IDE
2. File → New Project → Microchip Embedded → Standalone Project
3. Selecciona el dispositivo: PIC16F887
4. Selecciona el programador (PICkit 3, PICkit 4, etc.)
5. Selecciona el compilador: mpasm (v5.xx)
6. Nombra el proyecto: REGULADOR_DE_NIVEL_DE_LUZ

### Paso 3: Agregar el Código
1. Copia el contenido de `main.asm` al proyecto
2. Ajusta la configuración según tu hardware
3. Build Project (Production → Build)

### Paso 4: Programar el PIC
1. Conecta tu programador PICkit al PIC16F887
2. Make and Program Device

## ⚙️ Configuración

Ajusta estos parámetros en el código según tus necesidades:

```assembly
; En la sección de configuración de bits
_FOSC_INTRC_NOCLKOUT    ; Oscilador interno sin salida de reloj

; En las constantes
LUZ_MIN     EQU .50     ; Nivel mínimo de luz
LUZ_MAX     EQU .200    ; Nivel máximo de luz

; En CONFIGURAR_OSCILADOR
B'01100000'             ; 4MHz (ajustar según necesidad)
```

## 📝 Personalización

El código incluye plantillas para las funciones principales:

- `CONFIGURAR_PUERTOS`: Configuración de entradas/salidas
- `CONFIGURAR_ADC`: Configuración del convertidor analógico-digital
- `CONFIGURAR_PWM`: Configuración de modulación por ancho de pulso
- `LEER_SENSOR_LUZ`: Lectura del sensor
- `CALCULAR_PWM`: Lógica de control (personalizar según tu algoritmo)
- `ACTUALIZAR_PWM`: Actualización de la salida

## 💡 Notas Importantes

- El código está comentado en español para facilitar la comprensión
- Los valores de configuración son ejemplos - ajusta según tu hardware
- Los retardos son aproximados - calibra según tu frecuencia de reloj
- La función `CALCULAR_PWM` contiene lógica básica - implementa tu algoritmo de control aquí

## 📚 Recursos

- [Hoja de datos PIC16F887](https://www.microchip.com/wwwproducts/en/PIC16F887)
- [MPLAB X IDE](https://www.microchip.com/mplab/mplab-x-ide)
- [Tutorial de PWM en PIC](https://www.microchip.com/)

## ✍️ Desarrollo

Puedes editar el código directamente en Replit como editor de texto, pero recuerda que la compilación y programación debe hacerse en MPLAB X IDE.

---
**Nota**: Este es un proyecto de firmware embebido. Replit solo sirve como editor de código - no puede compilar ni simular código para microcontroladores PIC.
