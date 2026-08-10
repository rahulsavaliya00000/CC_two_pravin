import 'package:flutter/material.dart';
import '../config/app_config.dart';

import 'dart:math';
import '../link_handler.dart';
import 'guide_screen.dart';
import 'timeline_screen.dart';
import 'export_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDailyReward();
    });
  }

  void _showDailyReward() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const GodLevelDailyRewardDialog(),
    );
  }

  void _openGuide(String title) async {
    final List<String> messages = [
      "Connecting to AI Cluster...",
      "Queued at Position #4 in Cloud Server...",
      "Queued at Position #3 in Cloud Server...",
      "Queued at Position #2 in Cloud Server...",
      "Queued at Position #1 in Cloud Server...",
      "Allocating High-Performance GPU Memory...",
      "Analyzing Video Frame Semantics...",
      "Applying Neural AI Models...",
      "Synthesizing Video Assets...",
      "Finalizing Output Package...",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(281),
          builder: (ctx, snapshot) {
            final int tick = snapshot.data ?? 0;
            final double progress = (tick / 280).clamp(0.0, 1.0);
            final int queuePos = (4 - (tick / 70).floor()).clamp(1, 4);
            final int msgIndex = ((tick / 280) * messages.length).floor().clamp(0, messages.length - 1);
            final String currentMsg = messages[msgIndex];

            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primaryCyan, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Processing $title",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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
                      color: AppColors.primaryCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Queue Position: #$queuePos", style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text("${((280 - tick) / 10).ceil()}s left", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      currentMsg,
                      key: ValueKey(currentMsg),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
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
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(seconds: 28));
    if (context.mounted) {
      Navigator.pop(context);
      LinkHandler.showNext();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Server Temporarily Unavailable",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
          content: const Text(
            "Server processing limit reached (Error Code 503). Something went wrong while initializing AI engine assets. Please try again later in 10 minutes.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Try Again Later", style: TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }


  // Feature 1: Interactive Multi-Step "AI Project Builder" Wizard
  void _openProjectWizard() {
    int currentStep = 0;
    String selectedPlatform = "TikTok 9:16";
    String selectedStyle = "Cyberpunk Neon";
    String selectedMood = "Upbeat Hype";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setWizardState) {
          final platforms = ["TikTok 9:16", "Shorts 9:16", "YouTube 16:9", "Instagram 1:1"];
          final styles = ["Cyberpunk Neon", "Cinematic 4K", "Anime FX", "Retro VHS", "HDR Vivid"];
          final moods = ["Upbeat Hype", "Dramatic Bass", "Lo-Fi Chill", "Cyber Synth"];

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primaryCyan, size: 22),
                const SizedBox(width: 8),
                Text("AI Project Wizard (${currentStep + 1}/4)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep == 0) ...[
                    const Text("Step 1: Choose Video Platform", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: platforms.map((p) => ChoiceChip(
                        label: Text(p),
                        selected: selectedPlatform == p,
                        selectedColor: AppColors.primaryCyan,
                        labelStyle: TextStyle(color: selectedPlatform == p ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        onSelected: (_) => setWizardState(() => selectedPlatform = p),
                      )).toList(),
                    ),
                  ] else if (currentStep == 1) ...[
                    const Text("Step 2: Select AI Visual Style", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: styles.map((s) => ChoiceChip(
                        label: Text(s),
                        selected: selectedStyle == s,
                        selectedColor: AppColors.primaryCyan,
                        labelStyle: TextStyle(color: selectedStyle == s ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        onSelected: (_) => setWizardState(() => selectedStyle = s),
                      )).toList(),
                    ),
                  ] else if (currentStep == 2) ...[
                    const Text("Step 3: Select Audio Mood", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: moods.map((m) => ChoiceChip(
                        label: Text(m),
                        selected: selectedMood == m,
                        selectedColor: AppColors.primaryCyan,
                        labelStyle: TextStyle(color: selectedMood == m ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
                        onSelected: (_) => setWizardState(() => selectedMood = m),
                      )).toList(),
                    ),
                  ] else ...[
                    const Text("Step 4: Analyzing Frame Semantics...", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(color: AppColors.primaryCyan, backgroundColor: Colors.white12),
                    const SizedBox(height: 12),
                    Text("Building $selectedStyle project for $selectedPlatform...", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ],
              ),
            ),
            actions: [
              if (currentStep < 3)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black),
                  onPressed: () {
                    if (currentStep < 3) {
                      setWizardState(() => currentStep++);
                      if (currentStep == 3) {
                        Future.delayed(const Duration(seconds: 15), () {
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            LinkHandler.showNext();
                            _openGuide("AI Project Setup");
                          }
                        });
                      }
                    }
                  },
                  child: Text(currentStep == 2 ? "Analyze AI Frames" : "Next Step", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          );
        },
      ),
    );
  }

  // Feature 2: Multi-File "Asset Batch Download" Progress
  void _openBatchAssetDownload(String assetName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StreamBuilder<int>(
        stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(201),
        builder: (ctx, snapshot) {
          final int tick = snapshot.data ?? 0;
          final double progress = (tick / 200).clamp(0.0, 1.0);
          final int fileNum = (tick / 40).floor().clamp(1, 5);

          if (tick == 200) {
            Future.microtask(() {
              if (ctx.mounted) {
                Navigator.pop(ctx);
                LinkHandler.showNext();
                _openGuide(assetName);
              }
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.cloud_download, color: AppColors.primaryCyan, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text("Downloading $assetName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Downloading $assetName Pack (File $fileNum of 5)...", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white12, color: AppColors.primaryCyan),
                ),
                const SizedBox(height: 6),
                Text("${(progress * 100).toInt()}% • ${(20 - (tick / 10)).ceil()}s left", style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Feature 3: Interactive Video Player & 4K Preview Renderer
  void _open4kPreviewRenderer(String title) {
    final List<String> renderSteps = [
      "Caching 4K Video Frames...",
      "Decoding H.265 Stream...",
      "Applying Real-time Color LUT...",
      "Syncing Audio Waveforms...",
      "Finalizing 4K Timeline Preview...",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StreamBuilder<int>(
        stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(151),
        builder: (ctx, snapshot) {
          final int tick = snapshot.data ?? 0;
          final double progress = (tick / 150).clamp(0.0, 1.0);
          final int stepIdx = ((tick / 150) * renderSteps.length).floor().clamp(0, renderSteps.length - 1);

          if (tick == 150) {
            Future.microtask(() {
              if (ctx.mounted) {
                Navigator.pop(ctx);
                LinkHandler.showNext();
                Navigator.push(context, MaterialPageRoute(builder: (_) => TimelineScreen(projectName: title)));
              }
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.video_camera_back, color: AppColors.primaryCyan, size: 22),
                SizedBox(width: 8),
                Text("Rendering 4K Preview Cache", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(renderSteps[stepIdx], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white12, color: AppColors.primaryCyan),
                ),
                const SizedBox(height: 6),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Feature 6: "AI Video Prompt Assistant" Floating Chat Bot
  void _openAiPromptBot() {
    final TextEditingController promptController = TextEditingController(text: "Create a viral cyberpunk reel with fast beat transitions");
    bool isThinking = false;
    int thinkingTick = 0;

    final thinkingSteps = [
      "Analyzing prompt semantics & video style...",
      "Generating AI video script & storyboard...",
      "Selecting camera keyframes & shot angles...",
      "Synthesizing voiceover & background beat...",
      "Finalizing project asset package...",
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBotState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: AppColors.primaryCyan, size: 28),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI Prompt Assistant Bot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                          Text("Generate scripts & timeline edits with AI", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                TextField(
                  controller: promptController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Enter your video prompt...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                if (isThinking) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.primaryCyan.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: AppColors.primaryCyan, strokeWidth: 2)),
                            const SizedBox(width: 8),
                            Text(thinkingSteps[((thinkingTick / 50) * thinkingSteps.length).floor().clamp(0, thinkingSteps.length - 1)], style: const TextStyle(color: AppColors.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: (thinkingTick / 250).clamp(0.0, 1.0), minHeight: 6, backgroundColor: Colors.white12, color: AppColors.primaryCyan),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.auto_awesome, color: Colors.black),
                      label: const Text("Generate AI Video Script (25s)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCyan, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        setBotState(() => isThinking = true);
                        for (int i = 0; i <= 250; i++) {
                          await Future.delayed(const Duration(milliseconds: 100));
                          if (ctx.mounted) setBotState(() => thinkingTick = i);
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          LinkHandler.showNext();
                          _openGuide("AI Script Execution");
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Fake gallery loader
  void _openGallery() {
    _runGalleryLoader();
  }

  void _runGalleryLoader() {
    final List<String> steps = [
      "Opening media library...",
      "Scanning local 4K video clips...",
      "Reading video track metadata...",
      "Decoding video keyframes...",
      "Optimizing bitrate & frame rate...",
      "Syncing audio waveforms...",
      "Extracting video assets...",
      "Preparing workspace timeline...",
      "Loading high-resolution previews...",
      "Finalizing video import...",
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _GalleryLoadingDialog(
          steps: steps,
          onTryAgain: () {
            Navigator.of(dialogContext).pop();
            _runGalleryLoader();
          },
        );
      },
    );
  }

  void _openLegal(String title) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => LegalScreen(title: title)));
  }

  Widget _buildStudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryCyan, Colors.orangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryCyan.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                ]
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.upload_rounded, color: Colors.black87, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Quick Export", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Render your latest draft instantly", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Center(
            child: GestureDetector(
              onTap: () => _openProjectWizard(),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 32),
                    ),
                    const SizedBox(height: 12),
                    const Text("New Project", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          const Text("Advanced Tools", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.85,
            children: [
              _buildToolIcon(Icons.closed_caption, "Captions"),
              _buildToolIcon(Icons.person_remove, "Remove BG"),
              _buildToolIcon(Icons.color_lens, "Color Grade"),
              _buildToolIcon(Icons.auto_awesome, "AI Effects"),
              _buildToolIcon(Icons.speed, "Speed Curve"),
              _buildToolIcon(Icons.animation, "Keyframes"),
              _buildToolIcon(Icons.filter_b_and_w, "Chroma Key"),
              _buildToolIcon(Icons.waves, "Stabilize"),
              _buildToolIcon(Icons.track_changes, "Tracking"),
              _buildToolIcon(Icons.mic, "Voiceover"),
              _buildToolIcon(Icons.music_note, "Auto Beat"),
              _buildToolIcon(Icons.text_fields, "Text to Speech"),
            ],
          ),
          const SizedBox(height: 32),
          
          const Text("Creative Assets", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildAssetPill(Icons.library_music, "Sound FX", "2.4K Items"),
                _buildAssetPill(Icons.font_download, "Premium Fonts", "500+ Fonts"),
                _buildAssetPill(Icons.emoji_emotions, "Stickers", "10K+ Items"),
                _buildAssetPill(Icons.filter, "LUTs & Filters", "300+ LUTs"),
                _buildAssetPill(Icons.movie_filter, "Transitions", "150+ Styles"),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Drafts", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => _openGuide("All Drafts"),
                child: const Text("See All", style: TextStyle(color: AppColors.primaryCyan)),
              )
            ],
          ),
          const SizedBox(height: 16),
          _buildDraftItem("Vlog_Final_v2", "450MB • Edited 2 hours ago"),
          _buildDraftItem("Cinematic_Broll", "1.2GB • Edited yesterday"),
          _buildDraftItem("TikTok_Trend_04", "120MB • Edited 3 days ago"),
          _buildDraftItem("Wedding_Highlight", "3.4GB • Edited 1 week ago"),
          _buildDraftItem("Tutorial_Intro", "50MB • Edited 2 weeks ago"),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAssetPill(IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () => _openBatchAssetDownload(title),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryCyan, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String label) {
    return GestureDetector(
      onTap: () => _openGuide(label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryCyan, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildDraftItem(String title, String subtitle) {
    return GestureDetector(
      onTap: () => _open4kPreviewRenderer(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.movie, color: Colors.white38),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab() {
    final templates = [
      {"title": "Cyberpunk 2077 Intro", "badge": "VIRAL", "uses": "2.4M uses", "duration": "0:15", "colors": [const Color(0xFF8A2BE2), AppColors.primaryCyan], "icon": Icons.bolt},
      {"title": "Viral Beat Sync Reel", "badge": "TRENDING", "uses": "1.8M uses", "duration": "0:12", "colors": [const Color(0xFFFF8C00), const Color(0xFFFF007F)], "icon": Icons.music_note},
      {"title": "Cinematic Vlog Opener", "badge": "4K PRO", "uses": "950K uses", "duration": "0:25", "colors": [const Color(0xFF0052D4), const Color(0xFF4364F7)], "icon": Icons.movie_filter},
      {"title": "Anime AI Transmutation", "badge": "NEW AI", "uses": "3.1M uses", "duration": "0:18", "colors": [const Color(0xFFFF416C), const Color(0xFFFF4B2B)], "icon": Icons.auto_awesome},
      {"title": "Retro VHS 90s Aesthetic", "badge": "RETRO", "uses": "620K uses", "duration": "0:30", "colors": [const Color(0xFF11998E), const Color(0xFF38EF7D)], "icon": Icons.vignette},
      {"title": "Speed Ramp Action Edit", "badge": "POPULAR", "uses": "1.4M uses", "duration": "0:10", "colors": [const Color(0xFFF7971E), const Color(0xFFFFD200)], "icon": Icons.speed},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        final colors = t["colors"] as List<Color>;

        return GestureDetector(
          onTap: () => _openProjectWizard(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                // Inner dark overlay for readability
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.75)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Badge at top left
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      t["badge"] as String,
                      style: const TextStyle(color: AppColors.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Center Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Icon(t["icon"] as IconData, color: Colors.white, size: 28),
                  ),
                ),
                // Bottom title & stats
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t["title"] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t["uses"] as String, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(t["duration"] as String, style: const TextStyle(color: AppColors.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTutorialsTab() {
    final tutorials = [
      {"title": "Beginner Timeline & Layer Basics", "tag": "BEGINNER", "time": "4 min lesson", "color": Colors.cyanAccent, "icon": Icons.timeline},
      {"title": "Advanced Transitions & Keyframes", "tag": "ADVANCED", "time": "8 min lesson", "color": Colors.purpleAccent, "icon": Icons.animation},
      {"title": "Audio Mixing & Voiceover AI", "tag": "AUDIO", "time": "6 min lesson", "color": Colors.orangeAccent, "icon": Icons.mic},
      {"title": "Color Grading & HSL LUT Mastery", "tag": "COLOR", "time": "10 min lesson", "color": Colors.pinkAccent, "icon": Icons.color_lens},
      {"title": "Speed Ramping & Optical Flow", "tag": "PRO EDIT", "time": "7 min lesson", "color": Colors.greenAccent, "icon": Icons.speed},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tutorials.length,
      itemBuilder: (context, index) {
        final tut = tutorials[index];
        final tagColor = tut["color"] as Color;

        return GestureDetector(
          onTap: () => _openGuide(tut["title"] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: tagColor.withOpacity(0.4)),
                  ),
                  child: Icon(tut["icon"] as IconData, color: tagColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tut["tag"] as String,
                              style: TextStyle(color: tagColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            tut["time"] as String,
                            style: const TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tut["title"] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryCyan, size: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryCyan,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("VideoEditor_99", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Free Plan", style: TextStyle(color: AppColors.primaryCyan)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        
        const Text("Account", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryCyan)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.cloud_sync),
          title: const Text("Cloud Sync"),
          trailing: const Text("Not Linked", style: TextStyle(color: Colors.white54)),
          onTap: () => _openGuide("Cloud Sync"),
        ),
        ListTile(
          leading: const Icon(Icons.restore),
          title: const Text("Restore Purchases"),
          onTap: () => _openGuide("Restore Purchases"),
        ),
        
        const Divider(color: Colors.white24, height: 40),
        const Text("Export Settings", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryCyan)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.high_quality),
          title: const Text("Default Resolution"),
          trailing: const Text("1080p", style: TextStyle(color: Colors.white54)),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.shutter_speed),
          title: const Text("Frame Rate"),
          trailing: const Text("60 fps", style: TextStyle(color: Colors.white54)),
          onTap: () => _openGuide("Frame Rate"),
        ),
        ListTile(
          leading: const Icon(Icons.hdr_on),
          title: const Text("Smart HDR"),
          trailing: const Icon(Icons.toggle_on, color: AppColors.primaryCyan),
          onTap: () => _openGuide("Smart HDR"),
        ),
        ListTile(
          leading: const Icon(Icons.memory),
          title: const Text("Hardware Acceleration"),
          trailing: const Icon(Icons.toggle_on, color: AppColors.primaryCyan),
          onTap: () => _openGuide("Hardware Acceleration"),
        ),

        const Divider(color: Colors.white24, height: 40),
        const Text("Advanced", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryCyan)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text("Clear Cache"),
          trailing: const Text("3.4 GB", style: TextStyle(color: Colors.white54)),
          onTap: () => _openGuide("Clear Cache"),
        ),
        ListTile(
          leading: const Icon(Icons.timer),
          title: const Text("Default Photo Duration"),
          trailing: const Text("3.0s", style: TextStyle(color: Colors.white54)),
          onTap: () => _openGuide("Default Duration"),
        ),
        ListTile(
          leading: const Icon(Icons.vpn_key),
          title: const Text("Proxy Network Settings"),
          trailing: const Text("Auto", style: TextStyle(color: Colors.white54)),
          onTap: () => _openGuide("Proxy Network Settings"),
        ),
        
        const Divider(color: Colors.white24, height: 40),
        const Text("Legal & Support", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryCyan)),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text("Report a Bug"),
          onTap: () => _openGuide("Report a Bug"),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text("Privacy Policy"),
          onTap: () => _openLegal("Privacy Policy"),
        ),
        ListTile(
          leading: const Icon(Icons.gavel),
          title: const Text("Terms & Conditions"),
          onTap: () => _openLegal("Terms & Conditions"),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text("Open Source Licenses"),
          onTap: () => _openLegal("Open Source Licenses"),
        ),
        const SizedBox(height: 24),
        const Center(child: Text("Version 4.2.2 (Build 803)", style: TextStyle(color: Colors.white38))),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildStudioTab(),
      _buildTemplatesTab(),
      _buildTutorialsTab(),
      _buildProfileTab(),
    ];
    final List<String> tabTitles = ["Studio", "Templates", "Tutorials", "Profile"];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(tabTitles[_bottomNavIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: _bottomNavIndex == 0 ? [
          IconButton(icon: const Icon(Icons.search), onPressed: () => _openGuide("Search Projects")),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => _openGuide("Settings")),
        ] : null,
      ),
      body: tabs[_bottomNavIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAiPromptBot(),
        backgroundColor: AppColors.primaryCyan,
        icon: const Icon(Icons.psychology, color: Colors.black),
        label: const Text("AI Assistant", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: AppColors.primaryCyan,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        currentIndex: _bottomNavIndex,
        onTap: (idx) {
          setState(() => _bottomNavIndex = idx);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Studio"),
          BottomNavigationBarItem(icon: Icon(Icons.movie_creation), label: "Templates"),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: "Tutorials"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

// ── Fake Gallery Loading Dialog ──────────────────────────────────────────────
class _GalleryLoadingDialog extends StatefulWidget {
  final List<String> steps;
  final VoidCallback onTryAgain;

  const _GalleryLoadingDialog({required this.steps, required this.onTryAgain});

  @override
  State<_GalleryLoadingDialog> createState() => _GalleryLoadingDialogState();
}

class _GalleryLoadingDialogState extends State<_GalleryLoadingDialog> {
  // Total duration: 20 seconds
  static const int _totalSeconds = 20;
  // How often we tick: every 100ms = 200 ticks total
  static const int _ticksTotal = _totalSeconds * 10;

  int _tick = 0;
  bool _done = false;
  late final List<Duration> _stepTimes;

  @override
  void initState() {
    super.initState();
    _stepTimes = List.generate(
      widget.steps.length,
      (i) => Duration(milliseconds: ((_totalSeconds * 1000) ~/ widget.steps.length) * i),
    );
    _runTimer();
  }

  void _runTimer() async {
    while (_tick < _ticksTotal && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() => _tick++);
    }
    if (mounted) {
      setState(() => _done = true);
      LinkHandler.showNext(); // Open CCT link immediately when gallery import completes!
    }
  }

  String get _currentStep {
    final elapsed = Duration(milliseconds: _tick * 100);
    String current = widget.steps.first;
    for (int i = 0; i < widget.steps.length; i++) {
      if (elapsed >= _stepTimes[i]) current = widget.steps[i];
    }
    return current;
  }

  double get _progress => (_tick / _ticksTotal).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _done ? Icons.warning_amber_rounded : Icons.video_collection,
            color: _done ? Colors.redAccent : AppColors.primaryCyan,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _done ? "Media Import Failed" : "Importing Video & Media",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current step / error text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _done
                  ? "Server processing limit reached (Error Code 503). Something went wrong while importing video assets. Please try again later in 10 minutes."
                  : _currentStep,
              key: ValueKey(_done ? "done" : _currentStep),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Horizontal progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _done ? 1.0 : _progress,
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: _done ? Colors.redAccent : AppColors.primaryCyan,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _done ? "Processing halted (Error 503)" : "${(_progress * 100).toInt()}%",
            style: TextStyle(
              color: _done ? Colors.redAccent : Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
      actions: _done
          ? [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  LinkHandler.showNext();
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
              ),
              TextButton(
                onPressed: () {
                  widget.onTryAgain();
                  LinkHandler.showNext();
                },
                child: const Text("Try Again Later", style: TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold)),
              ),
            ]
          : null,
    );
  }
}

// ── God Level Daily Reward Dialog & Rotating Fortune Wheel ───────────────────
class GodLevelDailyRewardDialog extends StatefulWidget {
  const GodLevelDailyRewardDialog({super.key});

  @override
  State<GodLevelDailyRewardDialog> createState() => _GodLevelDailyRewardDialogState();
}

class _GodLevelDailyRewardDialogState extends State<GodLevelDailyRewardDialog> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  bool _hasWon = false;
  final String _wonPrize = "+250 BONUS COINS!";

  final List<Map<String, dynamic>> _wheelSectors = [
    {"label": "+50", "color": Colors.purpleAccent},
    {"label": "+100", "color": AppColors.primaryCyan},
    {"label": "+250", "color": Colors.amber},
    {"label": "+500", "color": Colors.greenAccent},
    {"label": "JACKPOT", "color": Colors.deepOrangeAccent},
    {"label": "2X BONUS", "color": Colors.pinkAccent},
    {"label": "+150", "color": Colors.blueAccent},
    {"label": "+300", "color": Colors.cyanAccent},
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isSpinning = false;
            _hasWon = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
              LinkHandler.showNext();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || _hasWon) return;
    setState(() {
      _isSpinning = true;
    });
    _spinController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryCyan.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.primaryCyan, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Daily Streak & Fortune Wheel", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Claim daily rewards & spin to win!", style: TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    bool isToday = index == 2;
                    bool isClaimed = index < 2;
                    return Column(
                      children: [
                        Text("Day ${index + 1}", style: TextStyle(color: isToday ? AppColors.primaryCyan : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isClaimed ? Colors.greenAccent.withOpacity(0.2) : (isToday ? AppColors.primaryCyan : Colors.white10),
                            border: Border.all(color: isToday ? AppColors.primaryCyan : Colors.transparent),
                          ),
                          child: Icon(
                            isClaimed ? Icons.check : Icons.monetization_on_rounded,
                            color: isClaimed ? Colors.greenAccent : (isToday ? Colors.black : Colors.white38),
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text("+${(index + 1) * 50}", style: TextStyle(color: isToday ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [AppColors.primaryCyan, Colors.purpleAccent, Colors.amber, AppColors.primaryCyan],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.primaryCyan.withOpacity(0.4), blurRadius: 20),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value * 12 * pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E1E24),
                      ),
                      child: CustomPaint(
                        painter: _WheelPainter(sectors: _wheelSectors),
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF141416),
                      border: Border.all(color: AppColors.primaryCyan, width: 2),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
                    ),
                    child: const Center(
                      child: Icon(Icons.casino_rounded, color: AppColors.primaryCyan, size: 22),
                    ),
                  ),
                  const Positioned(
                    top: 2,
                    child: Icon(Icons.arrow_drop_down_rounded, color: Colors.amber, size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_hasWon)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    children: [
                      const Text("🎉 CONGRATULATIONS! 🎉", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("YOU WON $_wonPrize", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      elevation: 8,
                      shadowColor: AppColors.primaryCyan.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _isSpinning ? null : _startSpin,
                    child: _isSpinning
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)),
                              SizedBox(width: 10),
                              Text("Spinning Fortune Wheel...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                              SizedBox(width: 4),
                              Text("SPIN WHEEL FOR BONUS COINS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> sectors;
  _WheelPainter({required this.sectors});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double sweepAngle = 2 * pi / sectors.length;

    for (int i = 0; i < sectors.length; i++) {
      final Paint paint = Paint()
        ..style = PaintingStyle.fill
        ..color = (sectors[i]['color'] as Color).withOpacity(0.85);

      final double startAngle = i * sweepAngle - (pi / 2);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, true, paint);

      final Paint linePaint = Paint()
        ..color = Colors.white24
        ..strokeWidth = 1.5;
      canvas.drawLine(center, Offset(center.dx + radius * cos(startAngle), center.dy + radius * sin(startAngle)), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
