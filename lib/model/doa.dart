class Doa {
  final String arab;
  final String indo;
  final String judul;
  final String source;

  Doa({
    required this.arab,
    required this.indo,
    required this.judul,
    required this.source,
  });

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      arab: json['arab'],
      indo: json['indo'],
      judul: json['judul'],
      source: json['source'],
    );
  }
}
