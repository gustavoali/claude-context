# Chemical - Juego Educativo de Quimica

**Plataforma:** Flutter (Android)
**Estado:** En desarrollo - MVP
**Inicio:** 2025-12-28

---

## Vision del Proyecto

Chemical es un juego educativo que combina:

- **Puzzle** - Mecanica principal de combinacion de elementos
- **Aventura** - Progresion narrativa salvando ecosistemas
- **Simulador de Laboratorio** - Experimentacion con reacciones
- **Ecologia Sustentable** - Contexto de problemas ambientales reales

---

## MVP - Navegacion de Tabla Periodica

### Funcionalidad

- Tarjeta que muestra un elemento quimico
- Tap en mitad inferior: avanzar al siguiente elemento
- Tap en mitad superior: retroceder al elemento anterior
- Mensajes al llegar al inicio (Hidrogeno) o final (Oganeson) de la tabla

### Arquitectura

```
lib/
├── main.dart
├── models/
│   └── chemical_element.dart
├── data/
│   └── elements_data.dart
├── screens/
│   └── element_card_screen.dart
└── widgets/
    ├── element_card.dart
    └── boundary_message.dart
```

---

## Documentacion

| Documento | Descripcion |
|-----------|-------------|
| [PRODUCT_BACKLOG.md](./PRODUCT_BACKLOG.md) | Historias de usuario del MVP |
| LEARNINGS.md | Patrones y decisiones tecnicas (por crear) |

---

## Roadmap

| Version | Funcionalidad |
|---------|---------------|
| **MVP** | Navegacion basica de elementos |
| v0.2 | Informacion adicional de elementos |
| v0.3 | Laboratorio simple |
| v0.4 | Primera historia/niveles |
| v0.5 | Sistema de progresion |

---

## Tecnologias

- Flutter SDK 3.16+
- Dart 3.0+
- Material Design 3
- Android minSdk: 21

---

## Comandos

```bash
# Crear proyecto
flutter create chemical

# Ejecutar en modo desarrollo
flutter run

# Build para Android
flutter build apk

# Ejecutar tests
flutter test
```

---

**Ultima actualizacion:** 2025-12-28
