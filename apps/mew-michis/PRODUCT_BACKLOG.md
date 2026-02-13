# Product Backlog - Mew Michis

**Proyecto:** Sistema de Alimentacion Casera Felina
**Version:** 3.0
**Fecha de creacion:** 2026-01-26
**Ultima actualizacion:** 2026-02-05
**Product Owner:** Usuario
**Escala:** Micro (1 developer)

---

## ID Registry

| ID | Descripcion | Epic | Pts | Status |
|----|-------------|------|-----|--------|
| MEW-001 | Configurar perfil nutricional basico | E1 | 3 | Done |
| MEW-002 | Calcular necesidades diarias y semanales | E1 | 5 | Done |
| MEW-003 | Persistir perfil en SQLite | E1 | 2 | Done |
| MEW-004 | Definir modelo de datos de recetas base | E2 | 3 | Done |
| MEW-005 | Cargar recetas A-F predefinidas | E2 | 5 | Done |
| MEW-006 | Visualizar detalle de receta | E2 | 3 | Done |
| MEW-007 | Aplicar variaciones de proteinas | E2 | 5 | Done |
| MEW-008 | Escalar receta por peso de gatos | E3 | 5 | Done |
| MEW-009 | Calcular suplementos obligatorios | E3 | 3 | Done |
| MEW-010 | Aplicar ajustes estacionales | E3 | 5 | Done |
| MEW-011 | Crear menu semanal con calendario | E4 | 5 | Done |
| MEW-012 | Validar restricciones semanales | E4 | 5 | Done |
| MEW-013 | Persistir menu semanal | E4 | 3 | Done |
| MEW-014 | Generar lista de compras semanal | E5 | 5 | Done |
| MEW-015 | Agrupar ingredientes por categoria | E5 | 3 | Done |
| MEW-016 | Registrar precios de ingredientes | E6 | 3 | Done |
| MEW-017 | Calcular costo semanal y por kilo | E6 | 5 | Done |
| MEW-018 | Fix SnackBar no desaparece en variaciones | E7 | 2 | Done |
| MEW-019 | Onboarding guiado inicial | E8 | 5 | Done |
| MEW-020 | Desglose explicativo del calculo nutricional | E8 | 3 | Done |
| MEW-021 | Tooltips de justificacion nutricional | E8 | 3 | Done |
| MEW-022 | Badge de seguridad nutricional en menu | E8 | 3 | Done |
| MEW-023 | Errores accionables en validaciones | E8 | 5 | Done |
| MEW-024 | Alertas de valores atipicos en perfil | E8 | 3 | Done |
| MEW-025 | Score nutricional semanal | E8 | 5 | Pending |
| MEW-026 | Indicador de completitud de receta | E8 | 2 | Done |
| MEW-027 | Exportar lista de compras (texto/WhatsApp) | E9 | 5 | Pending |
| MEW-028 | Modo compra real con redondeo comercial | E9 | 3 | Pending |
| MEW-029 | Historico de precios por ingrediente | E9 | 5 | Pending |
| MEW-030 | Costo por comida individual | E9 | 3 | Pending |
| MEW-031 | Compartir menu semanal | E9 | 5 | Pending |
| MEW-032 | Informacion individual por gato | E10 | 5 | Pending |
| MEW-033 | Modo usuario avanzado | E10 | 5 | Pending |
| MEW-034 | Simulaciones hipoteticas | E10 | 5 | Pending |
| MEW-035 | Sugerencias automaticas de correccion | E10 | 5 | Pending |
| MEW-036 | Sustituciones rapidas en lista de compras | E10 | 3 | Pending |
| MEW-037 | Modelo de recetas extendidas | E11 | 8 | Pending |
| MEW-038 | Crear receta personalizada | E11 | 8 | Pending |
| MEW-039 | Formato SER y exportacion de recetas | E11 | 8 | Pending |
| MEW-040 | Importacion de recetas externas | E11 | 10 | Pending |

**Proximo ID disponible:** MEW-041

---

## Vision del Producto

Aplicacion movil que permite a cuidadores de gatos planificar alimentacion casera balanceada de forma segura, generando menus semanales validados, listas de compras y presupuestos, funcionando completamente offline.

---

## Epicas

| Epic | Nombre | Pts | Status | Detalle |
|------|--------|-----|--------|---------|
| E1 | Perfil Nutricional | 10 | Done | [E01](backlog/epics/E01-perfil-nutricional.md) |
| E2 | Catalogo de Recetas | 16 | Done | [E02](backlog/epics/E02-catalogo-recetas.md) |
| E3 | Motor Nutricional | 13 | Done | [E03](backlog/epics/E03-motor-nutricional.md) |
| E4 | Menu Semanal | 13 | Done | [E04](backlog/epics/E04-menu-semanal.md) |
| E5 | Lista de Compras | 8 | Done | [E05](backlog/epics/E05-lista-compras.md) |
| E6 | Presupuesto | 8 | Done | [E06](backlog/epics/E06-presupuesto.md) |
| E7 | Bugs y Mejoras | 2 | En progreso | [E07](backlog/epics/E07-bugs-mejoras.md) |
| E8 | UX y Explicabilidad | 29 | En progreso | [E08](backlog/epics/E08-ux-explicabilidad.md) |
| E9 | Exportacion y Compartir | 21 | Planificado | [E09](backlog/epics/E09-exportacion-compartir.md) |
| E10 | Funcionalidades Avanzadas | 23 | Planificado | [E10](backlog/epics/E10-funcionalidades-avanzadas.md) |
| E11 | Recetas Personalizadas | 34 | Futuro | [E11](backlog/epics/E11-recetas-personalizadas.md) |

---

## Progreso

| Version | Pts Total | Pts Done | Status |
|---------|-----------|----------|--------|
| MVP (E1-E6) | 68 | 68 | COMPLETADO |
| v1.1 (E7-E8) | 31 | 26 | En progreso |
| v1.2 (E9 parcial) | 16 | 0 | Planificado |
| v1.3 (E9 parcial + E10) | 28 | 0 | Planificado |
| v2.0 (E11) | 34 | 0 | Futuro |
| **Total** | **177** | **79** | |

---

## Roadmap

### v1.1: UX y Explicabilidad (en progreso)

| ID | Historia | Pts | Status | Detalle |
|----|----------|-----|--------|---------|
| MEW-018 | Fix SnackBar | 2 | Done | [story](backlog/stories/MEW-018-fix-snackbar.md) |
| MEW-022 | Badge seguridad | 3 | Done | [story](backlog/stories/MEW-022-badge-seguridad.md) |
| MEW-023 | Errores accionables | 5 | Done | [story](backlog/stories/MEW-023-errores-accionables.md) |
| MEW-024 | Alertas valores atipicos | 3 | Done | [story](backlog/stories/MEW-024-alertas-valores-atipicos.md) |
| MEW-025 | Score nutricional | 5 | Pending | [story](backlog/stories/MEW-025-score-nutricional.md) |
| MEW-026 | Indicador completitud | 2 | Done | [story](backlog/stories/MEW-026-indicador-completitud.md) |
| **Subtotal pendiente** | | **5** | | |

### v1.2: Exportacion y Mejoras

| ID | Historia | Pts | Status | Detalle |
|----|----------|-----|--------|---------|
| MEW-027 | Exportar lista compras | 5 | Pending | [story](backlog/stories/MEW-027-exportar-lista-compras.md) |
| MEW-028 | Modo compra real | 3 | Pending | [story](backlog/stories/MEW-028-modo-compra-real.md) |
| MEW-029 | Historico precios | 5 | Pending | [story](backlog/stories/MEW-029-historico-precios.md) |
| MEW-030 | Costo por comida | 3 | Pending | [story](backlog/stories/MEW-030-costo-por-comida.md) |
| **Subtotal** | | **16** | | |

### v1.3: Funcionalidades Avanzadas

| ID | Historia | Pts | Status | Detalle |
|----|----------|-----|--------|---------|
| MEW-031 | Compartir menu | 5 | Pending | [story](backlog/stories/MEW-031-compartir-menu.md) |
| MEW-032 | Info por gato | 5 | Pending | [story](backlog/stories/MEW-032-info-individual-gato.md) |
| MEW-033 | Modo avanzado | 5 | Pending | [story](backlog/stories/MEW-033-modo-usuario-avanzado.md) |
| MEW-034 | Simulaciones | 5 | Pending | [story](backlog/stories/MEW-034-simulaciones-hipoteticas.md) |
| MEW-035 | Sugerencias correccion | 5 | Pending | [story](backlog/stories/MEW-035-sugerencias-correccion.md) |
| MEW-036 | Sustituciones rapidas | 3 | Pending | [story](backlog/stories/MEW-036-sustituciones-rapidas.md) |
| **Subtotal** | | **28** | | |

### v2.0: Recetas Personalizadas

| ID | Historia | Pts | Status | Detalle |
|----|----------|-----|--------|---------|
| MEW-037 | Modelo recetas extendidas | 8 | Pending | [story](backlog/stories/MEW-037-modelo-recetas-extendidas.md) |
| MEW-038 | Crear receta personalizada | 8 | Pending | [story](backlog/stories/MEW-038-crear-receta-personalizada.md) |
| MEW-039 | Formato SER exportacion | 8 | Pending | [story](backlog/stories/MEW-039-formato-ser-exportacion.md) |
| MEW-040 | Importacion recetas | 10 | Pending | [story](backlog/stories/MEW-040-importacion-recetas.md) |
| **Subtotal** | | **34** | | |

---

## Dependencias Clave

```
MEW-022, MEW-023 --> Dependen de ValidationService existente
MEW-025 --> Depende de validaciones (MEW-022/023)
MEW-029 --> Nueva tabla price_history (migracion)
MEW-032 --> Nueva tabla cats (migracion)
MEW-033 --> Base para MEW-034, MEW-035, MEW-036
MEW-037 --> Base para MEW-038, MEW-039, MEW-040
MEW-040 --> Depende de MEW-039 (formato SER)
```

---

## Archivos

| Tipo | Ubicacion |
|------|-----------|
| Stories pendientes | `backlog/stories/MEW-XXX-*.md` |
| Epics | `backlog/epics/EXX-*.md` |
| Historias completadas | `backlog/archive/2026-Q1-mvp-completed.md` |

---

**Ultima actualizacion:** 2026-02-05
**Proximo ID disponible:** MEW-041
