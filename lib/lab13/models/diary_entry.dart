
class DiaryEntry {
  final String id;
  final String imagePath;
  final String caption;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final bool favorite;

  const DiaryEntry({
    required this.id,
    required this.imagePath,
    required this.caption,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    this.favorite = false,
  });

  DiaryEntry copyWith({bool? favorite}) {
    return DiaryEntry(
      id: id,
      imagePath: imagePath,
      caption: caption,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'caption': caption,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'accuracy': accuracy,
    'favorite': favorite,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      caption: json['caption'] as String,
      timestamp: DateTime.parse(
        json['timestamp'] as String,
      ),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      favorite: json['favorite'] as bool? ?? false,
    );
  }
}
