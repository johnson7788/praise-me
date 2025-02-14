import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class VoicePraisePage extends StatefulWidget {
  const VoicePraisePage({super.key});

  @override
  _VoicePraisePageState createState() => _VoicePraisePageState();
}

class _VoicePraisePageState extends State<VoicePraisePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _playPraise() async {
    try {
      setState(() => _isPlaying = true);
      await _audioPlayer.play(UrlSource('your_audio_api_url'));
    } finally {
      setState(() => _isPlaying = false);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('语音夸')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isPlaying ? null : _playPraise,
          child: Text(_isPlaying ? '播放中...' : '播放夸夸语音'),
        ),
      ),
    );
  }
}
