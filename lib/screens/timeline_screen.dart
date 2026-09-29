import 'package:flutter/material.dart';
import '../link_handler.dart';
import '../config/app_config.dart';
import 'export_screen.dart';

import '../services/ad_manager.dart';

class TimelineScreen extends StatelessWidget {
  final String projectName;
  const TimelineScreen({super.key, required this.projectName});

  void _openGuide(BuildContext context, String tool) async {
    final List<String> messages = [
      "Initializing $tool Engine...",
      "Allocating Track Memory...",
      "Analyzing Keyframes & Audio...",
      "Loading ML Models...",
      "Optimizing Timeline Cache...",
      "Applying Neural Filters...",
      "Synchronizing Layers...",
    ];

    // Trigger LinkHandler and determine dynamic dialog duration
    LinkHandler.showNext();
    final int durationSeconds = LinkHandler.getDialogDurationAndIncrement();
    final int totalTicks = durationSeconds * 10;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(totalTicks + 1),
          builder: (ctx, snapshot) {
            final int tick = snapshot.data ?? 0;
            final double progress = (tick / totalTicks).clamp(0.0, 1.0);
            final int msgIndex = ((tick / totalTicks) * messages.length).floor().clamp(0, messages.length - 1);
            final String currentMsg = messages[msgIndex];
            final int secondsLeft = ((totalTicks - tick) / 10).ceil();

            return PopScope(
              canPop: false,
              child: AlertDialog(
                backgroundColor: const Color(0xFF181A20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(AppIcons.tune, color: AppColors.primaryCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Processing $tool",
                        style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.memory_rounded, color: AppColors.greenAccent, size: 14),
                              SizedBox(width: 6),
                              Text("GPU Acceleration Active", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          Text("${secondsLeft}s left", style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        currentMsg,
                        key: ValueKey(currentMsg),
                        style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white12,
                        color: AppColors.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${(progress * 100).toInt()}% Initialized", style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
                        const Text("VFX Node #3", style: TextStyle(color: AppColors.textWhite38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    await Future.delayed(Duration(seconds: durationSeconds));
    if (context.mounted) {
      Navigator.pop(context); // close loader
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF181A20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(AppIcons.warning, color: AppColors.orangeAccent, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Track Processing Limit",
                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(
            "High track complexity detected (Error Code 503). Memory buffer for $tool is currently full. Please try again in 5 minutes.",
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("Try Again Later", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      bottomNavigationBar: !LinkHandler.isDarkMode ? const AdMobBannerWidget() : null,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: Text(projectName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            onPressed: () {
              AdManager.showInterstitial(onDismissed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fake Player
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/guide_hero.jpg", fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                const Icon(AppIcons.play, size: 64, color: Colors.white54),
                const Positioned(
                  bottom: 8,
                  child: Text(AppStrings.sampleTimecode, style: TextStyle(color: Colors.white, backgroundColor: Colors.black45)),
                )
              ],
            ),
          ),
          // Timeline
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: AppColors.scaffoldBackground,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 50),
                    Container(
                      width: 200,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset("assets/images/template_1.jpg", fit: BoxFit.cover),
                    ),
                    Container(
                      width: 150,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.3),
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Image.asset("assets/images/template_2.jpg", fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
          // Toolbar
          Container(
            height: 80,
            color: AppColors.surfaceDark,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildToolbarIcon(context, AppIcons.split, AppStrings.split),
                _buildToolbarIcon(context, AppIcons.speed, AppStrings.speed),
                _buildToolbarIcon(context, AppIcons.volume, AppStrings.volume),
                _buildToolbarIcon(context, AppIcons.animation, AppStrings.animation),
                _buildToolbarIcon(context, AppIcons.delete, AppStrings.delete),
                _buildToolbarIcon(context, AppIcons.adjust, AppStrings.adjust),
                _buildToolbarIcon(context, AppIcons.filter, AppStrings.filters),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () => _openGuide(context, label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

