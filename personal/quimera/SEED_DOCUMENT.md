# Quimera - Seed Document
**Fecha:** 2026-03-21
**Fuente:** quimera-business-model.md (brainstorming session)
**Estado:** SEMILLA

## Vision
Plataforma unificada de entretenimiento digital generado por AI, dirigida al publico infantil y adolescente argentino (4-19 anos). Cuatro productos integrados bajo una sola marca, segmentados por edad, con identidad cultural local (espanol rioplatense).

## Problema
- Entretenimiento AI existente: en ingles o traducciones genericas
- No hay plataforma que combine contenido generativo para distintas edades en espanol argentino
- Padres buscan contenido personalizado y seguro, no hay opciones locales
- Adolescentes consumen memes/entretenimiento viral sin reflejo de su cultura

## Propuesta de Valor
Entretenimiento personalizado e ilimitado generado por AI, en espanol argentino, seguro para menores, con identidad cultural local. Cada cuento, historia, meme o roast es unico.

## Productos (4 integrados)

### 1. Cuentos Personalizados (Chiquis, 4-8 anos)
- Protagonista = el nene (nombre + edad + tema + personaje favorito)
- Output: cuento ilustrado (5-10 pags) + audio narrado
- Recompra: un cuento nuevo cada noche
- Cross-sell: stickers WhatsApp del personaje

### 2. Historias Interactivas (Pibes, 9-13 anos)
- Choose Your Adventure: aventura, misterio, sci-fi, fantasia
- Decisiones del usuario cambian trama y desenlace
- Personaje personalizado (nombre, avatar, habilidades)
- Capitulos diarios, multiples finales, sagas
- Cultura AR: barrios, modismos, colegio, club, plaza

### 3. Roasts AI (Adolescentes, 14-19 anos)
- Input: foto o descripcion -> Output: roast comico argentino
- Variantes: "Tu red flag", "Tu personaje de serie", "Que dice tu foto de perfil"
- Humor argentino: cumples de 15, bondi, fernet, colegio
- Motor viral: se comparte por WhatsApp/Instagram

### 4. Memes/Stickers Personalizados (Pibes + Adolescentes, 9-19)
- Stickers WhatsApp con tu cara o la de amigos
- Memes con templates argentinos + AI adapta texto
- Packs tematicos: colegio, futbol, egresados, feriados
- Publicidad gratis: cada pack enviado trae nuevos usuarios

## Flujo Viral Cross-Selling
```
Roast viral (adolescente comparte) -> amigos entran
  -> descubren memes/stickers -> compran packs
    -> ven historias interactivas -> se enganchan
      -> padre descubre cuentos para el hermano menor
        -> suscripcion familiar
```

## Modelo de Precios

### Unitarios
| Producto | Precio USD | Costo AI | Margen |
|----------|-----------|----------|--------|
| Cuento ilustrado + audio | ~$1.30 | ~$0.10 | ~$1.20 |
| Capitulo historia | ~$0.45 | ~$0.03 | ~$0.42 |
| Pack 10 stickers/memes | ~$0.70 | ~$0.10 | ~$0.60 |
| Roast personalizado | ~$0.45 | ~$0.02 | ~$0.43 |

### Suscripciones
| Plan | Incluye | USD/mes |
|------|---------|---------|
| Chiquis | 30 cuentos + audio + stickers | ~$7 |
| Pibes | Historias ilimitadas + 5 packs stickers | ~$4.50 |
| Adolescente | Roasts + memes + historias ilimitados | ~$3.50 |
| Familiar | Todo, hasta 4 perfiles | ~$10.50 |

### Path a $50 USD/dia
- Mes 1-2: 50 cuentos + 30 roasts + 20 packs = ~$55/dia
- Mes 3-6: 50 suscriptores + 30 unitarios/dia = ~$60/dia
- Mes 6+: 150 suscriptores familiares = ~$52/dia estable

## Stack Tecnico

### Backend (motor compartido)
- **Framework:** FastAPI (Python)
- **LLM:** Claude API o GPT-4o-mini (principal), Groq/Llama (fallback dev)
- **Image Gen:** DALL-E 3 o Stable Diffusion (self-hosted para costos)
- **TTS:** Para audio de cuentos (experiencia con Narrador)
- **PDF:** fpdf2 o reportlab (cuentos descargables)
- **DB:** PostgreSQL en Docker
- **Cache:** Redis

### Frontend
- **PWA:** Next.js o Astro (SSR para SEO), mobile-first
- **Integraciones:** WhatsApp (compartir), Instagram (stories)

### Pagos
- MercadoPago (AR principal) + Stripe (expansion)

### Hosting
- Railway o Fly.io: ~$10-15/mes
- Dominio .com.ar: ~$1/mes
- **Total fijo: ~$15/mes**

## Seguridad y Privacidad (Audiencia Menor - CRITICO)
- No almacenar fotos de menores (procesamiento efimero)
- Filtros de contenido por segmento etario
- Sin datos personales de <13 (cuenta del padre)
- Moderacion de prompts (lista negra temas inapropiados)
- Compliance Ley 25.326 (Proteccion Datos Personales AR)
- Roasts con filtro anti-bullying

## Identidad de Marca
- **Nombre:** Quimera
- **Idioma:** Espanol rioplatense (vos, che, modismos)
- **Humor:** Argentino (autoironia, cultura barrial)
- **Tono cuentos:** Calido, imaginativo
- **Tono historias:** Aventurero, misterioso
- **Tono roasts:** Picante pero no hiriente
- **Fechas especiales:** Dia del nino, dia del amigo, egresados, vacaciones de invierno

## Riesgos Principales
| Riesgo | Mitigacion |
|--------|-----------|
| Contenido inapropiado para menores | Filtros por segmento, safe mode, moderacion |
| Costos image gen suben | Stable Diffusion self-hosted como fallback |
| MercadoPago bloquea cuenta | Stripe como backup |
| Padres desconfian de AI + hijos | Landing clara, privacidad, sin fotos de menores |
| Inflacion AR | Precios en USD internamente, conversion dinamica |

## Roadmap
- **Fase 1 (sem 1-4):** MVP Cuentos + Roasts
- **Fase 2 (sem 5-8):** Historias interactivas + Stickers + TTS + Perfiles
- **Fase 3 (mes 3-4):** Suscripciones + Growth + SEO
- **Fase 4 (mes 5+):** App nativa/PWA mejorada + expansion LATAM

## Metricas de Exito
| Metrica | Mes 1 | Mes 3 | Mes 6 |
|---------|-------|-------|-------|
| Transacciones/dia | 20 | 60 | 100+ |
| Revenue USD/dia | $10 | $30 | $50+ |
| Usuarios registrados | 100 | 500 | 2,000 |
| Suscriptores | 0 | 30 | 150 |
