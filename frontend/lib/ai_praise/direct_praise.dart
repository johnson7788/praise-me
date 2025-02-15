import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import '../config.dart';
import '../language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    final shareUrl = '${AppConfig.BACKEND_API}/voteyou?id=$_currentHash';
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
      body: SingleChildScrollView(
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
                                  const SizedBox(width: 20),
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
    );
  }
}