class InvoiceResponse {
  final bool success;
  final InvoiceData data;

  InvoiceResponse({required this.success, required this.data});

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      success: json['success'] ?? false,
      data: InvoiceData.fromJson(json['data']),
    );
  }
}

class InvoiceData {
  final String message;
  final List<Invoice> invoices;
  final int totalAmount;
  final int pendingAmount;

  InvoiceData({
    required this.message,
    required this.invoices,
    required this.totalAmount,
    required this.pendingAmount,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      message: json['message'],
      invoices: List<Invoice>.from(json['invoices'].map((x) => Invoice.fromJson(x))),
      totalAmount: json['totalAmount'],
      pendingAmount: json['pendingAmount'],
    );
  }
}

class Invoice {
  final String id;
  final bool isPaid;
  final Post post;
  final DateTime date;
  final DateTime expiry;
  final int amount;
  final String invoiceId;

  Invoice({
    required this.id,
    required this.isPaid,
    required this.post,
    required this.date,
    required this.expiry,
    required this.amount,
    required this.invoiceId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'],
      isPaid: json['isPaid'],
      post: Post.fromJson(json['post']),
      date: DateTime.parse(json['date']),
      expiry: DateTime.parse(json['expiry']),
      amount: json['amount'],
      invoiceId: json['invoiceId'],
    );
  }
}

class Post {
  final User userId;
  final String video;
  final DateTime date;

  Post({required this.userId, required this.video, required this.date});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: User.fromJson(json['userId']),
      video: json['video'],
      date: DateTime.parse(json['date']),
    );
  }
}

class User {
  final String name;

  User({required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
    );
  }
}
