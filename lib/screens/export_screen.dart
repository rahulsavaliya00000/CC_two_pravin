import 'package:flutter/material.dart';

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 450), (i) => i).take(101),
          builder: (context, snapshot) {
            int progress = snapshot.data ?? 0;
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Rendering & Initializing Export...", style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Initializing asset rendering. Please keep screen active.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100.0,
                      minHeight: 12,
                      backgroundColor: Colors.white24,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("$progress%", style: const TextStyle(color: Colors.white54)),
                ],
              ),
            );
          },
        );
      },
    );

    // Wait exactly 45 seconds
    await Future.delayed(const Duration(seconds: 45));
    if (!mounted) return;
    
    if (context.mounted) {
      Navigator.pop(context); // close progress dialog
      // Show failure dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Export Failed", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: const Text("Error Code 402 (Device Codec Unsupported). Please try exporting at a lower resolution or clear device storage.", style: TextStyle(color: Colors.white70, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Color(0xFF00E5FF))),
            )
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
              
            if (_hasAnalyzed)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _startExport,
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
