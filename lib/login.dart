import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan/daftar.dart';
import 'package:plan/dashboard.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/logic/alert.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _dbService = DatabaseSvc.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _gagalLogin = false;

  Future<void> _loginUser() async {
    String usernamenya = _usernameController.text.trim();
    String passwordnya = _passwordController.text.trim();

    bool adaUsernya =
        await _dbService.authenticateUser(usernamenya, passwordnya);

    if (usernamenya.isNotEmpty && passwordnya.isNotEmpty) {
      setState(() {
        _gagalLogin = false;
      });
    }
    if (usernamenya.isEmpty || passwordnya.isEmpty) {
      setState(() {
        _gagalLogin = true;
        _usernameController.text = '';
        _passwordController.text = '';
      });
    } else if (await adaUsernya) {
      await _dbService.userLogin(usernamenya);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(username: usernamenya),
        ),
      );
    } else {
      alertGagal(context, message: 'Username atau Password Salah!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8FF),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                'assets/planbiggernobg.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Mulai hari yang lebih produktif!',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF063FBA)),
              ),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_gagalLogin) ...[
              SizedBox(height: 10),
              Text(
                'Username atau Password harus diisi!',
                style: TextStyle(color: Colors.red),
              ),
            ] else
              ...[],
            SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loginUser,
              icon: Icon(Icons.login),
              label: Text(
                'Login',
                style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFFECF8FF), fontSize: 14),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF063FBA))),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {},
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Belum punya akun?',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: Colors.grey.shade700),
                    ),
                    TextSpan(
                      text: ' Daftar terlebih dahulu!',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Color(0xFF45B1FF),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DaftarAkun(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
