import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/todo_model.dart';

class FirebaseService {
  static bool _isAvailable = false;
  static bool get isAvailable => _isAvailable;

  static void setAvailable(bool value) {
    _isAvailable = value;
  }

  FirebaseAuth? get _auth => _isAvailable ? FirebaseAuth.instance : null;
  FirebaseDatabase? get _db => _isAvailable ? FirebaseDatabase.instance : null;

  User? get currentUser => _auth?.currentUser;

  Future<UserCredential?> signIn(String email, String password) async {
    if (!_isAvailable) throw Exception('Firebase is not initialized');
    try {
      return await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signUp(String email, String password) async {
    if (!_isAvailable) throw Exception('Firebase is not initialized');
    try {
      return await _auth!.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!_isAvailable) return;
    await _auth?.signOut();
  }

  Future<void> syncToCloud(List<Todo> todos) async {
    if (!_isAvailable) throw Exception('Firebase is not initialized');
    final user = currentUser;
    if (user == null) throw Exception('Must be logged in to sync');

    final ref = _db!.ref('users/${user.uid}/todos');

    final Map<String, dynamic> data = {};
    for (var todo in todos) {
      data[todo.id] = {
        'title': todo.title,
        'description': todo.description,
        'status': todo.status.index,
        'totalSeconds': todo.totalSeconds,
        'remainingSeconds': todo.remainingSeconds,
        'lastStartedAt': todo.lastStartedAt?.toIso8601String(),
      };
    }

    await ref.set(data);
  }
}
