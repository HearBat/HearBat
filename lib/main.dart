import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hearbat/stats/stats_db.dart';
import 'package:provider/provider.dart';
import 'providers/my_app_state.dart';
import 'pages/sound_adjustment_page.dart'; 
import 'utils/config_util.dart';
import 'utils/data_service_util.dart';
import 'utils/translations.dart';

final FlutterLocalization localization = FlutterLocalization.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalization.instance.ensureInitialized();
  await ConfigurationManager().fetchConfiguration();
  await DataService().loadJson();
  await StatsDatabase().init();
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
        const MapLocale('km', AppLocale.KM),
        const MapLocale('ja', AppLocale.JA),
      ],
      initLanguageCode: 'en',
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
  }
  
  void _onTranslatedLanguage(Locale? locale) {
    setState(() {}); // rebuild widget tree on translate
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
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
