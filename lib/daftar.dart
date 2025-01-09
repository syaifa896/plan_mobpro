import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/logic/alert.dart';
import 'package:plan/login.dart';
import 'package:google_fonts/google_fonts.dart';

class DaftarAkun extends StatefulWidget {
  @override
  _DaftarAkunState createState() => _DaftarAkunState();
}

class _DaftarAkunState extends State<DaftarAkun> {
  final _dbService = DatabaseSvc.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _regisUser() async {
    String usernamenya = _usernameController.text.trim();
    String passwordnya = _passwordController.text.trim();

    if (usernamenya.isNotEmpty && passwordnya.isNotEmpty) {
      final users = await _dbService.readUsers();
      bool userAda = users.any((user) => user['username'] == usernamenya);

      if (!userAda) {
        await _dbService.tambahUser(usernamenya, passwordnya);
        alertSukses(context,
            message: 'User $usernamenya berhasil didaftarkan!');
        _usernameController.clear();
        _passwordController.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        alertGagal(context,
            message: 'Username sudah diambil! Gunakan Username lain');
      }
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
                'Daftar dan kelola tugasmu lebih mudah!',
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
            ),
            SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _regisUser,
              icon: Icon(Icons.person),
              label: Text(
                'Daftar',
                style: GoogleFonts.plusJakartaSans(
                    color: Color(0xFFECF8FF), fontSize: 14),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color(0xFF063FBA))),
            ),
            TextButton(
              onPressed: () {},
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Sudah terdaftar?',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                    TextSpan(
                      text: ' Login',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
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
