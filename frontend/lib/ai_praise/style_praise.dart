import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StylePraisePage extends StatefulWidget {
  const StylePraisePage({super.key});

  @override
  _StylePraisePageState createState() => _StylePraisePageState();
}

class _StylePraisePageState extends State<StylePraisePage> {
  String? _selectedStyle;
  String _praiseText = '';
  bool _isLoading = false;

  final List<Map<String, String>> _styles = [
    {'value': 'zhonger', 'label': '中二风'},
    {'value': 'batong', 'label': '霸总风'},
    {'value': 'tangshi', 'label': '唐诗风'},
  ];

  Future<void> _generatePraise() async {
    if (_selectedStyle == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
          Uri.parse('your_api_url/style-praise'),
          body: {'style': _selectedStyle!}
      );
      if (response.statusCode == 200) {
        setState(() => _praiseText = response.body);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('风格夸')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStyle,
              items: _styles.map((style) => DropdownMenuItem(
                value: style['value'],
                child: Text(style['label']!),
              )).toList(),
              onChanged: (value) => setState(() => _selectedStyle = value),
              decoration: const InputDecoration(
                labelText: '选择风格',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_selectedStyle == null || _isLoading)
                  ? null
                  : _generatePraise,
              child: const Text('生成夸夸'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _praiseText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
