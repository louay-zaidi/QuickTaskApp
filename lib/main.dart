import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quick_tasks/models/task.dart';
import 'package:quick_tasks/screens/Home.dart';
import 'package:quick_tasks/screens/add.dart';
import 'package:quick_tasks/screens/calendar.dart';
import 'package:quick_tasks/screens/about.dart';
import 'package:quick_tasks/themes/theme_notifier.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());

  await Hive.openBox('settings');

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', 'US');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  void _loadLocale() {
    final box = Hive.box('settings');
    final String? languageCode = box.get('languageCode', defaultValue: 'en');
    final String? countryCode = box.get('countryCode', defaultValue: 'US');
    setState(() {
      _locale = Locale(languageCode!, countryCode!);
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });

    final box = Hive.box('settings');
    box.put('languageCode', locale.languageCode);
    box.put('countryCode', locale.countryCode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: AppLocalizations.of(context)?.translate('appTitle') ??
              'QuickTasks',
          theme: themeNotifier.currentTheme,
          locale: _locale,
          supportedLocales: [
            Locale('en', 'US'),
            Locale('it', 'IT'),
          ],
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: NavigationScreen(setLocale: setLocale),
        );
      },
    );
  }
}

class NavigationScreen extends StatefulWidget {
  final Function(Locale) setLocale;

  NavigationScreen({required this.setLocale});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();
  final List<Widget> _screens = [
    Home(),
    AddTaskScreen(),
    Calendar(),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('appTitle') ??
            'QuickTasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)?.translate('appTitle') ??
                        'QuickTasks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading:
                    Icon(Icons.info, color: Theme.of(context).iconTheme.color),
                title: Text(
                    AppLocalizations.of(context)?.translate('aboutApp') ??
                        'About App'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.language,
                    color: Theme.of(context).iconTheme.color),
                title: Text(
                    AppLocalizations.of(context)?.translate('selectLanguage') ??
                        'Select Language'),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              SwitchListTile(
                title: Text(
                    AppLocalizations.of(context)?.translate('darkMode') ??
                        'Dark Mode'),
                value: themeNotifier.isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.toggleTheme();
                  Navigator.pop(context);
                },
                secondary: Icon(Icons.brightness_6),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Color(0xFFc3f44d),
        selectedItemColor: Color(0xFF1a434e),
        unselectedItemColor: Color(0xFF1a434e),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.home_filled, size: 24),
            ),
            label: AppLocalizations.of(context)?.translate('home') ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1a434e),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFFc3f44d),
                size: 28,
              ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.calendar_today_rounded, size: 24),
            ),
            label: AppLocalizations.of(context)?.translate('calendar') ??
                'Calendar',
          ),
        ],
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedFontSize: 0,
        unselectedFontSize: 0,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.language),
                title: Text('English'),
                onTap: () {
                  widget.setLocale(Locale('en', 'US'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.language),
                title: Text('Italiano'),
                onTap: () {
                  widget.setLocale(Locale('it', 'IT'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
