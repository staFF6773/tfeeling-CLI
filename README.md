# Sylvie TUI - Teaching Feeling Simulation (Rust Edition)

![Version](https://img.shields.io/badge/version-1.1.0-pink)
![License](https://img.shields.io/badge/GPL-3.0-blue)
![Rust](https://img.shields.io/badge/Rust-Ratatui-orange)

Un simulador interactivo por terminal basado en la popular novela visual **Teaching Feeling**, ahora portado completamente a **Rust** para una experiencia más fluida y profesional con **Ratatui**.

<img width="1365" height="767" alt="imagen" src="https://github.com/user-attachments/assets/ec9b3410-21df-4524-a4a2-b1ab5505bceb" />

## 🌟 Características Principales

- **Motor Nativo en Rust**: Alto rendimiento y gestión de estado robusta.
- **Interfaz Ratatui**: Una TUI moderna con barras de estado, navegación por teclado y divisiones de pantalla.
- **Sistema de Afecto y Confianza**: Las reacciones de Sylvie evolucionan basándose en tus acciones.
- **Motor de Diálogos Dinámicos**: Selección inteligente de diálogos basada en estadísticas y momento del día.
- **Persistencia en JSON**: El progreso se guarda automáticamente en `~/.sylvie_save.json`.

## 📂 Estructura del Proyecto

```text
tfeeling-CLI/
├── src/
│   ├── main.rs           # Entrada de la aplicación y manejo de terminal
│   ├── engine.rs         # Motor de lógica y estadísticas
│   └── ui.rs             # Definición de la interfaz Ratatui
├── modules/
│   └── dialogues.json    # Base de datos de diálogos
├── Cargo.toml            # Dependencias de Rust
└── README.md             # Documentación
```

## 🚀 Instalación y Requisitos

### Requisitos
- **Rust** (edición 2024 o superior)
- **Cargo** (gestor de paquetes de Rust)

### Compilación y Uso
1. **Clonar o descargar** el repositorio.
2. **Compilar el proyecto**:
   ```bash
   cargo build --release
   ```
3. **Ejecutar el simulador**:
   ```bash
   ./target/release/tfeeling-CLI
   ```
   *O simplemente usa `cargo run --release` para compilar y ejecutar en un solo paso.*

## 🎮 Controles
- **Flechas (Arriba/Abajo)**: Navegar por el menú.
- **Enter**: Seleccionar acción.
- **Esc / Q**: Salir del juego.

## 👥 Créditos

- **Ray-K**: Creador original de la novela visual *Teaching Feeling*.
- **staFF6773**: Desarrollador original de la versión CLI.

## 📝 Licencia

Este proyecto está bajo la Licencia GPL. Siéntete libre de usarlo, modificarlo y compartirlo.

---
*Desarrollado con ❤️ para la comunidad de fans de Teaching Feeling.*
