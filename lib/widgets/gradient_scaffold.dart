import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A scaffold that renders the purple gradient background used across
/// all screens in the new design. Drop-in replacement for [Scaffold].
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: AppTheme.scaffoldGradient,
        child: body,
      ),
    );
  }
}

/// A transparent AppBar designed for use on gradient backgrounds.
/// White title, white icons, no shadow.
AppBar gradientAppBar({
  required String title,
  List<Widget>? actions,
  bool showBack = true,
  VoidCallback? onBack,
  BuildContext? context,
}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    foregroundColor: Colors.white,
    leading: showBack
        ? Builder(
            builder: (ctx) => IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: onBack ?? () => Navigator.of(ctx).pop(),
                ))
        : null,
    automaticallyImplyLeading: showBack,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    actions: actions,
  );
}
