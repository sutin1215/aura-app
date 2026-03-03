import 'package:cloud_firestore/cloud_firestore.dart';

class HealthReport {
  final String id;
  final String patientId;
  final String? providerId;
  final String pdfUrl;
  final String title;
  final DateTime dateUploaded;

  HealthReport({
    required this.id,
    required this.patientId,
    this.providerId,
    required this.pdfUrl,
    required this.title,
    required this.dateUploaded,
  });

  factory HealthReport.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return HealthReport(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      providerId: data['providerId'],
      pdfUrl: data['pdfUrl'] ?? '',
      title: data['title'] ?? 'Health Report',
      dateUploaded: (data['dateUploaded'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'providerId': providerId,
      'pdfUrl': pdfUrl,
      'title': title,
      'dateUploaded': Timestamp.fromDate(dateUploaded),
    };
  }
}
