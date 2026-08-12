import 'package:flutter/material.dart';
import 'package:intereasever2/screens/email_confirmation_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void showLoginDialog(
  BuildContext context,
  VoidCallback onLogin,
) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Text(
              isLogin ? "Вход" : "Регистрация",
              textAlign: TextAlign.center,
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Пароль",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            actions: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    child: Text(
                      isLogin ? "Войти" : "Зарегистрироваться",
                    ),

                    onPressed: () async {
                      final supabase = Supabase.instance.client;

                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Заполни email и пароль"),
                          ),
                        );
                        return;
                      }

                      // 💚 ВХОД
                      if (isLogin) {
                        try {
                          print("Пытаемся войти");
                          
                          final response = await supabase.auth.signInWithPassword(
                            email: email,
                            password: password,
                          );
                          
                          print("Ответ получен");
                          print(response.user);

                          print("Текущий пользователь:");
                          print(Supabase.instance.client.auth.currentUser);

                          Navigator.pop(dialogContext);
                          
                          } catch (e, stackTrace) {
                          print("ОШИБКА ВХОДА:");
                          print(e);
                          print(stackTrace);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Ошибка входа: $e"),
                              ),
                            );
                          }
                        }
                      }

                      // 🧡 РЕГИСТРАЦИЯ
                      else {
                        try {
                          await supabase.auth.signUp(
                            email: email,
                            password: password,
                          );

                          Navigator.pop(dialogContext);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EmailConfirmationScreen(),
                            ),
                          );
                          
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Ошибка регистрации: $e")),
                            );
                          }
                        } 
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        emailController.clear();
                        passwordController.clear();
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Нет аккаунта? Зарегистрироваться"
                          : "Уже есть аккаунт? Войти",
                      textAlign: TextAlign.center,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    child: const Text("Отмена"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}