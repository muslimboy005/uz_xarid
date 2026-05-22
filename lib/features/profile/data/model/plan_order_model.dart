class PlanOrderRequest {
  final String orderType;
  final int userPlanId;
  final String paymentMethod;

  const PlanOrderRequest({
    required this.orderType,
    required this.userPlanId,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
    'order_type': orderType,
    'user_plan_id': userPlanId,
    'payment_method': paymentMethod,
  };
}

class PlanOrderResponse {
  final bool status;
  final PlanOrderData data;

  const PlanOrderResponse({required this.status, required this.data});

  factory PlanOrderResponse.fromJson(Map<String, dynamic> json) {
    return PlanOrderResponse(
      status: json['status'] == true,
      data: PlanOrderData.fromJson(
        (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }
}

class PlanOrderData {
  final int id;
  final String orderType;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentLink;

  const PlanOrderData({
    required this.id,
    required this.orderType,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentLink,
  });

  factory PlanOrderData.fromJson(Map<String, dynamic> json) {
    return PlanOrderData(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderType: json['order_type'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentLink: json['payment_link'] as String? ?? '',
    );
  }
}
