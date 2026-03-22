// Seeds admin users via Firebase Auth REST + Firestore REST (no Flutter / dart:ui).
//
// Run: cd rapid_reels_app && dart run tool/seed_admin_users.dart
//
// Uses the same project as lib/firebase_options.dart (apiKey + projectId).

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// From lib/firebase_options.dart — Identity Toolkit accepts this Web/Android key.
const String _apiKey = 'AIzaSyAAuzYnTH6DhyFewO57ITLXa2CJB7B1IX4';
const String _projectId = 'rapidreelnew-de86a';

const String _password = 'brave123';

const List<String> _adminEmails = [
  'braveadmin@rapidreels.com',
  'bravehearts@rapidreels.com',
];

const List<String> _createFields = [
  'email',
  'fullName',
  'userType',
  'walletBalance',
  'totalEventsBooked',
  'totalReelsReceived',
  'isActive',
  'isVerified',
  'createdAt',
  'updatedAt',
];

const List<String> _mergeFields = ['userType', 'email', 'updatedAt'];

Future<void> main() async {
  for (final email in _adminEmails) {
    await _ensureAdminUser(email);
  }
  print('seed_admin_users: finished.');
}

String _maskQuery(Iterable<String> fields) => fields
    .map((f) => 'updateMask.fieldPaths=${Uri.encodeQueryComponent(f)}')
    .join('&');

Future<void> _ensureAdminUser(String email) async {
  final token = await _getIdToken(email);
  final uid = token.localId;
  final idToken = token.idToken;

  final base =
      'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents/users/$uid';

  final getRes = await http.get(
    Uri.parse(base),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $idToken'},
  );

  final now = DateTime.now().toUtc().toIso8601String();

  if (getRes.statusCode == 404) {
    final uri = Uri.parse(
      '$base?currentDocument.exists=false&${_maskQuery(_createFields)}',
    );
    final body = {
      'fields': {
        'email': {'stringValue': email},
        'fullName': {'stringValue': _displayNameFromEmail(email)},
        'userType': {'stringValue': 'admin'},
        'walletBalance': {'doubleValue': 0.0},
        'totalEventsBooked': {'integerValue': '0'},
        'totalReelsReceived': {'integerValue': '0'},
        'isActive': {'booleanValue': true},
        'isVerified': {'booleanValue': true},
        'createdAt': {'timestampValue': now},
        'updatedAt': {'timestampValue': now},
      },
    };
    final res = await http.patch(
      uri,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $idToken',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError(
        'Firestore create ${res.statusCode} for $email: ${res.body}',
      );
    }
    print('seed_admin_users: created Firestore users/$uid ($email)');
    return;
  }

  if (getRes.statusCode != 200) {
    throw StateError(
      'Firestore GET ${getRes.statusCode} for $email: ${getRes.body}',
    );
  }

  final uri = Uri.parse('$base?${_maskQuery(_mergeFields)}');
  final patchBody = {
    'fields': {
      'userType': {'stringValue': 'admin'},
      'email': {'stringValue': email},
      'updatedAt': {'timestampValue': now},
    },
  };
  final res = await http.patch(
    uri,
    headers: {
      HttpHeaders.authorizationHeader: 'Bearer $idToken',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: jsonEncode(patchBody),
  );
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw StateError(
      'Firestore merge ${res.statusCode} for $email: ${res.body}',
    );
  }
  print('seed_admin_users: updated Firestore users/$uid ($email)');
}

Future<({String idToken, String localId})> _getIdToken(String email) async {
  final signUpUri = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_apiKey',
  );
  final signUpRes = await http.post(
    signUpUri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': _password,
      'returnSecureToken': true,
    }),
  );

  if (signUpRes.statusCode == 200) {
    final j = jsonDecode(signUpRes.body) as Map<String, dynamic>;
    print('seed_admin_users: created Auth user $email');
    return (idToken: j['idToken'] as String, localId: j['localId'] as String);
  }

  final err = jsonDecode(signUpRes.body) as Map<String, dynamic>?;
  final msg = err?['error'] as Map<String, dynamic>?;
  final reason = msg?['message'] as String? ?? signUpRes.body;

  if (reason.contains('EMAIL_EXISTS')) {
    final signInUri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_apiKey',
    );
    final signInRes = await http.post(
      signInUri,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': _password,
        'returnSecureToken': true,
      }),
    );
    if (signInRes.statusCode != 200) {
      throw StateError(
        'Auth sign-in failed for $email: ${signInRes.statusCode} ${signInRes.body}',
      );
    }
    final j = jsonDecode(signInRes.body) as Map<String, dynamic>;
    print('seed_admin_users: signed in existing Auth user $email');
    return (idToken: j['idToken'] as String, localId: j['localId'] as String);
  }

  throw StateError(
    'Auth sign-up failed for $email: ${signUpRes.statusCode} $reason',
  );
}

String _displayNameFromEmail(String email) {
  final local = email.split('@').first;
  return local.replaceAll('.', ' ').replaceAll('_', ' ');
}
