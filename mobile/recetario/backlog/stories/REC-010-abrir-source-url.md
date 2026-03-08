### REC-010: sourceUrl no se puede abrir - TODO pendiente

**Points:** 1 | **Priority:** HIGH | **DoR Level:** L1
**Epic:** EPIC-003 - Mejora de UX/UI

**As a** usuario de Recetario
**I want** poder tocar la URL de origen de una receta importada para abrirla en el navegador
**So that** pueda volver al sitio original para ver fotos, comentarios o detalles adicionales

#### Acceptance Criteria

**AC1: Tap en sourceUrl abre el navegador externo**
- Given que estoy viendo el detalle de una receta que tiene sourceUrl
- When toco la URL de origen mostrada en la pantalla
- Then se abre el navegador predeterminado del dispositivo con esa URL

**AC2: sourceUrl ausente no muestra el elemento**
- Given que estoy viendo el detalle de una receta sin sourceUrl (creada manualmente)
- When observo la pantalla de detalle
- Then no se muestra ninguna seccion de URL de origen

**AC3: Error al abrir URL muestra feedback**
- Given que estoy viendo una receta con sourceUrl invalida o que no se puede abrir
- When toco la URL de origen
- Then se muestra un SnackBar indicando que no se pudo abrir la URL

#### Technical Notes

- Archivo afectado: `lib/features/recipes/presentation/screens/recipe_detail_screen.dart` (linea 338)
- Actualmente tiene `// TODO: Open URL` en el onTap
- Usar paquete `url_launcher` (ya deberia estar en pubspec.yaml)
- Implementar con `launchUrl(Uri.parse(sourceUrl), mode: LaunchMode.externalApplication)`
- Verificar con `canLaunchUrl()` antes de intentar abrir

#### DoD

- [ ] Codigo implementado reemplazando el TODO
- [ ] Manual testing: tocar URL abre navegador
- [ ] Manual testing: receta sin URL no muestra seccion
- [ ] Build 0 warnings
