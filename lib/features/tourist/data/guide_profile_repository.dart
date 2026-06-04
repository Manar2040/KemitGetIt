import '../../../data/models/guide.dart';

abstract class GuideProfileRepository {
  Future<Guide> getGuideProfile(String id);
}
