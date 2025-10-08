class SearchModel {
  String imageUrl;
  String name;
  String followers;
  bool isFollowed;
  List<String> hashtags;
  String location;
  String userId;
  String email;

  SearchModel({
    required this.imageUrl,
    required this.name,
    required this.followers,
    required this.isFollowed,
    required this.hashtags,
    required this.userId,
    required this.email,
    this.location = '',
  });
}
