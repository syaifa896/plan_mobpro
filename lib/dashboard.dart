import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/logic/alert.dart';
import 'package:plan/tambahubahtugas.dart';
import 'package:plan/widget/card_tugas.dart';

class Dashboard extends StatefulWidget {
  final String username;
  const Dashboard({super.key, required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _dbService = DatabaseSvc.instance;
  bool loadingg = true;
  List<Map<String, dynamic>> listTugas = [];

  @override
  void initState() {
    super.initState();
    ambilTugas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFECF8FF),
        leading: IconButton(
          onPressed: () {
            dialogLogout(context, widget.username);
          },
          icon: Icon(Icons.logout),
          color: Colors.redAccent.shade700,
        ),
        flexibleSpace: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Image.asset(
              'assets/planlogonobg.png',
              width: 125,
            ),
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: Color(0xFF063FBA).withOpacity(0.1),
            width: 3.0,
          ),
        ),
      ),
      body: Visibility(
        visible: loadingg,
        replacement: RefreshIndicator(
          onRefresh: ambilTugas,
          child: Visibility(
            visible: listTugas.isNotEmpty,
            replacement: Center(
              child: Text(
                '''Belum ada tugas\nTambah dulu''',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  color: Color(0xFF063FBA).withOpacity(0.2),
                ),
              ),
            ),
            child: ListView.builder(
              itemCount: listTugas.length,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final item = listTugas[index];

                return CardTugas(
                  index: index,
                  item: item,
                  navigasiEdit: navigasiKeEdit,
                  hapusTugas: (id) => hapusTugas(item['id_tugas']),
                );
              },
            ),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: navigasiKeTambah,
        backgroundColor: Color(0xFF063FBA),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF063FBA),
        height: 40,
        shape: const CircularNotchedRectangle(),
        notchMargin: 3,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  Future<void> navigasiKeEdit(Map item) async {
    final keTambah = MaterialPageRoute(
      builder: (context) => TambahUbahTugas(
        tugasnya: item,
        username: widget.username,
      ),
    );
    await Navigator.push(context, keTambah);
    setState(() {
      loadingg = true;
    });
    ambilTugas();
  }

  Future<void> navigasiKeTambah() async {
    final keTambah = MaterialPageRoute(
      builder: (context) => TambahUbahTugas(
        username: widget.username,
      ),
    );
    await Navigator.push(context, keTambah);
    setState(() {
      loadingg = true;
    });
    await ambilTugas();
  }

  Future<void> ambilTugas() async {
    setState(() {
      loadingg = true;
    });

    try {
      final tugas = await _dbService.readTugasByUser(widget.username);

      print('Tugas yang diambil: $tugas');

      setState(() {
        listTugas = tugas;
        loadingg = false;
      });
    } catch (e) {
      alertGagal(context, message: 'Error saat mengambil data tugas!');
      setState(() {
        loadingg = false;
      });
    }
  }

  Future<void> hapusTugas(int idTugas) async {
    await _dbService.deleteTugas(idTugas);
    ambilTugas();
    alertSukses(context, message: 'Tugas sudah dihapus!');
  }
}
