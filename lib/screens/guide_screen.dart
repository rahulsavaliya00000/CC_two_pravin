import 'package:flutter/material.dart';
import '../link_handler.dart';
import '../config/app_config.dart';

class GuideScreen extends StatefulWidget {
  final String title;
  const GuideScreen({super.key, required this.title});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  bool _isApplying = false;
  bool _isApplied = false;
  double _progress = 0.0;

  int _getHash(String s) {
    int hash = 0;
    for (int i = 0; i < s.length; i++) {
      hash = 31 * hash + s.codeUnitAt(i);
    }
    return hash.abs();
  }

  String _getGuideContent() {
    final lowerTitle = widget.title.toLowerCase();
    
    String baseText = "";
    if (lowerTitle.contains("chroma key") || lowerTitle.contains("remove bg")) {
      baseText = "Step 1: Select your clip in the timeline.\n\nStep 2: Tap on the Chroma Key tool from the bottom menu.\n\nStep 3: Use the color picker to select the green screen background.\n\nStep 4: Adjust the Intensity and Shadow sliders to cleanly remove the background.\n\nPro Tip: Ensure your subject is well-lit before applying Chroma Key for the best edge detection. Common mistake: using a background color that matches the subject's clothing.";
    } else if (lowerTitle.contains("color grade") || lowerTitle.contains("lut")) {
      baseText = "Step 1: Tap the Adjust or Filter tool.\n\nStep 2: Adjust the Brightness, Contrast, and Saturation.\n\nStep 3: Use the HSL sliders to isolate and enhance specific colors.\n\nStep 4: Apply your look to all clips or save it as a preset.\n\nPro Tip: Always color correct (fix white balance and exposure) before applying creative color grades (LUTs). Common mistake: over-saturating skin tones.";
    } else if (lowerTitle.contains("speed curve")) {
      baseText = "Step 1: Select a video clip.\n\nStep 2: Tap the Speed tool, then select Curve.\n\nStep 3: Add beats to the graph and drag them up (to speed up) or down (to slow down).\n\nStep 4: Use optical flow for smooth slow motion.\n\nPro Tip: Speed ramping works best on clips with lots of physical movement (like dancing or action shots). Ensure optical flow is enabled to prevent choppy frames.";
    } else if (lowerTitle.contains("caption") || lowerTitle.contains("text")) {
      baseText = "Step 1: Finish your audio mix.\n\nStep 2: Tap Text > Auto Captions.\n\nStep 3: Select your language and tap Generate.\n\nStep 4: The engine will automatically transcribe speech to text. You can batch-edit the styling.\n\nPro Tip: Use bright, high-contrast fonts (like yellow or white with thick black strokes) for maximum viewer retention on social media.";
    } else if (lowerTitle.contains("export") || lowerTitle.contains("frame rate") || lowerTitle.contains("resolution")) {
      baseText = "Export Settings determine the final quality of your video.\n\n- Resolution: 1080p is standard for social media. Use 4K for maximum quality if your source footage is high-res.\n- Frame Rate: 30fps is cinematic, while 60fps is ultra-smooth for action and gaming footage.\n\nHigher settings will result in larger file sizes.\n\nPro Tip: Don't export in 4K if your original footage was 1080p. It just increases file size without improving quality.";
    } else if (lowerTitle.contains("sound fx") || lowerTitle.contains("font") || lowerTitle.contains("sticker")) {
      baseText = "Step 1: Open the Assets library.\n\nStep 2: Browse or search for specific ${widget.title}.\n\nStep 3: Tap the download icon, then tap the '+' button to add it to your timeline.\n\nStep 4: Drag the edges to adjust duration and position.\n\nPro Tip: Layer multiple sound effects (e.g., a whoosh + a bass drop) to create more impactful transitions.";
    } else if (lowerTitle.startsWith("edit ") || lowerTitle.startsWith("template ") || lowerTitle.startsWith("style ")) {
      baseText = "Opening the ${widget.title} project file...\n\nStep 1: The timeline will load all associated media.\n\nStep 2: Replace the placeholder clips with your own footage.\n\nStep 3: Retain the existing beat-synced transitions and effects.\n\nStep 4: Export your localized version.\n\nPro Tip: Make sure your replacement clips match the length of the placeholder clips to keep the beat sync perfectly intact.";
    } else if (lowerTitle.contains("keyframe") || lowerTitle.contains("track")) {
      baseText = "Step 1: Select a clip or sticker on the timeline.\n\nStep 2: Tap the diamond icon to add a Keyframe.\n\nStep 3: Move forward in the timeline and change the scale or position.\n\nStep 4: The software will automatically animate the movement between the two keyframes.\n\nPro Tip: Ease in and ease out your keyframes to make the animation look natural instead of robotic.";
    } else {
      baseText = "Welcome to the ${widget.title} module.\n\nStep 1: Navigate to the appropriate section in the editor.\n\nStep 2: Configure the settings to match your creative vision.\n\nStep 3: Preview the changes in the player window.\n\nStep 4: Apply the changes to your project.\n\nPro Tip: Always experiment with blending modes when applying new effects. It can drastically change the mood of the edit.";
    }
    
    return baseText;
  }

  void _applyEffect() async {
    setState(() {
      _isApplying = true;
      _progress = 0.0;
    });
    
    // Fake 10-second progress
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _progress = (i + 1) / 100.0;
      });
    }
    
    setState(() {
      _isApplying = false;
    });

    if (mounted) {
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
                  AppStrings.toolProcessingFailed,
                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          content: Text(
            "Server processing limit reached (Error Code 503). Something went wrong while applying ${widget.title} engine assets. Please try again later in 10 minutes.",
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
    final int hash = _getHash(widget.title);
    final int imageIndex = (hash % 4) + 1;
    final List<Color> colors = [Colors.amber, Colors.blueAccent, Colors.pinkAccent, Colors.cyanAccent, Colors.purpleAccent, Colors.greenAccent];
    final Color accentColor = colors[hash % colors.length];
    final List<IconData> icons = [Icons.play_circle_fill, Icons.music_note, Icons.color_lens, Icons.auto_awesome, Icons.speed, Icons.cut, Icons.settings];
    final IconData icon = icons[hash % icons.length];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1E1E1E),
                image: DecorationImage(
                  image: AssetImage("assets/images/template_$imageIndex.jpg"),
                  fit: BoxFit.cover,
                )
              ),
              child: Center(
                child: Icon(icon, size: 64, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "How to use: ${widget.title}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: accentColor),
            ),
            const SizedBox(height: 16),
            Text(
              _getGuideContent(),
              style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.white70),
            ),
            const SizedBox(height: 40),
            
            // Interactive Apply Button Area
            if (!_isApplied && !_isApplying)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Simulate Effect Application", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _applyEffect,
                ),
              )
            else if (_isApplying)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rendering Preview...", style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${(_progress * 100).toInt()}%", style: const TextStyle(color: Colors.white70)),
                  ),
                ],
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Text("Effect Applied Successfully!", style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  const LegalScreen({super.key, required this.title});

  String _getContent() {
    if (title == "Privacy Policy") {
      return AppStrings.privacyPolicyText;
    } else if (title == "Terms & Conditions") {
      return AppStrings.termsAndConditionsText;
    } else if (title == "Open Source Licenses") {
      return AppStrings.openSourceLicensesText;
    }
    return AppStrings.privacyPolicyText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.gold),
            ),
            const SizedBox(height: 24),
            Text(
              _getContent(),
              style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textWhite70),
            ),
          ],
        ),
      ),
    );
  }
}
