import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/my_app_state.dart';
import 'pages/sound_adjustment_page.dart'; 
import 'utils/config_util.dart';
import 'utils/data_service_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigurationManager().fetchConfiguration();
  await DataService().loadJson();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'HearBat',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromARGB(255, 232, 218, 255),
          useMaterial3: true,
          textTheme: GoogleFonts.beVietnamProTextTheme(
            Theme.of(context).textTheme,
          ),
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 67, 0, 99)),
        ),
        home: SoundAdjustmentPage(),
      ),
    );
  }
}
