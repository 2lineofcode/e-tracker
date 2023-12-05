/// *
/// * JSON Source: {"message":"Berhasil menampilkan alokasi portofolio","data":{"invested_amount":144109632,"market_value":145655261.58999997,"pending_amount":0,"total_portfolio":145655261.58999997,"profit_loss_amount":1545635,"profit_loss_percentage":0.0107,"allocations":[{"type":"MONEY_MARKET","label":"Pasar Uang","percentage":0.05}]}}
/// * Code generated: https://2lineofcode.github.io/json_to_dart2023
/// *
class BibitAllocationSummary {
  String? message;
  BibitAllocationSummaryData? data;

  BibitAllocationSummary({this.message, this.data});

  BibitAllocationSummary.fromJson(Map<String, dynamic> json) {
    message = json['message'] ?? '';
    data = (json['data'] != null) ? BibitAllocationSummaryData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BibitAllocationSummaryData {
  num? investedAmount = 0;
  num? marketValue = 0;
  num? pendingAmount = 0;
  num? totalPortfolio = 0;
  num? profitLossAmount = 0;
  num? profitLossPercentage = 0;
  List<BibitAllocationSummaryDataAllocations>? allocations;

  BibitAllocationSummaryData({this.investedAmount, this.marketValue, this.pendingAmount, this.totalPortfolio, this.profitLossAmount, this.profitLossPercentage, this.allocations});

  BibitAllocationSummaryData.fromJson(Map<String, dynamic> json) {
    investedAmount = json['invested_amount'] ?? 0;
    marketValue = json['market_value'] ?? 0.0;
    pendingAmount = json['pending_amount'] ?? 0;
    totalPortfolio = json['total_portfolio'] ?? 0.0;
    profitLossAmount = json['profit_loss_amount'] ?? 0;
    profitLossPercentage = json['profit_loss_percentage'] ?? 0.0;
    allocations = json['allocations'] == null ? null : (json['allocations'] as List).map((e) => BibitAllocationSummaryDataAllocations.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['invested_amount'] = investedAmount;
    data['market_value'] = marketValue;
    data['pending_amount'] = pendingAmount;
    data['total_portfolio'] = totalPortfolio;
    data['profit_loss_amount'] = profitLossAmount;
    data['profit_loss_percentage'] = profitLossPercentage;
    if (allocations != null) {
      data['allocations'] = allocations?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class BibitAllocationSummaryDataAllocations {
  String? type;
  String? label;
  num? percentage;

  BibitAllocationSummaryDataAllocations({this.type, this.label, this.percentage});

  BibitAllocationSummaryDataAllocations.fromJson(Map<String, dynamic> json) {
    type = json['type'] ?? '';
    label = json['label'] ?? '';
    percentage = json['percentage'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['type'] = type;
    data['label'] = label;
    data['percentage'] = percentage;
    return data;
  }
}
