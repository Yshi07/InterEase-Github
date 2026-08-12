import 'package:flutter/material.dart';
import 'package:intereasever2/appbar.dart';
import 'package:intereasever2/screens/news.dart';
import 'package:intereasever2/screens/search.dart';
import 'package:intereasever2/screens/infos.dart';
import 'package:intereasever2/screens/faqp.dart';
import 'package:intereasever2/screens/chatp.dart';
import 'package:intereasever2/screens/ent.dart';
import 'package:intereasever2/screens/persp.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intereasever2/map_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/screens/ent.dart';
import 'package:intereasever2/dates/profile_service.dart';
import 'package:intereasever2/dates/plan_service.dart';
import 'package:intereasever2/dates/plan.dart';
import 'package:intereasever2/dates/plan_dialogs.dart';
import 'package:intereasever2/screens/myplans.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ieemvdgkkzbzhtzkymgn.supabase.co',
    anonKey: 'sb_publishable_yBVLpkHR3-DikgxpYn7oDw_1TC0db1E',
  );

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [Locale('ru', 'RU')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Plan> _plans = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
    });
  }

  Future<void> _loadPlans() async {
    final data = await PlanService.loadPlans();
    
    
    setState(() {
      _plans = data;
    });
  }

  void _showCalendar(BuildContext context) {
  final overlay = Overlay.of(context);

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // фон
          GestureDetector(
            onTap: () => entry.remove(),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),

          Positioned(
            right: 20,
            top: 220, // подгонишь под кнопку
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 250,
                  maxHeight: 300,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TableCalendar(
                  locale: 'ru_RU',
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2035),
                  focusedDay: _focusedDay,
                  
                  selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day),

                  eventLoader: (day) {
                    return _plans.where((plan) {
                      return isSameDay(plan.date, day);
                    }).toList();
                    print("checking day: $day");
                  },

                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    
                    entry.remove();
                    
                    final dayPlans = _plans.where((plan) {
                      return isSameDay(plan.date, selectedDay);
                    }).toList();
                    
                    if (dayPlans.isEmpty) return;
                    
                    if (dayPlans.length == 1) {
                      _showPlanDialog(dayPlans.first);
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text("Заметки за день"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: dayPlans.map((plan) {
                                return ListTile(
                                  title: Text(plan.title),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showPlanDialog(plan);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                     );
                    }
                  },
                   
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    headerPadding: EdgeInsets.symmetric(vertical: 4),
                    titleTextStyle: TextStyle(fontSize: 14),
                  ),
                  
                  daysOfWeekHeight: 18,
                  rowHeight: 32,
                  
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                     markerDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  
  overlay.insert(entry);
  }
  
  void _showPlanDialog(Plan plan) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(plan.title),
          content: Text(plan.content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showEditPlanDialog(context, plan, _loadPlans);
              },
              child: const Text("Редактировать"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Закрыть"),
            ),
          ],
        );
      },
    );
  }

  final profileService = ProfileService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: const Color(0xFF1B3146),
      
      body: Stack(
        children: [
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 375,
                child: Opacity(
                  opacity: 0.7,
                  child: Image.asset(
                    'assets/background.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 375,
                height: MediaQuery.of(context).size.height * 1.1,
                color: const Color(0xFF99D98C).withAlpha(110),
              ),
            ),
          ),
          
          SizedBox.expand(
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.calendar_month,
                        color: Colors.white, size: 32),
                        onPressed: () => _showCalendar(context),
                      ),
                      
                      const SizedBox(width: 8),                      
                      IconButton(
                        onPressed: () {
                          MapService.openCityMap(city: "Москва");
                        },
                        
                        icon: const Icon(Icons.map_outlined,
                        color: Colors.white, size: 32),
                      ),
                      
                      const SizedBox(width: 8),
                      const Icon(Icons.settings_outlined,
                      color: Colors.white, size: 32),
                    ],
                  ),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                      AssetImage('assets/avatar.png'),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    StreamBuilder<AuthState>(
                      stream: Supabase.instance.client.auth.onAuthStateChange,
                      builder: (context, snapshot) {
                        final user = Supabase.instance.client.auth.currentUser;
                        
                        if (user == null) {
                          return const Text(
                            'Привет, Гость!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }
                        
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: profileService.getProfile(user.id),
                          builder: (context, profileSnapshot) {
                            final profile = profileSnapshot.data;
                            final name = profileService.getDisplayName(profile, user.email);
                            
                            return Text(
                              'Привет, $name',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        );
                      },
                    )
                  ],
                ),
                
                const SizedBox(height: 20),
                StreamBuilder<AuthState>(
                  stream: Supabase.instance.client.auth.onAuthStateChange,
                  builder: (context, snapshot) {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      return ElevatedButton(
                        onPressed: () {
                          showLoginDialog(context, () {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F6D7A),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Войти/Регистрация'),
                      );
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PerP(
                                  onLogout: () async {
                                    await Supabase.instance.client.auth.signOut();
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F6D7A),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Личный кабинет'),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        ElevatedButton(
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                          },
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Выйти'),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButton(context, Icons.search,
                      'Поиск', PageSearch()),
                      _buildButton(context, Icons.newspaper,
                      'Новости', PageNews()),
                      _buildButton(context, Icons.lightbulb,
                      'Полезная информация', PageInfos()),
                    ],
                  ),
                ),
                
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBottomButton(
                      context, 'FAQ', PageFaq()),
                      _buildBottomButton(
                        context, 'Chat', PageChat()),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

   static Widget _buildButton(
  BuildContext context,
  IconData icon,
  String text,
  Widget page,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 65),
    child: PhysicalModel(
      color: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },

        icon: Icon(icon, color: Colors.black),
        label: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    ),
  );
}

  static Widget _buildBottomButton(
    BuildContext context,
    String text,
    Widget page,
    ){
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: Colors.black,
      elevation: 12,
      borderRadius: BorderRadius.circular(15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120,60),
          backgroundColor: Colors.blueGrey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },

        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      )

  
    );
  }
}