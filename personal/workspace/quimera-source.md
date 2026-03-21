# Quimera - Plataforma de Entretenimiento AI para Jovenes Argentinos

## Vision

Plataforma unificada de entretenimiento digital generado por inteligencia artificial, dirigida al publico infantil y adolescente argentino. Cuatro productos integrados bajo una sola marca, segmentados por edad, donde cada producto alimenta a los demas y comparten el mismo motor tecnico.

## Problema

- Los productos de entretenimiento AI existentes estan en ingles o son traducciones genericas
- No existe una plataforma que combine contenido generativo para distintas edades en espanol rioplatense
- Los padres argentinos buscan contenido personalizado y seguro para sus hijos pero no encuentran opciones locales
- Los adolescentes argentinos consumen memes y entretenimiento viral pero las herramientas disponibles no reflejan su cultura

## Propuesta de Valor

Entretenimiento personalizado e ilimitado generado por AI, en espanol argentino, seguro para menores, con identidad cultural local. Cada cuento, historia, meme o roast es unico porque se genera para vos.

## Segmentacion por Edad

### Chiquis (4-8 anos)
**Producto: Cuentos Personalizados**
- El nene es el protagonista de la historia
- Input: nombre + edad + tema + personaje favorito
- Output: cuento ilustrado (5-10 paginas) + audio narrado
- Recompra natural: un cuento nuevo cada noche
- Cross-sell: stickers de WhatsApp del personaje del cuento (para mandar a abuelos, tios)

### Pibes (9-13 anos)
**Producto: Historias Interactivas (Choose Your Adventure)**
- Aventura, misterio, ciencia ficcion, fantasia
- El usuario elige decisiones que cambian la trama y el desenlace
- Personaje personalizado (nombre, avatar, habilidades)
- Capitulos diarios, multiples finales, sagas
- Adaptacion argentina: referencias culturales (barrios, modismos, situaciones locales del colegio, club, plaza)
- Cross-sell: memes/stickers de los personajes, compartir finales con amigos

### Adolescentes (14-19 anos)
**Productos: Roasts AI + Memes/Stickers Personalizados**

**Roasts / "La AI te re contra juzga":**
- Input: foto o descripcion de la persona
- Output: roast comico en tono argentino (no americano)
- Variantes: "Tu red flag", "Que dice tu foto de perfil de vos", "Tu personaje de serie"
- Humor argentino: referencias a cumples de 15, colegio, bondi, fernet, asado
- Viralidad: se comparte por WhatsApp/Instagram, cada resultado trae nuevos usuarios

**Memes y Stickers Personalizados:**
- Generador de stickers WhatsApp con tu cara o la de amigos
- Memes con templates argentinos + AI que adapta el texto
- Packs tematicos: colegio, futbol, egresados, feriados argentinos
- Cada pack enviado por WhatsApp es publicidad gratis

## Flujo Viral y Cross-Selling

```
ROAST viral (adolescente lo comparte en grupo de WhatsApp)
  -> Amigos entran a la plataforma
      -> Descubren MEMES/STICKERS -> compran packs
          -> Ven HISTORIAS INTERACTIVAS -> se enganchan
              -> Padre ve que el hijo usa la app
                  -> Descubre CUENTOS para el hermano menor
                      -> Suscripcion familiar
```

Cada producto es puerta de entrada para otro segmento etario. Una familia, tres segmentos, una sola cuenta.

## Modelo de Precios

### Unitarios (MercadoPago, pesos argentinos)
| Producto | Precio | Costo AI | Margen USD |
|----------|--------|----------|------------|
| Cuento ilustrado + audio | ~$1.30 USD | ~$0.10 | ~$1.20 |
| Capitulo historia interactiva | ~$0.45 USD | ~$0.03 | ~$0.42 |
| Pack 10 stickers/memes | ~$0.70 USD | ~$0.10 | ~$0.60 |
| Roast personalizado | ~$0.45 USD | ~$0.02 | ~$0.43 |

### Suscripciones Mensuales
| Plan | Incluye | USD/mes |
|------|---------|---------|
| Chiquis | 30 cuentos + audio + stickers del personaje | ~$7 |
| Pibes | Historias ilimitadas + 5 packs stickers | ~$4.50 |
| Adolescente | Roasts ilimitados + memes + historias | ~$3.50 |
| Familiar | Todo, hasta 4 perfiles | ~$10.50 |

### Path a $50 USD/dia
- Mes 1-2 (solo unitarios): 50 cuentos + 30 roasts + 20 packs memes = ~$55/dia
- Mes 3-6 (mix): 50 suscriptores + 30 unitarios/dia = ~$60/dia
- Mes 6+ (suscripciones): 150 suscriptores familiares = ~$52/dia estable

## Identidad y Tono de Marca

| Aspecto | Enfoque |
|---------|---------|
| Nombre | Quimera (fantasia, imaginacion, criatura mitica) |
| Idioma | Espanol rioplatense (vos, che, modismos argentinos) |
| Humor | Argentino (autoironia, cultura barrial, referencias locales) |
| Personajes | Situaciones de colegio argentino, bondi, plaza, club de barrio |
| Fechas especiales | Dia del nino, dia del amigo, egresados, vacaciones de invierno |
| Templates memes | Cultura AR (Messi, mate, fernet, asado) |
| Tono cuentos | Calido, imaginativo, educativo sin ser didactico |
| Tono historias | Aventurero, misterioso, con giros tipo series |
| Tono roasts | Picante pero no hiriente, humor de grupo de amigos |

## Stack Tecnico Propuesto

### Backend (motor compartido)
- **Framework:** FastAPI (Python) - ideal para AI workloads
- **LLM Service:** Generacion de texto para cuentos, historias, roasts, memes
  - Proveedor principal: Claude API o GPT-4o-mini (costo/calidad)
  - Fallback: Groq (Llama 3.3 70B, gratis para dev)
- **Image Generation:** Ilustraciones, memes, stickers
  - DALL-E 3 o Stable Diffusion (self-hosted para reducir costos)
  - Flux como alternativa
- **TTS Service:** Audio para cuentos
  - Experiencia existente con Narrador TTS
- **PDF Service:** Cuentos descargables
  - fpdf2 o reportlab (experiencia existente)
- **Base de datos:** PostgreSQL en Docker
- **Cache:** Redis para contenido generado frecuente

### Frontend
- **Web App (PWA):** Funciona como app sin publicar en stores inicialmente
  - Framework: Next.js o Astro (SSR para SEO)
  - Mobile-first (la audiencia es 100% mobile)
- **Integracion WhatsApp:** Compartir cuentos, stickers, resultados de roasts
- **Integracion Instagram:** Compartir resultados como stories/posts

### Pagos
- **MercadoPago:** Argentina (principal)
- **Stripe:** Expansion futura a LATAM/global

### Hosting
- Railway o Fly.io: ~$10-15/mes
- Dominio .com.ar: ~$1/mes
- Total fijo: ~$15/mes

## Seguridad y Privacidad (Critico - Audiencia Menor)

### Politicas obligatorias
- No se almacenan fotos de menores en servidores (procesamiento efimero)
- Filtros de contenido por segmento etario (safe mode en LLM e image gen)
- Sin registro de datos personales para menores de 13 (cuenta del padre)
- Moderacion de prompts: lista negra de temas inapropiados
- Compliance con Ley de Proteccion de Datos Personales argentina (25.326)
- Los roasts tienen filtro de tono (picante pero no hiriente, sin bullying)

### Perfiles por edad
- Chiquis: contenido 100% seguro, sin interaccion social directa
- Pibes: interaccion limitada (compartir finales, no chat abierto)
- Adolescentes: mas libertad pero con filtros de contenido

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigacion |
|--------|-------------|---------|-----------|
| Contenido inapropiado generado | Media | Alto | Filtros por segmento, safe mode, moderacion de prompts |
| Costos de image gen suben | Baja | Medio | Stable Diffusion self-hosted como fallback |
| MercadoPago bloquea cuenta | Baja | Alto | Stripe como backup, multiples procesadores |
| Competencia copia | Media | Medio | Tono argentino dificil de copiar desde afuera |
| Padres desconfian de AI + hijos | Alta | Alto | Landing clara, privacidad, sin fotos de menores |
| Inflacion distorsiona precios AR | Alta | Medio | Precios en USD internamente, conversion dinamica |

## Roadmap de Lanzamiento

### Fase 1 - MVP Cuentos + Roasts (Semanas 1-4)
**Cuentos** (motor de retencion):
- Web app: nombre + edad + tema -> cuento ilustrado (3 imagenes)
- Pago unitario via MercadoPago
- Compartir cuento por WhatsApp

**Roasts** (motor viral):
- Web app: descripcion -> roast argentino + imagen compartible
- Pago unitario via MercadoPago
- Compartir resultado en Instagram/WhatsApp

### Fase 2 - Historias + Stickers (Semanas 5-8)
- Historias interactivas con branching
- Generador de stickers WhatsApp
- Perfiles de usuario (biblioteca de cuentos, progreso de historias)
- Audio narrado para cuentos (TTS)

### Fase 3 - Suscripciones + Growth (Mes 3-4)
- Planes de suscripcion (Chiquis, Pibes, Adolescente, Familiar)
- Personajes recurrentes en cuentos
- Sagas y continuaciones en historias
- SEO en espanol para posicionamiento organico

### Fase 4 - Expansion (Mes 5+)
- App nativa (o PWA mejorada)
- Expansion a otros paises LATAM (adaptando modismos)
- Integraciones adicionales (Telegram, Discord)
- Merchandising digital (wallpapers, avatares)

## Metricas de Exito

| Metrica | Meta Mes 1 | Meta Mes 3 | Meta Mes 6 |
|---------|-----------|-----------|-----------|
| Transacciones/dia | 20 | 60 | 100+ |
| Revenue USD/dia | $10 | $30 | $50+ |
| Usuarios registrados | 100 | 500 | 2,000 |
| Suscriptores | 0 | 30 | 150 |
| Tasa de recompra | 15% | 25% | 35% |
| NPS | >30 | >40 | >50 |
