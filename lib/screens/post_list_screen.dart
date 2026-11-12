import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/empty_state.dart';

/// Halaman yang menampilkan data dari API publik (`GET /posts`).
///
/// Menampilkan loading state, error state (dengan tombol "Coba lagi"),
/// empty state, dan daftar data dalam `ListView`.
class PostListScreen extends StatefulWidget {
  /// Service API yang dapat di-inject untuk pengujian.
  final ApiService? apiService;

  /// Membuat [PostListScreen].
  const PostListScreen({super.key, this.apiService});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final ApiService _apiService;
  List<Post> _posts = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _loadPosts();
  }

  @override
  void dispose() {
    // Hanya tutup client yang dibuat sendiri oleh halaman ini.
    if (widget.apiService == null) _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final posts = await _apiService.getPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memproses data.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data API (Posts)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: _isLoading ? null : _loadPosts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data dari API...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Gagal Memuat Data',
        message: _errorMessage!,
        actionLabel: 'Coba Lagi',
        onAction: _loadPosts,
      );
    }

    if (_posts.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Data kosong',
        message: 'Server tidak mengembalikan data.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${post.id}')),
              title: Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}
