import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan/database/database_svc.dart';

void alertGagal(BuildContext context, {required String message}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.red[700],
    duration: Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void alertSukses(BuildContext context, {required String message}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: Colors.green[700],
    duration: Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void dialogLogout(BuildContext context, usernamenya) {
  final _dbService = DatabaseSvc.instance;

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 5, 46, 136),
          title: Text(
            'Konfirmasi Logout',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'Anda yakin ingin logout?',
            style:
                GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent.shade700),
              ),
            ),
            TextButton(
                onPressed: () async {
                  await _dbService.userLogout(usernamenya);
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Ya',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent.shade400),
                ))
          ],
        );
      });
}
