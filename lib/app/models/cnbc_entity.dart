class CnbcMarketEntity {
  String? dataname;
  String? status;
  String? message;
  String? source;
  String? lastUpdate;
  List<Data>? data;
  int? statusCode;
  String? statusMessage;

  CnbcMarketEntity({this.dataname, this.status, this.message, this.source, this.lastUpdate, this.data, this.statusCode, this.statusMessage});

  CnbcMarketEntity.fromJson(Map<String, dynamic> json) {
    dataname = json['dataname'];
    status = json['status'];
    message = json['message'];
    source = json['source'];
    lastUpdate = json['last_update'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    statusMessage = json['statusMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dataname'] = dataname;
    data['status'] = status;
    data['message'] = message;
    data['source'] = source;
    data['last_update'] = lastUpdate;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['statusMessage'] = statusMessage;
    return data;
  }
}

class Data {
  String? cODE;
  String? nAME;
  String? cFNAME;
  double? cFLAST;
  double? cFNETCHNG;
  double? pCTCHNG;
  String? cATEGORYID;

  Data({this.cODE, this.nAME, this.cFNAME, this.cFLAST, this.cFNETCHNG, this.pCTCHNG, this.cATEGORYID});

  Data.fromJson(Map<String, dynamic> json) {
    cODE = json['CODE'];
    nAME = json['NAME'];
    cFNAME = json['CF_NAME'];
    cFLAST = json['CF_LAST'];
    cFNETCHNG = json['CF_NETCHNG'];
    pCTCHNG = json['PCTCHNG'];
    cATEGORYID = json['CATEGORY_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CODE'] = cODE;
    data['NAME'] = nAME;
    data['CF_NAME'] = cFNAME;
    data['CF_LAST'] = cFLAST;
    data['CF_NETCHNG'] = cFNETCHNG;
    data['PCTCHNG'] = pCTCHNG;
    data['CATEGORY_ID'] = cATEGORYID;
    return data;
  }
}
