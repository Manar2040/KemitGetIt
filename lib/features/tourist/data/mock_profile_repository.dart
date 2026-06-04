import '../../../shared/models/user.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  User _mockUser = User(
    name: "William",
    email: "tourist5875@gmail.com",
    phone: "+955 456 786",
    age: 33,
    country: "Spanish",
    language: "English",
    interests: ["History", "Culture", "History", "Photography"],
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
  );

  @override
  Future<User> getProfile() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockUser;
  }

  @override
  Future<void> updateProfile(User user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _mockUser = user;
  }
}
