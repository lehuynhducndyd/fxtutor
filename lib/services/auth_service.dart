import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _webClientId =
      '1044259371187-ejqr9gj5oq8f15p41in6n6gfd5kk9jai.apps.googleusercontent.com';

  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    try {
      // 1. Khởi tạo lại đối tượng GoogleSignIn (với cấu hình cũ)
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
        scopes: ['email', 'profile', 'openid'],
      );

      // 2. Kiểm tra xem có đang đăng nhập Google không
      if (await googleSignIn.isSignedIn()) {
        // 3. Đăng xuất khỏi Google -> Lần sau sẽ hiện bảng chọn tài khoản
        await googleSignIn.signOut();

        // Mẹo: Nếu muốn xóa sạch quyền truy cập (thu hồi token), dùng .disconnect()
        // await googleSignIn.disconnect();
      }
    } catch (e) {
      print("Lỗi khi đăng xuất Google: $e");
      // Vẫn tiếp tục chạy để đăng xuất Supabase
    }

    // 4. Cuối cùng mới đăng xuất khỏi Supabase
    await _supabase.auth.signOut();
  }

  String? getCurrentUserEmail() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return user.email;
    }
    return null;
  }

  Future<AuthResponse> loginWithGoogle() async {
    /// 1. Khởi tạo Google Sign In
    /// serverClientId: Bắt buộc để lấy idToken gửi cho Supabase
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );

    /// 2. Mở hộp thoại đăng nhập Native
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print("User cancelled login");
      throw 'Đã hủy đăng nhập Google';
    }

    /// 3. Lấy Authentication (accessToken & idToken) từ Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      print("No token found");
      throw 'Không tìm thấy Token từ Google';
    }

    /// 4. Gửi Token cho Supabase để xác thực
    return await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }
}
