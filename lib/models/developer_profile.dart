class DeveloperProfile {
  final String id;
  final String bannerUrl;
  final String avatarUrl;
  final String name;
  final String friendsCount;
  final String githubUrl;
  final String? bio;
  final String? email;

  DeveloperProfile({
    required this.id,
    required this.bannerUrl,
    required this.avatarUrl,
    required this.name,
    required this.friendsCount,
    required this.githubUrl,
    this.bio,
    this.email,
  });

  factory DeveloperProfile.fromJson(Map<String, dynamic> json) {
    return DeveloperProfile(
      id: json['id'] ?? '1',
      bannerUrl: json['banner_url'] ?? 'https://via.placeholder.com/1200x400',
      avatarUrl: json['avatar_url'] ?? 'https://via.placeholder.com/200',
      name: json['name'] ?? 'José Pablo Miranda Quintanilla',
      friendsCount: json['friends_count'] ?? '153',
      githubUrl: json['github_url'] ?? 'https://github.com/jpmiranda',
      bio: json['bio'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'banner_url': bannerUrl,
      'avatar_url': avatarUrl,
      'name': name,
      'friends_count': friendsCount,
      'github_url': githubUrl,
      'bio': bio,
      'email': email,
    };
  }
}