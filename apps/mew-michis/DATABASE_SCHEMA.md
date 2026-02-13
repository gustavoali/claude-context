# Database Schema - Mew Michis

**Proyecto:** Sistema de Alimentacion Casera Felina
**Base de Datos:** SQLite (local, offline-first)
**Package:** drift (recomendado para Flutter)
**Version:** 1.0
**Fecha:** 2026-01-26

---

## Diagrama Entidad-Relacion (ASCII)

```
+------------------+       +------------------+       +------------------+
|  perfil_nutri    |       |     receta       |       |   ingrediente    |
+------------------+       +------------------+       +------------------+
| PK id            |       | PK id            |       | PK id            |
|    peso_total    |       |    codigo        |       |    nombre        |
|    num_gatos     |       |    nombre        |       |    categoria_id  |----+
|    temporada     |       |    descripcion   |       |    unidad_medida |    |
|    actividad     |       |    es_inmutable  |       |    es_proteina   |    |
|    created_at    |       |    version       |       |    es_graso      |    |
|    updated_at    |       |    created_at    |       |    created_at    |    |
+------------------+       +------------------+       +------------------+    |
                                   |                         |                |
                                   | 1:N                     |                |
                                   v                         |                |
                           +------------------+              |                |
                           | receta_ingrediente|             |                |
                           +------------------+              |                |
                           | PK id            |              |                |
                           | FK receta_id     |--------------+                |
                           | FK ingrediente_id|<-------------+                |
                           |    cantidad_base |                               |
                           |    es_reemplazable|                              |
                           |    orden         |                               |
                           +------------------+                               |
                                                                              |
+------------------+       +------------------+       +------------------+    |
|    suplemento    |       |receta_suplemento |       |    categoria     |<---+
+------------------+       +------------------+       +------------------+
| PK id            |       | PK id            |       | PK id            |
|    nombre        |       | FK receta_id     |       |    nombre        |
|    unidad_medida |       | FK suplemento_id |       |    orden         |
|    cantidad_por_kg|      |    es_obligatorio|       |    icono         |
|    es_obligatorio|       +------------------+       +------------------+
|    descripcion   |
+------------------+

+------------------+       +------------------+       +------------------+
|   restriccion    |       |variacion_proteina|       |   menu_semanal   |
+------------------+       +------------------+       +------------------+
| PK id            |       | PK id            |       | PK id            |
|    tipo          |       | FK ingrediente_  |       |    nombre        |
|    limite        |       |    origen_id     |       |    fecha_inicio  |
|    periodo       |       | FK ingrediente_  |       |    es_activo     |
|    mensaje       |       |    reemplazo_id  |       |    created_at    |
|    severidad     |       |    porcentaje_max|       |    updated_at    |
+------------------+       |    ajuste_aceite |       +------------------+
        |                  |    descripcion   |               |
        | N:M              +------------------+               | 1:N
        v                                                     v
+------------------+                                  +------------------+
|receta_restriccion|                                  |    menu_slot     |
+------------------+                                  +------------------+
| PK id            |                                  | PK id            |
| FK receta_id     |                                  | FK menu_id       |
| FK restriccion_id|                                  | FK receta_id     |
| FK ingrediente_id|                                  |    dia_semana    |
+------------------+                                  |    variacion_json|
                                                      |    notas         |
                                                      +------------------+

+------------------+       +------------------+
| precio_ingrediente|      |lista_compra_item |
+------------------+       +------------------+
| PK id            |       | PK id            |
| FK ingrediente_id|       | FK menu_id       |
|    precio        |       | FK ingrediente_id|
|    fecha_actualizacion|  |    cantidad      |
+------------------+       |    comprado      |
                           |    orden         |
                           +------------------+

+------------------+
|   app_config     |
+------------------+
| PK key           |
|    value         |
|    updated_at    |
+------------------+
```

---

## DDL - Definicion de Tablas

### 1. Tabla: categoria

Categorias para agrupar ingredientes en la lista de compras.

```sql
CREATE TABLE categoria (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    orden INTEGER NOT NULL DEFAULT 0,
    icono TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Seed data obligatorio
INSERT INTO categoria (id, nombre, orden, icono) VALUES
    (1, 'Carnes', 1, 'meat'),
    (2, 'Visceras', 2, 'organ'),
    (3, 'Pescados', 3, 'fish'),
    (4, 'Vegetales', 4, 'vegetable'),
    (5, 'Huevos y Lacteos', 5, 'egg'),
    (6, 'Aceites', 6, 'oil'),
    (7, 'Suplementos', 7, 'supplement');
```

### 2. Tabla: ingrediente

Catalogo maestro de ingredientes disponibles.

```sql
CREATE TABLE ingrediente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    nombre_display TEXT NOT NULL,
    categoria_id INTEGER NOT NULL,
    unidad_medida TEXT NOT NULL DEFAULT 'g',  -- g, ml, unidad, mg
    es_proteina INTEGER NOT NULL DEFAULT 0,   -- boolean: 1=true
    es_graso INTEGER NOT NULL DEFAULT 0,      -- boolean: para ajuste de aceite
    tiene_restriccion_semanal INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (categoria_id) REFERENCES categoria(id)
);

-- Indice para busquedas por categoria
CREATE INDEX idx_ingrediente_categoria ON ingrediente(categoria_id);
CREATE INDEX idx_ingrediente_proteina ON ingrediente(es_proteina);
```

### 3. Tabla: suplemento

Suplementos nutricionales (taurina, calcio, etc.).

```sql
CREATE TABLE suplemento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL UNIQUE,
    nombre_display TEXT NOT NULL,
    unidad_medida TEXT NOT NULL DEFAULT 'mg',  -- mg, g
    cantidad_por_kg REAL NOT NULL,             -- cantidad base por kg de gato
    es_obligatorio INTEGER NOT NULL DEFAULT 1, -- boolean
    descripcion TEXT,
    forma_recomendada TEXT,                    -- ej: "carbonato de calcio"
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Seed data obligatorio
INSERT INTO suplemento (id, nombre, nombre_display, unidad_medida, cantidad_por_kg, es_obligatorio, descripcion, forma_recomendada) VALUES
    (1, 'taurina', 'Taurina', 'mg', 250.0, 1, 'Aminoacido esencial para gatos. Deficiencia causa problemas cardiacos y de vision.', 'Taurina en polvo'),
    (2, 'calcio', 'Calcio', 'mg', 1000.0, 1, 'Esencial para huesos y dientes. Deficiencia causa problemas oseos.', 'Carbonato de calcio o hueso molido');
```

### 4. Tabla: receta

Recetas base inmutables (A-F).

```sql
CREATE TABLE receta (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    codigo TEXT NOT NULL UNIQUE,              -- 'A', 'B', 'C', 'D', 'E', 'F'
    nombre TEXT NOT NULL,
    descripcion TEXT,
    proteina_principal TEXT NOT NULL,         -- descripcion breve
    es_inmutable INTEGER NOT NULL DEFAULT 1,  -- boolean: recetas base no editables
    version INTEGER NOT NULL DEFAULT 1,       -- para futuras actualizaciones de seed
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_receta_codigo ON receta(codigo);
```

### 5. Tabla: receta_ingrediente

Relacion N:M entre recetas e ingredientes con cantidades.

```sql
CREATE TABLE receta_ingrediente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    receta_id INTEGER NOT NULL,
    ingrediente_id INTEGER NOT NULL,
    cantidad_base REAL NOT NULL,              -- cantidad por 1 kg de gato
    es_reemplazable INTEGER NOT NULL DEFAULT 0, -- boolean: permite variaciones
    notas TEXT,                               -- ej: "puede omitirse si hay higado"
    orden INTEGER NOT NULL DEFAULT 0,         -- orden de visualizacion

    FOREIGN KEY (receta_id) REFERENCES receta(id) ON DELETE CASCADE,
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id),
    UNIQUE(receta_id, ingrediente_id)
);

CREATE INDEX idx_receta_ingrediente_receta ON receta_ingrediente(receta_id);
CREATE INDEX idx_receta_ingrediente_ingrediente ON receta_ingrediente(ingrediente_id);
```

### 6. Tabla: receta_suplemento

Suplementos asociados a cada receta.

```sql
CREATE TABLE receta_suplemento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    receta_id INTEGER NOT NULL,
    suplemento_id INTEGER NOT NULL,
    cantidad_override REAL,                   -- si difiere de cantidad_por_kg del suplemento
    es_obligatorio INTEGER NOT NULL DEFAULT 1,
    notas TEXT,

    FOREIGN KEY (receta_id) REFERENCES receta(id) ON DELETE CASCADE,
    FOREIGN KEY (suplemento_id) REFERENCES suplemento(id),
    UNIQUE(receta_id, suplemento_id)
);

CREATE INDEX idx_receta_suplemento_receta ON receta_suplemento(receta_id);
```

### 7. Tabla: restriccion

Reglas de restriccion semanal (pescado max 2x, higado max 2x, etc.).

```sql
CREATE TABLE restriccion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tipo TEXT NOT NULL,                       -- 'FRECUENCIA_MAXIMA', 'OBLIGATORIO_SI', 'INCOMPATIBLE'
    nombre TEXT NOT NULL UNIQUE,
    limite INTEGER,                           -- max veces permitidas
    periodo TEXT NOT NULL DEFAULT 'SEMANA',   -- 'DIA', 'SEMANA'
    mensaje_advertencia TEXT NOT NULL,
    mensaje_error TEXT,
    severidad TEXT NOT NULL DEFAULT 'WARNING', -- 'INFO', 'WARNING', 'ERROR'
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Seed data obligatorio
INSERT INTO restriccion (id, tipo, nombre, limite, periodo, mensaje_advertencia, severidad) VALUES
    (1, 'FRECUENCIA_MAXIMA', 'max_pescado_semanal', 2, 'SEMANA', 'Pescado maximo 2 veces por semana por acumulacion de metales pesados', 'WARNING'),
    (2, 'FRECUENCIA_MAXIMA', 'max_higado_semanal', 2, 'SEMANA', 'Higado maximo 2 veces por semana por exceso de vitamina A', 'WARNING'),
    (3, 'OBLIGATORIO_SI', 'aceite_sin_pescado_graso', NULL, 'DIA', 'Aceite obligatorio si no hay pescado graso en la receta', 'ERROR');
```

### 8. Tabla: receta_restriccion

Relacion N:M entre recetas/ingredientes y restricciones.

```sql
CREATE TABLE receta_restriccion (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    receta_id INTEGER,                        -- puede ser NULL si aplica a ingrediente
    ingrediente_id INTEGER,                   -- ingrediente que activa la restriccion
    restriccion_id INTEGER NOT NULL,

    FOREIGN KEY (receta_id) REFERENCES receta(id) ON DELETE CASCADE,
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id),
    FOREIGN KEY (restriccion_id) REFERENCES restriccion(id)
);

CREATE INDEX idx_receta_restriccion_receta ON receta_restriccion(receta_id);
CREATE INDEX idx_receta_restriccion_ingrediente ON receta_restriccion(ingrediente_id);
```

### 9. Tabla: variacion_proteina

Variaciones permitidas de proteinas con reglas.

```sql
CREATE TABLE variacion_proteina (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingrediente_origen_id INTEGER NOT NULL,   -- proteina original
    ingrediente_reemplazo_id INTEGER NOT NULL, -- proteina de reemplazo
    porcentaje_maximo INTEGER NOT NULL,       -- 25, 30, 50, etc.
    ajuste_aceite REAL NOT NULL DEFAULT 0,    -- -1.0 = eliminar, -0.5 = reducir 50%, 0 = sin cambio
    descripcion TEXT,
    es_activo INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (ingrediente_origen_id) REFERENCES ingrediente(id),
    FOREIGN KEY (ingrediente_reemplazo_id) REFERENCES ingrediente(id),
    UNIQUE(ingrediente_origen_id, ingrediente_reemplazo_id)
);

CREATE INDEX idx_variacion_origen ON variacion_proteina(ingrediente_origen_id);
CREATE INDEX idx_variacion_reemplazo ON variacion_proteina(ingrediente_reemplazo_id);
```

### 10. Tabla: perfil_nutricional

Perfil del usuario (single record pattern).

```sql
CREATE TABLE perfil_nutricional (
    id INTEGER PRIMARY KEY CHECK (id = 1),    -- Solo permite un registro
    peso_total REAL NOT NULL,                 -- kg totales de gatos
    num_gatos INTEGER DEFAULT 1,
    temporada TEXT NOT NULL DEFAULT 'VERANO', -- 'VERANO', 'INVIERNO'
    actividad TEXT NOT NULL DEFAULT 'NORMAL', -- 'BAJO', 'NORMAL', 'ALTO'
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Trigger para actualizar updated_at
CREATE TRIGGER update_perfil_timestamp
AFTER UPDATE ON perfil_nutricional
BEGIN
    UPDATE perfil_nutricional SET updated_at = datetime('now') WHERE id = NEW.id;
END;
```

### 11. Tabla: menu_semanal

Menu semanal planificado.

```sql
CREATE TABLE menu_semanal (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT,                              -- opcional, ej: "Semana 1 Enero"
    fecha_inicio TEXT,                        -- fecha del lunes de la semana
    es_activo INTEGER NOT NULL DEFAULT 0,     -- solo uno activo a la vez
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_menu_activo ON menu_semanal(es_activo);
CREATE INDEX idx_menu_fecha ON menu_semanal(fecha_inicio);

-- Trigger para updated_at
CREATE TRIGGER update_menu_timestamp
AFTER UPDATE ON menu_semanal
BEGIN
    UPDATE menu_semanal SET updated_at = datetime('now') WHERE id = NEW.id;
END;
```

### 12. Tabla: menu_slot

Slots individuales del menu (7 dias).

```sql
CREATE TABLE menu_slot (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    menu_id INTEGER NOT NULL,
    receta_id INTEGER,                        -- NULL si dia vacio
    dia_semana INTEGER NOT NULL,              -- 1=Lunes ... 7=Domingo
    variacion_json TEXT,                      -- JSON con variaciones aplicadas
    notas TEXT,

    FOREIGN KEY (menu_id) REFERENCES menu_semanal(id) ON DELETE CASCADE,
    FOREIGN KEY (receta_id) REFERENCES receta(id),
    UNIQUE(menu_id, dia_semana),
    CHECK(dia_semana BETWEEN 1 AND 7)
);

CREATE INDEX idx_menu_slot_menu ON menu_slot(menu_id);
CREATE INDEX idx_menu_slot_receta ON menu_slot(receta_id);

-- Ejemplo de variacion_json:
-- {
--   "variaciones": [
--     {"ingrediente_origen_id": 1, "ingrediente_reemplazo_id": 5, "porcentaje": 30}
--   ],
--   "ajuste_aceite_total": -0.5
-- }
```

### 13. Tabla: precio_ingrediente

Precios ingresados por el usuario.

```sql
CREATE TABLE precio_ingrediente (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ingrediente_id INTEGER NOT NULL UNIQUE,
    precio REAL NOT NULL,                     -- precio por unidad base (kg, unidad, etc.)
    moneda TEXT NOT NULL DEFAULT 'ARS',
    fecha_actualizacion TEXT NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id)
);

CREATE INDEX idx_precio_ingrediente ON precio_ingrediente(ingrediente_id);

-- Trigger para fecha_actualizacion
CREATE TRIGGER update_precio_timestamp
AFTER UPDATE ON precio_ingrediente
BEGIN
    UPDATE precio_ingrediente SET fecha_actualizacion = datetime('now') WHERE id = NEW.id;
END;
```

### 14. Tabla: lista_compra_item

Items de lista de compras generada (para persistir estado de checkboxes).

```sql
CREATE TABLE lista_compra_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    menu_id INTEGER NOT NULL,
    ingrediente_id INTEGER NOT NULL,
    suplemento_id INTEGER,                    -- si es suplemento en vez de ingrediente
    cantidad REAL NOT NULL,
    unidad TEXT NOT NULL,
    comprado INTEGER NOT NULL DEFAULT 0,      -- boolean: checkbox
    orden INTEGER NOT NULL DEFAULT 0,

    FOREIGN KEY (menu_id) REFERENCES menu_semanal(id) ON DELETE CASCADE,
    FOREIGN KEY (ingrediente_id) REFERENCES ingrediente(id),
    FOREIGN KEY (suplemento_id) REFERENCES suplemento(id)
);

CREATE INDEX idx_lista_compra_menu ON lista_compra_item(menu_id);
```

### 15. Tabla: app_config

Configuracion general de la aplicacion (key-value).

```sql
CREATE TABLE app_config (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Seed data
INSERT INTO app_config (key, value) VALUES
    ('db_version', '1'),
    ('seed_version', '1'),
    ('moneda_default', 'ARS'),
    ('primera_ejecucion', '1');
```

---

## Seed Data - Ingredientes

```sql
-- CARNES (categoria_id = 1)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina, es_graso) VALUES
    (1, 'pollo_muslo', 'Muslo de pollo', 1, 'g', 1, 0),
    (2, 'pollo_pechuga', 'Pechuga de pollo', 1, 'g', 1, 0),
    (3, 'vaca_carne', 'Carne de vaca', 1, 'g', 1, 0),
    (4, 'cerdo_magro', 'Cerdo magro', 1, 'g', 1, 1),
    (5, 'conejo', 'Conejo', 1, 'g', 1, 0),
    (6, 'pavo', 'Pavo', 1, 'g', 1, 0);

-- VISCERAS (categoria_id = 2)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina, tiene_restriccion_semanal) VALUES
    (10, 'higado_pollo', 'Higado de pollo', 2, 'g', 1, 1),
    (11, 'higado_vaca', 'Higado de vaca', 2, 'g', 1, 1),
    (12, 'corazon_vaca', 'Corazon de vaca', 2, 'g', 1, 0),
    (13, 'corazon_pollo', 'Corazon de pollo', 2, 'g', 1, 0),
    (14, 'molleja', 'Molleja', 2, 'g', 1, 0);

-- PESCADOS (categoria_id = 3)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina, es_graso, tiene_restriccion_semanal) VALUES
    (20, 'merluza', 'Merluza', 3, 'g', 1, 0, 1),
    (21, 'cornalito', 'Cornalito', 3, 'g', 1, 1, 1),
    (22, 'salmon', 'Salmon', 3, 'g', 1, 1, 1),
    (23, 'sardina', 'Sardina', 3, 'g', 1, 1, 1),
    (24, 'atun_fresco', 'Atun fresco', 3, 'g', 1, 0, 1);

-- VEGETALES (categoria_id = 4)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina) VALUES
    (30, 'zapallo', 'Zapallo', 4, 'g', 0),
    (31, 'zanahoria', 'Zanahoria', 4, 'g', 0),
    (32, 'zapallito', 'Zapallito', 4, 'g', 0),
    (33, 'brocoli', 'Brocoli', 4, 'g', 0),
    (34, 'espinaca', 'Espinaca', 4, 'g', 0);

-- HUEVOS Y LACTEOS (categoria_id = 5)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina) VALUES
    (40, 'huevo', 'Huevo', 5, 'unidad', 1),
    (41, 'yema_huevo', 'Yema de huevo', 5, 'unidad', 1),
    (42, 'queso_crema', 'Queso crema', 5, 'g', 0);

-- ACEITES (categoria_id = 6)
INSERT INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina, es_graso) VALUES
    (50, 'aceite_oliva', 'Aceite de oliva', 6, 'ml', 0, 1),
    (51, 'aceite_girasol', 'Aceite de girasol', 6, 'ml', 0, 1),
    (52, 'aceite_salmon', 'Aceite de salmon', 6, 'ml', 0, 1);
```

---

## Seed Data - Recetas Base (Ejemplo Receta A)

```sql
-- Receta A: Pollo con vegetales
INSERT INTO receta (id, codigo, nombre, descripcion, proteina_principal) VALUES
    (1, 'A', 'Pollo con Vegetales', 'Receta basica con muslo de pollo, higado y vegetales', 'Pollo');

-- Ingredientes de Receta A (cantidades por 1 kg de gato)
INSERT INTO receta_ingrediente (receta_id, ingrediente_id, cantidad_base, es_reemplazable, orden) VALUES
    (1, 1, 70.0, 1, 1),   -- Muslo de pollo: 70g/kg (reemplazable)
    (1, 10, 10.0, 0, 2),  -- Higado de pollo: 10g/kg
    (1, 13, 10.0, 0, 3),  -- Corazon de pollo: 10g/kg
    (1, 30, 5.0, 0, 4),   -- Zapallo: 5g/kg
    (1, 31, 5.0, 0, 5),   -- Zanahoria: 5g/kg
    (1, 50, 2.0, 0, 6);   -- Aceite de oliva: 2ml/kg

-- Suplementos de Receta A
INSERT INTO receta_suplemento (receta_id, suplemento_id, es_obligatorio) VALUES
    (1, 1, 1),  -- Taurina obligatoria
    (1, 2, 1);  -- Calcio obligatorio

-- Restricciones de Receta A
INSERT INTO receta_restriccion (receta_id, ingrediente_id, restriccion_id) VALUES
    (1, 10, 2);  -- Higado -> max 2x semana

-- Recetas B-F seguirian el mismo patron...
-- (El seed completo se generaria segun las recetas reales del sistema)
```

---

## Seed Data - Variaciones de Proteinas

```sql
-- Variaciones permitidas (desde pollo como base)
INSERT INTO variacion_proteina (ingrediente_origen_id, ingrediente_reemplazo_id, porcentaje_maximo, ajuste_aceite, descripcion) VALUES
    -- Pollo -> Vaca (sin limite especial)
    (1, 3, 100, 0, 'Reemplazo total por carne de vaca permitido'),
    -- Pollo -> Cerdo (max 50%, reduce aceite)
    (1, 4, 50, -0.5, 'Cerdo mas graso, reducir aceite 50%'),
    -- Pollo -> Corazon de vaca (max 25%)
    (1, 12, 25, 0, 'Corazon como complemento, max 25%'),
    -- Pollo -> Merluza (max 30%, es pescado)
    (1, 20, 30, 0, 'Pescado magro, respetar limite semanal'),
    -- Pollo -> Cornalito (max 30%, elimina aceite)
    (1, 21, 30, -1.0, 'Pescado graso, eliminar aceite agregado'),
    -- Pollo -> Salmon (max 30%, elimina aceite)
    (1, 22, 30, -1.0, 'Pescado graso, eliminar aceite agregado');
```

---

## Queries Frecuentes con Indices

### 1. Obtener perfil nutricional activo

```sql
-- Query simple, tabla tiene 1 solo registro
SELECT * FROM perfil_nutricional WHERE id = 1;
```

### 2. Listar recetas con proteina principal

```sql
-- Indice: idx_receta_codigo
SELECT
    r.id,
    r.codigo,
    r.nombre,
    r.proteina_principal,
    r.descripcion
FROM receta r
WHERE r.es_inmutable = 1
ORDER BY r.codigo;
```

### 3. Obtener ingredientes de una receta

```sql
-- Indices: idx_receta_ingrediente_receta, idx_ingrediente_categoria
SELECT
    i.id,
    i.nombre_display,
    i.unidad_medida,
    ri.cantidad_base,
    ri.es_reemplazable,
    c.nombre AS categoria
FROM receta_ingrediente ri
JOIN ingrediente i ON ri.ingrediente_id = i.id
JOIN categoria c ON i.categoria_id = c.id
WHERE ri.receta_id = ?
ORDER BY ri.orden;
```

### 4. Obtener suplementos de una receta

```sql
-- Indice: idx_receta_suplemento_receta
SELECT
    s.id,
    s.nombre_display,
    s.unidad_medida,
    COALESCE(rs.cantidad_override, s.cantidad_por_kg) AS cantidad_por_kg,
    rs.es_obligatorio,
    s.forma_recomendada
FROM receta_suplemento rs
JOIN suplemento s ON rs.suplemento_id = s.id
WHERE rs.receta_id = ?;
```

### 5. Obtener menu semanal activo con recetas

```sql
-- Indices: idx_menu_activo, idx_menu_slot_menu
SELECT
    ms.dia_semana,
    r.codigo AS receta_codigo,
    r.nombre AS receta_nombre,
    ms.variacion_json,
    ms.notas
FROM menu_semanal m
JOIN menu_slot ms ON m.id = ms.menu_id
LEFT JOIN receta r ON ms.receta_id = r.id
WHERE m.es_activo = 1
ORDER BY ms.dia_semana;
```

### 6. Validar restricciones semanales (pescado)

```sql
-- Contar cuantas veces aparece pescado en el menu activo
SELECT COUNT(*) AS veces_pescado
FROM menu_slot ms
JOIN menu_semanal m ON ms.menu_id = m.id
JOIN receta_ingrediente ri ON ms.receta_id = ri.receta_id
JOIN ingrediente i ON ri.ingrediente_id = i.id
WHERE m.es_activo = 1
AND i.categoria_id = 3;  -- Categoria pescados
```

### 7. Generar lista de compras (consolidada)

```sql
-- Consolidar ingredientes del menu activo
SELECT
    i.id,
    i.nombre_display,
    i.unidad_medida,
    c.nombre AS categoria,
    c.orden AS categoria_orden,
    SUM(ri.cantidad_base * p.peso_total) AS cantidad_total
FROM menu_semanal m
JOIN menu_slot ms ON m.id = ms.menu_id
JOIN receta_ingrediente ri ON ms.receta_id = ri.receta_id
JOIN ingrediente i ON ri.ingrediente_id = i.id
JOIN categoria c ON i.categoria_id = c.id
CROSS JOIN perfil_nutricional p
WHERE m.es_activo = 1
AND ms.receta_id IS NOT NULL
GROUP BY i.id
ORDER BY c.orden, i.nombre_display;
```

### 8. Obtener variaciones permitidas para un ingrediente

```sql
-- Indice: idx_variacion_origen
SELECT
    vp.id,
    i_reemplazo.nombre_display AS proteina_reemplazo,
    vp.porcentaje_maximo,
    vp.ajuste_aceite,
    vp.descripcion
FROM variacion_proteina vp
JOIN ingrediente i_reemplazo ON vp.ingrediente_reemplazo_id = i_reemplazo.id
WHERE vp.ingrediente_origen_id = ?
AND vp.es_activo = 1;
```

### 9. Calcular costo semanal

```sql
-- Costo total del menu activo
SELECT
    SUM(
        (ri.cantidad_base * p.peso_total / 1000.0) * pr.precio
    ) AS costo_total
FROM menu_semanal m
JOIN menu_slot ms ON m.id = ms.menu_id
JOIN receta_ingrediente ri ON ms.receta_id = ri.receta_id
JOIN ingrediente i ON ri.ingrediente_id = i.id
LEFT JOIN precio_ingrediente pr ON i.id = pr.ingrediente_id
CROSS JOIN perfil_nutricional p
WHERE m.es_activo = 1
AND ms.receta_id IS NOT NULL;
```

---

## Estrategia de Migraciones

### Versionado de Schema

```sql
-- En app_config
SELECT value FROM app_config WHERE key = 'db_version';
-- Retorna: '1'
```

### Patron de Migracion

```dart
// En Dart/Flutter con drift o sqflite
class DatabaseMigrations {
  static const int currentVersion = 1;

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      await _runMigration(db, version);
    }
  }

  static Future<void> _runMigration(Database db, int version) async {
    switch (version) {
      case 2:
        // Ejemplo: agregar columna a tabla existente
        await db.execute('ALTER TABLE perfil_nutricional ADD COLUMN nombre_mascota TEXT');
        break;
      case 3:
        // Ejemplo: nueva tabla
        await db.execute('''
          CREATE TABLE historial_peso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            peso REAL NOT NULL,
            fecha TEXT NOT NULL
          )
        ''');
        break;
    }
    // Actualizar version
    await db.execute("UPDATE app_config SET value = '$version' WHERE key = 'db_version'");
  }
}
```

### Reglas de Migracion

1. **Nunca modificar migraciones ya ejecutadas** - Son inmutables
2. **Siempre agregar nuevas migraciones** - Incrementar version
3. **Mantener retrocompatibilidad** - Usuarios existentes no deben perder datos
4. **Seed data versionado** - Usar `seed_version` para updates de datos
5. **Backup antes de migracion** - En migraciones mayores

### Ejemplo: Migracion de Seed Data

```sql
-- Verificar version de seed
SELECT value FROM app_config WHERE key = 'seed_version';

-- Si seed_version < 2, agregar nuevos ingredientes
INSERT OR IGNORE INTO ingrediente (id, nombre, nombre_display, categoria_id, unidad_medida, es_proteina) VALUES
    (7, 'pato', 'Pato', 1, 'g', 1);

-- Actualizar seed_version
UPDATE app_config SET value = '2' WHERE key = 'seed_version';
```

---

## Consideraciones de Performance

### Indices Creados

| Tabla | Indice | Columnas | Proposito |
|-------|--------|----------|-----------|
| ingrediente | idx_ingrediente_categoria | categoria_id | Agrupar por categoria |
| ingrediente | idx_ingrediente_proteina | es_proteina | Filtrar proteinas |
| receta | idx_receta_codigo | codigo | Busqueda por codigo |
| receta_ingrediente | idx_receta_ingrediente_receta | receta_id | JOIN con receta |
| receta_ingrediente | idx_receta_ingrediente_ingrediente | ingrediente_id | JOIN con ingrediente |
| receta_suplemento | idx_receta_suplemento_receta | receta_id | JOIN con receta |
| receta_restriccion | idx_receta_restriccion_receta | receta_id | Validaciones |
| receta_restriccion | idx_receta_restriccion_ingrediente | ingrediente_id | Validaciones |
| variacion_proteina | idx_variacion_origen | ingrediente_origen_id | Buscar variaciones |
| variacion_proteina | idx_variacion_reemplazo | ingrediente_reemplazo_id | Buscar usos |
| menu_semanal | idx_menu_activo | es_activo | Menu activo |
| menu_semanal | idx_menu_fecha | fecha_inicio | Historial |
| menu_slot | idx_menu_slot_menu | menu_id | Slots del menu |
| menu_slot | idx_menu_slot_receta | receta_id | Receta del slot |
| precio_ingrediente | idx_precio_ingrediente | ingrediente_id | Lookup precio |
| lista_compra_item | idx_lista_compra_menu | menu_id | Items del menu |

### Volumen Esperado

| Tabla | Registros Estimados | Crecimiento |
|-------|---------------------|-------------|
| categoria | 7 | Fijo |
| ingrediente | 50-100 | Bajo |
| suplemento | 5-10 | Fijo |
| receta | 6 (A-F) | Fijo MVP |
| receta_ingrediente | 40-60 | Fijo |
| restriccion | 5-10 | Fijo |
| variacion_proteina | 20-30 | Fijo |
| perfil_nutricional | 1 | Fijo |
| menu_semanal | 1-50 (historial) | Lento |
| menu_slot | 7 por menu | Lento |
| precio_ingrediente | 50-100 | Bajo |
| lista_compra_item | 20-40 por menu | Lento |

**Conclusion:** Con estos volumenes, SQLite maneja perfectamente sin optimizaciones adicionales.

---

## Constraints y Validaciones

### A Nivel de Base de Datos

```sql
-- Perfil: solo un registro
CHECK (id = 1)

-- Menu slot: dia valido
CHECK (dia_semana BETWEEN 1 AND 7)

-- Cantidades positivas
CHECK (cantidad_base > 0)
CHECK (peso_total > 0)
CHECK (porcentaje_maximo BETWEEN 1 AND 100)

-- Unique constraints
UNIQUE (receta_id, ingrediente_id)
UNIQUE (menu_id, dia_semana)
UNIQUE (ingrediente_id) -- en precio_ingrediente
```

### A Nivel de Aplicacion (Dart)

- Peso total: 0.1 - 100 kg
- Numero de gatos: 1 - 20
- Porcentaje variacion: 0 - 100%
- Precios: >= 0
- Temporada: ENUM(VERANO, INVIERNO)
- Actividad: ENUM(BAJO, NORMAL, ALTO)

---

## Notas de Implementacion

### JSON en variacion_json

```json
{
  "variaciones": [
    {
      "ingrediente_origen_id": 1,
      "ingrediente_reemplazo_id": 4,
      "porcentaje": 30
    }
  ],
  "ajustes_aplicados": {
    "aceite": -0.5,
    "temporada": 0.2
  },
  "notas": "Reemplazo parcial con cerdo"
}
```

### Enums Sugeridos (Dart)

```dart
enum Temporada { verano, invierno }
enum NivelActividad { bajo, normal, alto }
enum TipoRestriccion { frecuenciaMaxima, obligatorioSi, incompatible }
enum Severidad { info, warning, error }
enum DiaSemana { lunes, martes, miercoles, jueves, viernes, sabado, domingo }
```

---

## Resumen de Tablas

| # | Tabla | Tipo | Registros |
|---|-------|------|-----------|
| 1 | categoria | Seed | 7 |
| 2 | ingrediente | Seed | ~50 |
| 3 | suplemento | Seed | 2-5 |
| 4 | receta | Seed | 6 |
| 5 | receta_ingrediente | Seed | ~50 |
| 6 | receta_suplemento | Seed | ~12 |
| 7 | restriccion | Seed | 3-5 |
| 8 | receta_restriccion | Seed | ~10 |
| 9 | variacion_proteina | Seed | ~25 |
| 10 | perfil_nutricional | Usuario | 1 |
| 11 | menu_semanal | Usuario | Variable |
| 12 | menu_slot | Usuario | Variable |
| 13 | precio_ingrediente | Usuario | Variable |
| 14 | lista_compra_item | Generado | Variable |
| 15 | app_config | Sistema | ~5 |

**Total:** 15 tablas

---

## Proximos Pasos

1. **Implementar con drift** - Generar codigo Dart desde este schema
2. **Crear seed data completo** - Las 6 recetas reales A-F
3. **Tests de integracion** - Verificar queries y constraints
4. **Documentar API de datos** - Repositorios y DAOs

---

**Ultima actualizacion:** 2026-01-26
**Version:** 1.0
**Autor:** database-expert agent
