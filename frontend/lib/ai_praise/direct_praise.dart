import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../config.dart';
import '../language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart'; // 添加AudioPlayer相关
import 'package:path_provider/path_provider.dart'; // 添加getTemporaryDirectory
import 'dart:io'; // 添加File类

class DirectPraisePage extends StatefulWidget {
  const DirectPraisePage({super.key});

  @override
  _DirectPraisePageState createState() => _DirectPraisePageState();
}

class _DirectPraisePageState extends State<DirectPraisePage> {
  String _praiseText = '';
  bool _isLoading = false;
  bool _isLiked = false;
  String? _currentHash;
  bool _isSaving = false;
  // 新增状态变量
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  //添加获取并播放音频的方法：
  Future<void> _fetchAndPlayAudio() async {
    if (_praiseText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noPraiseText)),
      );
      return;
    }

    setState(() => _isLoadingAudio = true);

    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav');

      // POST请求
      final response = await http.post(
        Uri.parse('${AppConfig.TTS_API}/api/tts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'tts_text': _praiseText,
          'language': languageProvider.locale.languageCode,
        }),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        // 停止当前播放
        await _audioPlayer.stop();

        // 使用正确的播放方式
        await _audioPlayer.setSourceDeviceFile(file.path);
        await _audioPlayer.resume();

        // 监听播放完成
        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() => _isPlaying = false);
        });

        // 错误处理通过日志流
        _audioPlayer.onLog.listen((log) {
          if (log.contains("ERROR")) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('播放失败: $log')),
            );
          }
        });

        setState(() {
          _isPlaying = true;
          _audioPath = file.path;
        });
      } else {
        throw Exception('请求失败: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('音频错误: $e')),
      );
    } finally {
      setState(() => _isLoadingAudio = false);
    }
  }

  Future<void> _getPraise() async {
    setState(() {
      _isLoading = true;
      _isLiked = false;
      _currentHash = null;
    });

    try {
      final languageProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      final String languageCode = languageProvider.locale.languageCode;

      final response = await http.post(
        Uri.parse('${AppConfig.BACKEND_API}/direct-praise'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'language': languageCode}),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final content = jsonData['text'];
        final bytes = utf8.encode(content);
        final digest = sha256.convert(bytes);

        if (mounted) {
          setState(() {
            _praiseText = content;
            _currentHash = digest.toString();
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.serverError} (${response.statusCode})'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.networkError}: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePraiseRecord() async {
    if (_currentHash == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.BACKEND_API}/save-praise-record'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'record_id': _currentHash,
          'praise_type': 'direct',
          'content': _praiseText,
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _isLiked = true);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text(AppLocalizations.of(context)!.saveSuccess),
        //   ),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.saveFailed} (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.saveFailed}: $e'),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showShareDialog() {
    if (_currentHash == null) return;

    final shareUrl = '${AppConfig.WEB_BASE_URL}/voteyou?id=$_currentHash';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sharePraise),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                shareUrl,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.content_copy, size: 18),
              label: Text(AppLocalizations.of(context)!.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.copySuccess),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.directPraise),
        elevation: 0,
        centerTitle: true,
      ),
        body: Center( // 使用 Center Widget 包裹 SingleChildScrollView
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.celebration_outlined),
                    label: Text(
                      // 修改判断条件为_praiseText是否为空
                      _praiseText.isEmpty ? l10n.instantPraise : l10n.againPraise,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      foregroundColor: theme.colorScheme.onPrimary,
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    onPressed: _isLoading ? null : _getPraise,
                  ),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: SizedBox(
                      height: 300,
                      child: _isLoading
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 15),
                              Text(
                                l10n.collectingPraiseEnergy,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.disabledColor),
                              ),
                            ],
                          ),
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _praiseText.isEmpty
                                      ? l10n.receiveTodayHappy
                                      : '✨ $_praiseText ✨',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _praiseText.isEmpty
                                        ? theme.disabledColor
                                        : theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (_praiseText.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: _isSaving
                                            ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : Icon(
                                          Icons.favorite,
                                          color: _isLiked
                                              ? Colors.red
                                              : theme.disabledColor,
                                          size: 32,
                                        ),
                                        onPressed: _isLiked || _isSaving
                                            ? null
                                            : _savePraiseRecord,
                                      ),
                                      const SizedBox(width: 10),
                                      _buildAudioControls(), // 添加播放控制
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          color: theme.colorScheme.secondary,
                                          size: 32,
                                        ),
                                        onPressed: _showShareDialog,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }

  // 在UI中添加播放控制
  Widget _buildAudioControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: _isLoadingAudio
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.volume_up),
          onPressed: _isLoadingAudio ? null : _fetchAndPlayAudio,
        ),
        if (_audioPath != null)
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () async {
              if (_isPlaying) {
                await _audioPlayer.pause();
              } else {
                await _audioPlayer.resume();
              }
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
      ],
    );
  }
}