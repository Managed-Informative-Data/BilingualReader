import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/word_entry.dart';
import 'models/text_entry.dart';
import 'models/word_list.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(WordEntryAdapter());
  Hive.registerAdapter(TextEntryAdapter());
  Hive.registerAdapter(WordListAdapter());

  runApp(const ProviderScope(child: BilingualReaderApp()));
}

class BilingualReaderApp extends StatelessWidget {
  const BilingualReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bilingual Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
