class Budget {
  final int month;
  final double limit;

  Budget({required this.month, required this.limit});

  Map<String, dynamic> toJson() => {
        'month': month,
        'limit': limit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      month: json['month'],
      limit: json['limit'],
    );
  }
}
