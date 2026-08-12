import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key});

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final supabase = Supabase.instance.client;

  bool loading = false;

  Future<void> checkEmail() async {
    setState(() => loading = true);

    try {
      await supabase.auth.refreshSession();

      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Пользователь не найден")),
        );
        return;
      }

      if (user.emailConfirmedAt != null) {
       Navigator.pop(context);
       setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ещё не подтверждён"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка: $e")),
      );
    }

    setState(() => loading = false);
  }

  Future<void> resendEmail() async {
    try {
      final email = supabase.auth.currentUser?.email;

      if (email == null) return;

      await supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Письмо отправлено")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка отправки: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Подтверждение"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 30),

              const Text(
                "Почти готово!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Мы отправили письмо для подтверждения регистрации.\n\n"
                "Откройте почту и перейдите по ссылке.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : checkEmail,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text("Я подтвердил"),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: resendEmail,
                child: const Text("Отправить письмо ещё раз"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}