import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/logic/alert.dart';

// Sebenernya ini bisa dibikin halaman baru ya biar kesannya rajin banyak halaman tapi ngga ah hehe

class TambahUbahTugas extends StatefulWidget {
  final Map? tugasnya;
  TambahUbahTugas({super.key, this.tugasnya, required this.username});
  final String username;

  @override
  State<TambahUbahTugas> createState() => _TambahUbahTugasState();
}

class _TambahUbahTugasState extends State<TambahUbahTugas> {
  final _dbService = DatabaseSvc.instance;
  TextEditingController judulController = TextEditingController();
  TextEditingController descController = TextEditingController();
  String prio = 'Rendah';
  DateTime? tanggalDeadTugas;

  bool lagiUbah = false;

  @override
  void initState() {
    super.initState();
    final tugasnyea = widget.tugasnya;
    if (tugasnyea != null) {
      lagiUbah = true;
      judulController.text = tugasnyea['judul_tugas'] ?? 'Judul Kosong';
      descController.text = tugasnyea['desc_tugas'] ?? 'Desc Kosong';
      prio = tugasnyea['prio_tugas'] ?? 'Rendah';
      tanggalDeadTugas = DateTime.parse(
          tugasnyea['deadline_tugas'] ?? DateTime.now().toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8FF),
      appBar: AppBar(
        title: Text(
          lagiUbah ? 'Ubah Tugas' : 'Tambah Tugas',
          style: GoogleFonts.poppins(fontSize: 24, color: Color(0xFF063FBA)),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFECF8FF),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: [
          TextField(
            controller: judulController,
            decoration: InputDecoration(
              hintText: 'Judul Tugas',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF063FBA).withOpacity(0.3),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          TextField(
            controller: descController,
            decoration: InputDecoration(
              hintText: 'Deskripsi Tugas',
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF063FBA).withOpacity(0.3),
              ),
            ),
            minLines: 5,
            maxLines: 8,
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: PopupMenuButton<String>(
              onSelected: (String newValue) {
                setState(() {
                  prio = newValue;
                });
                FocusScope.of(context).unfocus();
              },
              color: Color(0xFFECF8FF),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'Tinggi',
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Tinggi',
                        groupValue: prio,
                        onChanged: (String? newValue) {
                          setState(() {
                            prio = newValue!;
                          });
                          FocusScope.of(context).unfocus();
                        },
                        activeColor: Colors.redAccent.shade700,
                      ),
                      Text(
                        'Tinggi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Sedang',
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Sedang',
                        groupValue: prio,
                        onChanged: (String? newValue) {
                          setState(() {
                            prio = newValue!;
                          });
                        },
                        activeColor: Colors.yellow.shade700,
                      ),
                      Text(
                        'Sedang',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Rendah',
                  child: Row(
                    children: [
                      Radio<String>(
                        value: 'Rendah',
                        groupValue: prio,
                        onChanged: (String? newValue) {
                          setState(() {
                            prio = newValue!;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      Text(
                        'Rendah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: [
                  Text(
                    'Prioritas Tugas: $prio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Color(0xFF063FBA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            title: Text(
              'Deadline: ${tanggalDeadTugas?.toLocal().toString().split(' ')[0] ?? ''}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Color(0xFF063FBA),
              ),
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: tanggalDeadTugas ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  tanggalDeadTugas = picked;
                });
              }
            },
          ),
          const SizedBox(
            height: 15,
          ),
          const SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: lagiUbah ? editTugas : submitTugas,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF063FBA),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  lagiUbah ? 'Ubah' : 'Tambah',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editTugas() async {
    final tugasnyea = widget.tugasnya;

    if (tugasnyea == null) {
      return;
    }

    final idnya = tugasnyea['id_tugas'];
    final judul = judulController.text.trim();
    final desc = descController.text.trim();
    final prio = this.prio;

    if (judul.isEmpty || desc.isEmpty) {
      alertGagal(context,
          message: 'Judul dan deskripsi tugas tidak boleh kosong!');
      return;
    }

    if (tanggalDeadTugas == null) {
      alertGagal(context, message: 'Tanggal Deadline harus diisi!');
      return;
    }

    await _dbService.updateTugas(
        idnya, judul, desc, prio, tanggalDeadTugas!.toIso8601String());

    alertSukses(context, message: 'Tugas berhasil diubah!');
    Navigator.pop(context);
  }

  Future<void> submitTugas() async {
    final judul = judulController.text.trim();
    final desc = descController.text.trim();
    final prio = this.prio;
    final usernya = widget.username;

    if (judul.isEmpty || desc.isEmpty) {
      alertGagal(context, message: 'Judul dan deskripsi tidak boleh kosong!');
      return;
    }

    if (tanggalDeadTugas == null) {
      alertGagal(context, message: 'Tanggal Deadline harus diisi!');
      return;
    }

    await _dbService.tambahTugas(
      judul,
      desc,
      usernya,
      prio,
      tanggalDeadTugas!.toIso8601String(),
    );

    alertSukses(context, message: 'Tugas berhasil ditambahkan!');
    Navigator.pop(context);
  }
}
