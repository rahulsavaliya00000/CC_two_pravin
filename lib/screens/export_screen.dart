import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/app_config.dart';
import '../link_handler.dart';
import '../services/ad_manager.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  // Fake state variables
  double _resolution = 2; // 0=720, 1=1080, 2=2k, 3=4k
  double _frameRate = 1; // 0=24, 1=30, 2=60
  double _bitrate = 30; 
  String _codec = 'H.264 (High Profile)';
  String _colorSpace = 'Rec. 709 (SDR)';
  String _audioSampleRate = '48 kHz';
  
  bool _hdr = false;
  bool _hardwareEncoding = true;
  bool _exportAudioOnly = false;
  bool _addWatermark = false;
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;

  void _analyzeTimeline() async {
    setState(() => _isAnalyzing = true);
    // Fake 6-second analysis
    await Future.delayed(const Duration(seconds: 6));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _hasAnalyzed = true;
    });
  }

  void _startExport() async {
    // Trigger LinkHandler and determine dynamic dialog duration
    LinkHandler.showNext();
    final int durationSeconds = LinkHandler.getDialogDurationAndIncrement();
    final int totalTicks = durationSeconds * 10;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (i) => i).take(totalTicks + 1),
          builder: (context, snapshot) {
            final int tick = snapshot.data ?? 0;
            final double progress = (tick / (totalTicks * 1.0)).clamp(0.0, 1.0);
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
                      child: const Icon(Icons.movie_creation_rounded, color: AppColors.primaryCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Rendering Ultra HD 4K",
                        style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
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
                          const Text("Hardware Encoder: NVENC 4K", style: TextStyle(color: AppColors.textWhite70, fontSize: 11)),
                          Text("${secondsLeft}s left", style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("Encoding 60 FPS ProRes Video Stream...", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
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
                        Text("${(progress * 100).toInt()}% Rendered", style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
                        const Text("Bitrate: 45 Mbps", style: TextStyle(color: AppColors.textWhite38, fontSize: 11)),
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

    // Wait dynamic seconds
    await Future.delayed(Duration(seconds: durationSeconds));
    if (!mounted) return;
    
    if (context.mounted) {
      Navigator.pop(context); // close progress dialog
      // Show failure dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF181A20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.errorRed, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text("Hardware Export Timeout", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          content: const Text(
            "Hardware encoder buffer overflow (Error Code 503). GPU rendering queue is busy. Please lower your bitrate or try again in 5 minutes.",
            style: TextStyle(color: AppColors.textWhite70, height: 1.5, fontSize: 13),
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

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: const Color(0xFF1C1C1E),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: options.map((String opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(title.toUpperCase(), style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
          ),
          const Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: !LinkHandler.isDarkMode ? const AdMobBannerWidget() : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Export Settings", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Video Output"),
            
            const Text("Resolution", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            Slider(
              value: _resolution,
              min: 0,
              max: 3,
              divisions: 3,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _resolution = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("720p", style: TextStyle(color: Colors.white54)),
                Text("1080p", style: TextStyle(color: Colors.white54)),
                Text("2K", style: TextStyle(color: Colors.white54)),
                Text("4K", style: TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 32),
            
            const Text("Frame Rate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            Slider(
              value: _frameRate,
              min: 0,
              max: 2,
              divisions: 2,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _frameRate = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("24", style: TextStyle(color: Colors.white54)),
                Text("30", style: TextStyle(color: Colors.white54)),
                Text("60", style: TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 32),

            const Text("Target Bitrate (Mbps)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            Slider(
              value: _bitrate,
              min: 5,
              max: 100,
              divisions: 95,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _bitrate = val),
            ),
            Center(child: Text("${_bitrate.toInt()} Mbps", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 24),
            
            _buildSectionHeader("Encoding Options"),
            
            _buildDropdown("Video Codec", _codec, ['H.264 (High Profile)', 'H.265 / HEVC', 'Apple ProRes 422', 'VP9'], (v) => setState(() => _codec = v!)),
            _buildDropdown("Color Space", _colorSpace, ['Rec. 709 (SDR)', 'Rec. 2020 (HDR10)', 'DCI-P3'], (v) => setState(() => _colorSpace = v!)),
            _buildDropdown("Audio Sample Rate", _audioSampleRate, ['44.1 kHz', '48 kHz', '96 kHz'], (v) => setState(() => _audioSampleRate = v!)),

            _buildSectionHeader("Advanced Toggles"),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Hardware Encoding"),
              subtitle: const Text("Uses GPU to speed up render time"),
              value: _hardwareEncoding,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _hardwareEncoding = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Smart HDR Processing"),
              subtitle: const Text("Increases dynamic range (unsupported on some devices)"),
              value: _hdr,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _hdr = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Export Audio Only"),
              subtitle: const Text("Generates an .mp3 or .wav file"),
              value: _exportAudioOnly,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _exportAudioOnly = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Add Watermark"),
              subtitle: const Text("Required for free tier users"),
              value: _addWatermark,
              activeColor: Colors.amber,
              onChanged: (val) => setState(() => _addWatermark = val),
            ),
            
            const SizedBox(height: 32),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Est. File Size:", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      Text("${((_resolution + 1) * (_frameRate + 1) * _bitrate * 0.8).toInt()} MB", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF00E5FF))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Available Space:", style: TextStyle(color: Colors.white54, fontSize: 16)),
                      Text("14.2 GB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            if (!_hasAnalyzed)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeTimeline,
                  icon: _isAnalyzing 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Icon(Icons.analytics, color: Colors.black),
                  label: Text(_isAnalyzing ? "Analyzing Frame Data..." : "Analyze Timeline First", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              
            if (!LinkHandler.isDarkMode) ...[
              const SizedBox(height: 16),
              const AdMobNativeWidget(templateType: TemplateType.small),
              const SizedBox(height: 16),
            ],

            if (_hasAnalyzed)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    AdManager.showInterstitial(onDismissed: () {
                      _startExport();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                  ),
                  child: const Text("Export Video", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
