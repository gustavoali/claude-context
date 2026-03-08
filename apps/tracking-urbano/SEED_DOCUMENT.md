# Seed Document - Tracking Urbano de Activos

**Fuente:** Proyectos_IoT_Seguridad_Tracking_Urbano.pdf
**Fecha:** 2026-03-01

---

## Resumen Ejecutivo

Dos proyectos IoT evaluados. El tracking urbano se identifica como el de mayor potencial comercial.

### 1. Proyecto LoRaWAN + Drones (Agricultura)
- Red de sensores LoRaWAN en campo con dron como gateway movil
- Ideal para monitoreo rural de humedad, temperatura y riego
- Escalable y de bajo consumo energetico
- Modelo orientado a B2B agro tecnologico

### 2. Proyecto Tracking Urbano de Activos (RECOMENDADO)
- Rastreo de bicicletas, motos, mochilas y objetos urbanos
- El celular no es sistema anti-robo robusto por si solo
- Requiere tracker independiente con bateria propia
- Modelo con mayor potencial comercial en entorno urbano

## Tecnologias Evaluadas

| Tecnologia | Uso ideal | Notas |
|------------|-----------|-------|
| LoRaWAN | Rural | Excelente rango, requiere gateways |
| NB-IoT / LTE-M | Urbano (RECOMENDADO) | Compacto, usa red celular existente |
| 4G tradicional | General | Mas consumo energetico |
| Sigfox | - | Ecosistema limitado actualmente |

## Factor Critico - Bateria
- El tamano final del dispositivo lo define la bateria
- Mayor frecuencia de transmision implica mayor consumo
- Equilibrio entre autonomia y tamano es clave

## Arquitectura Recomendada (Urbano)

### Hardware
- Dispositivo GPS + NB-IoT + bateria interna

### Software
- Backend en .NET 8 con arquitectura event-driven
- Ingesta via MQTT / HTTPS
- Dashboard con mapas, geofencing y alertas

## Conclusion Estrategica
- LoRaWAN es ideal para rural
- NB-IoT es superior para tracking urbano compacto
- Modelo mas prometedor: plataforma de tracking urbano con hardware dedicado + backend inteligente
