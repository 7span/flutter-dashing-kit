---
trigger: always_on
glob:
description: "Flutter Assets Management Rule (flutter_gen)"
---


## Overview
This rule enforces the use of `flutter_gen` package for type-safe asset management in Flutter projects, replacing raw string asset paths with generated code.

## Rule Application

### ❌ NEVER Use Raw String Paths
**Avoid this pattern:**
```dart
// DON'T DO THIS
Image.asset("assets/demo.png")
Image.asset("assets/icons/home.svg")
Image.asset("assets/images/profile.jpg")
```

### ✅ ALWAYS Use Generated Asset Classes
**Use this pattern instead:**
```dart
// DO THIS
Assets.images.demo.image()
Assets.icons.home.svg()
Assets.images.profile.image()
```

## Implementation Steps

### 1. Asset Placement
- **ALWAYS** add assets to the `assets` folder in the **app_ui** package
- Organize assets by type (images, icons, fonts, etc.)
- Use descriptive, snake_case naming for asset files

### 2. Directory Structure
```
app_ui/
├── assets/
│   ├── images/
│   │   ├── demo.png
│   │   ├── profile.jpg
│   │   └── background.png
│   ├── icons/
│   │   ├── home.svg
│   │   ├── search.svg
│   │   └── settings.svg
│   └── fonts/
│       └── custom_font.ttf
```

### 3. Code Generation
After adding new assets, **ALWAYS** run:
```bash
melos run asset-gen
```

### 4. Usage Patterns

#### Images
```dart
// For PNG/JPG images
Assets.images.demo.image()
Assets.images.profile.image()
Assets.images.background.image()

// With additional properties
Assets.images.demo.image(
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

#### SVG Icons
```dart
// For SVG assets
Assets.icons.home.svg()
Assets.icons.search.svg()
Assets.icons.settings.svg()

// With color and size
Assets.icons.home.svg(
  color: Colors.blue,
  width: 24,
  height: 24,
)
```

#### Raw Asset Paths (when needed)
```dart
// If you need the path string
Assets.images.demo.path
Assets.icons.home.path
```

## Asset Type Mappings

### Common Asset Extensions and Usage
| Extension | Usage Pattern | Example |
|-----------|---------------|---------|
| `.png`, `.jpg`, `.jpeg` | `.image()` | `Assets.images.photo.image()` |
| `.svg` | `.svg()` | `Assets.icons.star.svg()` |
| `.json` | `.path` | `Assets.animations.loading.path` |
| `.ttf`, `.otf` | Reference in theme | Font family name |

## Implementation Checklist

### Adding New Assets:
- [ ] Place asset in appropriate folder within `app_ui/assets/`
- [ ] Use descriptive, snake_case naming
- [ ] Run `melos run asset-gen` command
- [ ] Verify asset appears in generated `Assets` class
- [ ] Update existing raw string references to use generated code

### Code Review Checklist:
- [ ] No raw string asset paths (`"assets/..."`)
- [ ] All assets use `Assets.category.name.method()` pattern
- [ ] Asset generation command run after adding new assets
- [ ] Unused assets removed from assets folder

## Common Patterns

### Image Widget
```dart
// Basic image
Assets.images.logo.image()

// Image with properties
Assets.images.banner.image(
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
)

// Image in Container
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: Assets.images.background.provider(),
      fit: BoxFit.cover,
    ),
  ),
)
```

### SVG Usage
```dart
// Basic SVG
Assets.icons.menu.svg()

// Styled SVG
Assets.icons.heart.svg(
  color: theme.primaryColor,
  width: 20,
  height: 20,
)

// SVG in IconButton
IconButton(
  onPressed: () {},
  icon: Assets.icons.settings.svg(),
)
```

### Asset Provider (for advanced usage)
```dart
// For use with other widgets that need ImageProvider
CircleAvatar(
  backgroundImage: Assets.images.avatar.provider(),
)

// For precaching
precacheImage(Assets.images.splash.provider(), context);
```

## Best Practices

### Naming Conventions
- Use `snake_case` for asset file names
- Be descriptive: `user_profile.png` instead of `img1.png`
- Group related assets: `icon_home.svg`, `icon_search.svg`

### Organization
- **images/**: Photos, illustrations, backgrounds
- **icons/**: SVG icons, small graphics
- **animations/**: Lottie files, GIFs
- **fonts/**: Custom font files

### Performance
- Use appropriate image formats (SVG for icons, PNG/JPG for photos)
- Optimize image sizes before adding to assets
- Consider using `precacheImage()` for critical images

## Migration from Raw Strings

### Find and Replace Pattern
1. Search for: `Image.asset("assets/`
2. Replace with appropriate `Assets.` pattern
3. Run asset generation if needed
4. Test all asset references

### Example Migration
```dart
// Before
Image.asset("assets/images/logo.png", width: 100)

// After  
Assets.images.logo.image(width: 100)
```

## Troubleshooting

### Asset Not Found
1. Verify asset exists in `app_ui/assets/` folder
2. Check file naming (no spaces, special characters)
3. Run `melos run asset-gen` command
4. Restart IDE/hot restart app

### Generated Code Not Updated
1. Run `melos run asset-gen` command
2. Check for build errors in terminal
3. Verify `flutter_gen` is properly configured in `pubspec.yaml`
4. Clean and rebuild project if necessary