# Gaia Protocol - Seed Document

**Fecha de consolidacion:** 2026-02-21
**Fuentes:** 5 documentos PDF (GDD v1, GDD v2 Extended, TDD Arquitectura, Plan y Backlog, Conversacion Compilada)

---

## 1. Vision General

Gaia Protocol es un juego de estrategia 4X por turnos en mapa hexagonal donde las civilizaciones compiten por influencia, liderazgo cientifico y estabilidad ecologica. El combate militar tradicional es reemplazado por "conquista blanda": calidad de vida, innovacion, resiliencia climatica y poder diplomatico.

El mundo posee limites planetarios modelados de forma sistemica: emisiones de carbono, temperatura media, biodiversidad y estabilidad social global. Ignorar estos limites puede conducir a un colapso climatico y social que implique la derrota colectiva de todos los jugadores.

### Fantasia del Jugador
- Disenar el modelo de desarrollo de una civilizacion moderna
- Equilibrar economia, bienestar social y proteccion ambiental
- Influir en otras naciones mediante acuerdos, ciencia y cultura, no por la fuerza
- Participar en gobernanza global multilateral

---

## 2. Decisiones de Diseno Clave

| Aspecto | Decision |
|---------|----------|
| Mapa | Hexagonal (coordenadas axiales q,r), con biomas y atributos por hex |
| Tema central | Sostenibilidad, ecologia, desarrollo socioeconomico y ciencia |
| Inspiracion | Civilization (estructura 4X, tech tree, distritos), foco verde sin militar |
| Conquista | Influencia blanda (atractividad del modelo de desarrollo) + integracion pacifica |
| Capa global | Sistema climatico global con umbrales y eventos extremos |
| Late game | Consejo Global multilateral con tratados, fondos, sanciones y cooperacion |
| Modo epico | Hibrido (civilizaciones + bloques + multilateral) con epicas configurables |
| Frontend | Unity (C#) para Android |
| Backend | .NET 8 (Clean Architecture) para persistencia y futuro multiplayer |

---

## 3. Stack Tecnologico

- **Frontend/Cliente:** Unity (C#) targeting Android, posible expansion a PC/WebGL
- **Nucleo de Simulacion:** C# compartible entre Unity y backend
- **Backend:** .NET 8 con Clean Architecture (opcional para MVP)
- **Persistencia offline:** JSON/MessagePack (save files locales)
- **Persistencia servidor:** PostgreSQL o SQL Server con EF Core
- **Data-driven:** Biomas, techs, policies en JSON para iterar sin recompilar

---

## 4. Sistemas de Juego

### 4.1 Sistema Economico
Recursos abstractos: Produccion, Alimentos, Ciencia, Cultura, Dinero. Cada hex y ciudad aporta cantidades variables segun atributos, distritos y politicas activas.

### 4.2 Sistema Ecologico y Climatico
- **Global:** CO2 acumulado, temperatura media, nivel del mar, indice de biodiversidad
- **Local:** Polucion e integridad ecologica por hex
- Modelo climatico simplificado: emisiones -> CO2 -> temperatura -> eventos extremos
- Eventos pueden danar infraestructura, reducir productividad, desplazar poblacion

### 4.3 Sistema de Ciencia y Tecnologia
Arbol tecnologico como eje de progresion:
- Energia: Solar, Eolica, Geotermica, Fusion
- Urbanismo: Smart Cities, Transporte Electrico
- Ecologia: Rewilding, Agricultura Regenerativa
- Sociedad: Reforma Educativa, Gobernanza Digital
- Ingenieria Climatica (late game): Captura de Carbono, Geoingenieria

### 4.4 Sistema de Influencia y Soft Power
Calculo periodico de atractivo relativo considerando bienestar, estabilidad, economia, ciencia y ecologia. Se traduce en puntos de influencia que generan cambios pacificos en alineacion territorial.

### 4.5 Sistema Diplomatico y Consejo Global
Se activa en mid/late game. Propuestas: reduccion de emisiones, fondos de transicion, proteccion de biomas, sanciones. Decisiones por votacion ponderada.

### 4.6 Sistema de Epicas
Modulos configurables que ajustan ponderaciones, eventos y condiciones de victoria:
- **Restauracion Planetaria:** clima y biodiversidad
- **Cientifica:** megaproyecto tecnologico
- **Bienestar Social:** salud, educacion, igualdad
- **Diplomatica:** liderazgo en Consejo Global
- **Economica Sostenible:** economia circular
- **Ideologica / Soft Power:** expansion por atraccion

El jugador selecciona una epica principal y opcionalmente una secundaria.

---

## 5. Arquitectura Tecnica

### Principios
- **Determinismo por turno:** misma entrada -> mismo resultado
- **Separacion de concerns:** UI independiente del motor de simulacion
- **Extensibilidad:** epics y sistemas como modulos enchufables
- **Testabilidad:** motor validado con unit tests y escenarios
- **Offline-first para MVP**

### Modos de Despliegue
- **Modo A (MVP):** Unity ejecuta simulacion localmente, save files en dispositivo
- **Modo B (futuro):** Cliente/Servidor, backend ejecuta simulacion y persiste

### Modelo de Dominio
- Game, World, HexTile, Civilization, District/Building, Technology, Policy, Epic, GlobalState, CouncilSession

### Motor de Simulacion por Turnos (orden de ejecucion)
1. Aplicar acciones validadas (build, politicas, investigacion, diplomacia)
2. EconomyEngine: produccion, comercio, recursos, mantenimiento
3. ClimateEngine: emisiones -> CO2 -> temperatura -> eventos
4. EcologyEngine: biodiversidad, reforestacion, degradacion
5. SocialEngine: bienestar, desigualdad, estabilidad, migraciones
6. InfluenceEngine: difusion de influencia, integraciones
7. DiplomacyEngine: resolver votos del Consejo y tratados
8. EpicEngine: efectos de epicas y chequeo de condiciones de victoria
9. Generar TurnSummary para UI/log

### API Propuesta (backend)
- POST /api/games, GET /api/games/{id}, GET /api/games/{id}/map
- POST /api/games/{id}/actions, POST /api/games/{id}/advance
- GET /api/games/{id}/tech, GET /api/games/{id}/council

### Cliente Unity - Estructura
- Assets/Scripts/Core (modelos, utilidades, serializacion)
- Assets/Scripts/Simulation (engines, epics, reglas)
- Assets/Scripts/UI (panels, bindings, navegacion)
- Assets/Scripts/Map (grid, seleccion, overlays, camara)
- Assets/Scripts/Networking (API client, DTOs, sync)
- Assets/Resources (data: biomas, techs, policies en JSON)

---

## 6. Estructura del Mapa

### Hexagonal Grid
- Coordenadas axiales (q, r)
- Biomas: Bosque, Tundra, Desierto, Costa, Selva Tropical, Pradera, Montanoso, Humedal, Isla Volcanica
- Atributos por hex: bioma, uso del suelo, poblacion, indices (economico, ambiental, cientifico, social), polucion, influencia por jugador

### Distritos
Inspirados en Civilization pero con consecuencias ambientales y sociales:
- Campus Verde, Parque de Investigacion, Distrito Industrial, Planta Solar/Eolica, Agricultura Regenerativa, Hub Cultural, Centro de Salud, Puerto Comercial

---

## 7. MVP - Alcance

### Contenido MVP
- Mapa medio (~25x25 hex) con 4-6 biomas
- 3-4 civilizaciones (rasgos distintos + IA simple)
- 10-15 tecnologias, 6-10 distritos, 6-10 politicas
- Sistema climatico basico (CO2, temperatura, 3 tipos de eventos)
- Sistema de influencia (difusion vecinal + integracion con umbral)
- Consejo Global basico (1-2 tipos de tratados)
- Guardado/carga de partida
- 1 epica completa (Restauracion Planetaria)

### Criterios de Aceptacion MVP
- Partida inicia en Android sin crashes, jugable 30-60 turnos
- Jugador puede construir, investigar, aplicar politica y avanzar turno
- Clima responde a emisiones con tendencia visible
- Influencia cambia con el tiempo, produce al menos una integracion pacifica
- Al menos una condicion de victoria o derrota global funcional
- Guardado y carga funcionan correctamente

---

## 8. Milestones y Roadmap

| Milestone | Objetivo |
|-----------|----------|
| M0 | Repo + pipeline + estructura base (Unity + C# core) |
| M1 | Mapa hex render + seleccion + panel de info |
| M2 | Simulacion minima (economia + clima) offline |
| M3 | Acciones del jugador (build, policy, research) + avance de turno |
| M4 | Influencia + integracion pacifica |
| M5 | Consejo Global basico + 1 epica completa (Restauracion) |
| M6 | Balance inicial + UI pulida + build Android jugable end-to-end |

### Sprints Propuestos
| Sprint | Objetivo |
|--------|----------|
| S1 | Fundacion tecnica: repo, estructura Unity, modelos base, hex grid render |
| S2 | Simulacion base: EconomyEngine + ClimateEngine con tests, TurnSummary |
| S3 | Acciones del jugador: distritos + costes + investigacion + avance de turno |
| S4 | Influencia: InfluenceEngine + reglas de integracion + UI overlays |
| S5 | Consejo Global: CouncilSession + 1 tratado + votacion IA + efectos |
| S6 | Epicas y victoria: sistema IEpic + 1 epica + pantalla victoria/derrota |
| S7 | Pulido MVP: guardado/carga, optimizaciones, UI/UX, balance IA vs IA |

---

## 9. Riesgos y Mitigaciones

| Riesgo | Mitigacion |
|--------|-----------|
| Complejidad de simulacion | Empezar con modelos simples, profundidad por capas |
| Balance | Harness de simulacion IA vs IA para ajustar parametros |
| UI en movil | Priorizar legibilidad (zoom, overlays, paneles) y performance |
| Scope creep | MVP cerrado; todo extra va a backlog post-MVP |

---

## 10. Testing y Calidad

- Unit tests para cada engine (inputs conocidos -> outputs esperados)
- Tests de escenarios: seeds controladas, 20-50 turnos, asserts sobre metricas
- Snapshot testing: comparar estado serializado en golden files
- Balance harness: simulaciones automaticas IA vs IA para ajustar parametros

---

## 11. Decisiones Tomadas (Preguntas Resueltas)

| Pregunta | Decision MVP | Evolucion post-MVP |
|----------|-------------|---------------------|
| Mapa | Hibrido: templates base con variacion procedural | - |
| Economia | Tipo Civ: recursos abstractos (produccion, alimentos, ciencia, cultura, dinero) | Estudio de profundizacion de complejidad economica, social, cultural y ambiental |
| Ciudades | Multi-hex tipo Civ: ciudad controla hexes adyacentes con distritos | Estudio de evolucion del modelo de administracion territorial |
| Estilo visual | Minimalista/infografico para MVP | Evolucionar a artistico post-MVP |
