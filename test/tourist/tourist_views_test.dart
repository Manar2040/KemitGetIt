import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kemit_get_it/features/tourist/view/my_requests_view.dart';
import '../mocks/tourist_seed_data.dart';

/// Mocks the http.Client globally so we don't have to alter ApiClient.
class MockHttpOverrides extends HttpOverrides {
  final Map<String, String> jsonResponses;
  final int statusCode;

  MockHttpOverrides(this.jsonResponses, {this.statusCode = 200});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(jsonResponses, statusCode);
  }
}

class _MockHttpClient implements HttpClient {
  final Map<String, String> responses;
  final int statusCode;

  _MockHttpClient(this.responses, this.statusCode);

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async {
    return _MockHttpClientRequest(responses[path] ?? '[]', statusCode);
  }
  
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest(responses[url.path] ?? '[]', statusCode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final String body;
  final int statusCode;
  _MockHttpClientRequest(this.body, this.statusCode);

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(body, statusCode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
  
  @override
  void remove(String name, Object value) {}
  
  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  final String body;
  @override
  final int statusCode;
  
  _MockHttpClientResponse(this.body, this.statusCode);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(utf8.encode(body)).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Tourist UI Scenarios using Seed Data', () {
    
    testWidgets('Omar (Fresh Account) shows empty state in MyRequestsView', (WidgetTester tester) async {
      HttpOverrides.global = MockHttpOverrides({
        '/api/requests/tourist': jsonEncode(TouristSeedData.omarRequests.map((e) => e.toJson()).toList()),
      });

      await tester.pumpWidget(const MaterialApp(home: MyRequestsView()));
      await tester.pumpAndSettle();

      expect(find.text('You have no requests yet.'), findsOneWidget);
      expect(find.text('Ready Trip'), findsNothing);
    });

    testWidgets('Sara shows Declined and Pending requests', (WidgetTester tester) async {
      HttpOverrides.global = MockHttpOverrides({
        '/api/requests/tourist': jsonEncode(TouristSeedData.saraRequests.map((e) => e.toJson()).toList()),
      });

      await tester.pumpWidget(const MaterialApp(home: MyRequestsView()));
      await tester.pumpAndSettle();

      expect(find.text('Khaled Nasser'), findsOneWidget); // guide name for declined
      expect(find.text('Nour Ibrahim'), findsOneWidget); // guide name for pending
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('PendingRequest'), findsOneWidget);
    });

    testWidgets('Lena shows Completed past trips', (WidgetTester tester) async {
      HttpOverrides.global = MockHttpOverrides({
        '/api/requests/tourist': jsonEncode(TouristSeedData.lenaRequests.map((e) => e.toJson()).toList()),
      });

      await tester.pumpWidget(const MaterialApp(home: MyRequestsView()));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Aswan & Abu Simbel Express'), findsOneWidget);
      expect(find.text('Hassan Farouk'), findsOneWidget);
    });
  });
}
