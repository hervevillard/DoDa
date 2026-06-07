class WordModel {
  final String id;
  final String wordEn;
  final String wordRw;
  final String image;
  final String audioEn;
  final String audioRw;
  final List<String> letters;
  final String category;
  final int difficulty;

  const WordModel({
    required this.id,
    required this.wordEn,
    required this.wordRw,
    required this.image,
    required this.audioEn,
    required this.audioRw,
    required this.letters,
    required this.category,
    required this.difficulty,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as String,
      wordEn: json['word_en'] as String,
      wordRw: json['word_rw'] as String,
      image: json['image'] as String,
      audioEn: json['audio_en'] as String,
      audioRw: json['audio_rw'] as String,
      letters: List<String>.from(json['letters'] as List),
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
    );
  }

  String wordFor(String languageCode) => languageCode == 'en' ? wordEn : wordRw;
  String audioFor(String languageCode) =>
      languageCode == 'en' ? audioEn : audioRw;
}
