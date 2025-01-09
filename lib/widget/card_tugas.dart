import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plan/database/database_svc.dart';
import 'package:plan/logic/alert.dart';

class CardTugas extends StatelessWidget {
  final _dbService = DatabaseSvc.instance;
  final int index;
  final Map item;
  final Function(Map) navigasiEdit;
  final Function(int) hapusTugas;

  CardTugas({
    super.key,
    required this.index,
    required this.item,
    required this.navigasiEdit,
    required this.hapusTugas,
  });

  @override
  Widget build(BuildContext context) {
    final idTugas = item['id_tugas'] as int;
    final prioColor = item['prio_tugas'];
    final statusTugas = item['status_tugas'] as String;

    Color warnaPrio;
    switch (prioColor) {
      case 'Tinggi':
        warnaPrio = Colors.redAccent.shade700;
        break;
      case 'Sedang':
        warnaPrio = Colors.orange;
        break;
      case 'Rendah':
      default:
        warnaPrio = Colors.green;
        break;
    }

    Color warnaCeklis;
    if (statusTugas == 'DONE') {
      warnaCeklis = Colors.greenAccent.shade400;
    } else if (statusTugas == 'WIP') {
      warnaCeklis = Colors.blueGrey;
    } else {
      warnaCeklis = Colors.blueGrey;
    }

    String hitungSelisihDeadline(String deadline) {
      try {
        final DateTime tglDeadline = DateTime.parse(deadline);
        final DateTime hariIni = DateTime.now();
        final Duration selisih = tglDeadline.difference(hariIni);

        if (selisih.inDays < -1) {
          return 'Deadline lewat ${-selisih.inDays} hari.';
        } else if (selisih.inDays == -1) {
          return 'Hari ini!';
        } else if (selisih.inDays == 0) {
          return '${selisih.inDays + 1} hari lagi!';
        } else if (selisih.inDays <= 3) {
          return '${selisih.inDays + 1} hari lagi!';
        } else if (selisih.inDays <= 5) {
          return '${selisih.inDays + 1} hari lagi.';
        } else if (selisih.inDays >= 6) {
          return '${selisih.inDays + 1} hari lagi.';
        }

        return '${selisih.inDays} hari lagi.';
      } catch (e) {
        return deadline;
      }
    }

    String deadlineText = hitungSelisihDeadline(item['deadline_tugas']);
    Color deadlineColor = Colors.green;

    if (deadlineText.contains('lewat')) {
      deadlineColor = Colors.redAccent.shade700;
    } else if (deadlineText.contains('ini')) {
      deadlineColor = Colors.red;
    } else {
      final selisihHari = int.tryParse(deadlineText.split(' ')[0]) ?? 0;
      if (selisihHari <= 3) {
        deadlineColor = Colors.red;
      } else if (selisihHari <= 5) {
        deadlineColor = Colors.orange;
      } else if (selisihHari >= 6) {
        deadlineColor = Colors.green;
      }
    }

    return Card(
      color: Color(0xFFECF8FF),
      child: ListTile(
        leading: GestureDetector(
          onTap: () async {
            bool? isConfirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Color.fromARGB(255, 5, 46, 136),
                title: Text(
                  'Konfirmasi Tugas',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Apakah tugas sudah selesai?',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Belum',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.redAccent.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Sudah',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.greenAccent.shade400,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );

            if (isConfirmed == true) {
              await _dbService.updateStatusTugas(idTugas, 'DONE');
              alertSukses(context, message: 'Tugas selesai!');
            }
          },
          child: Icon(
            Icons.check_circle_outline,
            color: warnaCeklis,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            item['judul_tugas'],
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['desc_tugas'],
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              const SizedBox(
                height: 10,
              ),
              if (statusTugas == 'WIP')
                Row(
                  children: [
                    Text(
                      'Prioritas: ',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['prio_tugas'],
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: warnaPrio),
                    ),
                  ],
                )
              else ...[
                Text(
                  'Tugas sudah selesai.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: Colors.greenAccent.shade400),
                ),
              ],
              const SizedBox(
                height: 8,
              ),
              if (statusTugas == 'WIP')
                Row(
                  children: [
                    Text(
                      'Deadline: ',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.redAccent.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      deadlineText,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14, color: deadlineColor),
                    ),
                  ],
                )
              else
                ...[],
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton(
            color: Color(0xFFECF8FF),
            onSelected: (value) {
              if (value == 'edit') {
                navigasiEdit(item);
              } else if (value == 'delete') {
                hapusTugas(idTugas);
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Ubah'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Hapus'),
                ),
              ];
            }),
      ),
    );
  }
}
