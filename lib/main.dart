import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model/mqtt_model.dart';
import 'controller/mqtt_controller.dart';
import 'view/mqtt_status_page.dart';
import 'view/set_suhu_page.dart';
import 'view/history_page.dart';
import 'view/profile_page.dart';
import 'view/login_page.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SupabaseConfig.init();
  await Supabase.instance.client.auth
      .signOut(); // Paksa logout setiap aplikasi dibuka
  final model = MqttModel();
  final controller = MqttController(model);
  runApp(MyApp(controller: controller));
}

class MyApp extends StatefulWidget {
  final MqttController controller;
  const MyApp({super.key, required this.controller});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = Supabase.instance.client.auth.currentUser != null;

  void handleLoginSuccess() {
    setState(() {
      loggedIn = true;
    });
  }

  void handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    setState(() {
      loggedIn = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Selalu cek status login saat aplikasi dibuka ulang
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        setState(() {
          loggedIn = true;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          loggedIn = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: loggedIn
          ? MainNavBar(controller: widget.controller, onLogout: handleLogout)
          : LoginPage(onLoginSuccess: handleLoginSuccess),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavBar extends StatefulWidget {
  final MqttController controller;
  final VoidCallback onLogout;
  const MainNavBar({
    super.key,
    required this.controller,
    required this.onLogout,
  });

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      MqttStatusPage(controller: widget.controller),
      SetSuhuPage(controller: widget.controller),
      HistoryPage(controller: widget.controller),
      const ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 12,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Status'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Set Suhu',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
