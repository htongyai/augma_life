import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class HealthService {
  // Create the health factory instance
  static final Health health = Health();

  // Call configure before using health
  static Future<void> initializeHealth() async {
    await health.configure();
  }

  // List of data types we want to access
  static final List<HealthDataType> types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WATER,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // Permissions we need to request
  static final List<HealthDataAccess> permissions = [HealthDataAccess.READ];

  // Open system settings for health permissions
  static Future<void> openHealthSettings() async {
    try {
      if (Platform.isIOS) {
        // For iOS, open Health app
        final Uri url = Uri.parse('x-apple-health://');
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
        } else {
          debugPrint('Could not launch Health app');
        }
      } else if (Platform.isAndroid) {
        // For Android, health connect app
        await health.installHealthConnect();
      }
    } catch (e) {
      debugPrint('Error opening health settings: $e');
    }
  }

  // Request authorization to access health data
  static Future<bool> requestAuthorization() async {
    try {
      // Initialize the health plugin before use
      await initializeHealth();

      // For iOS: Be more specific with permissions for each type
      final specificTypes = [
        HealthDataType.HEART_RATE,
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ];

      // Create matching permissions list with same length as types
      final permissionsList =
          specificTypes.map((_) => HealthDataAccess.READ).toList();

      // Log the request
      debugPrint(
        'Requesting authorization for types: ${specificTypes.length} with permissions: ${permissionsList.length}',
      );

      // Request specific permissions
      final bool authorized = await health.requestAuthorization(
        specificTypes,
        permissions: permissionsList,
      );

      debugPrint('Health data authorization status: $authorized');
      return authorized;
    } catch (e) {
      debugPrint('Error requesting health authorization: $e');
      return false;
    }
  }

  // Fetch average heart rate for today
  static Future<double?> fetchAverageHeartRate() async {
    try {
      // Ensure we have permission
      final authorized = await requestAuthorization();
      if (!authorized) {
        debugPrint('Health data access not authorized');
        return null;
      }

      // Set time range for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch heart rate data
      List<HealthDataPoint> heartRateData = await health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: midnight,
        endTime: now,
      );

      // If no data available
      if (heartRateData.isEmpty) {
        debugPrint('No heart rate data available for today');
        return null;
      }

      // Calculate average heart rate
      double sum = 0;
      for (var dataPoint in heartRateData) {
        // The value is a NumericHealthValue
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        sum += value!;
      }

      final average = sum / heartRateData.length;
      debugPrint(
        'Average heart rate: ${average.toStringAsFixed(1)} BPM from ${heartRateData.length} measurements',
      );
      return average;
    } catch (e) {
      debugPrint('Error fetching heart rate data: $e');
      return null;
    }
  }

  // Fetch step count for today
  static Future<int?> fetchStepCount() async {
    try {
      // Ensure we have permission
      final authorized = await requestAuthorization();
      if (!authorized) {
        debugPrint('Health data access not authorized');
        return null;
      }

      // Set time range for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Try to get total steps directly
      try {
        final steps = await health.getTotalStepsInInterval(midnight, now);
        debugPrint('Total steps today: $steps');
        return steps;
      } catch (e) {
        debugPrint('Error getting total steps: $e');

        // If direct method fails, try to get step data and calculate total
        List<HealthDataPoint> stepData = await health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: midnight,
          endTime: now,
        );

        // If no data available
        if (stepData.isEmpty) {
          debugPrint('No step data available for today');
          return null;
        }

        // Sum up all step counts
        int totalSteps = 0;
        for (var dataPoint in stepData) {
          final value = (dataPoint.value as NumericHealthValue).numericValue;
          totalSteps += value!.toInt();
        }

        debugPrint(
          'Total steps today: $totalSteps from ${stepData.length} measurements',
        );
        return totalSteps;
      }
    } catch (e) {
      debugPrint('Error fetching step data: $e');
      return null;
    }
  }

  // Fetch sleep duration for last night
  static Future<double?> fetchSleepDuration() async {
    try {
      // Ensure we have permission
      final authorized = await requestAuthorization();
      if (!authorized) {
        debugPrint('Health data access not authorized');
        return null;
      }

      // Set time range for last 24 hours
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      // Fetch sleep data
      List<HealthDataPoint> sleepData = await health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: yesterday,
        endTime: now,
      );

      // If no data available
      if (sleepData.isEmpty) {
        debugPrint('No sleep data available for last 24 hours');
        return null;
      }

      // Calculate total sleep duration in hours
      double totalSleepMinutes = 0;
      for (var dataPoint in sleepData) {
        // For sleep data, we need to calculate the duration
        final DateTime startTime = dataPoint.dateFrom;
        final DateTime endTime = dataPoint.dateTo;
        final duration = endTime.difference(startTime).inMinutes;
        totalSleepMinutes += duration;
      }

      final sleepHours = totalSleepMinutes / 60;
      debugPrint('Total sleep: ${sleepHours.toStringAsFixed(1)} hours');
      return sleepHours;
    } catch (e) {
      debugPrint('Error fetching sleep data: $e');
      return null;
    }
  }

  // Fetch water intake for today
  static Future<double?> fetchWaterIntake() async {
    try {
      // Ensure we have permission
      final authorized = await requestAuthorization();
      if (!authorized) {
        debugPrint('Health data access not authorized');
        return null;
      }

      // Set time range for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch water data
      List<HealthDataPoint> waterData = await health.getHealthDataFromTypes(
        types: [HealthDataType.WATER],
        startTime: midnight,
        endTime: now,
      );

      // If no data available
      if (waterData.isEmpty) {
        debugPrint('No water intake data available for today');
        return null;
      }

      // Calculate total water intake in liters (convert to bottles)
      double totalWaterLiters = 0;
      for (var dataPoint in waterData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalWaterLiters += value!;
      }

      // Convert to bottles (assuming 1 bottle = 0.5 liters)
      final waterBottles = totalWaterLiters / 0.5;
      debugPrint(
        'Total water intake: ${waterBottles.toStringAsFixed(1)} bottles',
      );
      return waterBottles;
    } catch (e) {
      debugPrint('Error fetching water intake data: $e');
      return null;
    }
  }

  // Fetch calories burned for today
  static Future<int?> fetchCaloriesBurned() async {
    try {
      // Ensure we have permission
      final authorized = await requestAuthorization();
      if (!authorized) {
        debugPrint('Health data access not authorized');
        return null;
      }

      // Set time range for today
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // Fetch calories data
      List<HealthDataPoint> caloriesData = await health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );

      // If no data available
      if (caloriesData.isEmpty) {
        debugPrint('No calories burned data available for today');
        return null;
      }

      // Calculate total calories burned
      double totalCalories = 0;
      for (var dataPoint in caloriesData) {
        final value = (dataPoint.value as NumericHealthValue).numericValue;
        totalCalories += value!;
      }

      debugPrint('Total calories burned: ${totalCalories.toInt()} kcal');
      return totalCalories.toInt();
    } catch (e) {
      debugPrint('Error fetching calories burned data: $e');
      return null;
    }
  }
}
