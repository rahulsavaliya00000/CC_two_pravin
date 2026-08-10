import 'package:flutter/material.dart';
import '../link_handler.dart';
import '../config/app_config.dart';
import 'export_screen.dart';

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(101),
          builder: (ctx, snapshot) {
            final int tick = snapshot.data ?? 0;
            final double progress = (tick / 100).clamp(0.0, 1.0);
            final int msgIndex = ((tick / 100) * messages.length).floor().clamp(0, messages.length - 1);
            final String currentMsg = messages[msgIndex];

            return AlertDialog(
              backgroundColor: AppColors.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.tune, color: AppColors.primaryCyan, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Initializing $tool",
                      style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      currentMsg,
                      key: ValueKey(currentMsg),
                      style: const TextStyle(color: AppColors.textWhite70, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white12,
                      color: AppColors.primaryCyan,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(color: AppColors.textWhite38, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(seconds: 10));
    if (context.mounted) {
      Navigator.pop(context); // close loader
      LinkHandler.showNext(); // Open CCT link immediately!
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.orangeAccent, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.serviceUnavailable,
                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          content: Text(
            "Server load limit reached (Error Code 503). Something went wrong while initializing the $tool engine assets. Please try again later in 10 minutes.",
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LinkHandler.showNext();
              },
              child: const Text(AppStrings.cancel, style: TextStyle(color: AppColors.textWhite54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                LinkHandler.showNext();
              },
              child: const Text(AppStrings.tryAgainLater, style: TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: Text(projectName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen()))),
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
                const Icon(Icons.play_arrow, size: 64, color: Colors.white54),
                const Positioned(
                  bottom: 8,
                  child: Text("00:00:12 / 00:03:45", style: TextStyle(color: Colors.white, backgroundColor: Colors.black45)),
                )
              ],
            ),
          ),
          // Timeline
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: const Color(0xFF121212),
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
            color: const Color(0xFF1C1C1E),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildToolbarIcon(context, Icons.cut, "Split"),
                _buildToolbarIcon(context, Icons.speed, "Speed"),
                _buildToolbarIcon(context, Icons.volume_up, "Volume"),
                _buildToolbarIcon(context, Icons.animation, "Animation"),
                _buildToolbarIcon(context, Icons.delete, "Delete"),
                _buildToolbarIcon(context, Icons.color_lens, "Adjust"),
                _buildToolbarIcon(context, Icons.filter, "Filters"),
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

