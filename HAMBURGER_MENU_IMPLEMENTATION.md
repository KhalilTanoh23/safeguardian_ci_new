# 📱 Hamburger Menu Implementation Guide

## Quick Start

### For Users
1. Tap the **hamburger icon (≡)** in the top-left corner
2. A menu slides in from the left showing navigation options:
   - 🏠 **Accueil** (Home)
   - 👥 **Contacts** (Emergency Contacts)
   - 📦 **Objets** (Valuable Items)
   - 📄 **Documents** (Documents)
3. Tap any option to navigate
4. Menu automatically closes after selection
5. To manually close: tap close button (✕) or the dark overlay

## Technical Implementation

### Files Structure
```
lib/
├── presentation/
│   ├── screens/
│   │   └── dashboard/
│   │       └── dashboard_screen.dart (MODIFIED)
│   └── widgets/
│       ├── custom_hamburger_menu.dart (NEW)
│       ├── cards/
│       ├── ...
```

### Class: CustomHamburgerMenu

**Location:** `lib/presentation/widgets/custom_hamburger_menu.dart`

#### Constructor
```dart
CustomHamburgerMenu({
  required List<HamburgerMenuItem> items,      // Menu items to display
  required Function(int index) onItemSelected, // Selection callback
  required int selectedIndex,                  // Currently selected item
})
```

#### Key Methods

**_toggleMenu()**
- Opens/closes the menu
- Triggers animation controller
- Updates internal state

**_selectItem(int index)**
- Calls callback to parent widget
- Closes menu after selection

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| items | `List<HamburgerMenuItem>` | Navigation items |
| onItemSelected | `Function(int)` | Selection callback |
| selectedIndex | `int` | Current selected item |
| _animationController | `AnimationController` | Manages animations |
| _menuExpandAnimation | `Animation<double>` | Menu expansion progress (0-1) |
| _isMenuOpen | `bool` | Menu visibility state |

### Class: HamburgerMenuItem

**Purpose:** Data model for menu items

```dart
HamburgerMenuItem({
  required IconData icon,      // Material icon
  required String label,       // Display text
  required Color color,        // Item color
})
```

#### Example Usage
```dart
HamburgerMenuItem(
  icon: Icons.home_rounded,
  label: 'Accueil',
  color: const Color(0xFF3B82F6),
)
```

## Integration in DashboardScreen

### 1. Import the Widget
```dart
import 'package:safeguardian_ci_new/presentation/widgets/custom_hamburger_menu.dart';
```

### 2. Define Menu Items
```dart
final hamburgerItems = [
  HamburgerMenuItem(
    icon: Icons.home_rounded,
    label: 'Accueil',
    color: const Color(0xFF3B82F6),
  ),
  HamburgerMenuItem(
    icon: Icons.contacts_rounded,
    label: 'Contacts',
    color: const Color(0xFF10B981),
  ),
  HamburgerMenuItem(
    icon: Icons.inventory_2_rounded,
    label: 'Objets',
    color: const Color(0xFF8B5CF6),
  ),
  HamburgerMenuItem(
    icon: Icons.description_rounded,
    label: 'Documents',
    color: const Color(0xFFF59E0B),
  ),
];
```

### 3. Add to Stack
```dart
Stack(
  children: [
    // ... existing content ...
    
    // Hamburger Menu Overlay
    CustomHamburgerMenu(
      items: hamburgerItems,
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    ),
  ],
)
```

## Code Walkthrough

### Menu Structure (CustomHamburgerMenu)

#### 1. Hamburger Button
```dart
Positioned(
  top: 20,
  left: 20,
  child: GestureDetector(
    onTap: _toggleMenu,
    child: AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Animated hamburger icon (3 lines)
        // Lines rotate and fade based on animation value
      },
    ),
  ),
)
```

#### 2. Dark Overlay
```dart
if (_isMenuOpen)
  GestureDetector(
    onTap: _toggleMenu,  // Close on tap
    child: Container(
      color: Colors.black.withOpacity(0.3),
    ),
  ),
```

#### 3. Menu Panel
```dart
SlideTransition(
  position: Tween<Offset>(
    begin: const Offset(-1, 0),    // Start off-left
    end: Offset.zero,              // End at origin
  ).animate(_menuExpandAnimation),
  child: Container(
    // Menu content
    child: Column(
      children: [
        _buildHeader(),    // SafeGuardian header
        _buildMenuItems(), // ListView of items
      ],
    ),
  ),
)
```

#### 4. Menu Items
```dart
ListView.builder(
  itemCount: widget.items.length,
  itemBuilder: (context, index) {
    final item = widget.items[index];
    final isSelected = widget.selectedIndex == index;
    
    return InkWell(
      onTap: () => _selectItem(index),
      child: Container(
        // Item styling with color coding
        // Shows check icon if selected
      ),
    );
  },
)
```

## Customization Guide

### Change Menu Item Colors
Edit `dashboard_screen.dart` in the `build()` method:

```dart
hamburgerItems = [
  HamburgerMenuItem(
    icon: Icons.home_rounded,
    label: 'Accueil',
    color: const Color(0xFF00FF00),  // Change to green
  ),
  // ... other items
];
```

### Change Menu Width
Edit `custom_hamburger_menu.dart` in the `build()` method:

```dart
Container(
  width: MediaQuery.of(context).size.width * 0.50,  // Change from 0.75 to 0.50
  // ...
)
```

### Change Animation Duration
Edit `custom_hamburger_menu.dart` in `initState()`:

```dart
_animationController = AnimationController(
  duration: const Duration(milliseconds: 600),  // Change from 400 to 600
  vsync: this,
);
```

### Modify Hamburger Icon Style
Edit `custom_hamburger_menu.dart` in `build()` method:

```dart
Container(
  width: 52,  // Change from 48
  height: 52,
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.3),  // Change opacity
    borderRadius: BorderRadius.circular(20),  // Change radius
  ),
)
```

## State Management

### Flow Diagram
```
User taps hamburger
        ↓
_toggleMenu() called
        ↓
_isMenuOpen = !_isMenuOpen
_animationController.forward/reverse()
        ↓
setState() updates UI
        ↓
CustomHamburgerMenu redraws
```

### Page Navigation Flow
```
User selects menu item
        ↓
_selectItem(index) called
        ↓
widget.onItemSelected(index) callback
        ↓
DashboardScreen._selectedIndex = index
_pageController.animateToPage()
        ↓
PageView updates to new page
        ↓
Menu closes automatically
```

## Performance Optimization

### Animation Performance
- Uses `AnimatedBuilder` for efficient rebuilds
- Only rebuilds animated widgets, not entire menu
- AnimationController properly disposed

### Memory Management
```dart
@override
void dispose() {
  _animationController.dispose();  // Release resources
  super.dispose();
}
```

### ListView Performance
- Uses `ListView.builder()` for efficient item rendering
- Only builds visible menu items
- Smooth scrolling even with many items

## Testing Checklist

### Functional Tests
- [ ] Menu opens on hamburger tap
- [ ] Menu closes on close button tap
- [ ] Menu closes on overlay tap
- [ ] Menu closes on item selection
- [ ] Correct page loads on item selection
- [ ] Selected item shows highlight and checkmark
- [ ] All 4 menu items are accessible

### Animation Tests
- [ ] Hamburger icon animates smoothly
- [ ] Menu slides in/out smoothly
- [ ] No animation jank or stuttering
- [ ] Animation timing feels responsive

### Edge Cases
- [ ] Menu works in landscape mode
- [ ] Menu works on small screens
- [ ] Menu works on large screens
- [ ] Rapid taps don't break state
- [ ] Back button closes menu if open
- [ ] Safe area handled correctly

### Accessibility Tests
- [ ] Touch targets are at least 48x48px
- [ ] Colors have sufficient contrast
- [ ] Text is readable at all sizes
- [ ] Screen reader can navigate menu

## Debugging Tips

### Menu Not Opening
Check:
1. `_toggleMenu()` is being called
2. `_animationController` is initialized
3. `_isMenuOpen` state changes
4. No exceptions in console

### Animation Not Smooth
Check:
1. AnimationController duration isn't too short
2. No heavy computations in build
3. FPS is stable (60fps)
4. No other animations conflicting

### Items Not Tappable
Check:
1. `InkWell` onTap callback is set
2. `_selectItem()` is being called
3. `onItemSelected` callback triggers
4. No widget covering the items

### Menu Not Closing
Check:
1. Animation completes before close
2. State update happens in `_selectItem()`
3. No errors in callbacks
4. Widget is properly disposed

## Future Enhancements

### Potential Features
- [ ] Swipe gesture to open/close
- [ ] Menu badges (notification counts)
- [ ] Keyboard shortcuts
- [ ] Remember last selected item
- [ ] Custom animations
- [ ] Dark theme support
- [ ] Menu search feature

### Performance Improvements
- [ ] Lazy load menu on first open
- [ ] Cache menu items
- [ ] Optimize rebuild on theme change
- [ ] Add animation frame rate limiting

### UX Improvements
- [ ] Add haptic feedback on selection
- [ ] Add sound effect options
- [ ] Customizable menu order
- [ ] Menu position options (left/right)

---

## Common Issues & Solutions

### Issue: Menu appears behind content
**Solution:** Ensure `CustomHamburgerMenu` is last child in Stack
```dart
Stack(
  children: [
    // Other content first
    CustomHamburgerMenu(  // Last child
      // ...
    ),
  ],
)
```

### Issue: Selected index doesn't update
**Solution:** Ensure callback updates parent state
```dart
onItemSelected: (index) {
  setState(() => _selectedIndex = index);  // Don't forget setState!
  _pageController.animateToPage(index, ...);
}
```

### Issue: Animation stutters
**Solution:** Check if animations conflict
- Reduce other animations while menu is open
- Check device performance settings
- Profile with DevTools

### Issue: Menu doesn't close on item select
**Solution:** Ensure `_toggleMenu()` is called in `_selectItem()`
```dart
void _selectItem(int index) {
  widget.onItemSelected(index);
  _toggleMenu();  // This must be called!
}
```

---

**Last Updated:** 2024-12-27  
**Status:** ✅ Ready for Development  
**Difficulty:** Easy to Moderate  
