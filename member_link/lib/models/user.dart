class User {
  String? adminId;
  String? adminFullname;
  String? adminEmail;
  String? adminGender;
  String? adminPhone;
  String? adminDateReg;
  String? userRole;

  User({
    this.adminId,
    this.adminFullname,
    this.adminEmail,
    this.adminGender,
    this.adminPhone,
    this.adminDateReg,
    this.userRole,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      adminId: json['user_id'], // Map from the API response
      adminFullname: json['user_fullname'],
      adminEmail: json['user_email'],
      adminGender: json['user_gender'],
      adminPhone: json['user_phone'],
      adminDateReg: json['user_datereg'],
      userRole: json['user_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'admin_fullname': adminFullname,
      'admin_email': adminEmail,
      'admin_gender': adminGender,
      'admin_phone': adminPhone,
      'admin_dateReg': adminDateReg,
      'user_role': userRole,
    };
  }
}
