# IDEA-026: Construccion de figuras 3D a partir de imagenes, bocetos o dibujos

**Fecha:** 2026-02-21
**Categoria:** general
**Estado:** Seed
**Prioridad:** Sin definir

---

## Descripcion

Servicio o herramienta que toma una imagen, boceto o dibujo (2D) y genera un modelo 3D imprimible o coleccionable. Desde el dibujo de un nene hasta concept art de un artista, convertirlo en una figura fisica.

## Motivacion

Hay una brecha entre la idea visual (dibujo, boceto, foto de personaje) y el objeto fisico. Generar modelos 3D requiere habilidades de modelado (Blender, ZBrush) que la mayoria no tiene. Con IA generativa de modelos 3D y la democratizacion de la impresion 3D, esta brecha se puede cerrar.

## Flujo posible

1. El usuario sube una imagen/boceto/dibujo (puede ser a mano, digital, foto)
2. El sistema genera un modelo 3D a partir de la imagen (IA image-to-3D)
3. El usuario revisa y ajusta (rotacion, escala, detalles)
4. Opciones de salida:
   - Descargar archivo STL/OBJ para imprimir
   - Pedir impresion 3D (servicio incluido)
   - Pedir figura pintada a mano (premium)

## Tecnologias a investigar

- **IA image-to-3D:** OpenAI Shap-E, Stability AI (Stable Zero123), Google DreamFusion, Meshy, Tripo3D
- **Impresion 3D:** FDM (barato, para prototipos), resina SLA (detalle fino, para figuras)
- **Post-procesado:** lijado, pintura, acabado
- **Formatos:** STL, OBJ, GLTF

## Posibles mercados

- **Ninos/familias:** "converti el dibujo de tu hijo en una figura"
- **Gamers/fans:** figuras custom de personajes de juegos, anime, comics
- **Artistas/ilustradores:** materializar sus creaciones en 3D
- **Empresas:** merchandising custom, mascotas corporativas
- **Arquitectura/diseno:** maquetas rapidas desde bocetos

## Modelo de negocio

- **Freemium:** generacion del modelo 3D gratis (con marca de agua), descarga STL paga
- **Servicio completo:** imagen -> modelo -> impresion -> envio
- **Suscripcion:** para artistas/estudios con volumen
- **Marketplace:** vender modelos generados por la comunidad

## Notas

- La calidad de image-to-3D esta mejorando rapidamente, investigar estado del arte actual
- Puede arrancar como servicio manual (modelador + impresora) y automatizar con IA despues
- Vinculacion posible con Gaia Protocol: figuras de unidades/edificios del juego
- Considerar si es emprendimiento fisico (taller de impresion) o 100% digital (solo genera el STL)

## Comentario de Claude

Esta idea tiene un potencial de cruce con varios otros proyectos: las figuras de Gaia Protocol como merchandising, la IDEA-025 de imagen para negocios (un comercio podria querer su mascota en 3D), y hasta Mew Michis (figuras de gatos). Ademas, el pitch "converti el dibujo de tu hijo en una figura" tiene un gancho emocional muy fuerte que practicamente se vende solo. Como MVP rapido, podria ser una landing page + formulario donde la gente sube el dibujo, vos generas el modelo con IA + retoque manual, y lo imprimis en resina. Validas demanda sin invertir en automatizacion.

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-21 | Idea capturada |
