/// Model data post dari API publik JSONPlaceholder (`/posts`).
class Post {
  /// Id post.
  final int id;

  /// Id pengguna pembuat post.
  final int userId;

  /// Judul post.
  final String title;

  /// Isi post.
  final String body;

  /// Membuat objek [Post].
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  /// Membuat [Post] dari `Map` hasil decode JSON response API.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}
