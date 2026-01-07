import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';

class PostRepository {
  final http.Client client;
  final String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  const PostRepository({required this.client});

  Future<Post> fetchPostById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Post.fromJson(json);
    } else {
      throw Exception('Failed to load post: ${response.statusCode}');
    }
  }
}
