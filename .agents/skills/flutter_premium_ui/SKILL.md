---
name: Flutter Premium UI Design System
description: Best practices for creating visually stunning, presentation-ready Flutter applications.
---

# Premium Flutter UI/UX Best Practices

When tasked with making a Flutter application look "premium", "ambitious", or "presentation-ready", follow these core principles:

## 1. Typography represents 50% of the design
- Use modern, geometric, or neo-grotesque sans-serif fonts instead of Roboto.
- **Top Picks:** `GoogleFonts.outfit()`, `GoogleFonts.plusJakartaSans()`, `GoogleFonts.poppins()`, `GoogleFonts.manrope()`.
- **Hierarchy:** Ensure strong contrast between titles (bold, large, tight tracking) and body text (regular, softer color, looser tracking).

## 2. Depth and Shadows
- Avoid default generic drop shadows (`blurRadius: 4`).
- Use **Soft, diffuse shadows**: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: Offset(0, 8))`
- Colored shadows for primary buttons: `BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: Offset(0, 4))`

## 3. Glassmorphism (Frosted Glass)
- Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` wrapped over a semi-transparent container `Color(0xFFFFFF).withOpacity(0.2)`.
- Add a subtle 1px border with a linear gradient (white to transparent) to simulate the glass edge.

## 4. Micro-Animations
- Static screens feel dead. Use the `flutter_animate` package to bring elements to life.
- **Staggered entry:** List items should slide up and fade in sequentially.
  - Usage: `child.animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0)`
- **Interaction:** Buttons should scale down slightly on tap (`ScaleTransition` or `GestureDetector` logic).

## 5. Color Palettes
- Don't use raw Material colors (`Colors.blue`). Use curated hex codes.
- Use **Mesh Gradients** or rich linear gradients for hero sections and important buttons.
- Keep the background off-white (e.g., `#F8F9FA`) rather than pure white to reduce eye strain and make white cards pop.

## 6. Border Radii
- Use "Squircle" shapes. In Flutter, use `ContinuousRectangleBorder(borderRadius: BorderRadius.circular(32))` instead of standard `RoundedRectangleBorder` for a smoother, iOS-like curve.

---
*Reference these principles whenever overhauling a UI.*
