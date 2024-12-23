import 'dart:convert';

class RewardSummaryResponse {
  bool? success;
  String? currentBalance;
  String? minRedeemWarning;

  RewardSummaryResponse(
      {this.success, this.currentBalance, this.minRedeemWarning});
  factory RewardSummaryResponse.fromJson(String str) =>
      RewardSummaryResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RewardSummaryResponse.fromMap(Map<String, dynamic> json) =>
      RewardSummaryResponse(
          success: json['success'] ?? false,
          currentBalance: json['current_balance'] ?? "",
          minRedeemWarning: json['min_redeem_warning'] ?? "");

  Map<String, dynamic> toMap() => {
        "success": success,
        "current_balance": currentBalance,
        "min_redeem_warning": minRedeemWarning
      };
}
