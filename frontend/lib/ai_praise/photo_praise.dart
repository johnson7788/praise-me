// photo_praise.dart
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';
import '../config.dart';
import '../language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart'; // 新增音频包
import 'package:path_provider/path_provider.dart'; // 新增路径获取

class PhotoPraisePage extends StatefulWidget {
  const PhotoPraisePage({super.key});

  @override
  _PhotoPraisePageState createState() => _PhotoPraisePageState();
}

class _PhotoPraisePageState extends State<PhotoPraisePage> {
  File? _selectedFile;
  String _praiseText = '';
  bool _isLoading = false;
  bool _isLiked = false;
  String? _currentHash;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();
  // 新增音频相关状态
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // 初始化播放器
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 释放资源
    super.dispose();
  }

  // 音频处理方法
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
      final file = File('${directory.path}/photo_audio_${DateTime.now().millisecondsSinceEpoch}.wav');

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
        await _audioPlayer.stop();
        await _audioPlayer.setSourceDeviceFile(file.path);
        await _audioPlayer.resume();

        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() => _isPlaying = false);
        });

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

  Future<void> _pickFile(ImageSource source) async { // ImageSource 参数
    final l10n = AppLocalizations.of(context)!;

    try {
      final pickedFile = await (source == ImageSource.camera
          ? _picker.pickImage(source: source) // 拍照选择图片
          : _picker.pickImage(source: source)); // 从相册选择图片

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _praiseText = '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.filePickError)),
      );
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() => _isLoading = true);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final languageCode = languageProvider.locale.languageCode;

    try {
      final uri = Uri.parse('${AppConfig.BACKEND_API}/photo-praise');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          _selectedFile!.path,
          contentType: MediaType(
            _selectedFile!.path.endsWith('.mp4') ? 'video' : 'image',
            _selectedFile!.path.split('.').last,
          ),
        ))
        ..fields['language'] = languageCode;

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(respStr);
        final content = jsonData['text'];
        final bytes = utf8.encode(content);
        final digest = sha256.convert(bytes);

        setState(() {
          _praiseText = content;
          _currentHash = digest.toString();
        });
      } else {
        final error = json.decode(respStr)['detail'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.uploadError}: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
          'praise_type': 'photo',
          'content': _praiseText,
          'likes': 1
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _isLiked = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.saveFailed} (${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.saveFailed}: $e')),
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
          children: [
            SelectableText(shareUrl),
            ElevatedButton(
              onPressed: () => Clipboard.setData(ClipboardData(text: shareUrl)),
              child: Text(AppLocalizations.of(context)!.copy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final isVideo = _selectedFile!.path.endsWith('.mp4');
    return Column(
      children: [
        isVideo
            ? const Icon(Icons.videocam, size: 100)
            : Image.file(_selectedFile!, height: 200),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadFile,
          child: Text(AppLocalizations.of(context)!.generatePraise),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.photoPraise)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 添加居中属性
          children: [
            // 修改按钮布局在这里
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 水平居中
              children: [
                Expanded( // 使用 Expanded 让按钮平分空间
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 按钮左右间距
                    child: ElevatedButton.icon(
                      onPressed: () => _pickFile(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.takePhoto),
                      style: ElevatedButton.styleFrom( // 放大按钮
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Expanded( // 使用 Expanded 让按钮平分空间, 上传图片或者视频
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // 按钮左右间距
                    child: ElevatedButton.icon(
                      onPressed: () => _pickFile(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.uploadFromGallery),
                      style: ElevatedButton.styleFrom( // 放大按钮
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // 按钮和预览区域间距

            _buildPreview(),
            if (_isLoading) const CircularProgressIndicator(),
            if (_praiseText.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('✨ $_praiseText ✨', textAlign: TextAlign.center),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: _isLiked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                    onPressed: _isLiked ? null : _savePraiseRecord,
                  ),
                  // 音频控制组件
                  _buildAudioControls(),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _showShareDialog,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 新增音频控制组件
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