import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../config.dart';
import '../language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 添加本地化生成文件

class DirectPraisePage extends StatefulWidget {
  const DirectPraisePage({super.key});

  @override
  _DirectPraisePageState createState() => _DirectPraisePageState();
}

class _DirectPraisePageState extends State<DirectPraisePage> {
  String _praiseText = '';
  bool _isLoading = false;

  Future<void> _getPraise() async {
    setState(() => _isLoading = true);
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
        setState(() => _praiseText = jsonData['text']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.serverError} (CODE:${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.networkError}: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // 获取本地化对象

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.directPraise), // 使用本地化标题
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.celebration_outlined),
                label: Text(l10n.instantPraise, style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                onPressed: _isLoading ? null : _getPraise,
              ),
              const SizedBox(height: 30),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 15),
                    Text(
                      l10n.collectingPraiseEnergy,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _praiseText.isEmpty
                        ? l10n.receiveTodayHappy
                        : '✨ ${_praiseText} ✨',
                    style: TextStyle(
                      fontSize: 18,
                      color: _praiseText.isEmpty
                          ? Colors.grey
                          : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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