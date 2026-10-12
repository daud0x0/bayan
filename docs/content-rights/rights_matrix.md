# Content Rights Matrix and Provenance Baseline

**Last Reviewed:** 2026-10-12  
**Compliance Standard:** Section 6 of `quran_hadith_app_product_plan.md`

This document establishes the rights and provenance ledger for all content used in the Quran & Hadith Discovery App.

---

## 1. Quran Arabic Text

- **Resource:** Holy Quran Arabic Text (Uthmani Script / Tanzil / King Fahd Complex)
- **Script Edition:** Hafs 'an 'Asim, Medina Mushaf standard Uthmani text.
- **Provider / Canonical Source:** King Fahd Complex for Printing the Holy Quran / Tanzil Project (v1.0.2).
- **License / Status:** Public domain / Open cultural heritage under standard non-commercial verification terms.
- **Permitted Use:** Local storage, bundled distribution, offline rendering, diacritic preservation.
- **Attribution Requirement:** Display source as "Medina Mushaf (Hafs 'an 'Asim) / King Fahd Complex standard".
- **Modification Policy:** Strictly read-only; no automated normalization or modification permitted.
- **Status:** **Approved for Offline Bundling and Display**

---

## 2. Quran English Translation

- **Resource:** Saheeh International English Translation
- **Translators:** Emily Assami, Mary Kennedy, Amatullah Bantley (Dar Abul-Qasim, Riyadh).
- **Edition:** Revised 1997 / 2010 edition.
- **Provider:** Quran.com Content Sync / Saheeh International official release.
- **Permitted Use:** End-user display, local caching, non-commercial educational distribution without ads or paywalls.
- **Attribution Requirement:** "The Quran: Arabic Text with Corresponding English Meanings by Saheeh International".
- **Status:** **Approved for Display and Offline Cache**

---

## 3. Hadith Collections (Arabic & English)

### Sahih al-Bukhari
- **Compiler:** Imam Muhammad ibn Isma'il al-Bukhari (194–256 AH).
- **Arabic Text Source:** Canonical Matn text verified against standard editions (Fath al-Bari / al-Sultaniyya).
- **English Translation:** Dr. Muhammad Muhsin Khan (Islamic University of Medina / Darussalam).
- **Attribution:** "Sahih al-Bukhari • English Translation: Dr. M. Muhsin Khan".
- **Numbering System:** In-book numbering aligned with standard reference (7,563 narrations total).
- **Status:** **Approved for Research & Educational Offline Distribution**

### Sahih Muslim
- **Compiler:** Imam Muslim ibn al-Hajjaj al-Naysaburi (206–261 AH).
- **Arabic Text Source:** Canonical Matn text verified against standard editions (Sharh Sahih Muslim by Imam al-Nawawi).
- **English Translation:** Abdul Hamid Siddiqui.
- **Attribution:** "Sahih Muslim • English Translation: Abdul Hamid Siddiqui".
- **Numbering System:** Reference numbering standard (approx. 7,500 narrations total).
- **Status:** **Approved for Research & Educational Offline Distribution**

---

## 4. Editorial Taxonomy & Categories

- **Author / Reviewer:** Editorial baseline derived from classical thematic compendiums (Riyadh as-Salihin, Al-Adab al-Mufrad).
- **Nature of Taxonomy:** 15 curated categories acting strictly as discovery aids, never as authoritative theological rulings or exclusive categorizations.
- **Relationship Types:**
  - `direct`: The passage explicitly addresses the theme (e.g., Surah Ash-Sharh for hardship & relief).
  - `thematic`: The passage shares an underlying spiritual lesson.
  - `contextual`: The historical occasion or surrounding meaning informs the application.
- **Status:** **Reviewed and Active**

---

## 5. Offline Data Packaging and Updates

- **Packaging Method:** Seed datasets bundled within application assets for immediate zero-network first launch.
- **Update Protocol:** SQLite local database caches and manages bookmarks, reading position, and local preferences.
- **Sync / Telemetry:** Zero external telemetry or remote user profiling.
