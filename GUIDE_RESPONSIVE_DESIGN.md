# Guide d'utilisation Responsive Design 📱💻🖥️

## Vue d'ensemble

SafeGuardian CI est maintenant entièrement responsive et s'adapte à tous les types d'appareils:
- **Petits téléphones** (< 360px)
- **Téléphones** (360-599px)
- **Tablettes** (600-1199px)
- **Ordinateurs de bureau** (≥ 1200px)

## Utilisation dans vos widgets

### 1. Utiliser ResponsiveHelper (Méthode recommandée)

```dart
import 'package:safeguardian_ci_new/core/utils/responsive_helper.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Padding(
      padding: EdgeInsets.all(responsive.paddingMedium),
      child: Text(
        'Bienvenue',
        style: TextStyle(
          fontSize: responsive.fontSizeLarge,
        ),
      ),
    );
  }
}
```

### 2. Utiliser ResponsiveMixin

```dart
import 'package:safeguardian_ci_new/core/mixins/responsive_mixin.dart';

class MyScreen extends StatelessWidget with ResponsiveMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: getResponsivePadding(context),
      child: isTablet(context) 
        ? buildTabletLayout(context)
        : buildMobileLayout(context),
    );
  }
}
```

### 3. Utiliser ResponsiveTheme

```dart
import 'package:safeguardian_ci_new/core/theme/responsive_theme.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Titre',
      style: ResponsiveTheme.getHeadline1(context),
    );
  }
}
```

### 4. Utiliser les widgets responsives

```dart
import 'package:safeguardian_ci_new/presentation/widgets/responsive/responsive_widgets.dart';

// Layout adaptatif automatique
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)

// Container avec largeur maximale
ResponsiveContainer(
  maxWidth: 1200,
  padding: EdgeInsets.all(16),
  child: MyContent(),
)

// GridView responsive
ResponsiveGridView(
  children: items,
  crossAxisCount: (context) => ResponsiveMixin.getGridColumns(context),
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
)

// Text responsive
ResponsiveText(
  'Mon texte',
  baseStyle: TextStyle(fontSize: 16),
)
```

## Propriétés disponibles dans ResponsiveHelper

### Détection des appareils
```dart
responsive.isMobile      // true si < 600px
responsive.isTablet      // true si 600-1199px
responsive.isDesktop     // true si >= 1200px
responsive.isPortrait    // true si orientation portrait
responsive.isLandscape   // true si orientation paysage
```

### Espacement adaptatif
```dart
responsive.paddingSmall      // 4% de la largeur
responsive.paddingMedium     // 5% de la largeur
responsive.paddingLarge      // 6% de la largeur
responsive.spacerSmall       // 8
responsive.spacerMedium      // 16
responsive.spacerLarge       // 24
responsive.spacerXLarge      // 32
```

### Tailles de police
```dart
responsive.fontSizeSmall     // 12-16px selon device
responsive.fontSizeNormal    // 14-18px selon device
responsive.fontSizeMedium    // 16-20px selon device
responsive.fontSizeLarge     // 18-24px selon device
responsive.fontSizeTitle     // 24-36px selon device
```

### Tailles des composants
```dart
responsive.buttonHeight      // 48-60px selon device
responsive.appBarHeight      // 56-72px selon device
responsive.bottomNavHeight   // 56-70px selon device
responsive.iconSizeSmall     // 20-28px selon device
responsive.iconSizeMedium    // 24-32px selon device
responsive.iconSizeLarge     // 28-40px selon device
```

### Layouts
```dart
responsive.gridColumns       // 1-5 colonnes selon device
responsive.listColumns       // 1-4 colonnes selon device
responsive.maxContentWidth   // largeur max selon device
```

### Géométrie adaptative
```dart
responsive.radiusSmall       // 8-12px selon device
responsive.radiusMedium      // 12-16px selon device
responsive.radiusLarge       // 16-24px selon device
```

## Propriétés disponibles dans ResponsiveMixin

```dart
// Vérifications
isSmallPhone(context)
isPhone(context)
isTablet(context)
isDesktop(context)
isPortrait(context)
isLandscape(context)

// Dimensions
getScreenWidth(context)
getScreenHeight(context)
widthPercent(context, 50)  // 50% de la largeur
heightPercent(context, 30) // 30% de la hauteur

// Valeurs responsives génériques
getResponsiveValue<T>(
  context: context,
  mobile: 'Mobile',
  tablet: 'Tablet',
  desktop: 'Desktop',
)

// Layouts
getGridColumns(context)
getResponsivePadding(context)
getMaxContentWidth(context)

// Composants
getAppBarHeight(context)
getButtonHeight(context)
getIconSize(context, size: 'large')
getFontSize(context, size: 'heading')

// Utilitaires
getItemsPerRow(context, 100) // Nombre d'items de 100px par ligne
```

## Propriétés disponibles dans ResponsiveTheme

```dart
// TextStyle responsives
ResponsiveTheme.getHeadline1(context)
ResponsiveTheme.getHeadline2(context)
ResponsiveTheme.getHeadline3(context)
ResponsiveTheme.getBodyText(context)
ResponsiveTheme.getSmallText(context)

// Dimensions
ResponsiveTheme.getAppBarHeight(context)
ResponsiveTheme.getButtonHeight(context)
ResponsiveTheme.getButtonWidth(context)
ResponsiveTheme.getCardWidth(context)
ResponsiveTheme.getDialogWidth(context)

// Layouts
ResponsiveTheme.getGridColumns(context)

// Espacements
ResponsiveTheme.getSpacing(context, size: 'md')
ResponsiveTheme.getBorderRadius(context, size: 'medium')
```

## Breakpoints définis

```dart
const double mobileBreakpoint = 600;      // Mobile < 600px
const double tabletBreakpoint = 900;      // Tablet 600-899px
const double desktopBreakpoint = 1200;    // Desktop >= 1200px
```

## Exemples pratiques

### Exemple 1: Layout adaptatif avec GridView
```dart
import 'package:safeguardian_ci_new/core/utils/responsive_helper.dart';

class ItemGrid extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return GridView.count(
      crossAxisCount: responsive.gridColumns,
      mainAxisSpacing: responsive.paddingMedium,
      crossAxisSpacing: responsive.paddingMedium,
      padding: EdgeInsets.all(responsive.paddingLarge),
      children: items.map((item) => ItemCard(item: item)).toList(),
    );
  }
}
```

### Exemple 2: Widget conditionnel
```dart
import 'package:safeguardian_ci_new/core/mixins/responsive_mixin.dart';

class Dashboard extends StatelessWidget with ResponsiveMixin {
  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) {
      return DesktopDashboard();
    } else if (isTablet(context)) {
      return TabletDashboard();
    } else {
      return MobileDashboard();
    }
  }
}
```

### Exemple 3: Contenu avec largeur maximale
```dart
import 'package:safeguardian_ci_new/presentation/widgets/responsive/responsive_widgets.dart';

class CenteredContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      maxWidth: 1200,
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Titre'),
          SizedBox(height: 24),
          Text('Contenu principal'),
        ],
      ),
    );
  }
}
```

### Exemple 4: Texte adaptatif
```dart
import 'package:safeguardian_ci_new/presentation/widgets/responsive/responsive_widgets.dart';

ResponsiveText(
  'Mon texte qui s\'adapte',
  baseStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
)
```

### Exemple 5: Padding adaptatif
```dart
import 'package:safeguardian_ci_new/presentation/widgets/responsive/responsive_widgets.dart';

ResponsivePadding(
  padding: (context) => EdgeInsets.all(
    context.responsive.paddingMedium,
  ),
  child: MyChild(),
)
```

## Points importants

1. **Toujours utiliser `context`** pour accéder aux infos responsive
2. **Tester sur plusieurs appareils**: émulateurs mobile, tablette, web
3. **Préférer les pourcentages** pour les dimensions principales
4. **Utiliser l'orientation** pour adapter les layouts
5. **Tester en paysage et portrait** sur tous les devices
6. **Éviter les tailles fixes** - utiliser les helpers responsives

## Conseils de performance

- Les propriétés responsive sont recalculées à chaque build (c'est rapide)
- Mettre en cache les valeurs si nécessaire dans initState
- Utiliser LayoutBuilder pour les cas complexes
- Tester avec DevTools pour vérifier les performances

## Ressources

- [MediaQuery Documentation](https://api.flutter.dev/flutter/widgets/MediaQuery-class.html)
- [LayoutBuilder Documentation](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)
- [Responsive Flutter Guide](https://flutter.dev/docs/development/ui/layout/adaptive-responsive)

---

**L'application s'adapte maintenant parfaitement à tous les appareils! 🎉**
