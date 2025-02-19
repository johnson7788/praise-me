import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'package:flutter/services.dart';
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

// 新增评论数据模型
class Comment {
  final String commentId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'].toString(),
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
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
  final Map<String, List<Comment>> _commentsCache = {};
  final Map<String, bool> _loadingComments = {};
  final Map<String, bool> _expandedItems = {};

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.BACKEND_API}/leaderboard?period=monthly'),
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
    final shareUrl = '${AppConfig.WEB_BASE_URL}/voteyou?id=$recordId';
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

  // 新增评论获取方法
  Future<void> _fetchComments(String recordId) async {
    setState(() => _loadingComments[recordId] = true);

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.BACKEND_API}/comments/$recordId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _commentsCache[recordId] = (data['comments'] as List)
              .map((c) => Comment.fromJson(c))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.loadCommentsFailed} (${response.statusCode})'),
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
      setState(() => _loadingComments[recordId] = false);
    }
  }

  // 新增评论提交方法
  Future<void> _submitComment(String recordId, String content) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.BACKEND_API}/comments/$recordId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      if (response.statusCode == 200) {
        // 刷新评论列表
        await _fetchComments(recordId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.commentSuccess),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.commentFailed}: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.networkError}: $e'),
        ),
      );
    }
  }

  // 新增评论对话框
  void _showCommentDialog(String recordId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.writeComment),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.commentHint,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = textController.text.trim();
              if (content.isEmpty) return;

              Navigator.pop(context);
              await _submitComment(recordId, content);
            },
            child: Text(AppLocalizations.of(context)!.submit),
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
          final isExpanded = _expandedItems[item.recordId] ?? false; //是否展开评论
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
                      // 点赞按钮和数字组合
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,  // 去除内边距
                              constraints: const BoxConstraints(),  // 移除默认约束
                              icon: Icon(
                                Icons.favorite,
                                color: theme.colorScheme.error,
                                size: 24,  // 适当调小图标
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
                          ],
                        ),
                      ),
                      // 评论按钮
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.comment, size: 24),
                        onPressed: () {
                          setState(() {
                            _expandedItems[item.recordId] = !isExpanded;
                            if (isExpanded && !_commentsCache.containsKey(item.recordId)) {
                              _fetchComments(item.recordId);
                            }
                          });
                        },
                      ),
                      // 写评论按钮
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.edit, size: 24),
                        onPressed: () => _showCommentDialog(item.recordId),
                      ),
                      const SizedBox(width: 8),  // 缩小间距
                      // 分享按钮
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.share,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        onPressed: () => _showShareDialog(item.recordId),
                      ),
                    ],
                  ),
                  // 评论展开区域
                  if (isExpanded) _buildCommentsSection(item.recordId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentsSection(String recordId) {
    final comments = _commentsCache[recordId];
    final isLoading = _loadingComments[recordId] ?? false;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            AppLocalizations.of(context)!.comments,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (comments == null || comments.isEmpty)
            Text(AppLocalizations.of(context)!.noComments)
          else
            ...comments.map((comment) => ListTile(
              title: Text(comment.content),
              subtitle: Text(
                '${comment.createdAt.toLocal()}',
                style: const TextStyle(fontSize: 12),
              ),
            )),
        ],
      ),
    );
  }
}