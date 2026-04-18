class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? profilePictureUrl;

  AppUser({
    required this.uid, 
    required this.email,
    required this.name,
    this.profilePictureUrl,
    });

    //convert app user to json format
    Map<String, dynamic> toJson(){
      return{
        'uid': uid,
        'email': email,
        'name': name,
        'profilePictureUrl': profilePictureUrl,
      };
    }

    //convert json to app user format 
    factory AppUser.fromJson(Map<String,dynamic> jsonUser) {
      return AppUser(
        uid: jsonUser['uid'], 
        email:jsonUser['email'],
        name:jsonUser['name'] ??'',
        profilePictureUrl: jsonUser['profilePictureUrl'],
        );
    }

    // Create a copy with modified fields
    AppUser copyWith({
      String? uid,
      String? email,
      String? name,
      String? profilePictureUrl,
    }) {
      return AppUser(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        name: name ?? this.name,
        profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      );
    }
}
