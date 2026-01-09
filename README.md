# Sylvie CLI - Teaching Feeling Simulation

![Version](https://img.shields.io/badge/version-1.0.0-pink)
![License](https://img.shields.io/badge/GPL-3.0-blue)

Un simulador interactivo por terminal basado en la popular novela visual **Teaching Feeling**. Gestiona el bienestar de Sylvie a través de un sistema de estadísticas dinámico, diálogos contextuales y un ciclo de tiempo realista.

<img width="1365" height="767" alt="imagen" src="https://github.com/user-attachments/assets/03044e36-15ab-4747-b926-7b3a29368ea5" />

## 🌟 Características Principales

- **Sistema de Afecto y Confianza**: Las reacciones de Sylvie evolucionan de la desconfianza total al afecto profundo basándose en tus acciones.
- **Motor de Diálogos Dinámicos**: Más de 60 variaciones de texto que dependen del nivel de felicidad, la acción reciente y el momento del día.
- **Ciclo de Tiempo Realista**: Sistema de reloj interno que avanza con cada acción, alternando entre mañana, tarde y noche.
- **Interfaz ASCII**: Representación visual ligera y estética optimizada para cualquier terminal con soporte de colores ANSI.
- **Persistencia de Datos**: El progreso se guarda automáticamente en `~/.sylvie_data`.
- **Arquitectura Modular**: Diálogos separados en módulos para facilitar la personalización.

## 📂 Estructura del Proyecto

```text
tfeeling-CLI/
├── sylvie.sh             # Script principal (Lógica y UI)
└── modules/
    └── dialogues.sh      # Base de datos de diálogos
```

## 🚀 Instalación y Uso

1. **Clonar o descargar** el repositorio en tu máquina local.
2. Asegúrate de que los archivos tengan permisos de ejecución:
   ```bash
   chmod +x sylvie.sh
   ```
3. **Ejecutar el simulador**:
   ```bash
   ./sylvie.sh
   ```

## 🎮 Mecánicas de Juego

| Acción | Impacto en Afecto | Impacto en Confianza | Descripción |
| :--- | :---: | :---: | :--- |
| **Acariciar** | +2 | +1 | Gana su confianza poco a poco. |
| **Hablar** | Variable | Variable | Mantén una conversación para saber cómo se siente. |
| **Dar Dulce** | +5 | +2 | El camino más rápido hacia su corazón. |

### Estados de Sylvie
- **Desconfianza** (Afecto < 20): Respuestas temerosas y distantes.
- **Neutral** (Afecto 20-60): Comienza a sentirse cómoda y agradecida.
- **Confianza** (Afecto > 60): Se muestra cariñosa y te llama "maestro".

## 🛠️ Personalización

Puedes añadir tus propios diálogos editando el archivo `modules/dialogues.sh`. Simplemente añade nuevas líneas a los arrays correspondientes siguiendo el formato de Bash.

## 📝 Licencia

Este proyecto está bajo la Licencia GPL. Siéntete libre de usarlo, modificarlo y compartirlo.

---
*Desarrollado con ❤️ para la comunidad de fans de Teaching Feeling.*
