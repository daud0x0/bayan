/// Represents an authentic Islamic reciter (Qari) for Ayah-by-Ayah audio recitation.
class Reciter {
  const Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.folder,
    required this.style,
  });

  final String id;
  final String name;
  final String arabicName;
  final String folder;
  final String style;

  /// Builds the direct EveryAyah CDN audio URL for a specific Surah and Ayah.
  /// Surah and Ayah are 1-indexed and zero-padded to 3 digits (e.g. 001001.mp3).
  String getAyahUrl(int surahNumber, int ayahNumber) {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumber.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$folder/$s$a.mp3';
  }

  /// Curated list of world-renowned Qaris with high-quality audio streams.
  static const List<Reciter> availableReciters = [
    Reciter(
      id: 'mishary_alafasy',
      name: 'Mishary Rashid Alafasy',
      arabicName: 'مشاري راشد العفاسي',
      folder: 'Alafasy_128kbps',
      style: 'Murattal • Melodious',
    ),
    Reciter(
      id: 'abdul_basit',
      name: 'Abdul Basit Abdul Samad',
      arabicName: 'عبد الباسط عبد الصمد',
      folder: 'Abdul_Basit_Mujawwad_128kbps',
      style: 'Mujawwad • Classical',
    ),
    Reciter(
      id: 'al_husary',
      name: 'Mahmoud Khalil Al-Husary',
      arabicName: 'محمود خليل الحصري',
      folder: 'Husary_128kbps',
      style: 'Murattal • Clear Tajweed',
    ),
    Reciter(
      id: 'al_muaiqly',
      name: 'Maher Al-Muaiqly',
      arabicName: 'ماهر المعيقلي',
      folder: 'MaherAlMuaiqly128kbps',
      style: 'Imam of Masjid al-Haram',
    ),
    Reciter(
      id: 'ash_shatri',
      name: 'Abu Bakr Ash-Shatri',
      arabicName: 'أبو بكر الشاطري',
      folder: 'Abu_Bakr_Ash-Shatri_128kbps',
      style: 'Murattal • Emotional',
    ),
  ];

  static Reciter get defaultReciter => availableReciters.first;

  static Reciter findById(String id) {
    return availableReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => defaultReciter,
    );
  }
}
