class LetterModel {
  final String id;
  final String letter;
  final String letterLower;
  final String soundDescription;
  final String audioFile;
  final String exampleWord;
  final String exampleImage;
  final String exampleAudio;
  final List<String> strokePaths;
  final int tracingDifficulty;
  final bool isCluster;

  const LetterModel({
    required this.id,
    required this.letter,
    required this.letterLower,
    required this.soundDescription,
    required this.audioFile,
    required this.exampleWord,
    required this.exampleImage,
    required this.exampleAudio,
    required this.strokePaths,
    required this.tracingDifficulty,
    this.isCluster = false,
  });

  factory LetterModel.fromJson(Map<String, dynamic> json) {
    return LetterModel(
      id: json['id'] as String,
      letter: json['letter'] as String,
      letterLower: json['letter_lower'] as String,
      soundDescription: json['sound_description'] as String,
      audioFile: json['audio_file'] as String,
      exampleWord: json['example_word'] as String,
      exampleImage: json['example_image'] as String,
      exampleAudio: json['example_audio'] as String,
      strokePaths: List<String>.from(json['stroke_paths'] as List),
      tracingDifficulty: json['tracing_difficulty'] as int,
      isCluster: json['is_cluster'] as bool? ?? false,
    );
  }
}
