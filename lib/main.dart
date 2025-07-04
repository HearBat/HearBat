import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearbat/stats/stats_db.dart';
import 'package:hearbat/streaks/streaks_db.dart';
import 'package:provider/provider.dart';
import 'providers/my_app_state.dart';
import 'streaks/streaks_provider.dart';
import 'pages/sound_adjustment_page.dart'; 
import 'utils/config_util.dart';
import 'utils/data_service_util.dart';
import 'utils/translations.dart';
import 'utils/push_notifs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final FlutterLocalization localization = FlutterLocalization.instance;

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await FlutterLocalization.instance.ensureInitialized();
    
    await DataService().loadJson();
    await StatsDatabase().init();
    
    final streaksDb = StreaksDatabase.instance;
    await streaksDb.database;
    
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
  } catch (e) {
    print('Critical initialization error: $e');
  }
  
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
    
    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.EN),
        const MapLocale('vi', AppLocale.VI),
      ],
      initLanguageCode: 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    
    _initializeNetworkFeatures();
  }
  
  Future<void> _initializeNetworkFeatures() async {
    try {
      await ConfigurationManager().fetchConfiguration();
      await PushNotifications().initFirebaseMessaging();
      
      final streaksDb = StreaksDatabase.instance;
      await streaksDb.syncWithFirestore();
      
      print('Network features initialized successfully');
    } catch (e) {
      print('Network initialization error: $e');
    }
  }
  
  void _onTranslatedLanguage(Locale? locale) {
    setState(() {}); // rebuild widget tree on translate
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MyAppState()),
        ChangeNotifierProvider(create: (context) => StreakProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: localization.supportedLocales,
        localizationsDelegates: localization.localizationsDelegates,
        title: 'HearBat',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 232, 218, 255),
          useMaterial3: true,
          textTheme: GoogleFonts.beVietnamProTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 67, 0, 99),
          ),
        ),
        home: SoundAdjustmentPage(),
      ),
    );
  }
}