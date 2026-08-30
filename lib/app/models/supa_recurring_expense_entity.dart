import 'dart:convert';

class SupaRecurringExpense {
  String? id;
  String? createdAt;
  String? updatedAt;
  String? userId;
  String? note;
  String? categoryName;
  int? amount;
  int? dueDay;
  int? intervalMonths;
  int? startMonth;
  bool? active;
  String? lastRunDate;
  String? archivedAt;

  SupaRecurringExpense({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.note,
    this.categoryName,
    this.amount,
    this.dueDay,
    this.intervalMonths,
    this.startMonth,
    this.active,
    this.lastRunDate,
    this.archivedAt,
  });

  SupaRecurringExpense.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    note = json['note'];
    categoryName = json['category_name'];
    amount = (json['amount'] as num?)?.toInt() ?? 0;
    dueDay = (json['due_day'] as num?)?.toInt() ?? 1;
    intervalMonths = (json['interval_months'] as num?)?.toInt() ?? 1;
    startMonth = (json['start_month'] as num?)?.toInt() ?? 1;
    active = json['active'] ?? true;
    lastRunDate = json['last_run_date'];
    archivedAt = json['archived_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      'user_id': userId,
      'note': note,
      'category_name': categoryName,
      'amount': amount,
      'due_day': dueDay,
      'interval_months': intervalMonths,
      'start_month': startMonth,
      'active': active,
      if (lastRunDate != null) 'last_run_date': lastRunDate,
      if (archivedAt != null) 'archived_at': archivedAt,
    };
  }

  String get scheduleLabel {
    return switch (intervalMonths ?? 1) {
      1 => 'Setiap bulan',
      12 => 'Setiap tahun',
      final interval => 'Setiap $interval bulan',
    };
  }

  DateTime nextRun({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var offset = 0; offset <= 36; offset++) {
      final cursor = DateTime(now.year, now.month + offset, 1);
      if ((cursor.month - (startMonth ?? 1)) % (intervalMonths ?? 1) != 0) {
        continue;
      }

      final maxDay = DateTime(cursor.year, cursor.month + 1, 0).day;
      final candidate = DateTime(
        cursor.year,
        cursor.month,
        (dueDay ?? 1).clamp(1, maxDay),
      );
      if (!candidate.isBefore(today)) return candidate;
    }

    return today;
  }

  int remainingDays({DateTime? from}) {
    final now = from ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return nextRun(from: now).difference(today).inDays;
  }

  @override
  String toString() => jsonEncode(toJson());
}
