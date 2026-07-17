class WelcomeDto {
  const WelcomeDto({required this.message});

  final String message;

  factory WelcomeDto.fromJson(Map<String, dynamic> json) {
    return WelcomeDto(message: json['message'] as String? ?? '');
  }

  Map<String, dynamic> toJson() => {'message': message};
}
