# Arquitectura Flutter - Mew Michis

**Proyecto:** Sistema de Alimentacion Casera Felina
**Version:** 1.0
**Fecha:** 2026-01-26
**Escala:** Micro (1 developer)
**Framework:** Flutter 3.x (Dart)

---

## Resumen Ejecutivo

Este documento define la arquitectura tecnica para Mew Michis, una aplicacion movil Flutter para planificacion de alimentacion felina. La arquitectura prioriza:

1. **Simplicidad** - Proyecto micro, evitar over-engineering
2. **Offline-first** - Funcionamiento completo sin conexion
3. **Testabilidad** - Logica de negocio critica (calculos nutricionales)
4. **Mantenibilidad** - Estructura clara para evolucion futura

---

## Diagrama de Capas

```
+------------------------------------------------------------------+
|                      PRESENTATION LAYER                           |
|  +------------------------------------------------------------+  |
|  |  Screens (Pages)     |  Widgets           |  Controllers   |  |
|  |  - ProfileScreen     |  - RecipeCard      |  (Riverpod     |  |
|  |  - RecipesScreen     |  - MenuDaySlot     |   Providers)   |  |
|  |  - MenuScreen        |  - IngredientTile  |                |  |
|  |  - ShoppingScreen    |  - ValidationBadge |                |  |
|  |  - BudgetScreen      |  - ...             |                |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
                              |
                              | (depende de)
                              v
+------------------------------------------------------------------+
|                        DOMAIN LAYER                               |
|  +------------------------------------------------------------+  |
|  |  Entities            |  Use Cases         |  Repositories  |  |
|  |  - NutritionalProfile|  - CalculateNeeds  |  (Interfaces)  |  |
|  |  - Recipe            |  - ScaleRecipe     |                |  |
|  |  - Ingredient        |  - ValidateMenu    |                |  |
|  |  - WeeklyMenu        |  - GenerateList    |                |  |
|  |  - ShoppingList      |  - CalculateCost   |                |  |
|  |  - Restriction       |  - ...             |                |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
                              |
                              | (depende de)
                              v
+------------------------------------------------------------------+
|                         DATA LAYER                                |
|  +------------------------------------------------------------+  |
|  |  Repositories Impl   |  Data Sources      |  Models (DTO)  |  |
|  |  - ProfileRepoImpl   |  - LocalDataSource |  - ProfileModel|  |
|  |  - RecipeRepoImpl    |    (SQLite)        |  - RecipeModel |  |
|  |  - MenuRepoImpl      |  - SeedDataSource  |  - MenuModel   |  |
|  |  - ...               |    (JSON/Constants)|  - ...         |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
                              |
                              | (usa)
                              v
+------------------------------------------------------------------+
|                      INFRASTRUCTURE                               |
|  +------------------------------------------------------------+  |
|  |  Database (Drift)    |  DI (Riverpod)     |  Router        |  |
|  |  - AppDatabase       |  - Providers       |  (go_router)   |  |
|  |  - DAOs              |  - Overrides       |  - Routes      |  |
|  |  - Migrations        |                    |  - Guards      |  |
|  +------------------------------------------------------------+  |
+------------------------------------------------------------------+
```

---

## Estructura de Carpetas

```
lib/
|
+-- main.dart                    # Entry point, inicializacion
|
+-- core/                        # Utilidades transversales
|   +-- constants/
|   |   +-- app_constants.dart   # Constantes globales
|   |   +-- nutritional_constants.dart  # Formulas, limites
|   +-- extensions/
|   |   +-- double_extensions.dart      # Redondeo practico
|   |   +-- list_extensions.dart
|   +-- utils/
|   |   +-- validators.dart      # Validaciones comunes
|   |   +-- formatters.dart      # Formateo de unidades
|   +-- errors/
|       +-- failures.dart        # Clases de error de dominio
|
+-- domain/                      # Logica de negocio pura
|   +-- entities/
|   |   +-- nutritional_profile.dart
|   |   +-- recipe.dart
|   |   +-- ingredient.dart
|   |   +-- supplement.dart
|   |   +-- restriction.dart
|   |   +-- protein_variation.dart
|   |   +-- weekly_menu.dart
|   |   +-- menu_slot.dart
|   |   +-- shopping_list.dart
|   |   +-- shopping_item.dart
|   |   +-- ingredient_price.dart
|   |
|   +-- enums/
|   |   +-- season.dart          # verano, invierno
|   |   +-- activity_level.dart  # bajo, normal, alto
|   |   +-- ingredient_category.dart
|   |   +-- day_of_week.dart
|   |   +-- validation_severity.dart  # error, warning, info
|   |
|   +-- repositories/            # Interfaces (contratos)
|   |   +-- profile_repository.dart
|   |   +-- recipe_repository.dart
|   |   +-- menu_repository.dart
|   |   +-- price_repository.dart
|   |
|   +-- use_cases/               # Logica de negocio
|       +-- profile/
|       |   +-- calculate_daily_needs.dart
|       |   +-- calculate_weekly_needs.dart
|       +-- recipe/
|       |   +-- scale_recipe.dart
|       |   +-- apply_variation.dart
|       |   +-- calculate_supplements.dart
|       |   +-- apply_seasonal_adjustments.dart
|       +-- menu/
|       |   +-- validate_weekly_menu.dart
|       |   +-- check_fish_limit.dart
|       |   +-- check_liver_limit.dart
|       |   +-- check_oil_requirement.dart
|       +-- shopping/
|       |   +-- generate_shopping_list.dart
|       |   +-- consolidate_ingredients.dart
|       +-- budget/
|           +-- calculate_weekly_cost.dart
|           +-- calculate_cost_per_kg.dart
|
+-- data/                        # Implementaciones
|   +-- models/                  # DTOs para persistencia
|   |   +-- profile_model.dart
|   |   +-- recipe_model.dart
|   |   +-- menu_model.dart
|   |   +-- price_model.dart
|   |
|   +-- repositories/            # Implementaciones concretas
|   |   +-- profile_repository_impl.dart
|   |   +-- recipe_repository_impl.dart
|   |   +-- menu_repository_impl.dart
|   |   +-- price_repository_impl.dart
|   |
|   +-- datasources/
|   |   +-- local/
|   |   |   +-- database.dart    # Drift database
|   |   |   +-- daos/
|   |   |       +-- profile_dao.dart
|   |   |       +-- menu_dao.dart
|   |   |       +-- price_dao.dart
|   |   +-- seed/
|   |       +-- recipes_seed.dart    # Recetas A-F hardcoded
|   |       +-- ingredients_seed.dart
|   |
|   +-- mappers/                 # Entity <-> Model
|       +-- profile_mapper.dart
|       +-- recipe_mapper.dart
|       +-- menu_mapper.dart
|
+-- presentation/                # UI
|   +-- app.dart                 # MaterialApp, tema, router
|   |
|   +-- router/
|   |   +-- app_router.dart      # Configuracion go_router
|   |   +-- routes.dart          # Constantes de rutas
|   |
|   +-- theme/
|   |   +-- app_theme.dart       # Tema de la app
|   |   +-- app_colors.dart
|   |   +-- app_text_styles.dart
|   |
|   +-- providers/               # Riverpod providers
|   |   +-- profile_providers.dart
|   |   +-- recipe_providers.dart
|   |   +-- menu_providers.dart
|   |   +-- shopping_providers.dart
|   |   +-- budget_providers.dart
|   |   +-- database_provider.dart
|   |
|   +-- screens/                 # Pantallas principales
|   |   +-- home/
|   |   |   +-- home_screen.dart
|   |   +-- profile/
|   |   |   +-- profile_screen.dart
|   |   |   +-- widgets/
|   |   |       +-- profile_form.dart
|   |   |       +-- needs_summary_card.dart
|   |   +-- recipes/
|   |   |   +-- recipes_list_screen.dart
|   |   |   +-- recipe_detail_screen.dart
|   |   |   +-- widgets/
|   |   |       +-- recipe_card.dart
|   |   |       +-- ingredient_list.dart
|   |   |       +-- variation_selector.dart
|   |   +-- menu/
|   |   |   +-- menu_screen.dart
|   |   |   +-- widgets/
|   |   |       +-- day_slot.dart
|   |   |       +-- validation_summary.dart
|   |   |       +-- recipe_picker_sheet.dart
|   |   +-- shopping/
|   |   |   +-- shopping_list_screen.dart
|   |   |   +-- widgets/
|   |   |       +-- category_section.dart
|   |   |       +-- shopping_item_tile.dart
|   |   +-- budget/
|   |       +-- budget_screen.dart
|   |       +-- prices_screen.dart
|   |       +-- widgets/
|   |           +-- cost_summary_card.dart
|   |           +-- price_input_tile.dart
|   |
|   +-- widgets/                 # Widgets compartidos
|       +-- common/
|       |   +-- loading_indicator.dart
|       |   +-- error_view.dart
|       |   +-- empty_state.dart
|       +-- cards/
|       |   +-- info_card.dart
|       |   +-- warning_card.dart
|       +-- inputs/
|           +-- numeric_input.dart
|           +-- dropdown_selector.dart
|
+-- di/                          # Dependency Injection
    +-- injection.dart           # Setup de providers

test/
+-- unit/
|   +-- domain/
|   |   +-- use_cases/
|   |       +-- calculate_daily_needs_test.dart
|   |       +-- scale_recipe_test.dart
|   |       +-- validate_weekly_menu_test.dart
|   +-- data/
|       +-- repositories/
|
+-- widget/
|   +-- screens/
|   +-- widgets/
|
+-- integration/
    +-- menu_to_shopping_flow_test.dart
```

---

## Decisiones Tecnicas

### 1. State Management: Riverpod

**Opcion elegida:** `flutter_riverpod` + `riverpod_annotation`

**Alternativas consideradas:**

| Opcion | Pros | Contras | Decision |
|--------|------|---------|----------|
| **Riverpod** | Type-safe, testable, sin context, code gen | Curva de aprendizaje inicial | ELEGIDO |
| Provider | Simple, oficial Flutter | Requiere context, menos features | Descartado |
| BLoC | Patron robusto, eventos claros | Boilerplate excesivo para micro | Descartado |
| GetX | Simple, rapido | Magia excesiva, menos testable | Descartado |

**Justificacion:**
- **Compile-time safety**: Detecta errores de dependencias en compilacion
- **No requiere BuildContext**: Facilita testing y uso en use cases
- **Code generation**: Reduce boilerplate con `@riverpod`
- **Scoping flexible**: Providers por familia, autodispose
- **Reactividad**: Perfecto para recalculos automaticos (peso -> escalado)

**Ejemplo de uso:**

```dart
// Providers con code generation
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<NutritionalProfile?> build() async {
    return ref.read(profileRepositoryProvider).getProfile();
  }

  Future<void> updateProfile(NutritionalProfile profile) async {
    state = const AsyncLoading();
    await ref.read(profileRepositoryProvider).saveProfile(profile);
    state = AsyncData(profile);
  }
}

@riverpod
DailyNeeds dailyNeeds(DailyNeedsRef ref) {
  final profile = ref.watch(profileNotifierProvider).valueOrNull;
  if (profile == null) return DailyNeeds.empty();
  return ref.read(calculateDailyNeedsProvider).execute(profile);
}
```

---

### 2. Persistencia: Drift (SQLite)

**Opcion elegida:** `drift` (antes moor)

**Alternativas consideradas:**

| Opcion | Pros | Contras | Decision |
|--------|------|---------|----------|
| **Drift** | Type-safe, migrations, DAOs, reactive | Setup inicial | ELEGIDO |
| sqflite | Simple, directo | SQL manual, no type-safe | Descartado |
| Isar | Rapido, NoSQL | Overhead para modelo simple | Descartado |
| Hive | Key-value rapido | No relacional, queries limitados | Descartado |

**Justificacion:**
- **Type-safety**: Queries verificadas en compilacion
- **Migrations**: Soporte nativo para evolucionar schema
- **Reactive streams**: Watch en tiempo real (auto-update UI)
- **DAOs**: Organizacion limpia de queries
- **Testing**: Bases de datos in-memory para tests

**Schema propuesto:**

```
+-------------------+       +-------------------+
|  profiles         |       |  weekly_menus     |
+-------------------+       +-------------------+
| id (PK)           |       | id (PK)           |
| total_weight      |       | start_date        |
| num_cats          |       | is_active         |
| season            |       | created_at        |
| activity_level    |       +-------------------+
| created_at        |               |
| updated_at        |               | 1:N
+-------------------+               v
                            +-------------------+
+-------------------+       |  menu_slots       |
|  recipes (seed)   |       +-------------------+
+-------------------+       | id (PK)           |
| id (PK)           |<------| menu_id (FK)      |
| name              |       | day_of_week       |
| description       |       | recipe_id (FK)    |
| base_protein      |       | variation_json    |
+-------------------+       +-------------------+
        |
        | 1:N
        v
+-------------------+       +-------------------+
|  recipe_ingredients|      |  ingredient_prices|
+-------------------+       +-------------------+
| id (PK)           |       | ingredient_id (PK)|
| recipe_id (FK)    |       | price_per_unit    |
| ingredient_id     |       | unit              |
| amount_per_kg     |       | updated_at        |
| is_replaceable    |       +-------------------+
+-------------------+

+-------------------+       +-------------------+
|  restrictions     |       |  shopping_checks  |
+-------------------+       +-------------------+
| id (PK)           |       | menu_id (FK)      |
| recipe_id (FK)    |       | ingredient_id     |
| ingredient_type   |       | is_checked        |
| max_per_week      |       +-------------------+
| description       |
+-------------------+
```

---

### 3. Navegacion: go_router

**Opcion elegida:** `go_router`

**Alternativas consideradas:**

| Opcion | Pros | Contras | Decision |
|--------|------|---------|----------|
| **go_router** | Declarativo, deep links, type-safe | Mas setup | ELEGIDO |
| Navigator 2.0 | Oficial, flexible | Complejo, verbose | Descartado |
| auto_route | Code gen, potente | Over-engineering para MVP | Descartado |

**Justificacion:**
- **Declarativo**: Rutas como configuracion, no codigo imperativo
- **Deep linking**: Preparado para futuro (compartir menus)
- **Type-safe parameters**: `$extra` para pasar objetos
- **Nested navigation**: Bottom nav con subrutas
- **Redirects**: Guards para flujos (ej: forzar perfil inicial)

**Configuracion propuesta:**

```dart
final goRouter = GoRouter(
  initialLocation: '/home',
  redirect: (context, state) {
    final hasProfile = // check profile exists
    if (!hasProfile && state.location != '/profile/setup') {
      return '/profile/setup';
    }
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/recipes',
            builder: (_, __) => const RecipesListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => RecipeDetailScreen(
                  recipeId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/menu', builder: (_, __) => const MenuScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/shopping', builder: (_, __) => const ShoppingListScreen()),
        ]),
      ],
    ),
    GoRoute(path: '/profile/setup', builder: (_, __) => const ProfileSetupScreen()),
    GoRoute(path: '/budget', builder: (_, __) => const BudgetScreen()),
    GoRoute(path: '/budget/prices', builder: (_, __) => const PricesScreen()),
  ],
);
```

---

### 4. Modelos Inmutables: Freezed

**Opcion elegida:** `freezed` + `json_serializable`

**Justificacion:**
- **Inmutabilidad**: Previene bugs por mutacion accidental
- **copyWith**: Actualizaciones parciales elegantes
- **Equality**: Comparacion de valores automatica
- **Union types**: Para estados (Loading/Success/Error)
- **JSON serialization**: Facil persistencia

**Ejemplo:**

```dart
@freezed
class NutritionalProfile with _$NutritionalProfile {
  const factory NutritionalProfile({
    required String id,
    required double totalWeight,
    int? numCats,
    required Season season,
    required ActivityLevel activityLevel,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NutritionalProfile;

  factory NutritionalProfile.fromJson(Map<String, dynamic> json) =>
      _$NutritionalProfileFromJson(json);
}

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    required String description,
    required List<Ingredient> ingredients,
    required List<Supplement> supplements,
    required List<Restriction> restrictions,
    required List<ProteinVariation> allowedVariations,
  }) = _Recipe;
}
```

---

### 5. Inyeccion de Dependencias

**Patron:** Riverpod como DI container

**Justificacion:**
- Riverpod ya maneja dependencias entre providers
- No necesita package adicional
- Testing con overrides simple

**Estructura de providers:**

```dart
// Database
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) => AppDatabase();

// DAOs
@riverpod
ProfileDao profileDao(ProfileDaoRef ref) =>
    ref.watch(databaseProvider).profileDao;

// Repositories
@riverpod
ProfileRepository profileRepository(ProfileRepositoryRef ref) =>
    ProfileRepositoryImpl(ref.watch(profileDaoProvider));

// Use Cases
@riverpod
CalculateDailyNeeds calculateDailyNeeds(CalculateDailyNeedsRef ref) =>
    CalculateDailyNeeds();

// UI State
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  // ...
}
```

---

## Patrones de Arquitectura

### Repository Pattern

Abstrae el origen de datos del dominio.

```dart
// domain/repositories/profile_repository.dart
abstract class ProfileRepository {
  Future<NutritionalProfile?> getProfile();
  Future<void> saveProfile(NutritionalProfile profile);
  Stream<NutritionalProfile?> watchProfile();
}

// data/repositories/profile_repository_impl.dart
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDao _dao;

  ProfileRepositoryImpl(this._dao);

  @override
  Future<NutritionalProfile?> getProfile() async {
    final model = await _dao.getActiveProfile();
    return model != null ? ProfileMapper.toEntity(model) : null;
  }

  @override
  Stream<NutritionalProfile?> watchProfile() {
    return _dao.watchActiveProfile()
        .map((model) => model != null ? ProfileMapper.toEntity(model) : null);
  }
}
```

### Use Case Pattern

Encapsula logica de negocio en unidades testables.

```dart
// domain/use_cases/recipe/scale_recipe.dart
class ScaleRecipe {
  ScaledRecipe execute(Recipe recipe, double catWeight, {
    ProteinVariation? variation,
    Season? season,
  }) {
    final scaleFactor = catWeight; // Recetas base son por 1kg

    final scaledIngredients = recipe.ingredients.map((ingredient) {
      var amount = ingredient.amountPerKg * scaleFactor;

      // Aplicar variacion si existe
      if (variation != null && ingredient.isReplaceable) {
        amount = _applyVariation(amount, variation);
      }

      // Aplicar ajuste estacional para aceite
      if (ingredient.category == IngredientCategory.oil && season == Season.winter) {
        amount *= 1.20; // +20% en invierno
      }

      return ScaledIngredient(
        ingredient: ingredient,
        scaledAmount: _roundPractical(amount, ingredient.category),
      );
    }).toList();

    return ScaledRecipe(
      recipe: recipe,
      scaledIngredients: scaledIngredients,
      appliedVariation: variation,
      seasonalAdjustments: season == Season.winter,
    );
  }

  double _roundPractical(double value, IngredientCategory category) {
    return switch (category) {
      IngredientCategory.meat => (value / 5).round() * 5.0,
      IngredientCategory.supplement => (value / 10).round() * 10.0,
      _ => value.roundToDouble(),
    };
  }
}
```

### Validation Engine Pattern

Motor de validaciones configurable y extensible.

```dart
// domain/use_cases/menu/validate_weekly_menu.dart
class ValidateWeeklyMenu {
  final List<MenuValidator> _validators = [
    FishLimitValidator(maxPerWeek: 2),
    LiverLimitValidator(maxPerWeek: 2),
    OilRequirementValidator(),
    SupplementsValidator(),
  ];

  ValidationResult execute(WeeklyMenu menu) {
    final issues = <ValidationIssue>[];

    for (final validator in _validators) {
      issues.addAll(validator.validate(menu));
    }

    return ValidationResult(
      isValid: !issues.any((i) => i.severity == Severity.error),
      issues: issues,
    );
  }
}

abstract class MenuValidator {
  List<ValidationIssue> validate(WeeklyMenu menu);
}

class FishLimitValidator implements MenuValidator {
  final int maxPerWeek;

  FishLimitValidator({required this.maxPerWeek});

  @override
  List<ValidationIssue> validate(WeeklyMenu menu) {
    final fishDays = menu.slots
        .where((s) => s.recipe?.containsFish ?? false)
        .length;

    if (fishDays > maxPerWeek) {
      return [
        ValidationIssue(
          severity: Severity.warning,
          message: 'Pescado asignado $fishDays veces (maximo recomendado: $maxPerWeek)',
          affectedDays: menu.slots
              .where((s) => s.recipe?.containsFish ?? false)
              .map((s) => s.day)
              .toList(),
        ),
      ];
    }
    return [];
  }
}
```

---

## Packages Recomendados

### Core

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `flutter_riverpod` | ^2.5.1 | State management | Type-safe, testable |
| `riverpod_annotation` | ^2.3.5 | Code generation | Reduce boilerplate |
| `freezed` | ^2.5.2 | Modelos inmutables | copyWith, equality |
| `freezed_annotation` | ^2.4.1 | Annotations | Para freezed |
| `json_annotation` | ^4.9.0 | JSON serialization | Para persistencia |

### Persistencia

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `drift` | ^2.16.0 | SQLite ORM | Type-safe, migrations |
| `drift_flutter` | ^0.1.0 | Flutter integration | Native sqlite |
| `path_provider` | ^2.1.2 | Paths de sistema | Ubicacion DB |
| `path` | ^1.9.0 | Manipulacion paths | Cross-platform |

### Navegacion y UI

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `go_router` | ^13.2.0 | Navegacion | Declarativo, deep links |
| `flutter_hooks` | ^0.20.5 | Hooks de UI | useTextController, etc |
| `hooks_riverpod` | ^2.5.1 | Hooks + Riverpod | Integracion |

### Utilidades

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `intl` | ^0.19.0 | Formateo | Fechas, numeros |
| `collection` | ^1.18.0 | Extensiones | groupBy, etc |
| `equatable` | ^2.0.5 | Equality helpers | Complemento a freezed |
| `uuid` | ^4.3.3 | IDs unicos | Generacion de IDs |

### Build

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `build_runner` | ^2.4.8 | Code generation | Para freezed, riverpod |
| `riverpod_generator` | ^2.4.0 | Provider generation | @riverpod |
| `freezed` | ^2.5.2 | Model generation | @freezed |
| `json_serializable` | ^6.7.1 | JSON generation | fromJson/toJson |
| `drift_dev` | ^2.16.0 | Drift generation | Tables, DAOs |

### Testing

| Package | Version | Proposito | Justificacion |
|---------|---------|-----------|---------------|
| `flutter_test` | sdk | Widget tests | Oficial |
| `mocktail` | ^1.0.3 | Mocking | Mas simple que mockito |
| `drift` (test) | - | In-memory DB | Tests de repositorios |

---

## Guia de Implementacion

### Fase 0: Setup Inicial

```bash
# 1. Crear proyecto Flutter
flutter create --org com.mewmichis mew_michis

# 2. Agregar dependencias a pubspec.yaml
# (lista de arriba)

# 3. Configurar build_runner
dart run build_runner build --delete-conflicting-outputs

# 4. Crear estructura de carpetas
# (seguir estructura propuesta)
```

### Sprint 1: Foundation (MEW-001 a MEW-004)

**Orden de implementacion:**

1. **Core setup**
   - Crear enums (Season, ActivityLevel)
   - Crear constantes nutricionales
   - Configurar tema basico

2. **Domain entities**
   - NutritionalProfile (freezed)
   - Recipe, Ingredient, Supplement
   - Crear use case: CalculateDailyNeeds

3. **Data layer**
   - Configurar Drift database
   - Crear ProfileDao
   - Implementar ProfileRepository

4. **Presentation**
   - Configurar go_router
   - ProfileScreen con formulario
   - ProfileNotifier (Riverpod)

### Sprint 2-5: Iterativo

Seguir el roadmap del backlog, implementando:
- Entities -> Repository interface -> Repository impl -> Use cases -> Providers -> Screens

---

## Testing Strategy

### Unit Tests (Criticos)

**Prioridad ALTA - Motor nutricional:**

```dart
// test/unit/domain/use_cases/calculate_daily_needs_test.dart
void main() {
  late CalculateDailyNeeds useCase;

  setUp(() {
    useCase = CalculateDailyNeeds();
  });

  group('CalculateDailyNeeds', () {
    test('should calculate 350g for 10kg cats with normal activity', () {
      final profile = NutritionalProfile(
        totalWeight: 10.0,
        activityLevel: ActivityLevel.normal,
        season: Season.summer,
      );

      final result = useCase.execute(profile);

      expect(result.dailyGrams, 350); // 10kg * 35g
    });

    test('should add 10% for winter season', () {
      final profile = NutritionalProfile(
        totalWeight: 10.0,
        activityLevel: ActivityLevel.normal,
        season: Season.winter,
      );

      final result = useCase.execute(profile);

      expect(result.dailyGrams, 385); // 350 * 1.10
    });
  });
}
```

**Prioridad ALTA - Validaciones de menu:**

```dart
// test/unit/domain/use_cases/validate_weekly_menu_test.dart
void main() {
  group('FishLimitValidator', () {
    test('should warn when fish exceeds 2 days', () {
      final menu = WeeklyMenu(slots: [
        MenuSlot(day: DayOfWeek.monday, recipe: fishRecipe),
        MenuSlot(day: DayOfWeek.wednesday, recipe: fishRecipe),
        MenuSlot(day: DayOfWeek.friday, recipe: fishRecipe), // 3rd!
      ]);

      final validator = FishLimitValidator(maxPerWeek: 2);
      final issues = validator.validate(menu);

      expect(issues, hasLength(1));
      expect(issues.first.severity, Severity.warning);
    });
  });
}
```

### Widget Tests

**Prioridad MEDIA - Formularios:**

```dart
// test/widget/screens/profile/profile_form_test.dart
void main() {
  testWidgets('should show validation error for weight > 100', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: ProfileForm())),
    );

    await tester.enterText(find.byKey(Key('weight_input')), '150');
    await tester.tap(find.byKey(Key('save_button')));
    await tester.pump();

    expect(find.text('El peso debe ser menor a 100 kg'), findsOneWidget);
  });
}
```

### Integration Tests

**Prioridad BAJA - Flujos completos:**

```dart
// test/integration/menu_to_shopping_flow_test.dart
void main() {
  testWidgets('complete flow: create menu -> generate shopping list', (tester) async {
    // Setup con datos mock
    // Navegar a menu
    // Asignar recetas a 7 dias
    // Navegar a shopping list
    // Verificar ingredientes consolidados
  });
}
```

---

## Consideraciones de Performance

### Lazy Loading de Recetas

Las recetas son seed data inmutable. Cargar en memoria al inicio y cachear:

```dart
@Riverpod(keepAlive: true)
Future<List<Recipe>> recipes(RecipesRef ref) async {
  return ref.read(recipeRepositoryProvider).getAllRecipes();
}
```

### Calculos Reactivos

Usar `select` para evitar rebuilds innecesarios:

```dart
final totalWeight = ref.watch(
  profileNotifierProvider.select((p) => p.valueOrNull?.totalWeight),
);
```

### Debounce en Inputs

Para campos numericos que disparan recalculos:

```dart
@riverpod
class WeightInput extends _$WeightInput {
  Timer? _debounce;

  void updateWeight(double value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(profileNotifierProvider.notifier).updateWeight(value);
    });
  }
}
```

---

## Evolucion Futura (Post-MVP)

### Fase 2: Mejoras UX
- Notificaciones locales (recordatorio de preparar comida)
- Drag & drop en calendario
- Temas claro/oscuro

### Fase 3: Backend (Opcional)
- Sincronizacion cloud (Firebase/Supabase)
- Compartir menus entre usuarios
- Backup automatico

### Fase 4: Inteligencia
- Sugerencias de menu basadas en historial
- Optimizacion de costos automatica
- Alertas de ingredientes proximos a vencer

---

## Checklist de Implementacion

### Setup Inicial
- [ ] Crear proyecto Flutter
- [ ] Configurar pubspec.yaml con dependencias
- [ ] Crear estructura de carpetas
- [ ] Configurar build_runner
- [ ] Setup basico de Drift
- [ ] Setup basico de go_router
- [ ] Setup basico de Riverpod

### Por cada Feature
- [ ] Crear/actualizar entities en domain/
- [ ] Crear use cases con tests unitarios
- [ ] Implementar repository si necesario
- [ ] Crear providers en presentation/providers/
- [ ] Implementar UI screens/widgets
- [ ] Agregar widget tests
- [ ] Verificar integracion con features existentes

---

## Referencias

### Documentacion Oficial
- [Flutter](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [Drift](https://drift.simonbinder.eu/)
- [go_router](https://pub.dev/packages/go_router)
- [Freezed](https://pub.dev/packages/freezed)

### Arquitectura
- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture - Reso Coder](https://resocoder.com/flutter-clean-architecture-tdd/)

---

**Ultima actualizacion:** 2026-01-26
**Version:** 1.0
**Estado:** Aprobado para implementacion
