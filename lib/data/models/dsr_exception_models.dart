class ExceptionMetadata {
  final List<ExceptionType> exceptionTypes;
  final List<StatusFlag> statusFlags;
  final String pendWith;

  ExceptionMetadata({
    required this.exceptionTypes,
    required this.statusFlags,
    required this.pendWith,
  });

  factory ExceptionMetadata.fromJson(Map<String, dynamic> json) {
    return ExceptionMetadata(
      exceptionTypes: (json['ExceptionTypes'] as List)
          .map((e) => ExceptionType.fromJson(e))
          .toList(),
      statusFlags: (json['StatusFlags'] as List)
          .map((e) => StatusFlag.fromJson(e))
          .toList(),
      pendWith: json['PendWith'] ?? '',
    );
  }
}

class ExceptionType {
  final String code;
  final String description;

  ExceptionType({
    required this.code,
    required this.description,
  });

  factory ExceptionType.fromJson(Map<String, dynamic> json) {
    return ExceptionType(
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}

class StatusFlag {
  final String code;
  final String description;

  StatusFlag({
    required this.code,
    required this.description,
  });

  factory StatusFlag.fromJson(Map<String, dynamic> json) {
    return StatusFlag(
      code: json['Code'] ?? '',
      description: json['Description'] ?? '',
    );
  }
}

class ExceptionRequest {
  final String userCode;
  final String dataDtCn;
  final String userName;
  final String excpDat1;
  final String excpDat2;
  final String excpRemk;

  ExceptionRequest({
    required this.userCode,
    required this.dataDtCn,
    required this.userName,
    required this.excpDat1,
    required this.excpDat2,
    required this.excpRemk,
  });

  factory ExceptionRequest.fromJson(Map<String, dynamic> json) {
    return ExceptionRequest(
      userCode: json['UserCode'] ?? '',
      dataDtCn: json['DataDtCn'] ?? '',
      userName: json['UserName'] ?? '',
      excpDat1: json['ExcpDat1'] ?? '',
      excpDat2: json['ExcpDat2'] ?? '',
      excpRemk: json['ExcpRemk'] ?? '',
    );
  }
}

class ExceptionHistory {
  final String employeeName;
  final String excpDate;
  final String remarks;
  final String status;
  final String createDate;

  ExceptionHistory({
    required this.employeeName,
    required this.excpDate,
    required this.remarks,
    required this.status,
    required this.createDate,
  });

  factory ExceptionHistory.fromJson(Map<String, dynamic> json) {
    return ExceptionHistory(
      employeeName: json['EmployeeName'] ?? '',
      excpDate: json['ExcpDate'] ?? '',
      remarks: json['Remarks'] ?? '',
      status: json['Status'] ?? '',
      createDate: json['CreateDate'] ?? '',
    );
  }
}

class ExceptionSubmission {
  final String procType;
  final String pendWith;
  final String userCode;
  final String excpType;
  final String excpDat1;
  final String excpRemk;
  final String statFlag;

  ExceptionSubmission({
    required this.procType,
    required this.pendWith,
    required this.userCode,
    required this.excpType,
    required this.excpDat1,
    required this.excpRemk,
    required this.statFlag,
  });

  Map<String, dynamic> toJson() {
    return {
      'ProcType': procType,
      'PendWith': pendWith,
      'UserCode': userCode,
      'ExcpType': excpType,
      'ExcpDat1': excpDat1,
      'ExcpRemk': excpRemk,
      'StatFlag': statFlag,
    };
  }
} 