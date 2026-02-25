import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';

class TakeAttendanceScreen extends StatefulWidget {
  final Subject subject;
  final List<Student> allStudents;
  final AttendanceRecord? existingRecord;
  final Function(AttendanceRecord) onSave;

  const TakeAttendanceScreen({
    super.key,
    required this.subject,
    required this.allStudents,
    this.existingRecord,
    required this.onSave,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  late Map<String, AttendanceStatus> _statuses;
  late List<Student> _subjectStudents;
  late AttendanceType _attendanceType;

  @override
  void initState() {
    super.initState();
    _subjectStudents = widget.allStudents
        .where((s) => widget.subject.studentIds.contains(s.id))
        .toList();
    
    _attendanceType = widget.existingRecord?.type ?? AttendanceType.classAttendance;

    if (widget.existingRecord != null) {
      _statuses = Map.from(widget.existingRecord!.studentStatuses);
      for (var s in _subjectStudents) {
        if (!_statuses.containsKey(s.id)) {
          _statuses[s.id] = AttendanceStatus.absent;
        }
      }
    } else {
      _statuses = {
        for (var s in _subjectStudents) s.id: AttendanceStatus.present
      };
    }
  }

  void _updateStatus(String studentId, AttendanceStatus status) {
    setState(() {
      _statuses[studentId] = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var id in _statuses.keys) {
        _statuses[id] = AttendanceStatus.present;
      }
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final now = widget.existingRecord?.date ?? DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weeklyRecords = widget.subject.attendanceRecords.where((r) {
      return r.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) && 
             r.date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();
    
    weeklyRecords.sort((a, b) => a.date.compareTo(b.date));

    final sortedStudents = List<Student>.from(_subjectStudents)
      ..sort((a, b) => a.rollNumber.compareTo(b.rollNumber));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                children: [
                  pw.Center(
                    child: pw.Text('WEEKLY ATTENDANCE REPORT', 
                      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Subject: ${widget.subject.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Type: ${_attendanceType == AttendanceType.classAttendance ? "Class" : "Lab"}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Duration: ${DateFormat('dd MMM').format(weekStart)} - ${DateFormat('dd MMM').format(weekEnd)}', 
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                ],
              ),
            ),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // SR
                1: const pw.FlexColumnWidth(2.5), // NAME (Reduced from 4)
                2: const pw.FlexColumnWidth(2), // REG# (Reduced from 3)
              },
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _pdfCell('SR', isBold: true),
                    _pdfCell('NAME', isBold: true),
                    _pdfCell('REG#', isBold: true),
                    ...List.generate(max(weeklyRecords.length, 6), (i) {
                      if (i < weeklyRecords.length) {
                        return _pdfCell(DateFormat('dd/MM').format(weeklyRecords[i].date), isBold: true);
                      }
                      return _pdfCell(' ');
                    }),
                  ],
                ),
                ...sortedStudents.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final student = entry.value;
                  return pw.TableRow(
                    children: [
                      _pdfCell('$index'),
                      _pdfCell(student.name),
                      _pdfCell(student.rollNumber),
                      ...List.generate(max(weeklyRecords.length, 6), (i) {
                        if (i < weeklyRecords.length) {
                          final status = weeklyRecords[i].studentStatuses[student.id];
                          String mark = '-';
                          if (status == AttendanceStatus.present) mark = 'P';
                          if (status == AttendanceStatus.absent) mark = 'A';
                          if (status == AttendanceStatus.late) mark = 'L';
                          return _pdfCell(mark);
                        }
                        return _pdfCell(' ');
                      }),
                    ],
                  );
                }).toList(),
              ],
            ),
            pw.SizedBox(height: 40),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      width: 180, 
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1))
                      )
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text('Instructor Signature', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _pdfCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11, 
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  void _shareOnWhatsApp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Attendance via WhatsApp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _shareOption('Absent Name & Roll No', 1),
            _shareOption('Absent Roll No Only', 2),
            _shareOption('Present Roll No Only', 3),
            _shareOption('Present Name & Roll No', 4),
            _shareOption('Complete Attendance', 5),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(String title, int type) {
    return ListTile(
      leading: const Icon(Icons.share, color: Color(0xFF7C3AED)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _generateAndSendWhatsApp(type);
      },
    );
  }

  void _generateAndSendWhatsApp(int type) async {
    String dateStr = DateFormat('dd/MM/yyyy').format(widget.existingRecord?.date ?? DateTime.now());
    String typeStr = _attendanceType == AttendanceType.classAttendance ? "Class" : "Lab";
    String message = "*Attendance Report ($typeStr) - ${widget.subject.name}*\nDate: $dateStr\n\n";

    List<Student> presentOnes = _subjectStudents.where((s) => _statuses[s.id] == AttendanceStatus.present || _statuses[s.id] == AttendanceStatus.late).toList();
    List<Student> absentOnes = _subjectStudents.where((s) => _statuses[s.id] == AttendanceStatus.absent).toList();

    switch (type) {
      case 1:
        message += "*Absent Students:*\n";
        for (var s in absentOnes) {
          message += "- ${s.name} (${s.rollNumber})\n";
        }
        break;
      case 2:
        message += "*Absent Roll Numbers:*\n";
        message += absentOnes.map((s) => s.rollNumber).join(", ");
        break;
      case 3:
        message += "*Present Roll Numbers:*\n";
        message += presentOnes.map((s) => s.rollNumber).join(", ");
        break;
      case 4:
        message += "*Present Students:*\n";
        for (var s in presentOnes) {
          message += "- ${s.name} (${s.rollNumber})\n";
        }
        break;
      case 5:
        message += "*Summary:*\nPresent: ${presentOnes.length}\nAbsent: ${absentOnes.length}\n\n";
        message += "*Full List:*\n";
        for (var s in _subjectStudents) {
          String status = _statuses[s.id] == AttendanceStatus.present ? "Present" : (_statuses[s.id] == AttendanceStatus.absent ? "Absent" : "Late");
          message += "${s.rollNumber} - ${s.name}: $status\n";
        }
        break;
    }

    final url = "whatsapp://send?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      final webUrl = "https://wa.me/?text=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    int present = _statuses.values.where((s) => s == AttendanceStatus.present).length;
    int absent = _statuses.values.where((s) => s == AttendanceStatus.absent).length;
    int lateCount = _statuses.values.where((s) => s == AttendanceStatus.late).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(widget.existingRecord?.date ?? DateTime.now()), 
              style: const TextStyle(fontSize: 12, color: Colors.grey)
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: _generatePdf, icon: const Icon(Icons.picture_as_pdf_outlined, size: 20)),
          IconButton(onPressed: () => _shareOnWhatsApp(context), icon: const Icon(Icons.share_outlined, size: 20)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Attendance Type Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Class'),
                  selected: _attendanceType == AttendanceType.classAttendance,
                  onSelected: (selected) {
                    if (selected) setState(() => _attendanceType = AttendanceType.classAttendance);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Lab'),
                  selected: _attendanceType == AttendanceType.labAttendance,
                  onSelected: (selected) {
                    if (selected) setState(() => _attendanceType = AttendanceType.labAttendance);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                _summaryCard('PRESENT', present, Colors.green),
                const SizedBox(width: 12),
                _summaryCard('ABSENT', absent, Colors.red),
                const SizedBox(width: 12),
                _summaryCard('LATE', lateCount, Colors.orange),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Students (${_subjectStudents.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _markAllPresent,
                  child: const Text('Mark All Present', style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _subjectStudents.length,
              itemBuilder: (context, index) {
                final student = _subjectStudents[index];
                return _studentAttendanceTile(student);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                widget.onSave(AttendanceRecord(
                  id: widget.existingRecord?.id,
                  date: widget.existingRecord?.date ?? DateTime.now(), 
                  studentStatuses: _statuses,
                  type: _attendanceType,
                ));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                widget.existingRecord != null ? 'Update Attendance' : 'Save Attendance', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _studentAttendanceTile(Student student) {
    final status = _statuses[student.id] ?? AttendanceStatus.absent;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(student.rollNumber, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statusButton(student.id, AttendanceStatus.present, 'Present', Colors.green),
              const SizedBox(width: 8),
              _statusButton(student.id, AttendanceStatus.absent, 'Absent', Colors.red),
              const SizedBox(width: 8),
              _statusButton(student.id, AttendanceStatus.late, 'Late', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(String studentId, AttendanceStatus status, String label, Color color) {
    bool isSelected = _statuses[studentId] == status;
    return Expanded(
      child: InkWell(
        onTap: () => _updateStatus(studentId, status),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
