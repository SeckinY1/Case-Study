class User {
  String id;
  String firstName;
  String lastName;
  String phoneNumber;
  String profileImageUrl;
  DateTime createdAt;

  // Constructor
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.createdAt,
  });

  // JSON'dan User objesine dönüştürme (manuel şekilde)
  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        phoneNumber = json['phoneNumber'],
        profileImageUrl = json['profileImageUrl'],
        createdAt = DateTime.parse(json['createdAt']);

  // User objesini JSON formatına dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
