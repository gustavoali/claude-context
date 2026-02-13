# Mew Michis - Sistema de Alimentacion Casera Felina

**Tipo:** Aplicacion Movil
**Framework:** Flutter
**Persistencia:** SQLite (local)
**Estado:** Iniciando MVP

---

## Objetivo

Aplicacion movil para planificar, validar y optimizar la alimentacion casera balanceada para gatos, generando menus semanales, listas de compras y presupuestos.

## Usuarios Objetivo

Cuidadores de uno o multiples gatos que necesitan una herramienta segura, organizada y economica para la planificacion alimentaria.

## Alcance MVP

- Perfil nutricional por peso total de gatos
- Recetas base inmutables (A-F)
- Variaciones controladas de proteinas
- Menu semanal con validaciones
- Lista de compras automatica
- Presupuesto y costos
- Funcionamiento offline

## Arquitectura

```
Flutter App (Dart)
    |
    +-- Presentation Layer (Widgets, Screens)
    |
    +-- Domain Layer (Use Cases, Entities)
    |
    +-- Data Layer (Repositories, SQLite)
```

## Reglas de Negocio Clave

- Taurina y calcio: siempre obligatorios
- Pescado: maximo 2 veces por semana
- Higado: maximo 2 veces por semana
- Aceite: obligatorio si no hay pescado graso
- Ajustes automaticos por cerdo y estacion

## Documentos Relacionados

- Especificacion: `C:/apps/mew-michis/Especificacion_App_Alimentacion_Felina.pdf`
- Backlog: `C:/claude_context/apps/mew-michis/PRODUCT_BACKLOG.md`

---

**Ultima actualizacion:** 2026-01-26
