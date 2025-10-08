class ProfileImageModel {
  final bool success;
  final String data;

  ProfileImageModel({required this.success, required this.data});

  factory ProfileImageModel.fromJson(Map<String, dynamic> json) {
    return ProfileImageModel(
      success: json['success'] ?? false,
      data: json['data'],
    );
  }
}

class ImageData {
  final String message;
  final String image;

  ImageData({required this.message, required this.image});

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      message: json['message'],
      image: json['image'],
    );
  }
}
