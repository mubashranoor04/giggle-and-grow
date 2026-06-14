import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Stream<int> getScoreStream() {
    if (_uid == null) return Stream.value(0);
    return _firestore
        .collection('users')
        .doc(_uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return snapshot.data()?['totalScore'] ?? 0;
          }
          return 0;
        });
  }

  Future<void> updateScore(int points, String gameId) async {
    if (_uid == null) return;
    final userDoc = _firestore.collection('users').doc(_uid);
    
    await userDoc.set({
      'totalScore': FieldValue.increment(points),
      'gameScores': {
        gameId: FieldValue.increment(points),
      }
    }, SetOptions(merge: true));
  }
}
