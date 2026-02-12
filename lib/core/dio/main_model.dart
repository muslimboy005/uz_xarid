class MainModel {
  final bool ok;
  final int status;
  final dynamic result;
  final String? errorCode;
  final dynamic detail;
  final String? timestamp;

  MainModel({
    required this.ok,
    required this.status,
    this.result,
    this.errorCode,
    this.detail,
    this.timestamp,
  });

  MainModel copyWith({
    bool? ok,
    int? status,
    dynamic result,
    String? errorCode,
    dynamic detail,
    String? timestamp,
  }) {
    return MainModel(
      ok: ok ?? this.ok,
      status: status ?? this.status,
      result: result ?? this.result,
      errorCode: errorCode ?? this.errorCode,
      detail: detail ?? this.detail,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'MainModel(ok: $ok, status: $status, result: $result, errorCode: $errorCode, detail: $detail, timestamp: $timestamp)';
  }
}

final defaultModel = MainModel(
  ok: false,
  status: 0,
  result: null,
  errorCode: 'unknown',
  detail: {'description': 'no response'},
  timestamp: DateTime.now().toIso8601String(),
);