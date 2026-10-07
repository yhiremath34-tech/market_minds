class FinancialCertificate {
  final String certificateId;
  final String recipientName;
  final String courseTitle;
  final DateTime completionDate;
  final String credentialHash;
  final int totalLessonsCompleted;
  final String issuer;

  const FinancialCertificate({
    required this.certificateId,
    required this.recipientName,
    required this.courseTitle,
    required this.completionDate,
    required this.credentialHash,
    required this.totalLessonsCompleted,
    this.issuer = 'Market Minds Financial Literacy Institute',
  });

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'recipientName': recipientName,
      'courseTitle': courseTitle,
      'completionDate': completionDate.toIso8601String(),
      'credentialHash': credentialHash,
      'totalLessonsCompleted': totalLessonsCompleted,
      'issuer': issuer,
    };
  }

  factory FinancialCertificate.fromJson(Map<String, dynamic> json) {
    return FinancialCertificate(
      certificateId: json['certificateId'] as String,
      recipientName: json['recipientName'] as String,
      courseTitle: json['courseTitle'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      credentialHash: json['credentialHash'] as String,
      totalLessonsCompleted: json['totalLessonsCompleted'] as int,
      issuer: json['issuer'] as String? ?? 'Market Minds Financial Literacy Institute',
    );
  }

  static FinancialCertificate createGraduation({
    required String studentName,
    String courseName = 'Certified Foundations in Financial Literacy & Market Principles',
  }) {
    final now = DateTime.now();
    return FinancialCertificate(
      certificateId: 'MM-CERT-${now.millisecondsSinceEpoch.toString().substring(5)}',
      recipientName: studentName,
      courseTitle: courseName,
      completionDate: now,
      credentialHash: 'SHA256:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1f',
      totalLessonsCompleted: 10,
    );
  }
}
