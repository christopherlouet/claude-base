# Agent QA-MOBILE

Audit de qualité spécifique aux applications mobiles (Flutter, React Native).

## Cible de l'audit
$ARGUMENTS

## 1. Performance

### Frames et Rendu

```
┌─────────────────────────────────────────────────────────┐
│  OBJECTIF : 60 FPS constant (16.67ms par frame max)     │
│  Sur devices 120Hz : 120 FPS (8.33ms par frame)         │
└─────────────────────────────────────────────────────────┘
```

#### Checklist
- [ ] 60 FPS maintenu pendant le scroll
- [ ] Pas de jank visible (frames dropped)
- [ ] Animations fluides (pas de saccades)
- [ ] Transitions de page sans lag
- [ ] Clavier apparaît/disparaît sans freeze

#### Outils de diagnostic Flutter
```dart
// Activer le performance overlay
MaterialApp(
  showPerformanceOverlay: true,
  // ...
);

// Ou via DevTools
// flutter run --profile
// Puis ouvrir DevTools > Performance
```

#### Anti-patterns à détecter
```dart
// ❌ MAUVAIS: Build coûteux dans un widget parent
class ParentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final expensiveData = computeExpensiveData(); // Recalculé à chaque build!
    return ListView.builder(
      itemBuilder: (_, i) => ItemWidget(data: expensiveData[i]),
    );
  }
}

// ✅ BON: Utiliser const et memoization
class ParentWidget extends StatelessWidget {
  const ParentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (_, i) => const ItemWidget(), // const!
    );
  }
}
```

### Mémoire

#### Checklist
- [ ] Pas de memory leaks (dispose() appelé)
- [ ] Images optimisées et mises en cache
- [ ] Pagination des grandes listes
- [ ] Streams/Subscriptions nettoyés
- [ ] Controllers disposés correctement

#### Outils
```bash
# Flutter DevTools - Memory tab
flutter run --profile

# Analyser les allocations
# DevTools > Memory > Allocation Tracing
```

#### Patterns à vérifier
```dart
// ❌ MAUVAIS: Pas de dispose
class MyWidget extends StatefulWidget { ... }
class _MyWidgetState extends State<MyWidget> {
  final controller = TextEditingController();
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = stream.listen((data) { ... });
  }
  // Oubli de dispose!
}

// ✅ BON: Dispose correctement
class _MyWidgetState extends State<MyWidget> {
  final controller = TextEditingController();
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = stream.listen((data) { ... });
  }

  @override
  void dispose() {
    controller.dispose();
    subscription.cancel();
    super.dispose();
  }
}
```

### Batterie et Réseau

#### Checklist
- [ ] Pas de polling excessif (préférer WebSocket/push)
- [ ] Location services utilisés avec parcimonie
- [ ] Background tasks minimisés
- [ ] Requêtes réseau avec retry et backoff exponentiel
- [ ] Images chargées en lazy loading
- [ ] Compression des données activée

#### Analyse réseau
```dart
// Intercepteur Dio pour mesurer
class PerformanceInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['startTime'] as DateTime;
    final duration = DateTime.now().difference(startTime);
    debugPrint('${response.requestOptions.path}: ${duration.inMilliseconds}ms');
    handler.next(response);
  }
}
```

## 2. Accessibilité Mobile

### Semantics Flutter

#### Checklist
- [ ] Semantics labels sur tous les boutons/icônes
- [ ] ExcludeSemantics pour éléments décoratifs
- [ ] MergeSemantics pour groupes logiques
- [ ] Ordonnancement logique de lecture (sortKey)
- [ ] Live regions pour contenus dynamiques

#### Exemples
```dart
// ❌ MAUVAIS: Bouton sans label
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: onDelete,
)

// ✅ BON: Avec semantic label
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: onDelete,
  tooltip: 'Supprimer',  // Aussi utilisé par Semantics
)

// Ou explicitement
Semantics(
  label: 'Supprimer cet élément',
  button: true,
  child: IconButton(
    icon: const Icon(Icons.delete),
    onPressed: onDelete,
  ),
)

// Exclure les éléments décoratifs
ExcludeSemantics(
  child: DecorativeImage(),
)

// Grouper les éléments liés
MergeSemantics(
  child: Row(
    children: [
      const Icon(Icons.star),
      Text('$rating étoiles'),
    ],
  ),
)
```

### Touch Targets

#### Checklist
- [ ] Touch targets minimum 48x48 dp (Material Design)
- [ ] Espacement minimum 8dp entre éléments cliquables
- [ ] Pas d'éléments trop proches qui causent des clics accidentels

```dart
// ❌ MAUVAIS: Trop petit
SizedBox(
  width: 24,
  height: 24,
  child: IconButton(icon: Icon(Icons.close), onPressed: onClose),
)

// ✅ BON: Taille suffisante
IconButton(
  icon: const Icon(Icons.close),
  onPressed: onClose,
  iconSize: 24,
  padding: const EdgeInsets.all(12), // Total: 48x48
)
```

### Contraste et Couleurs

#### Checklist
- [ ] Contraste texte/fond ≥ 4.5:1 (AA) ou ≥ 7:1 (AAA)
- [ ] Pas d'information transmise uniquement par la couleur
- [ ] Mode sombre supporté
- [ ] Couleurs testées pour daltonisme

#### Test de contraste
```dart
// Vérifier le contraste
double calculateContrast(Color foreground, Color background) {
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

// Ratio minimum: 4.5 pour texte normal, 3.0 pour grand texte
```

### Tests Accessibilité

```dart
testWidgets('Accessibility test', (tester) async {
  final SemanticsHandle handle = tester.ensureSemantics();

  await tester.pumpWidget(const MyApp());

  // Vérifier que le bouton a un label
  expect(
    tester.getSemantics(find.byType(IconButton)),
    matchesSemantics(
      label: 'Supprimer',
      isButton: true,
      hasTapAction: true,
    ),
  );

  // Vérifier qu'il n'y a pas de problèmes d'accessibilité
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));

  handle.dispose();
});
```

## 3. Responsive

### Breakpoints Mobile

| Device | Largeur | Catégorie |
|--------|---------|-----------|
| iPhone SE | 375 | Small |
| iPhone 14 | 390 | Medium |
| iPhone 14 Pro Max | 430 | Large |
| Pixel 7 | 412 | Medium |
| Galaxy S23 | 360 | Small |
| iPad Mini | 744 | Tablet |
| iPad Pro 12.9 | 1024 | Tablet Large |

### Checklist

- [ ] LayoutBuilder utilisé pour layouts adaptatifs
- [ ] MediaQuery pour obtenir les dimensions
- [ ] OrientationBuilder pour gérer la rotation
- [ ] SafeArea pour notch/home indicator/punch hole
- [ ] Pas de débordement (overflow) sur petits écrans
- [ ] Texte scalable (respecte les préférences utilisateur)

### Patterns Responsive

```dart
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  static const mobileBreakpoint = 600.0;
  static const tabletBreakpoint = 900.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

// Utilisation
ResponsiveLayout(
  mobile: const MobileProductList(),
  tablet: const TabletProductGrid(columns: 2),
  desktop: const DesktopProductGrid(columns: 4),
)
```

### Orientation

```dart
OrientationBuilder(
  builder: (context, orientation) {
    return GridView.count(
      crossAxisCount: orientation == Orientation.portrait ? 2 : 4,
      children: items.map((item) => ItemCard(item: item)).toList(),
    );
  },
)
```

### Safe Area

```dart
// ✅ BON: Utiliser SafeArea
Scaffold(
  body: SafeArea(
    child: Column(
      children: [
        const Header(),
        Expanded(child: Content()),
        const Footer(),
      ],
    ),
  ),
)

// Pour plus de contrôle
SafeArea(
  top: true,      // Notch, status bar
  bottom: true,   // Home indicator, navigation bar
  left: false,
  right: false,
  minimum: const EdgeInsets.all(16),
  child: Content(),
)
```

## 4. Tests sur Devices Réels

### Devices à tester

#### Priorité haute
- [ ] iPhone SE (petit écran iOS, baseline perf)
- [ ] iPhone 14/15 (écran standard iOS)
- [ ] Pixel 7/8 (Android stock)
- [ ] Samsung Galaxy A (Android mid-range)

#### Priorité moyenne
- [ ] iPhone Pro Max (grand écran iOS)
- [ ] iPad (si support tablette)
- [ ] Android low-end (2GB RAM)

### Conditions à tester

- [ ] Mode avion / hors ligne
- [ ] Connexion lente (3G throttling)
- [ ] Batterie faible / mode économie d'énergie
- [ ] Interruptions (appels entrants, notifications)
- [ ] Rotation d'écran
- [ ] Multi-window (Android)
- [ ] Picture-in-picture (si applicable)
- [ ] Accessibilité activée (TalkBack, VoiceOver)

### Outils de test cloud

| Service | Devices | Prix |
|---------|---------|------|
| Firebase Test Lab | Android + iOS | Gratuit (quota) |
| AWS Device Farm | Android + iOS | À la minute |
| BrowserStack | Android + iOS | Abonnement |
| Sauce Labs | Android + iOS | Abonnement |

## 5. Commandes de diagnostic

```bash
# Analyser les performances
flutter run --profile
# Puis ouvrir DevTools: flutter pub global run devtools

# Analyser le code
flutter analyze

# Taille de l'app
flutter build apk --analyze-size
flutter build ios --analyze-size

# Tests avec couverture
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Tests d'intégration sur device
flutter drive --target=test_driver/app.dart
```

## 6. Checklist globale

### Performance
- [ ] 60 FPS maintenu (vérifier avec DevTools)
- [ ] Pas de memory leaks
- [ ] Images optimisées (WebP, taille appropriée)
- [ ] Listes avec pagination ou virtualization
- [ ] Démarrage < 3s (cold start)

### Accessibilité
- [ ] Score Lighthouse Accessibility > 90
- [ ] Navigation clavier fonctionnelle
- [ ] Screen reader compatible
- [ ] Touch targets ≥ 48dp
- [ ] Contraste ≥ 4.5:1

### Responsive
- [ ] Testé sur 320px de large
- [ ] Testé sur 430px de large
- [ ] Testé en landscape
- [ ] SafeArea utilisé
- [ ] Pas de débordements

### Stabilité
- [ ] Crash-free rate > 99.5%
- [ ] Gestion des erreurs réseau
- [ ] État restauré après kill
- [ ] Deep links fonctionnels

## Output attendu

### Résumé

```
Score Performance: [X/100]
Score Accessibilité: [X/100]
Score Responsive: [X/100]
Score Global: [X/100]
```

### Problèmes identifiés

| Sévérité | Catégorie | Description | Solution | Fichier |
|----------|-----------|-------------|----------|---------|
| Critique | Perf | Jank sur scroll | ListView.builder | list_page.dart:45 |
| Haute | A11Y | Touch target < 48dp | Ajouter padding | icon_button.dart:12 |
| Moyenne | Responsive | Overflow sur iPhone SE | Utiliser Flexible | header.dart:78 |
| Basse | Perf | Image non optimisée | Utiliser cached_network_image | avatar.dart:23 |

### Métriques détaillées

```
Startup Time (cold): 2.3s
Startup Time (warm): 0.8s
Memory Usage (idle): 85MB
Memory Usage (peak): 156MB
Frame Build Time (avg): 4.2ms
Frame Raster Time (avg): 2.1ms
APK Size: 12.4MB
```

## Agents liés

| Agent | Quand l'utiliser |
|-------|------------------|
| `/dev-flutter` | Corriger les widgets |
| `/qa-perf` | Audit performance approfondi |
| `/qa-a11y` | Accessibilité approfondie |
| `/qa-responsive` | Responsive web détaillé |

---

IMPORTANT: Toujours tester sur de vrais devices, pas seulement les émulateurs.

YOU MUST atteindre 60 FPS sur les devices cibles minimum.

NEVER ignorer les warnings de performance du Flutter DevTools.

Think hard sur l'expérience utilisateur sur des devices variés (vieux téléphones, connexions lentes).
