import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:testing_app/repositories/post_repository.dart';

/// Mock class for http.Client: Tạo class mock để giả lập http.Client, dependency của [PostRepository].
// Mocktail dùng runtime mocking, nên extend Mock và implement interface.
class MockHttpClient extends Mock implements http.Client {}

// Fake for custom types (e.g., Uri): Tạo fake object để hỗ trợ matcher any() với types custom như Uri.
// Mocktail yêu cầu register fallback cho non-primitive types để tránh type error.
class FakeUri extends Fake implements Uri {}

void main() {
  // Register fallback for custom types (best practice for any() with non-primitives): Chạy một lần trước tất cả tests.
  // Đăng ký FakeUri() làm fallback để any() hoạt động với Uri.
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  // Group để tổ chức các tests liên quan đến PostRepository, giúp console output rõ ràng.
  group('PostRepository', () {
    // Khai báo variables: late để init sau trong setUp.
    late MockHttpClient mockClient;
    late PostRepository repository;

    // Constants postId giả, dùng chung trong tests.
    const int postId = 1;

    // setUp: Chạy trước mỗi test để reset state mới (isolation giữa các tests).
    setUp(() {
      // Tạo mock mới mỗi test.
      mockClient = MockHttpClient();
      // Inject mock vào repository (dependency injection).
      repository = PostRepository(client: mockClient);
    });

    // Happy path: Success fetch - Test case cho scenario success, kiểm tra repository trả Post đúng.
    test('fetchPostById return Post on successful API call', () async {
      // Stub: Giả lập response success với JSON đầy đủ để tránh null error khi parse.
      final mockResponse = http.Response(
        jsonEncode({
          "userId": 1,
          "id": postId,
          "title": "Testing post title",
          "body": "Testing post body",
        }),
        200,
      );
      // when: Stub method get() để trả async response mock khi gọi với any Uri.
      when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);

      // Run: Chạy method cần test.
      final post = await repository.fetchPostById(postId);

      // Assert: Kiểm tra output đúng với expect.
      expect(post.id, postId);
      expect(post.userId, 1);
      expect(post.title, "Testing post title");
      expect(post.body, "Testing post body");

      // Verify: Kiểm tra gọi get() đúng 1 lần với Uri chứa params đúng (matcher custom với predicate).
      verify(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.pathSegments.last == "$postId"),
          ),
        ),
      ).called(1);
    });

    // Error path: Throw exception on failure - Test handling errỏ khi API fail.
    test('fetchPostById throws Exception on API error', () async {
      // Stub: Giả lập error response với status 404.
      when(
        () => mockClient.get(any()),
      ).thenAnswer((_) async => http.Response('Error', 404));

      // Run và expect error: Kiểm tra throw Exception với message chứa '404'.
      expect(
        () async => await repository.fetchPostById(postId),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('404'),
          ),
        ),
      );

      // // Hoặc đơn giản hơn: Kiểm tra throw bất kỳ Exception nào.
      // expect(
      //   () async => await repository.fetchPostById(postId),
      //   throwsException,
      // );

      // Verify: Vẫn gọi API đúng 1 lần dù error.
      verify(() => mockClient.get(any())).called(1);
    });

    // Capture arguments: Kiểm tra params passed - Test inspect arguments vào mock.
    test('fetchPostById calls API with correct postId (capture args)', () async {
      // Stub với JSON đầy đủ để parse success
      final mockResponse = http.Response(
        jsonEncode({
          "userId": 1,
          "id": postId,
          "title": "Testing post title",
          "body": "Testing post body",
        }),
        200,
      );
      when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);

      // Run: Chạy method.
      await repository.fetchPostById(postId);

      // Capture và verify: Lấy captured args, check path segment cuối có phải là postId.
      final captured = verify(() => mockClient.get(captureAny())).captured;
      expect((captured.last as Uri).pathSegments.last, equals("$postId"));
    });

    // Multiple calls: Kiểm tra số lần gọi - Test gọi method nhiều lần.
    test('fetchPostById can be called multiple times', () async {
      // Stub với JSON đầy đủ
      final mockResponse = http.Response(
        jsonEncode({
          "userId": 1,
          "id": postId,
          "title": "Testing post title",
          "body": "Testing post body",
        }),
        200,
      );
      when(() => mockClient.get(any())).thenAnswer((_) async => mockResponse);

      // Run multiple: Gọi 2 lần với postId khác.
      await repository.fetchPostById(postId);
      await repository.fetchPostById(2);

      // Verify: Gọi get() đúng 2 lần.
      verify(() => mockClient.get(any())).called(2);
    });

    // Edge case: Stub dynamic based on input (nâng cao) - Test stub dựa trên input khác nhau.
    test('fetchPostById handles different cities dynamically', () async {
      // Stub dynamic: Cho '1' với JSON đầy đủ và success.
      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.pathSegments.last == '1'),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            "userId": 1,
            "id": 1,
            "title": "Post 1",
            "body": "Body 1",
          }),
          200,
        ),
      );

      // Stub cho error: Async throw Exception cho '-99'.
      when(
        () => mockClient.get(
          any(that: predicate<Uri>((uri) => uri.pathSegments.last == "-99")),
        ),
      ).thenAnswer((_) async => throw Exception('Invalid postId'));

      // Run success: Kiểm tra Post đúng cho postId = 1.
      final post = await repository.fetchPostById(1);
      expect(post.id, 1);

      // Run error: Kiểm tra throw Exception cho -99.
      expect(() async => await repository.fetchPostById(-99), throwsException);
    });
  });
}
