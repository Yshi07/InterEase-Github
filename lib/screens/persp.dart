import 'package:flutter/material.dart';
import 'package:intereasever2/appbar.dart';
import 'package:intereasever2/screens/mydates.dart';
import 'package:intereasever2/screens/mymod.dart';
import 'package:intereasever2/screens/myplans.dart';
import 'package:intereasever2/screens/mystudy.dart';
import 'package:intereasever2/screens/myuse.dart';
import 'package:intereasever2/screens/mychat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/profile_service.dart';

final profileService = ProfileService();

class PerP extends StatelessWidget {

    final VoidCallback onLogout;

  const PerP({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar (showBackButton: true,),
      backgroundColor: const Color(0xFF1B3146),
      body: Stack(
        children: [
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/background.png',
                width: 475,
                height: 475,
                fit: BoxFit.contain,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // Аватар
                    PhysicalModel(
                      color: Colors.transparent,
                      elevation: 12,
                      shadowColor: Colors.black,
                      shape: BoxShape.circle,
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(
                          'assets/avatar.png',
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // ИМЯ + КНОПКА ВЫХОДА
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          StreamBuilder<AuthState>(
                            stream: Supabase.instance.client.auth.onAuthStateChange,
                            builder: (context, snapshot) {
                              final user =
                              Supabase.instance.client.auth.currentUser;
                              
                              return FutureBuilder<Map<String, dynamic>?>(
                                future: profileService.getProfile(user!.id),
                                builder: (context, profileSnapshot) {
                                  final profile = profileSnapshot.data;
                                  
                                  final name = profileService.getDisplayName(
                                    profile,
                                    user.email,
                                  );
                                  
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
                          ),
                          
                          const SizedBox(height: 8),
                          
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              
                              child: const Text('Выйти'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 10),

                    // Кнопка со смайлом
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.black54,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyChat(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.sentiment_satisfied_alt,
                          size: 40,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Builder(
                        builder: (context) {
                          return _buildButton(context, 'Мои данные', MyDates());
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return _buildButton(context, 'Мои планы', MyPlans());
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return _buildButton(context, 'Моя учеба', MyStudy());
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return _buildButton(context, 'Всякое полезное', MyUse());
                        },
                      ),
                      Builder(
                        builder: (context) {
                          return _buildButton(context, 'Шаблоны документов', MyMod());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
                
                

static Widget _buildButton(
  BuildContext context,
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
      child: ElevatedButton(
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    ),
  );
}
}
