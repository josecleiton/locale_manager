import 'package:flutter/material.dart';
import 'package:locale_manager/locale_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Locale Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Locale Manager Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _controller;
  late final LocaleManager _locale;

  String? _nativeText;

  @override
  void initState() {
    _locale = LocaleManager();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.text = await _locale.getLocale();
      await _fetchText();
    });
    super.initState();
  }

  Future<void> _onPressed() async {
    await _locale.setLocale(_controller.text.trim());
    await _fetchText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Locale',
              ),
            ),
            Text(
              _nativeText ?? 'Dart Text',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onPressed,
        tooltip: 'Update Locale',
        child: const Icon(Icons.language),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _fetchText() async {
    final text = await _locale.getLocalized('TEXT');
    debugPrint('Fetched text: $text');
    if (!mounted) {
      return;
    }

    setState(() {
      _nativeText = text ?? 'Native Text Not Found';
    });
  }
}
