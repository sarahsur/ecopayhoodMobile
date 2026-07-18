class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String addressDetail;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.addressDetail,
  });

  bool get hasAddress => address.trim().isNotEmpty;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['id'] ?? map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      addressDetail: map['address_detail'] ?? map['addressDetail'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'address_detail': addressDetail,
    };
  }
}
