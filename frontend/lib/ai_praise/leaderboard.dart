import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../config.dart';
import 'package:flutter/services.dart';
import '../language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeaderboardItem {
  final String recordId;
  final String praiseType;
  final String content;
  int likes;

  LeaderboardItem({
    required this.recordId,
    required this.praiseType,
    required this.content,
    required this.likes,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      recordId: json['record_id'],
      praiseType: json['praise_type'],
      content: json['content'],
      likes: json['likes'],
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<LeaderboardItem> _leaderboardData = [];
  bool _isLoading = true;
  String _selectedPeriod = 'daily';
  final Map<String, String> _periodMap = {
    'daily': 'daily',
    'weekly': 'weekly',
    'monthly': 'monthly',
  };

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.BACKEND_API}/leaderboard?period=$_selectedPeriod'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _leaderboardData = data
              .map((item) => LeaderboardItem.fromJson(item))
              .toList();
        });
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noDataFound),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.serverError} (${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.networkError}: $e'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _likeItem(String recordId, int index) async {
    setState(() {
      _leaderboardData[index].likes++;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.BACKEND_API}/add-praise-like'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'record_id': recordId}),
      );

      if (response.statusCode != 200) {
        // Rollback if failed
        setState(() {
          _leaderboardData[index].likes--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.operationFailed}: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _leaderboardData[index].likes--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.networkError}: $e'),
        ),
      );
    }
  }

  void _showShareDialog(String recordId) {
    final shareUrl = '${AppConfig.BACKEND_API}/voteyou?id=$recordId';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sharePraise),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              shareUrl,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareUrl));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.copySuccess),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.copy),
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
        title: Text(l10n.leaderboard),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedPeriod = newValue);
                _fetchLeaderboardData();
              }
            },
            items: _periodMap.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboardData.isEmpty
          ? Center(child: Text(l10n.noDataFound))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _leaderboardData.length,
        itemBuilder: (context, index) {
          final item = _leaderboardData[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          item.praiseType.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      Text(
                        '#${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () => _likeItem(item.recordId, index),
                      ),
                      Text(
                        item.likes.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => _showShareDialog(item.recordId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}