import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/theme/app_theme.dart';

class CinematicScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const CinematicScaffold({
    Key? key,
    required this.child,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: AppColors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.charcoal,
              Color(0xFF0B1428),
              AppColors.black,
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const GlassIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.48),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x44FFFFFF)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class MovieImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const MovieImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.surfaceHigh,
        child: const Icon(Icons.movie_creation_outlined,
            color: AppColors.muted, size: 38),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceHigh,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceHigh,
        child: const Icon(Icons.broken_image_outlined,
            color: AppColors.muted, size: 34),
      ),
    );
  }
}

class MetaChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const MetaChip({
    Key? key,
    required this.label,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.gold),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppText.muted.copyWith(color: AppColors.text)),
        ],
      ),
    );
  }
}

class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const StateMessage({
    Key? key,
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.gold, size: 34),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppText.title, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: AppText.muted, textAlign: TextAlign.center),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Try again"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingPosterGrid extends StatelessWidget {
  const LoadingPosterGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.surfaceHigh],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

class FilmLoadingIndicator extends StatefulWidget {
  final String label;

  const FilmLoadingIndicator({
    Key? key,
    this.label = "Loading",
  }) : super(key: key);

  @override
  State<FilmLoadingIndicator> createState() => _FilmLoadingIndicatorState();
}

class _FilmLoadingIndicatorState extends State<FilmLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 116,
                height: 7,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.28 + (_controller.value * 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(widget.label, style: AppText.muted),
        ],
      ),
    );
  }
}

class AppSplash extends StatefulWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AppSplash({
    Key? key,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  State<AppSplash> createState() => _AppSplashState();
}

class _AppSplashState extends State<AppSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: CinematicScaffold(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.96 + (_controller.value * 0.05),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 92,
                      height: 126,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: 0.18),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_movies_rounded,
                        color: AppColors.gold,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text("Film Science", style: AppText.hero),
                  const SizedBox(height: 8),
                  Text("Discover. Save. Quote.", style: AppText.muted),
                  const SizedBox(height: 28),
                  if (widget.errorMessage == null)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: SizedBox(
                            width: 180,
                            height: 5,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: 0.35 + (_controller.value * 0.45),
                                  backgroundColor: AppColors.surfaceHigh,
                                  color: AppColors.gold,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Preparing your movie shelf...",
                          style: AppText.muted,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          widget.errorMessage!,
                          style: AppText.muted,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: widget.onRetry,
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
