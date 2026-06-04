import 'package:flutter_test/flutter_test.dart';
import 'package:kemit_get_it/data/models/hold_request_models.dart';
import 'package:kemit_get_it/data/models/tourist_models.dart';
import '../mocks/tourist_seed_data.dart';

void main() {
  group('Tourist Seed Data Model Verification', () {
    test('Omar (Fresh Account) handles empty lists correctly', () {
      final profile = TouristSeedData.omarProfile;
      expect(profile.email, 'omar@test.com');
      expect(profile.interests, isEmpty);
      
      final requests = TouristSeedData.omarRequests;
      expect(requests, isEmpty);
    });

    test('Sara handles pending and declined requests properly', () {
      final profile = TouristSeedData.saraProfile;
      expect(profile.email, 'sara@test.com');
      expect(profile.interests, contains('Adventure'));
      
      final requests = TouristSeedData.saraRequests;
      expect(requests.length, 2);
      expect(requests.any((r) => r.status == 'Declined'), isTrue);
      expect(requests.any((r) => r.status == 'PendingRequest'), isTrue);
    });

    test('John (Power User) handles active requests and plans', () {
      final profile = TouristSeedData.johnProfile;
      expect(profile.email, 'john@test.com');
      
      final requests = TouristSeedData.johnRequests;
      expect(requests.length, 1);
      final activeReq = requests.first;
      expect(activeReq.status, 'Active');
      expect(activeReq.requestType, 'ReadyTrip');
    });

    test('Lena (History User) handles completed trips', () {
      final profile = TouristSeedData.lenaProfile;
      expect(profile.email, 'lena@test.com');
      
      final requests = TouristSeedData.lenaRequests;
      expect(requests.length, 1);
      final completedReq = requests.first;
      expect(completedReq.status, 'Completed');
      expect(completedReq.totalPrice, 1500.0);
    });

    test('HoldRequestDto json serialization works correctly', () {
      final req = TouristSeedData.saraRequests.first;
      final json = req.toJson();
      
      expect(json['status'], 'Declined');
      expect(json['guideUserId'], 2);
      expect(json['requestType'], 'PrivateTrip');

      final reconstructed = HoldRequestDto.fromJson(json);
      expect(reconstructed.id, req.id);
      expect(reconstructed.touristUserId, req.touristUserId);
      expect(reconstructed.status, req.status);
    });
  });
}
