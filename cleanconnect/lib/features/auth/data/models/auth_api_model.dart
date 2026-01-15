

class AuthApiModel {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String address;
  final String?password;
  final String? profilePicture;

  AuthApiModel({
    required this.fullName,
    required this.email,
    this.password,
    required this.address,
    this.phoneNumber,
    required this.profilePicture
  });

  //toJSON
  Map<String, dynamic> toJson(){
    return{
      "name" : fullName,
      "email" : email,
      "phoneNumber" : phoneNumber,
      "address" : address,
      "password" : password,
      "profilePicture": profilePicture,
    };
  }

  //from JSON 
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      fullName: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String,
      password: json['password'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }
  
}