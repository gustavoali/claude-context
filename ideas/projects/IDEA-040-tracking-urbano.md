# IDEA-040: Plataforma de Tracking Urbano de Activos

**Fecha:** 2026-03-01
**Categoria:** projects
**Estado:** Seed
**Prioridad:** Alta

---

## Descripcion

Plataforma de rastreo de bicicletas, motos, mochilas y objetos urbanos con tracker GPS independiente (NB-IoT + bateria propia), backend en .NET 8 event-driven, ingesta MQTT/HTTPS, dashboard con mapas, geofencing y alertas.

## Motivacion

- Mayor potencial comercial en entorno urbano
- El celular no es sistema anti-robo robusto por si solo
- Mercado real con demanda concreta
- Stack .NET 8 alineado con conocimiento existente

## Tecnologias evaluadas

- **NB-IoT / LTE-M:** Mejor opcion urbana, compacto, usa red celular (recomendado)
- **LoRaWAN:** Excelente en rural, requiere gateways
- **4G tradicional:** Mas consumo energetico
- **Sigfox:** Ecosistema limitado

## Arquitectura recomendada

- Dispositivo GPS + NB-IoT + bateria interna
- Backend .NET 8 event-driven
- Ingesta via MQTT / HTTPS
- Dashboard con mapas, geofencing y alertas

## Factor critico

La bateria define el tamano final del dispositivo. Equilibrio entre frecuencia de transmision, autonomia y tamano es clave.

## Proyecto relacionado

- IDEA-002 (Reactivar Tracking App) - puede ser el mismo proyecto evolucionado

## Proyecto asociado

- Path: `C:/apps/tracking-urbano/`
- Repo: gustavoali/tracking-urbano

## Notas

- Documento fuente incluye tambien concepto LoRaWAN+Drones para agro (B2B), guardado en seed document
- Modelo mas prometedor segun analisis: tracking urbano

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-03-01 | Idea registrada desde PDF, proyecto sembrado |
