import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HintPraisePage extends StatefulWidget {
  const HintPraisePage({super.key});

  @override
  _HintPraisePageState createState() => _HintPraisePageState();
}

class _HintPraisePageState extends State<HintPraisePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hintController = TextEditingController();
  String _praiseResult = '';
  bool _isLoading = false;

  Future<void> _submitHint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
          Uri.parse('your_api_url/hint-praise'),
          body: {'hint': _hintController.text}
      );

      if (response.statusCode == 200) {
        setState(() => _praiseResult = response.body);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提示夸')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _hintController,
                decoration: const InputDecoration(
                  labelText: '分享你的成就/心情/爱好',
                  border: OutlineInputBorder(),
                  hintText: '例：今天学会了滑板，超级开心！',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请先输入一些内容哦～';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitHint,
                child: const Text('生成专属夸夸'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _praiseResult,
                    style: const TextStyle(fontSize: 16),
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
