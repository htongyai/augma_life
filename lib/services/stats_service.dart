import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get today's date as string (YYYY-MM-DD)
  String get _todayId => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Get reference to today's stats document
  DocumentReference<Map<String, dynamic>> get _todayStatsRef => _firestore
      .collection('users')
      .doc(currentUserId)
      .collection('daily_stats')
      .doc(_todayId);

  // Stream of user stats for today
  Stream<Map<String, dynamic>> getUserStatsStream() {
    if (currentUserId == null) {
      return Stream.value({});
    }

    return _todayStatsRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return {};
      return snapshot.data() ?? {};
    });
  }

  // Update individual stat
  Future<void> updateStat(String statName, dynamic value) async {
    if (currentUserId == null) return;

    await _todayStatsRef.set({
      statName: value,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Update multiple stats at once
  Future<void> updateStats(Map<String, dynamic> stats) async {
    if (currentUserId == null) return;

    await _todayStatsRef.set({
      ...stats,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream of health metrics
  Stream<Map<String, dynamic>> getHealthMetricsStream() {
    if (currentUserId == null) {
      return Stream.value({});
    }

    return _todayStatsRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return {'heartRate': 0, 'sleepHours': 0};
      final data = snapshot.data() ?? {};
      return {
        'heartRate': data['heart'] ?? 0,
        'sleepHours': data['sleep'] ?? 0,
      };
    });
  }

  // Update health metrics
  Future<void> updateHealthMetrics(Map<String, dynamic> metrics) async {
    if (currentUserId == null) return;

    await _todayStatsRef.set({
      ...metrics,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream of daily intentions
  Stream<List<Map<String, dynamic>>> getIntentionsStream() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _todayStatsRef.snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data() ?? {};
      if (!data.containsKey('intentions')) return [];
      return List<Map<String, dynamic>>.from(data['intentions'] as List? ?? []);
    });
  }

  // Update intentions
  Future<void> updateIntentions(List<Map<String, dynamic>> intentions) async {
    if (currentUserId == null) return;

    await _todayStatsRef.set({
      'intentions': intentions,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Reset daily stats
  Future<void> resetDailyStats({
    List<Map<String, dynamic>>? intentions,
    int? morningMood,
  }) async {
    if (currentUserId == null) return;

    // Create new document for today with initial values
    await _todayStatsRef.set({
      'date': _todayId,
      'energy':
          morningMood == null
              ? 0
              : morningMood * 20, // Convert 0-4 scale to 0-100
      'energyLevel': morningMood ?? 0, // 0-4 scale
      'morningMood': morningMood ?? 2, // Store original morning mood
      'water': 0,
      'sleep': 0,
      'calories': 0,
      'work': 0,
      'reading': 0,
      'heart': 0,
      'emotionalState': 'neutral',
      'intentions':
          intentions ??
          [
            {'text': 'Write your first intention here', 'isCompleted': false},
            {'text': 'Write your second intention here', 'isCompleted': false},
            {'text': 'Write your third intention here', 'isCompleted': false},
          ],
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get stats for a specific date
  Future<Map<String, dynamic>> getStatsForDate(DateTime date) async {
    if (currentUserId == null) return {};

    final dateId = DateFormat('yyyy-MM-dd').format(date);
    final docSnapshot =
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('daily_stats')
            .doc(dateId)
            .get();

    return docSnapshot.data() ?? {};
  }

  // Get stats history for a date range
  Future<List<Map<String, dynamic>>> getStatsHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (currentUserId == null) return [];

    final startDateId = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateId = DateFormat('yyyy-MM-dd').format(endDate);

    final querySnapshot =
        await _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('daily_stats')
            .where('date', isGreaterThanOrEqualTo: startDateId)
            .where('date', isLessThanOrEqualTo: endDateId)
            .orderBy('date', descending: true)
            .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Stream stats history for the last N days
  Stream<List<Map<String, dynamic>>> getStatsHistoryStream({int days = 7}) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final startDate = DateTime.now().subtract(Duration(days: days - 1));
    final startDateId = DateFormat('yyyy-MM-dd').format(startDate);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('daily_stats')
        .where('date', isGreaterThanOrEqualTo: startDateId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get aggregated stats for a time period
  Future<Map<String, dynamic>> getAggregatedStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final stats = await getStatsHistory(startDate: startDate, endDate: endDate);

    if (stats.isEmpty) return {};

    // Calculate averages and totals
    double totalEnergy = 0;
    double totalWater = 0;
    double totalSleep = 0;
    double totalCalories = 0;
    double totalWork = 0;
    double totalReading = 0;
    double totalHeartRate = 0;
    int completedIntentions = 0;
    int totalIntentions = 0;

    for (final dayStat in stats) {
      totalEnergy += (dayStat['energy'] as num?)?.toDouble() ?? 0;
      totalWater += (dayStat['water'] as num?)?.toDouble() ?? 0;
      totalSleep += (dayStat['sleep'] as num?)?.toDouble() ?? 0;
      totalCalories += (dayStat['calories'] as num?)?.toDouble() ?? 0;
      totalWork += (dayStat['work'] as num?)?.toDouble() ?? 0;
      totalReading += (dayStat['reading'] as num?)?.toDouble() ?? 0;
      totalHeartRate += (dayStat['heart'] as num?)?.toDouble() ?? 0;

      final intentions = List<Map<String, dynamic>>.from(
        dayStat['intentions'] as List? ?? [],
      );
      totalIntentions += intentions.length;
      completedIntentions +=
          intentions
              .where((intention) => intention['isCompleted'] == true)
              .length;
    }

    final days = stats.length;
    return {
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
        'days': days,
      },
      'averages': {
        'energy': totalEnergy / days,
        'water': totalWater / days,
        'sleep': totalSleep / days,
        'calories': totalCalories / days,
        'work': totalWork / days,
        'reading': totalReading / days,
        'heartRate': totalHeartRate / days,
      },
      'totals': {
        'water': totalWater,
        'calories': totalCalories,
        'work': totalWork,
        'reading': totalReading,
      },
      'intentions': {
        'total': totalIntentions,
        'completed': completedIntentions,
        'completionRate':
            totalIntentions > 0
                ? (completedIntentions / totalIntentions) * 100
                : 0,
      },
    };
  }

  Future<bool> hasTodayStats() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final statsDoc =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('stats')
            .doc(today)
            .get();

    return statsDoc.exists;
  }

  // Get stream of gratitude entries for today
  Stream<List<Map<String, dynamic>>> getGratitudeStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_stats')
        .doc(dateStr)
        .collection('gratitude')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'text': data['text'] ?? '',
              'timestamp': data['timestamp'] ?? Timestamp.now(),
            };
          }).toList();
        });
  }

  // Add a gratitude entry
  Future<void> addGratitudeEntry(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    // Add gratitude entry to subcollection
    final gratitudeRef =
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('daily_stats')
            .doc(dateStr)
            .collection('gratitude')
            .doc();

    await gratitudeRef.set({'text': text, 'timestamp': Timestamp.now()});

    // Fetch all gratitude entries for today
    final gratitudeSnapshot =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('daily_stats')
            .doc(dateStr)
            .collection('gratitude')
            .get();

    final gratitudeList =
        gratitudeSnapshot.docs
            .map((doc) => {'text': doc['text'], 'timestamp': doc['timestamp']})
            .toList();

    // Update the main daily_stats document with the gratitude list
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_stats')
        .doc(dateStr)
        .set({'gratitude': gratitudeList}, SetOptions(merge: true));

    // Get current stats to update energy
    final statsDoc = await _todayStatsRef.get();
    final currentStats = statsDoc.data() ?? {};
    final currentEnergy = (currentStats['energy'] as num?)?.toDouble() ?? 0.0;

    // Update energy in daily stats
    final newEnergy = math.min(100, currentEnergy + 5); // Cap at 100
    await _todayStatsRef.set({
      'energy': newEnergy,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete a gratitude entry
  Future<void> deleteGratitudeEntry(String entryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(today);

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('daily_stats')
        .doc(dateStr)
        .collection('gratitude')
        .doc(entryId)
        .delete();
  }
}
