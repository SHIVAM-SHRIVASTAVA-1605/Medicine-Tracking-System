import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'data/local/settings_service.dart';
import 'logic/services/notification_service.dart';
import 'logic/providers/medicine_provider.dart';
import 'logic/providers/settings_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/add_medicine_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/statistics_screen.dart';
import 'ui/screens/help_support_screen.dart';
import 'ui/screens/alarm_screen.dart';
import 'data/models/medicine_model.dart';

// Global navigation key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService.init();
  await SettingsService.init();
  await NotificationService.init();
  await NotificationService.loadSettings();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotificationHandler();
  }

  void _setupNotificationHandler() {
    print('\n');
    print('🔧 Setting up notification handler in MyApp...');
    NotificationService.onNotificationAction = (action) {
      print('\n');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📨 NOTIFICATION ACTION RECEIVED IN MYAPP');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🎬 Action: $action');
      print('🕐 Time: ${DateTime.now()}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      _handleNotificationAction(action);
    };
    print('✅ Notification handler setup complete');
    
    // Process any pending actions that occurred before callback was set
    print('🔍 Checking for pending notification actions...');
    final pendingActions = NotificationService.getPendingActions();
    if (pendingActions.isNotEmpty) {
      print('⚡ Processing ${pendingActions.length} pending action(s)');
      for (final action in pendingActions) {
        print('   Processing: $action');
        _handleNotificationAction(action);
      }
    } else {
      print('✅ No pending actions');
    }
    print('\n');
  }

  // Check if device is locked using platform channel
  Future<bool> _isDeviceLocked() async {
    try {
      const platform = MethodChannel('com.example.medicine_reminder/lockscreen');
      final bool isLocked = await platform.invokeMethod('isDeviceLocked');
      print('🔒 Device locked status: $isLocked');
      return isLocked;
    } catch (e) {
      print('❌ Error checking device lock status: $e');
      // If we can't determine, assume unlocked to show notification normally
      return false;
    }
  }

  void _handleNotificationAction(String action) async {
    try {
      print('\n');
      print('╔═══════════════════════════════════════════════════╗');
      print('║   HANDLING NOTIFICATION ACTION                    ║');
      print('╚═══════════════════════════════════════════════════╝');
      print('🎯 Action String: "$action"');
      print('⏰ Processing Time: ${DateTime.now()}');

      final context = navigatorKey.currentContext;
      print('🔍 Checking context availability...');
      if (context == null) {
        print('❌ FATAL ERROR: Context is null!');
        print('   Cannot access Provider without context');
        print('   NavigatorKey might not be properly initialized');
        return;
      }
      print('✅ Context is available');

      // Handle notification tap to show alarm screen
      if (action.startsWith('tap_')) {
        print('\n📱 NOTIFICATION TAP DETECTED');
        print('─────────────────────────────────────────────────');
        final idStr = action.replaceFirst('tap_', '');
        print('📝 Extracted ID string: "$idStr"');
        final id = int.tryParse(idStr);
        print('🔢 Parsed notification ID: $id');

        if (id != null) {
          print('✅ Valid notification ID');
          
          // Check if device is locked
          final isLocked = await _isDeviceLocked();
          
          if (!isLocked) {
            print('📱 Device is UNLOCKED - Not showing full alarm screen');
            print('   User can use notification action buttons instead');
            return; // Don't show alarm screen when device is unlocked
          }
          
          print('🔒 Device is LOCKED - Showing full alarm screen');
          print('🔍 Searching for medicine with notification ID: $id');

          // Find the medicine by notification ID
          final provider =
              Provider.of<MedicineProvider>(context, listen: false);
          print('✅ MedicineProvider accessed');
          final medicines = provider.medicinesMap;
          print('📊 Total medicines in database: ${medicines.length}');

          MedicineModel? medicine;
          for (var entry in medicines.entries) {
            print(
                '   Checking medicine "${entry.value.name}" (ID: ${entry.value.notificationId})');
            if (entry.value.notificationId == id) {
              medicine = entry.value;
              print('🎯 MATCH FOUND!');
              print('   Medicine: ${medicine.name}');
              print('   Dose: ${medicine.dose}');
              break;
            }
          }

          if (medicine != null) {
            print('\n📱 Showing alarm screen as fullscreen dialog...');
            // Show alarm screen as a fullscreen dialog that blocks other navigation
            showDialog(
              context: context,
              barrierDismissible: false, // Can't dismiss by tapping outside
              barrierColor: Colors.black, // Full black background
              builder: (BuildContext dialogContext) => AlarmScreen(
                medicineName: medicine!.name,
                dose: medicine.dose,
                notificationId: medicine.notificationId,
              ),
            );
            print('✅ Alarm screen dialog shown');
          } else {
            print('\n❌ ERROR: Medicine not found!');
            print('   No medicine has notification ID: $id');
          }
        } else {
          print('❌ ERROR: Could not parse ID from string "$idStr"');
        }
      } else if (action.startsWith('snooze_')) {
        print('\n🔔 SNOOZE ACTION DETECTED');
        print('─────────────────────────────────────────────────');
        final idStr = action.replaceFirst('snooze_', '');
        print('📝 Extracted ID string: "$idStr"');
        final id = int.tryParse(idStr);
        print('🔢 Parsed notification ID: $id');

        if (id != null) {
          print('✅ Valid notification ID');
          print('🔍 Searching for medicine with notification ID: $id');

          // Find the medicine by notification ID
          final provider =
              Provider.of<MedicineProvider>(context, listen: false);
          print('✅ MedicineProvider accessed');
          final medicines = provider.medicinesMap;
          print('📊 Total medicines in database: ${medicines.length}');

          MedicineModel? medicine;
          for (var entry in medicines.entries) {
            print(
                '   Checking medicine "${entry.value.name}" (ID: ${entry.value.notificationId})');
            if (entry.value.notificationId == id) {
              medicine = entry.value;
              print('🎯 MATCH FOUND!');
              print('   Medicine: ${medicine.name}');
              print('   Dose: ${medicine.dose}');
              break;
            }
          }

          if (medicine != null) {
            print('\n⏰ Executing snooze...');
            // Snooze notification silently in background
            await NotificationService.snoozeNotification(
              id: id,
              title: 'Medicine Reminder (Snoozed)',
              body: 'Time to take ${medicine.name} - ${medicine.dose}',
            );
            print('✅ Notification snoozed successfully (background)');
            
            // Show brief feedback to user
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${medicine.name} reminder snoozed'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } else {
            print('\n❌ ERROR: Medicine not found!');
            print('   No medicine has notification ID: $id');
            print('   Available notification IDs:');
            for (var entry in medicines.entries) {
              print(
                  '      - ${entry.value.name}: ${entry.value.notificationId}');
            }
          }
        } else {
          print('❌ ERROR: Could not parse ID from string "$idStr"');
        }
      } else if (action.startsWith('dismiss_')) {
        print('\n💊 MARK TAKEN ACTION DETECTED');
        print('─────────────────────────────────────────────────');
        final idStr = action.replaceFirst('dismiss_', '');
        print('📝 Extracted ID string: "$idStr"');
        final id = int.tryParse(idStr);
        print('🔢 Parsed notification ID: $id');

        if (id != null) {
          print('✅ Valid notification ID');
          print('🔍 Searching for medicine with notification ID: $id');

          // Find and mark medicine as taken
          final provider =
              Provider.of<MedicineProvider>(context, listen: false);
          print('✅ MedicineProvider accessed');
          final medicines = provider.medicinesMap;
          print('📊 Total medicines in database: ${medicines.length}');

          bool found = false;
          for (var entry in medicines.entries) {
            print(
                '   Checking medicine "${entry.value.name}" (ID: ${entry.value.notificationId})');
            if (entry.value.notificationId == id) {
              found = true;
              print('🎯 MATCH FOUND!');
              print('   Medicine: ${entry.value.name}');
              print('   Current taken status: ${entry.value.isTaken}');

              // Mark as taken
              print('\n💉 Marking medicine as taken...');
              await provider.toggleMedicineTaken(entry.key);
              print('✅ Medicine marked as taken successfully (background)');
              print('   New taken status: ${entry.value.isTaken}');
              
              // Show brief feedback to user
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${entry.value.name} marked as taken'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              break;
            }
          }

          if (!found) {
            print('\n❌ ERROR: Medicine not found!');
            print('   No medicine has notification ID: $id');
            print('   Available notification IDs:');
            for (var entry in medicines.entries) {
              print(
                  '      - ${entry.value.name}: ${entry.value.notificationId}');
            }
          }
        } else {
          print('❌ ERROR: Could not parse ID from string "$idStr"');
        }
      }
      print('\n╔═══════════════════════════════════════════════════╗');
      print('║   ACTION HANDLING COMPLETE                        ║');
      print('╚═══════════════════════════════════════════════════╝');
      print('\n');
    } catch (e, stackTrace) {
      print('\n');
      print('╔═══════════════════════════════════════════════════╗');
      print('║   ⚠️  ERROR IN NOTIFICATION HANDLER                ║');
      print('╚═══════════════════════════════════════════════════╝');
      print('❌ Error: $e');
      print('📋 Stack trace: $stackTrace');
      print('🔄 App will continue running...');
      print('\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Medicine Reminder',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
        routes: {
          '/add-medicine': (context) => const AddMedicineScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/statistics': (context) => const StatisticsScreen(),
          '/help-support': (context) => const HelpSupportScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/alarm') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => AlarmScreen(
                  medicineName: args['medicineName'] as String,
                  dose: args['dose'] as String,
                  notificationId: args['notificationId'] as int,
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}
