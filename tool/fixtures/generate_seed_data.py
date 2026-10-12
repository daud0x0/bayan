#!/usr/bin/env python3
"""
Seed Data Generator for Offline-First Quran & Hadith App.
Complies with Section 6, 8, 9 of the Product Plan.
Produces:
- assets/data/quran_data.json
- assets/data/hadith_data.json
- assets/data/categories_data.json
"""

import json
import os

# Complete list of 114 Surahs with canonical metadata
SURAHS = [
    (1, "الفاتحة", "Al-Fatihah", "The Opening", 7, "Meccan"),
    (2, "البقرة", "Al-Baqarah", "The Cow", 286, "Medinan"),
    (3, "آل عمران", "Ali 'Imran", "Family of Imran", 200, "Medinan"),
    (4, "النساء", "An-Nisa", "The Women", 176, "Medinan"),
    (5, "المائدة", "Al-Ma'idah", "The Table Spread", 120, "Medinan"),
    (6, "الأنعام", "Al-An'am", "The Cattle", 165, "Meccan"),
    (7, "الأعراف", "Al-A'raf", "The Heights", 206, "Meccan"),
    (8, "الأنفال", "Al-Anfal", "The Spoils of War", 75, "Medinan"),
    (9, "التوبة", "At-Tawbah", "The Repentance", 129, "Medinan"),
    (10, "يونس", "Yunus", "Jonah", 109, "Meccan"),
    (11, "هود", "Hud", "Hud", 123, "Meccan"),
    (12, "يوسف", "Yusuf", "Joseph", 111, "Meccan"),
    (13, "الرعد", "Ar-Ra'd", "The Thunder", 43, "Medinan"),
    (14, "إبراهيم", "Ibrahim", "Abraham", 52, "Meccan"),
    (15, "الحجر", "Al-Hijr", "The Rocky Tract", 99, "Meccan"),
    (16, "النحل", "An-Nahl", "The Bee", 128, "Meccan"),
    (17, "الإسراء", "Al-Isra", "The Night Journey", 111, "Meccan"),
    (18, "الكهف", "Al-Kahf", "The Cave", 110, "Meccan"),
    (19, "مريم", "Maryam", "Mary", 98, "Meccan"),
    (20, "طه", "Ta-Ha", "Ta-Ha", 135, "Meccan"),
    (21, "الأنبياء", "Al-Anbiya", "The Prophets", 112, "Meccan"),
    (22, "الحج", "Al-Hajj", "The Pilgrimage", 78, "Medinan"),
    (23, "المؤمنون", "Al-Mu'minun", "The Believers", 118, "Meccan"),
    (24, "النور", "An-Nur", "The Light", 64, "Medinan"),
    (25, "الفرقان", "Al-Furqan", "The Criterion", 77, "Meccan"),
    (26, "الشعراء", "Ash-Shu'ara", "The Poets", 227, "Meccan"),
    (27, "النمل", "An-Naml", "The Ants", 93, "Meccan"),
    (28, "القصص", "Al-Qasas", "The Stories", 88, "Meccan"),
    (29, "العنكبوت", "Al-'Ankabut", "The Spider", 69, "Meccan"),
    (30, "الروم", "Ar-Rum", "The Romans", 60, "Meccan"),
    (31, "لقمان", "Luqman", "Luqman", 34, "Meccan"),
    (32, "السجدة", "As-Sajdah", "The Prostration", 30, "Meccan"),
    (33, "الأحزاب", "Al-Ahzab", "The Combined Forces", 73, "Medinan"),
    (34, "سبأ", "Saba", "Sheba", 54, "Meccan"),
    (35, "فاطر", "Fatir", "Originator", 45, "Meccan"),
    (36, "يس", "Ya-Sin", "Ya-Sin", 83, "Meccan"),
    (37, "الصافات", "As-Saffat", "Those who set the Ranks", 182, "Meccan"),
    (38, "ص", "Sad", "The Letter Sad", 88, "Meccan"),
    (39, "الزمر", "Az-Zumar", "The Troops", 75, "Meccan"),
    (40, "غافر", "Ghafir", "The Forgiver", 85, "Meccan"),
    (41, "فصلت", "Fussilat", "Explained in Detail", 54, "Meccan"),
    (42, "الشورى", "Ash-Shura", "The Consultation", 53, "Meccan"),
    (43, "الزخرف", "Az-Zukhruf", "The Ornaments of Gold", 89, "Meccan"),
    (44, "الدخان", "Ad-Dukhan", "The Smoke", 59, "Meccan"),
    (45, "الجاثية", "Al-Jathiyah", "The Crouching", 37, "Meccan"),
    (46, "الأحقاف", "Al-Ahqaf", "The Wind-Curved Sandhills", 35, "Meccan"),
    (47, "محمد", "Muhammad", "Muhammad", 38, "Medinan"),
    (48, "الفتح", "Al-Fath", "The Victory", 29, "Medinan"),
    (49, "الحجرات", "Al-Hujurat", "The Rooms", 18, "Medinan"),
    (50, "ق", "Qaf", "The Letter Qaf", 45, "Meccan"),
    (51, "الذاريات", "Adh-Dhariyat", "The Winnowing Winds", 60, "Meccan"),
    (52, "الطور", "At-Tur", "The Mount", 49, "Meccan"),
    (53, "النجم", "An-Najm", "The Star", 62, "Meccan"),
    (54, "القمر", "Al-Qamar", "The Moon", 55, "Meccan"),
    (55, "الرحمن", "Ar-Rahman", "The Beneficent", 78, "Medinan"),
    (56, "الواقعة", "Al-Waqi'ah", "The Inevitable", 96, "Meccan"),
    (57, "الحديد", "Al-Hadid", "The Iron", 29, "Medinan"),
    (58, "المجادلة", "Al-Mujadila", "The Pleading Woman", 22, "Medinan"),
    (59, "الحشر", "Al-Hashr", "The Exile", 24, "Medinan"),
    (60, "الممتحنة", "Al-Mumtahanah", "She that is to be examined", 13, "Medinan"),
    (61, "الصف", "As-Saff", "The Ranks", 14, "Medinan"),
    (62, "الجمعة", "Al-Jumu'ah", "The Congregation", 11, "Medinan"),
    (63, "المنافقون", "Al-Munafiqun", "The Hypocrites", 11, "Medinan"),
    (64, "التغابن", "At-Taghabun", "The Mutual Disillusion", 18, "Medinan"),
    (65, "الطلاق", "At-Talaq", "The Divorce", 12, "Medinan"),
    (66, "التحريم", "At-Tahrim", "The Prohibition", 12, "Medinan"),
    (67, "الملك", "Al-Mulk", "The Sovereignty", 30, "Meccan"),
    (68, "القلم", "Al-Qalam", "The Pen", 52, "Meccan"),
    (69, "الحاقة", "Al-Haqqah", "The Reality", 52, "Meccan"),
    (70, "المعارج", "Al-Ma'arij", "The Ascending Stairways", 44, "Meccan"),
    (71, "نوح", "Nuh", "Noah", 28, "Meccan"),
    (72, "الجن", "Al-Jinn", "The Jinn", 28, "Meccan"),
    (73, "المزمل", "Al-Muzzammil", "The Enshrouded One", 20, "Meccan"),
    (74, "المدثر", "Al-Muddaththir", "The Cloaked One", 56, "Meccan"),
    (75, "القيامة", "Al-Qiyamah", "The Resurrection", 40, "Meccan"),
    (76, "الإنسان", "Al-Insan", "Man", 31, "Medinan"),
    (77, "المرسلات", "Al-Mursalat", "The Emissaries", 50, "Meccan"),
    (78, "النبأ", "An-Naba", "The Tidings", 40, "Meccan"),
    (79, "النازعات", "An-Nazi'at", "Those who drag forth", 46, "Meccan"),
    (80, "عبس", "'Abasa", "He Frowned", 42, "Meccan"),
    (81, "التكوير", "At-Takwir", "The Overthrowing", 29, "Meccan"),
    (82, "الانفطار", "Al-Infitar", "The Cleaving", 19, "Meccan"),
    (83, "المطففين", "Al-Mutaffifin", "Defrauding", 36, "Meccan"),
    (84, "الانشقاق", "Al-Inshiqaq", "The Splitting Open", 25, "Meccan"),
    (85, "البروج", "Al-Buruj", "The Mansions of the Stars", 22, "Meccan"),
    (86, "الطارق", "At-Tariq", "The Morning Star", 17, "Meccan"),
    (87, "الأعلى", "Al-A'la", "The Most High", 19, "Meccan"),
    (88, "الغاشية", "Al-Ghashiyah", "The Overwhelming", 26, "Meccan"),
    (89, "الفجر", "Al-Fajr", "The Dawn", 30, "Meccan"),
    (90, "البلد", "Al-Balad", "The City", 20, "Meccan"),
    (91, "الشمس", "Ash-Shams", "The Sun", 15, "Meccan"),
    (92, "الليل", "Al-Layl", "The Night", 21, "Meccan"),
    (93, "الضحى", "Ad-Duha", "The Morning Hours", 11, "Meccan"),
    (94, "الشرح", "Ash-Sharh", "The Relief", 8, "Meccan"),
    (95, "التين", "At-Tin", "The Fig", 8, "Meccan"),
    (96, "العلق", "Al-'Alaq", "The Clot", 19, "Meccan"),
    (97, "القدر", "Al-Qadr", "The Power", 5, "Meccan"),
    (98, "البينة", "Al-Bayyinah", "The Clear Proof", 8, "Medinan"),
    (99, "الزلزلة", "Az-Zalzalah", "The Earthquake", 8, "Medinan"),
    (100, "العاديات", "Al-'Adiyat", "The Courser", 11, "Meccan"),
    (101, "القارعة", "Al-Qari'ah", "The Calamity", 11, "Meccan"),
    (102, "التكاثر", "At-Takathur", "The Rivalry in world increase", 8, "Meccan"),
    (103, "العصر", "Al-'Asr", "The Declining Day", 3, "Meccan"),
    (104, "الهمزة", "Al-Humazah", "The Traducer", 9, "Meccan"),
    (105, "الفيل", "Al-Fil", "The Elephant", 5, "Meccan"),
    (106, "قريش", "Quraysh", "Quraysh", 4, "Meccan"),
    (107, "الماعون", "Al-Ma'un", "Small Kindnesses", 7, "Meccan"),
    (108, "الكوثر", "Al-Kawthar", "Abundance", 3, "Meccan"),
    (109, "الكافرون", "Al-Kafirun", "The Disbelievers", 6, "Meccan"),
    (110, "النصر", "An-Nasr", "Divine Support", 3, "Medinan"),
    (111, "المسد", "Al-Masad", "The Palm Fiber", 5, "Meccan"),
    (112, "الإخلاص", "Al-Ikhlas", "The Sincerity", 4, "Meccan"),
    (113, "الفلق", "Al-Falaq", "The Daybreak", 5, "Meccan"),
    (114, "الناس", "An-Nas", "Mankind", 6, "Meccan")
]

# Core authentic Quranic Ayahs with verified Uthmani script and Saheeh International translation
AYAHS = [
    # Al-Fatihah 1:1-7
    {"surah": 1, "ayah": 1, "ar": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", "en": "In the name of Allah, the Entirely Merciful, the Especially Merciful."},
    {"surah": 1, "ayah": 2, "ar": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ", "en": "[All] praise is [due] to Allah, Lord of the worlds -"},
    {"surah": 1, "ayah": 3, "ar": "الرَّحْمَٰنِ الرَّحِيمِ", "en": "The Entirely Merciful, the Especially Merciful,"},
    {"surah": 1, "ayah": 4, "ar": "مَالِكِ يَوْمِ الدِّينِ", "en": "Sovereign of the Day of Recompense."},
    {"surah": 1, "ayah": 5, "ar": "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", "en": "It is You we worship and You we ask for help."},
    {"surah": 1, "ayah": 6, "ar": "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ", "en": "Guide us to the straight path -"},
    {"surah": 1, "ayah": 7, "ar": "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ", "en": "The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray."},

    # Al-Baqarah selections
    {"surah": 2, "ayah": 45, "ar": "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ وَإِنَّهَا لَكَبِيرَةٌ إِلَّا عَلَى الْخَاشِعِينَ", "en": "And seek help through patience and prayer, and indeed, it is difficult except for the humbly submissive [to Allah]."},
    {"surah": 2, "ayah": 152, "ar": "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ", "en": "So remember Me; I will remember you. And be grateful to Me and do not deny Me."},
    {"surah": 2, "ayah": 153, "ar": "يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ", "en": "O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient."},
    {"surah": 2, "ayah": 155, "ar": "وَلَنَبْلُوَنَّكُم بِشَيْءٍ مِّنَ الْخَوْفِ وَالْجُوعِ وَنَقْصٍ مِّنَ الْأَمْوَالِ وَالْأَنفُسِ وَالثَّمَرَاتِ ۗ وَبَشِّرِ الصَّابِرِينَ", "en": "And We will surely test you with something of fear and hunger and a loss of wealth and lives and fruits, but give good tidings to the patient,"},
    {"surah": 2, "ayah": 186, "ar": "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ ۖ فَلْيَسْتَجِيبُوا لِي وَلْيُؤْمِنُوا بِي لَعَلَّهُمْ يَرْشُدُونَ", "en": "And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me. So let them respond to Me and believe in Me that they may be [rightly] guided."},
    {"surah": 2, "ayah": 255, "ar": "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ", "en": "Allah - there is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great."},
    {"surah": 2, "ayah": 286, "ar": "لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا", "en": "Allah does not charge a soul except [with that within] its capacity. It will have [the consequence of] what [good] it has gained, and it will bear [the consequence of] what [evil] it has earned. 'Our Lord, do not impose blame upon us if we have forgotten or erred.'"},

    # Ali 'Imran
    {"surah": 3, "ayah": 139, "ar": "وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنتُمُ الْأَعْلَوْنَ إِن كُنتُم مُّؤْمِنِينَ", "en": "So do not weaken and do not grieve, and you will be superior if you are [true] believers."},
    {"surah": 3, "ayah": 159, "ar": "فَبِمَا رَحْمَةٍ مِّنَ اللَّهِ لِنتَ لَهُمْ ۖ وَلَوْ كُنتَ فَظًّا غَلِيظَ الْقَلْبِ لَانفَضُّوا مِنْ حَوْلِكَ ۖ فَاعْفُ عَنْهُمْ وَاسْتَغْفِرْ لَهُمْ وَشَاوِرْهُمْ فِي الْأَمْرِ ۖ فَإِذَا عَزَمْتَ فَتَوَكَّلْ عَلَى اللَّهِ ۚ إِنَّ اللَّهَ يُحِبُّ الْمُتَوَكِّلِينَ", "en": "So by mercy from Allah, [O Muhammad], you were lenient with them. And if you had been rude and harsh in heart, they would have disbanded from about you. So pardon them and ask forgiveness for them and consult them in the matter. And when you have decided, then rely upon Allah. Indeed, Allah loves those who rely [upon Him]."},

    # An-Nahl
    {"surah": 16, "ayah": 128, "ar": "إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَّالَّذِينَ هُم مُّحْسِنُونَ", "en": "Indeed, Allah is with those who fear Him and those who are doers of good."},

    # Al-Isra
    {"surah": 17, "ayah": 23, "ar": "وَقَضَىٰ رَبُّكَ أَلَّا تَعْبُدُوا إِلَّا إِيَّاهُ وَبِالْوَالِدَيْنِ إِحْسَانًا ۚ إِمَّا يَبْلُغَنَّ عِندَكَ الْكِبَرَ أَحَدُهُمَا أَوْ كِلَاهُمَا فَلَا تَقُل لَّهُمَا أُفٍّ وَلَا تَنْهَرْهُمَا وَقُل لَّهُمَا قَوْلًا كَرِيمًا", "en": "And your Lord has decreed that you not worship except Him, and to parents, good treatment. Whether one or both of them reach old age [while] with you, say not to them [so much as], 'uff,' and do not repel them but speak to them a noble word."},

    # Ta-Ha
    {"surah": 20, "ayah": 114, "ar": "فَتَعَالَى اللَّهُ الْمَلِكُ الْحَقُّ ۗ وَلَا تَعْجَلْ بِالْقُرْآنِ مِن قَبْلِ أَن يُقْضَىٰ إِلَيْكَ وَحْيُهُ ۖ وَقُل رَّبِّ زِدْنِي عِلْمًا", "en": "So high [above all] is Allah, the Sovereign, the Truth. And do not hasten with [recitation of] the Qur'an before its revelation is completed to you, and say, 'My Lord, increase me in knowledge.'"},

    # An-Nur
    {"surah": 24, "ayah": 35, "ar": "اللَّهُ نُورُ السَّمَاوَاتِ وَالْأَرْضِ ۚ مَثَلُ نُورِهِ كَمِشْكَاةٍ فِيهَا مِصْبَاحٌ ۖ الْمِصْبَاحُ فِي زُجَاجَةٍ ۖ الزُّجَاجَةُ كَأَنَّهَا كَوْكَبٌ دُرِّيٌّ", "en": "Allah is the Light of the heavens and the earth. The example of His light is like a niche within which is a lamp, the lamp is within glass, the glass as if it were a pearly [white] star..."},

    # Az-Zumar
    {"surah": 39, "ayah": 53, "ar": "قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ", "en": "Say, 'O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful.'"},

    # Ghafir
    {"surah": 40, "ayah": 60, "ar": "وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ ۚ إِنَّ الَّذِينَ يَسْتَكْبِرُونَ عَنْ عِبَادَتِي سَيَدْخُلُونَ جَهَنَّمَ دَاخِرِينَ", "en": "And your Lord says, 'Call upon Me; I will respond to you.' Indeed, those who disdain My worship will enter Hell [rendered] contemptible."},

    # Al-Hujurat
    {"surah": 49, "ayah": 10, "ar": "إِنَّمَا الْمُؤْمِنُونَ إِخْوَةٌ فَأَصْلِحُوا بَيْنَ أَخَوَيْكُمْ ۚ وَاتَّقُوا اللَّهَ لَعَلَّكُمْ تُرْحَمُونَ", "en": "The believers are but brothers, so make settlement between your brothers. And fear Allah that you may receive mercy."},
    {"surah": 49, "ayah": 13, "ar": "يَا أَيُّهَا النَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوا ۚ إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ ۚ إِنَّ اللَّهَ عَلِيمٌ خَبِيرٌ", "en": "O mankind, indeed We have created you from male and female and made you peoples and tribes that you may know one another. Indeed, the most noble of you in the sight of Allah is the most righteous of you. Indeed, Allah is Knowing and Acquainted."},

    # Al-Hadid
    {"surah": 57, "ayah": 4, "ar": "هُوَ الَّذِي خَلَقَ السَّمَاوَاتِ وَالْأَرْضَ فِي سِتَّةِ أَيَّامٍ ثُمَّ اسْتَوَىٰ عَلَى الْعَرْشِ ۚ يَعْلَمُ مَا يَلِجُ فِي الْأَرْضِ وَمَا يَخْرُجُ مِنْهَا وَمَا يَنزِلُ مِنَ السَّمَاءِ وَمَا يَعْرُجُ فِيهَا ۖ وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ ۚ وَاللَّهُ بِمَا تَعْمَلُونَ بَصِيرٌ", "en": "It is He who created the heavens and earth in six days and then established Himself above the Throne. He knows what penetrates into the earth and what comes forth from it and what descends from the heaven and what ascends therein. And He is with you wherever you are. And Allah, of what you do, is Seeing."},

    # At-Talaq
    {"surah": 65, "ayah": 2, "ar": "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا", "en": "And whoever fears Allah - He will make for him a way out."},
    {"surah": 65, "ayah": 3, "ar": "وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ ۚ قَدْ جَعَلَ اللَّهُ لِكُلِّ شَيْءٍ قَدْرًا", "en": "And will provide for him from where he does not expect. And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose. Allah has already set for everything a [decreed] extent."},

    # Al-Mulk
    {"surah": 67, "ayah": 1, "ar": "تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ", "en": "Blessed is He in whose hand is dominion, and He is over all things competent -"},
    {"surah": 67, "ayah": 2, "ar": "الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ", "en": "[He] who created death and life to test you [as to] which of you is best in deed - and He is the Exalted in Might, the Forgiving -"},

    # Ad-Duha
    {"surah": 93, "ayah": 1, "ar": "وَالضُّحَىٰ", "en": "By the morning brightness"},
    {"surah": 93, "ayah": 2, "ar": "وَاللَّيْلِ إِذَا سَجَىٰ", "en": "And [by] the night when it covers with darkness,"},
    {"surah": 93, "ayah": 3, "ar": "مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ", "en": "Your Lord has not taken leave of you, [O Muhammad], nor has He detested [you]."},
    {"surah": 93, "ayah": 4, "ar": "وَلَلْآخِرَةُ خَيْرٌ لَّكَ مِنَ الْأُولَىٰ", "en": "And the Hereafter is better for you than the first [life]."},
    {"surah": 93, "ayah": 5, "ar": "وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ", "en": "And your Lord is going to give you, and you will be satisfied."},

    # Ash-Sharh
    {"surah": 94, "ayah": 1, "ar": "أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ", "en": "Did We not expand for you, [O Muhammad], your breast?"},
    {"surah": 94, "ayah": 2, "ar": "وَوَضَعْنَا عَنكَ وِزْرَكَ", "en": "And We removed from you your burden"},
    {"surah": 94, "ayah": 3, "ar": "الَّذِي أَنقَضَ ظَهْرَكَ", "en": "Which had weighed upon your back"},
    {"surah": 94, "ayah": 4, "ar": "وَرَفَعْنَا لَكَ ذِكْرَكَ", "en": "And raised high for you your repute."},
    {"surah": 94, "ayah": 5, "ar": "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا", "en": "For indeed, with hardship [will be] ease."},
    {"surah": 94, "ayah": 6, "ar": "إِنَّ مَعَ الْعُسْرِ يُسْرًا", "en": "Indeed, with hardship [will be] ease."},
    {"surah": 94, "ayah": 7, "ar": "فَإِذَا فَرَغْتَ فَانصَبْ", "en": "So when you have finished [your duties], then stand up [for worship]."},
    {"surah": 94, "ayah": 8, "ar": "وَإِلَىٰ رَبِّكَ فَارْغَب", "en": "And to your Lord direct [your] longing."},

    # Al-Asr
    {"surah": 103, "ayah": 1, "ar": "وَالْعَصْرِ", "en": "By time,"},
    {"surah": 103, "ayah": 2, "ar": "إِنَّ الْإِنسَانَ لَفِي خُسْرٍ", "en": "Indeed, mankind is in loss,"},
    {"surah": 103, "ayah": 3, "ar": "إِلَّا الَّذِينَ آمَنُوا وَعَمِلُوا الصَّالِحَاتِ وَتَوَاصَوْا بِالْحَقِّ وَتَوَاصَوْا بِالصَّبْرِ", "en": "Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience."},

    # Al-Ikhlas
    {"surah": 112, "ayah": 1, "ar": "قُلْ هُوَ اللَّهُ أَحَدٌ", "en": "Say, 'He is Allah, [who is] One,"},
    {"surah": 112, "ayah": 2, "ar": "اللَّهُ الصَّمَدُ", "en": "Allah, the Eternal Refuge."},
    {"surah": 112, "ayah": 3, "ar": "لَمْ يَلِدْ وَلَمْ يُولَدْ", "en": "He neither begets nor is born,"},
    {"surah": 112, "ayah": 4, "ar": "وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ", "en": "Nor is there to Him any equivalent.'"},

    # Al-Falaq
    {"surah": 113, "ayah": 1, "ar": "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ", "en": "Say, 'I seek refuge in the Lord of daybreak"},
    {"surah": 113, "ayah": 2, "ar": "مِن شَرِّ مَا خَلَقَ", "en": "From the evil of that which He created"},
    {"surah": 113, "ayah": 3, "ar": "وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ", "en": "And from the evil of darkness when it settles"},
    {"surah": 113, "ayah": 4, "ar": "وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ", "en": "And from the evil of the blowers in knots"},
    {"surah": 113, "ayah": 5, "ar": "وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ", "en": "And from the evil of an envier when he envies.'"},

    # An-Nas
    {"surah": 114, "ayah": 1, "ar": "قُلْ أَعُوذُ بِرَبِّ النَّاسِ", "en": "Say, 'I seek refuge in the Lord of mankind,"},
    {"surah": 114, "ayah": 2, "ar": "مَلِكِ النَّاسِ", "en": "The Sovereign of mankind,"},
    {"surah": 114, "ayah": 3, "ar": "إِلَٰهِ النَّاسِ", "en": "The God of mankind,"},
    {"surah": 114, "ayah": 4, "ar": "مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ", "en": "From the evil of the retreating whisperer -"},
    {"surah": 114, "ayah": 5, "ar": "الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ", "en": "Who whispers into the breasts of mankind -"},
    {"surah": 114, "ayah": 6, "ar": "مِنَ الْجِنَّةِ وَالنَّاسِ", "en": "From among the jinn and mankind.'"}
]

# Curated authentic Hadiths from Sahih al-Bukhari and Sahih Muslim
HADITHS = [
    {
        "id": "bukhari_1",
        "collection_id": "bukhari",
        "hadith_number": 1,
        "book_number": 1,
        "book_name_en": "Revelation (Bad' al-Wahy)",
        "book_name_ar": "كتاب بدء الوحي",
        "chapter_name": "How the Divine Inspiration started",
        "narrator": "Umar ibn al-Khattab",
        "ar": "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى، فَمَنْ كَانَتْ هِجْرَتُهُ إِلَى دُنْيَا يُصِيبُهَا أَوْ إِلَى امْرَأَةٍ يَنْكِحُهَا فَهِجْرَتُهُ إِلَى مَا هَاجَرَ إِلَيْهِ",
        "en": "Actions are but by intention and every man shall have only that which he intended. Thus he whose migration was for Allah and His Messenger, his migration was for Allah and His Messenger, and he whose migration was for some worldly benefit or for a woman to marry, his migration was for which he migrated.",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 1 • In-book reference: Book 1, Hadith 1"
    },
    {
        "id": "bukhari_13",
        "collection_id": "bukhari",
        "hadith_number": 13,
        "book_number": 2,
        "book_name_en": "Belief (Al-Iman)",
        "book_name_ar": "كتاب الإيمان",
        "chapter_name": "Loving for one's brother what one loves for oneself",
        "narrator": "Anas ibn Malik",
        "ar": "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
        "en": "None of you will believe until you love for your brother what you love for yourself.",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 13 • In-book reference: Book 2, Hadith 6"
    },
    {
        "id": "bukhari_5645",
        "collection_id": "bukhari",
        "hadith_number": 5645,
        "book_number": 75,
        "book_name_en": "Patients (Al-Marda)",
        "book_name_ar": "كتاب المرضى",
        "chapter_name": "What has come regarding expiation of illness",
        "narrator": "Abu Hurairah and Abu Sa'id al-Khudri",
        "ar": "مَا يُصِيبُ الْمُسْلِمَ مِنْ نَصَبٍ وَلاَ وَصَبٍ وَلاَ هَمٍّ وَلاَ حُزْنٍ وَلاَ أَذًى وَلاَ غَمٍّ حَتَّى الشَّوْكَةِ يُشَاكُهَا، إِلاَّ كَفَّرَ اللَّهُ بِهَا مِنْ خَطَايَاهُ",
        "en": "No fatigue, nor disease, nor sorrow, nor sadness, nor hurt, nor distress befalls a Muslim, even if it were the prick he receives from a thorn, but that Allah expiates some of his sins for that.",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 5645 • In-book reference: Book 75, Hadith 5"
    },
    {
        "id": "bukhari_6011",
        "collection_id": "bukhari",
        "hadith_number": 6011,
        "book_number": 78,
        "book_name_en": "Good Manners (Al-Adab)",
        "book_name_ar": "كتاب الأدب",
        "chapter_name": "Being dutiful to parents",
        "narrator": "Abu Hurairah",
        "ar": "جَاءَ رَجُلٌ إِلَى رَسُولِ اللَّهِ صلى الله عليه وسلم فَقَالَ يَا رَسُولَ اللَّهِ مَنْ أَحَقُّ النَّاسِ بِحُسْنِ صَحَابَتِي قَالَ ‏أُمُّكَ‏.‏ قَالَ ثُمَّ مَنْ قَالَ ‏أُمُّكَ‏.‏ قَالَ ثُمَّ مَنْ قَالَ ‏أُمُّكَ‏.‏ قَالَ ثُمَّ مَنْ قَالَ ‏ثُمَّ أَبُوكَ‏",
        "en": "A man came to Allah's Messenger and said, 'O Allah's Messenger! Who is more entitled to be treated with the best companionship by me?' The Prophet said, 'Your mother.' The man said. 'Who is next?' The Prophet said, 'Your mother.' The man further said, 'Who is next?' The Prophet said, 'Your mother.' The man asked for the fourth time, 'Who is next?' The Prophet said, 'Then your father.'",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 6011 • In-book reference: Book 78, Hadith 2"
    },
    {
        "id": "bukhari_6306",
        "collection_id": "bukhari",
        "hadith_number": 6306,
        "book_number": 80,
        "book_name_en": "Invocations (Ad-Da'awat)",
        "book_name_ar": "كتاب الدعوات",
        "chapter_name": "The master supplication for seeking forgiveness",
        "narrator": "Shaddad ibn Aws",
        "ar": "سَيِّدُ الاِسْتِغْفَارِ أَنْ تَقُولَ: اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ",
        "en": "The most superior way of asking for forgiveness from Allah is: 'O Allah, You are my Lord! None has the right to be worshiped but You. You created me and I am Your servant, and I am faithful to my covenant and my promise as much as I can. I seek refuge with You from all the evil I have done. I acknowledge before You all the blessings You have bestowed upon me, and I confess to You all my sins. So I entreat You to forgive my sins, for nobody can forgive sins except You.'",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 6306 • In-book reference: Book 80, Hadith 3"
    },
    {
        "id": "bukhari_6407",
        "collection_id": "bukhari",
        "hadith_number": 6407,
        "book_number": 80,
        "book_name_en": "Invocations (Ad-Da'awat)",
        "book_name_ar": "كتاب الدعوات",
        "chapter_name": "The virtue of remembering Allah",
        "narrator": "Abu Hurairah",
        "ar": "كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
        "en": "Two words are light on the tongue, heavy on the Scale, and beloved to the Most Merciful: 'Subhan Allahi wa bihamdihi' (Glory be to Allah and His is the praise), and 'Subhan Allahil-'Azim' (Glory be to Allah, the Supreme).",
        "grading": "Sahih",
        "attribution": "Sahih al-Bukhari 6407 • In-book reference: Book 80, Hadith 102"
    },
    {
        "id": "muslim_2699",
        "collection_id": "muslim",
        "hadith_number": 2699,
        "book_number": 48,
        "book_name_en": "Remembrance and Supplication (Adh-Dhikr)",
        "book_name_ar": "كتاب الذكر والدعاء والتوبة والاستغفار",
        "chapter_name": "The merit of gathering for the remembrance of Allah and seeking knowledge",
        "narrator": "Abu Hurairah",
        "ar": "مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الْجَنَّةِ، وَمَا اجْتَمَعَ قَوْمٌ فِي بَيْتٍ مِنْ بُيُوتِ اللَّهِ يَتْلُونَ كِتَابَ اللَّهِ وَيَتَدَارَسُونَهُ بَيْنَهُمْ إِلاَّ نَزَلَتْ عَلَيْهِمُ السَّكِينَةُ وَغَشِيَتْهُمُ الرَّحْمَةُ وَحَفَّتْهُمُ الْمَلاَئِكَةُ وَذَكَرَهُمُ اللَّهُ فِيمَنْ عِنْدَهُ",
        "en": "Whoever travels a path in search of knowledge, Allah will make easy for him a path to Paradise. No people gather together in one of the houses of Allah, reciting the Book of Allah and studying it among themselves, except that tranquility descends upon them, mercy envelops them, the angels surround them, and Allah mentions them to those near Him.",
        "grading": "Sahih",
        "attribution": "Sahih Muslim 2699a • In-book reference: Book 48, Hadith 50"
    },
    {
        "id": "muslim_2999",
        "collection_id": "muslim",
        "hadith_number": 2999,
        "book_number": 55,
        "book_name_en": "Asceticism and Heart-Softeners (Az-Zuhd)",
        "book_name_ar": "كتاب الزهد والرقائق",
        "chapter_name": "The wonderful affair of the believer",
        "narrator": "Suhayb ar-Rumi",
        "ar": "عَجَبًا لأَمْرِ الْمُؤْمِنِ إِنَّ أَمْرَهُ كُلَّهُ خَيْرٌ وَلَيْسَ ذَاكَ لأَحَدٍ إِلاَّ لِلْمُؤْمِنِ إِنْ أَصَابَتْهُ سَرَّاءُ شَكَرَ فَكَانَ خَيْرًا لَهُ وَإِنْ أَصَابَتْهُ ضَرَّاءُ صَبَرَ فَكَانَ خَيْرًا لَهُ",
        "en": "How wonderful is the affair of the believer, for his affairs are all good, and this applies to no one but the believer. If something good happens to him, he is thankful for it and that is good for him. If something bad happens to him, he bears it with patience and that is good for him.",
        "grading": "Sahih",
        "attribution": "Sahih Muslim 2999 • In-book reference: Book 55, Hadith 82"
    },
    {
        "id": "muslim_2564",
        "collection_id": "muslim",
        "hadith_number": 2564,
        "book_number": 45,
        "book_name_en": "Virtue, Enjoining Good Manners (Al-Birr)",
        "book_name_ar": "كتاب البر والصلة والآداب",
        "chapter_name": "Prohibition of mutual malice and severing ties",
        "narrator": "Abu Hurairah",
        "ar": "إِنَّ اللَّهَ لاَ يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ",
        "en": "Indeed, Allah does not look at your appearances or your wealth, but He looks at your hearts and your actions.",
        "grading": "Sahih",
        "attribution": "Sahih Muslim 2564c • In-book reference: Book 45, Hadith 46"
    },
    {
        "id": "muslim_2749",
        "collection_id": "muslim",
        "hadith_number": 2749,
        "book_number": 49,
        "book_name_en": "Repentance (At-Tawbah)",
        "book_name_ar": "كتاب التوبة",
        "chapter_name": "Exhortation to repentance",
        "narrator": "Abu Hurairah",
        "ar": "وَالَّذِي نَفْسِي بِيَدِهِ لَوْ لَمْ تُذْنِبُوا لَذَهَبَ اللَّهُ بِكُمْ وَلَجَاءَ بِقَوْمٍ يُذْنِبُونَ فَيَسْتَغْفِرُونَ اللَّهَ فَيَغْفِرُ لَهُمْ",
        "en": "By Him in Whose Hand is my life, if you were not to commit sin, Allah would sweep you out of existence and He would replace (you by) those people who would commit sin and seek forgiveness from Allah, and He would have pardoned them.",
        "grading": "Sahih",
        "attribution": "Sahih Muslim 2749 • In-book reference: Book 49, Hadith 15"
    },
    {
        "id": "muslim_1342",
        "collection_id": "muslim",
        "hadith_number": 1342,
        "book_number": 15,
        "book_name_en": "Pilgrimage and Travel (Al-Hajj)",
        "book_name_ar": "كتاب الحج",
        "chapter_name": "Supplication when mounting a riding animal for travel",
        "narrator": "Abdullah ibn Umar",
        "ar": "اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَذَا الْبِرَّ وَالتَّقْوَى، وَمِنَ الْعَمَلِ مَا تَرْضَى، اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا، وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ، وَالْخَلِيفَةُ فِي الأَهْلِ",
        "en": "O Allah, we ask You in this journey of ours for righteousness and piety, and for deeds that please You. O Allah, make this journey easy for us and shorten its distance. O Allah, You are our Companion in travel and the One Who looks after the family left behind.",
        "grading": "Sahih",
        "attribution": "Sahih Muslim 1342 • In-book reference: Book 15, Hadith 553"
    }
]

# 15 Editorial Categories from Section 5.1 of the Product Plan
CATEGORIES = [
    {
        "id": "hardship_and_hope",
        "title": "Hardship and Hope",
        "description": "Find comfort, reassurance, and divine solace during life's most challenging seasons.",
        "icon": "wb_sunny_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "94_5",
                "reference": "Surah Ash-Sharh [94:5-6]",
                "relationship": "direct",
                "rationale": "Explicit divine assurance that with every hardship arrives relief and ease."
            },
            {
                "content_type": "quran",
                "content_id": "93_3",
                "reference": "Surah Ad-Duha [93:3-5]",
                "relationship": "direct",
                "rationale": "Affirmation that Allah has not abandoned the believer and promises a brighter future."
            },
            {
                "content_type": "hadith",
                "content_id": "bukhari_5645",
                "reference": "Sahih al-Bukhari 5645",
                "relationship": "direct",
                "rationale": "Teaches that physical and emotional pain can serve as spiritual expiation and redemption."
            }
        ]
    },
    {
        "id": "patience",
        "title": "Patience (Sabr)",
        "description": "Cultivate perseverance, steadfastness, and dignified restraint in thought and deed.",
        "icon": "shield_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "2_153",
                "reference": "Surah Al-Baqarah [2:153]",
                "relationship": "direct",
                "rationale": "Divine injunction directing the faithful to seek aid through patient endurance and prayer."
            },
            {
                "content_type": "hadith",
                "content_id": "muslim_2999",
                "reference": "Sahih Muslim 2999",
                "relationship": "direct",
                "rationale": "Highlights how both gratitude in ease and patience in hardship transform every state into good."
            },
            {
                "content_type": "quran",
                "content_id": "103_3",
                "reference": "Surah Al-'Asr [103:3]",
                "relationship": "thematic",
                "rationale": "Emphasizes mutual counsel toward truth and unwavering patience to overcome human loss."
            }
        ]
    },
    {
        "id": "gratitude",
        "title": "Gratitude (Shukr)",
        "description": "Acknowledge blessings, nurture contentedness, and praise the Provider of all goodness.",
        "icon": "favorite_border",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "1_2",
                "reference": "Surah Al-Fatihah [1:2]",
                "relationship": "direct",
                "rationale": "Foundational verse opening the Quran in perpetual praise and recognition of the Lord of worlds."
            },
            {
                "content_type": "quran",
                "content_id": "2_152",
                "reference": "Surah Al-Baqarah [2:152]",
                "relationship": "direct",
                "rationale": "Direct command connecting remembrance with thankful celebration and rejecting ingratitude."
            },
            {
                "content_type": "hadith",
                "content_id": "muslim_2999",
                "reference": "Sahih Muslim 2999",
                "relationship": "thematic",
                "rationale": "Points out that giving thanks during pleasant times is inherently good and rewarded."
            }
        ]
    },
    {
        "id": "repentance_and_istighfar",
        "title": "Repentance & Istighfar",
        "description": "Turning back to Allah with humility, seeking pardon, and renewing our devotion.",
        "icon": "refresh_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "39_53",
                "reference": "Surah Az-Zumar [39:53]",
                "relationship": "direct",
                "rationale": "The most expansive divine invitation never to despair of Allah's limitless forgiveness."
            },
            {
                "content_type": "hadith",
                "content_id": "bukhari_6306",
                "reference": "Sahih al-Bukhari 6306",
                "relationship": "direct",
                "rationale": "The Master Supplication (Sayyid al-Istighfar) recognizing divine blessings and confessing shortcomings."
            },
            {
                "content_type": "hadith",
                "content_id": "muslim_2749",
                "reference": "Sahih Muslim 2749",
                "relationship": "thematic",
                "rationale": "Illustrates how divine clemency welcomes sincere repentance from fallible human beings."
            }
        ]
    },
    {
        "id": "mercy_and_forgiveness",
        "title": "Mercy and Forgiveness",
        "description": "Reflecting on divine compassion and manifesting gentle mercy toward all creation.",
        "icon": "water_drop_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "1_1",
                "reference": "Surah Al-Fatihah [1:1]",
                "relationship": "direct",
                "rationale": "Invocation of Allah's boundless mercy (Ar-Rahman) and specific mercy (Ar-Rahim)."
            },
            {
                "content_type": "quran",
                "content_id": "3_159",
                "reference": "Surah Ali 'Imran [3:159]",
                "relationship": "direct",
                "rationale": "Praising the Prophet's softness of heart and enjoining mutual pardon and consultation."
            }
        ]
    },
    {
        "id": "trust_in_allah",
        "title": "Trust in Allah (Tawakkul)",
        "description": "Surrendering worries to the Almighty after taking conscientious and honest effort.",
        "icon": "anchor_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "65_3",
                "reference": "Surah At-Talaq [65:3]",
                "relationship": "direct",
                "rationale": "Explicit assurance that whoever places their full trust in Allah will find Him sufficient."
            },
            {
                "content_type": "quran",
                "content_id": "3_159",
                "reference": "Surah Ali 'Imran [3:159]",
                "relationship": "direct",
                "rationale": "Command to take resolute decisions and rely completely upon Allah's love."
            }
        ]
    },
    {
        "id": "prayer_and_remembrance",
        "title": "Prayer & Remembrance (Dhikr)",
        "description": "Anchoring the restless heart through mindful devotion, supplication, and contemplation.",
        "icon": "alarm_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "2_186",
                "reference": "Surah Al-Baqarah [2:186]",
                "relationship": "direct",
                "rationale": "Affirms Allah's intimate nearness and His responsiveness to every sincere caller."
            },
            {
                "content_type": "hadith",
                "content_id": "bukhari_6407",
                "reference": "Sahih al-Bukhari 6407",
                "relationship": "direct",
                "rationale": "Two phrases light on the tongue and heavy in the scales of divine remembrance."
            },
            {
                "content_type": "quran",
                "content_id": "40_60",
                "reference": "Surah Ghafir [40:60]",
                "relationship": "direct",
                "rationale": "Divine injunction promising an answer to those who supplicate."
            }
        ]
    },
    {
        "id": "guidance_and_wisdom",
        "title": "Guidance and Wisdom",
        "description": "Seeking celestial clarity, moral discernment, and enlightened understanding in our journeys.",
        "icon": "lightbulb_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "1_6",
                "reference": "Surah Al-Fatihah [1:6]",
                "relationship": "direct",
                "rationale": "Daily supplication for guidance upon the straight path of righteous favor."
            },
            {
                "content_type": "quran",
                "content_id": "24_35",
                "reference": "Surah An-Nur [24:35]",
                "relationship": "contextual",
                "rationale": "The famous Verse of Light (Ayat an-Nur) representing divine illumination in the soul."
            }
        ]
    },
    {
        "id": "charity_and_generosity",
        "title": "Charity & Generosity (Sadaqah)",
        "description": "Sharing sustenance freely, uplifting the vulnerable, and spreading warm goodwill.",
        "icon": "volunteer_activism_outlined",
        "content_links": [
            {
                "content_type": "hadith",
                "content_id": "bukhari_13",
                "reference": "Sahih al-Bukhari 13",
                "relationship": "thematic",
                "rationale": "The foundation of fraternal empathy—wanting for one's brother what one loves for oneself."
            }
        ]
    },
    {
        "id": "family_and_relationships",
        "title": "Family and Relationships",
        "description": "Honoring sacred parental rights, cherishing kin, and treating loved ones with gentle kindness.",
        "icon": "group_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "17_23",
                "reference": "Surah Al-Isra [17:23]",
                "relationship": "direct",
                "rationale": "Inviolable command to treat aging parents with tender respect and speak noble words."
            },
            {
                "content_type": "hadith",
                "content_id": "bukhari_6011",
                "reference": "Sahih al-Bukhari 6011",
                "relationship": "direct",
                "rationale": "Prophetic instruction placing the mother at the pinnacle of companionship three times."
            }
        ]
    },
    {
        "id": "character_and_conduct",
        "title": "Character & Conduct (Akhlaq)",
        "description": "Adorning intentions with honesty, humility, fairness, and noble ethical decorum.",
        "icon": "military_tech_outlined",
        "content_links": [
            {
                "content_type": "hadith",
                "content_id": "bukhari_1",
                "reference": "Sahih al-Bukhari 1",
                "relationship": "direct",
                "rationale": "The cornerstone of Islamic conduct: every act is judged by its inner intention."
            },
            {
                "content_type": "hadith",
                "content_id": "muslim_2564",
                "reference": "Sahih Muslim 2564",
                "relationship": "direct",
                "rationale": "Reminds us that divine scrutiny centers on the heart's purity and deeds, not outward forms."
            },
            {
                "content_type": "quran",
                "content_id": "49_13",
                "reference": "Surah Al-Hujurat [49:13]",
                "relationship": "thematic",
                "rationale": "True nobility resides purely in conscious God-fearing piety (taqwa)."
            }
        ]
    },
    {
        "id": "fear_and_hope",
        "title": "Fear and Hope",
        "description": "Balancing awe of divine majesty with luminous hope in His infinite grace.",
        "icon": "balance_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "3_139",
                "reference": "Surah Ali 'Imran [3:139]",
                "relationship": "thematic",
                "rationale": "Overcoming despair and anxiety through genuine conviction in faith."
            },
            {
                "content_type": "quran",
                "content_id": "2_286",
                "reference": "Surah Al-Baqarah [2:286]",
                "relationship": "thematic",
                "rationale": "Comfort that no soul is burdened beyond its capacity."
            }
        ]
    },
    {
        "id": "travel",
        "title": "Travel & Exploration",
        "description": "Supplications, reflections, and safe conduct for journeys across the horizons.",
        "icon": "flight_takeoff_outlined",
        "content_links": [
            {
                "content_type": "hadith",
                "content_id": "muslim_1342",
                "reference": "Sahih Muslim 1342",
                "relationship": "direct",
                "rationale": "The prophetic prayer when embarking on travel, imploring piety and safety."
            }
        ]
    },
    {
        "id": "seeking_knowledge",
        "title": "Seeking Knowledge ('Ilm)",
        "description": "Purifying the intellect through learning, reflection, and sacred inquiry.",
        "icon": "menu_book_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "20_114",
                "reference": "Surah Ta-Ha [20:114]",
                "relationship": "direct",
                "rationale": "The sublime prayer: 'My Lord, increase me in knowledge.'"
            },
            {
                "content_type": "hadith",
                "content_id": "muslim_2699",
                "reference": "Sahih Muslim 2699",
                "relationship": "direct",
                "rationale": "Walking the pathway of knowledge eases the road to Paradise."
            }
        ]
    },
    {
        "id": "death_and_hereafter",
        "title": "Death and the Hereafter",
        "description": "Contemplating the transient nature of this world and preparing for eternal life.",
        "icon": "hourglass_bottom_outlined",
        "content_links": [
            {
                "content_type": "quran",
                "content_id": "67_2",
                "reference": "Surah Al-Mulk [67:2]",
                "relationship": "direct",
                "rationale": "Life and death created as purposeful trials to test who is best in deed."
            },
            {
                "content_type": "quran",
                "content_id": "112_1",
                "reference": "Surah Al-Ikhlas [112:1-4]",
                "relationship": "thematic",
                "rationale": "The singular absolute reality of Allah, transcendent and eternal."
            }
        ]
    }
]

def main():
    os.makedirs("assets/data", exist_ok=True)

    # 1. Quran Data JSON
    quran_payload = {
        "edition": {
            "name": "King Fahd Complex / Uthmani Script",
            "language": "ar",
            "type": "uthmani",
            "version": "1.0.0"
        },
        "translation": {
            "name": "Saheeh International",
            "language": "en",
            "translator": "Saheeh International",
            "attribution": "The Quran: English Meanings by Saheeh International",
            "version": "1.0.0"
        },
        "surahs": [
            {
                "number": s[0],
                "name_ar": s[1],
                "name_en": s[2],
                "name_translation": s[3],
                "ayah_count": s[4],
                "revelation_type": s[5]
            }
            for s in SURAHS
        ],
        "ayahs": AYAHS
    }

    with open("assets/data/quran_data.json", "w", encoding="utf-8") as f:
        json.dump(quran_payload, f, ensure_ascii=False, indent=2)
    print("✓ Created assets/data/quran_data.json with 114 surahs and core ayahs.")

    # 2. Hadith Data JSON
    hadith_payload = {
        "collections": [
            {
                "id": "bukhari",
                "name_en": "Sahih al-Bukhari",
                "name_ar": "صحيح البخاري",
                "author": "Imam Muhammad al-Bukhari",
                "description": "The most authentic compilation of prophetic traditions in Islamic scholarship.",
                "total_hadiths": 7563,
                "attribution": "Sahih al-Bukhari / Translation: Dr. M. Muhsin Khan"
            },
            {
                "id": "muslim",
                "name_en": "Sahih Muslim",
                "name_ar": "صحيح مسلم",
                "author": "Imam Muslim ibn al-Hajjaj",
                "description": "The second most authentic book of Hadith, renowned for thematic rigor.",
                "total_hadiths": 7500,
                "attribution": "Sahih Muslim / Translation: Abdul Hamid Siddiqui"
            }
        ],
        "hadiths": HADITHS
    }

    with open("assets/data/hadith_data.json", "w", encoding="utf-8") as f:
        json.dump(hadith_payload, f, ensure_ascii=False, indent=2)
    print("✓ Created assets/data/hadith_data.json with authentic Bukhari and Muslim narrations.")

    # 3. Categories Data JSON
    categories_payload = {
        "version": "1.0.0",
        "categories": CATEGORIES
    }

    with open("assets/data/categories_data.json", "w", encoding="utf-8") as f:
        json.dump(categories_payload, f, ensure_ascii=False, indent=2)
    print("✓ Created assets/data/categories_data.json with 15 editorial categories and source links.")

if __name__ == "__main__":
    main()
