import '../../../shared/models/user.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<void> updateProfile(User user);
}
