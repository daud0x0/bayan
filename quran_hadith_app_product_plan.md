# Product Plan: Offline-First Quran & Hadith Discovery App

**Status:** Implementation-ready planning baseline  
**Platform:** Android first  
**Framework:** Flutter / Dart  
**Funding:** Optional donations  
**Business model:** Free; no ads, subscriptions, paywalls, or paid feature tiers  
**Content scope:** Complete Quran; Arabic-English Sahih al-Bukhari and Sahih Muslim, subject to source verification and redistribution rights  
**Personalization:** Explicit user-selected topics and language preferences, stored locally  
**Connectivity:** Offline-first; core reading works without an active connection after required content is provisioned

> **Core product promise:** Discover a relevant teaching, read it with its source and context, and save or share it beautifully—without ads, an account, or a network dependency for everyday reading.

---

## 1. Executive summary

Build a polished, trustworthy Android app for reading and discovering Quran and Hadith. The app combines:

1. A complete Quran reader.
2. Arabic and English Hadith from Sahih al-Bukhari and Sahih Muslim, using named and verified editions.
3. Editorial topics such as hardship, repentance/istighfar, travel, patience, gratitude, prayer, mercy, and remembrance.
4. A discovery feed personalized only through user-selected preferences.
5. A mathematical visual engine that creates elegant color-only gradients, organic shapes, soft blur, and subtle texture.
6. Saved items, local reading progress, search, and shareable wallpaper cards.
7. A correction and update process for religious text and metadata.
8. Optional donations that never unlock features or interrupt reading.

**Critical distinction:** “Offline-first” does not automatically mean “we may bundle any content we can download.” Content availability, API access, local caching, offline synchronization, prepackaged datasets, translations, and redistribution are separate rights questions. Resolve them resource by resource before shipping. Build the UI and visual engine with synthetic fixtures while those questions are being resolved.

### Product principles

- Religious text must never be invented or silently rewritten.
- Every displayed item must have a traceable source reference.
- Translations must be attributed to their exact edition and translator.
- Categories are editorial discovery aids, not claims of authoritative interpretation.
- Readability outranks decorative backgrounds.
- No ads, subscription, mandatory account, or manipulative engagement mechanics.
- Local reading, search, bookmarks, and preferences should work offline.
- Personalization must be transparent and manually adjustable.
- Donations are optional and must not create religious or emotional pressure.
- No AI-generated Quran or Hadith text.

---

## 2. Goals, non-goals, and launch scope

### 2.1 V1 goals

- Complete Quran text for one clearly identified script/edition.
- At least one English Quran translation whose use is approved for the intended distribution model.
- Arabic-English Sahih al-Bukhari and Sahih Muslim, provided the selected editions and rights are verified.
- Search across installed content.
- Editorial categories with reviewed source mappings.
- A locally personalized discovery feed.
- Bookmarks and reading-position persistence.
- Shareable cards with exact text, reference, and required attribution.
- Seeded procedural backgrounds plus curated, legible presets.
- Minimal onboarding and no required sign-in.
- Core app flows functional in airplane mode after content provisioning.
- Clear credits, content versions, privacy explanation, and correction-reporting path.

### 2.2 Explicit non-goals for V1

- iOS or web launch before Android is stable.
- Social network, comments, public profiles, or followers.
- AI religious answers, AI tafsir, or automated rulings.
- Unverified automatic categorization presented as scholarly fact.
- Cross-device sync or cloud backup.
- Audio recitation unless rights, storage, and scope are approved separately.
- Streaks, leaderboards, or pressure-driven reminders.
- Arbitrary user-generated religious classifications presented as verified.
- A promise that every additional language found online can be included.

### 2.3 Release-blocking decisions

Do not ship the relevant resource until these are resolved:

- Exact Quran Arabic source and edition.
- Exact Quran English translation and distribution rights.
- Exact Arabic and English Hadith editions.
- Completeness and numbering conventions for each Hadith collection.
- Permission for offline storage and any bundled or downloadable content package.
- Provider-specific sync, attribution, update, and correction requirements.
- Editorial review process for category assignments.

---

## 3. Audience and core jobs

### Target users

- People who read Quran and Hadith regularly.
- Readers looking for teachings on a chosen topic.
- Arabic readers who also want English translation.
- Users who need a dependable offline reference.
- Multilingual users as approved translations are added.
- People who want to save or share a referenced passage in a well-designed card.

### Core jobs

1. Resume reading the Quran from the last position.
2. Find Quran or Hadith material about a manually selected topic.
3. Verify a quote’s source before sharing it.
4. Search installed text without internet.
5. Save a verse or narration for later.
6. Share a visually appealing card without losing its text, reference, or attribution.
7. Use the app privately without creating an account.
8. Switch to a plain, high-legibility reading style when decorative visuals are distracting.

---

## 4. Information architecture and UX

Use four primary destinations. Keep navigation small and predictable.

### 4.1 Discover

- Personalized feed based on explicitly selected topics and language preferences.
- Entry point to browse all categories.
- Mixed Quran and Hadith cards, with a clear content-type label.
- Filters for content type, collection, language, and category.
- “Why am I seeing this?” explanation.
- “Show less of this topic” and “Reset preferences” actions.
- Natural stopping points and topic browsing; do not optimize for compulsive scrolling.

Each card should show:
- Content type: Quran or Hadith.
- Arabic text when available and appropriate.
- Selected translation.
- Exact source reference.
- Translation attribution when required.
- Topic labels, visually secondary to the source.
- Save and share actions.
- A clear route to the complete source context.

### 4.2 Read

**Quran**
- Surah index.
- Reader with Arabic, selected translation, verse references, and chapter navigation.
- Jump to surah and verse.
- Adjustable Arabic and translation sizes.
- Reading-position persistence.
- Verse actions: save, share, open context.

**Hadith**
- Collection selection for Sahih al-Bukhari and Sahih Muslim.
- Book/chapter navigation where verified metadata exists.
- Arabic and English display.
- Source numbering and edition metadata.
- Translation attribution.
- Grading only when supplied by an appropriate, documented source.
- Nearby-context navigation.

### 4.3 Saved

- Bookmarks.
- Saved share-card designs.
- Recently read items.
- Local reading position.
- Optional private lists only if they remain simple and local.

### 4.4 Settings

- App language and translation preferences.
- Arabic and translation typography.
- Light, dark, and system theme.
- Background style and visual intensity.
- Plain-reading mode.
- Content source, version, and update status.
- Privacy and local-data reset.
- Credits, licenses, support, and correction reporting.
- Optional donation link.

### 4.5 Minimal onboarding

- Open into a useful screen immediately.
- Ask for language only when needed to make the first screen understandable.
- Let users choose topics later; do not force a long preference questionnaire.
- Explain any required content download honestly.
- No account creation.
- No forced notification permission.
- Use dismissible contextual tips instead of a multi-screen tutorial.

---

## 5. Editorial categories and manual personalization

### 5.1 Candidate category taxonomy

Initial proposed categories:

- Hardship and hope
- Repentance and istighfar
- Patience
- Gratitude
- Mercy and forgiveness
- Trust in Allah
- Prayer and remembrance
- Guidance and wisdom
- Charity and generosity
- Family and relationships
- Character and conduct
- Fear and hope
- Travel
- Seeking knowledge
- Death and the Hereafter

These are proposed product labels, not a final religious classification. A knowledgeable reviewer should approve category names, descriptions, and source mappings before release.

### 5.2 Category mapping rules

Each category-to-content relationship should contain:
- Stable category ID.
- Content type and stable content ID.
- Exact Quran or Hadith source reference.
- Relationship type, e.g. `direct`, `thematic`, or `contextual`.
- Short editorial rationale.
- Review status and reviewer record.
- Version and last-reviewed date.

Do not imply that a verse was revealed for a modern category or that a narration specifically addresses a topic unless the source supports that claim. Keep the full source context available. Distinguish direct subject matter from a broader thematic relationship.

### 5.3 Transparent feed algorithm

Do not use machine learning in V1. Use deterministic, local ranking.

An initial illustrative score:

`score = topic_match * 50 + language_match * 20 + content_type_preference * 10 + unseen_bonus * 10 + diversity_bonus * 10`

These weights are placeholders, not scientifically validated values. Tune them through usability testing.

Rules:
- Rank from explicit user preferences and local state only.
- Do not infer a user’s religious beliefs, emotional state, or personal circumstances.
- Add diversity rules to avoid long runs from one collection or category.
- Avoid showing the same items too frequently.
- Let users adjust, clear, or reset their preferences.
- Keep a sensible default feed before preferences are selected.
- Version the ranking algorithm and unit-test it.
- No remote reading-history analytics by default.

---

## 6. Content sourcing, rights, and verification

This is a release-blocking workstream.

### 6.1 Rights matrix

Maintain a rights record for every shipped resource, including each translation and relevant font or visual asset.

Required fields:
- Resource name and type.
- Provider and official source URL.
- Exact edition/resource identifier.
- Language and script.
- Translator/publisher, where applicable.
- License or written permission evidence.
- Required attribution.
- Permitted display, caching, offline storage, bundling, modification, and redistribution.
- Update/correction obligations.
- Date reviewed and reviewer.
- Approval status: `unreviewed`, `under_review`, `approved`, or `rejected`.

Do not mark a resource approved just because a public website displays it or an API returns it.

### 6.2 Quran Arabic text and translations

The Quran Arabic text, translation, commentary, font, and page images may have different rights conditions. Review them independently.

Record:
- Script edition, e.g. Uthmani or Indo-Pak.
- Source edition and canonical identifiers.
- Translation title, translator, and publisher.
- Exact source and version.
- Required attribution.
- Whether local caching is allowed.
- Whether a full offline copy may be retained.
- Whether a prepackaged database or downloadable content bundle is allowed.
- How corrections must be applied.

**Quran Foundation / Quran.com:** The current Developer Terms distinguish end-user display from redistribution of raw content or separately distributed content packages. For supported offline resources, Content Sync is the required path for obtaining and maintaining offline copies; sync at least every seven days when connectivity permits and apply available changes. The terms say a prepackaged content database is not automatically authorized by the offline-sync exception. Donations may be allowed for an app displaying content within its user experience, subject to the terms. Review the current terms directly before implementation.  
Sources:
- https://api-docs.quran.com/legal/developer-terms/
- https://api-docs.quran.com/docs/tutorials/content-sync/getting-started/
- https://api-docs.quran.com/docs/tutorials/content-sync/offline-cache-patterns/
- https://api-docs.quran.com/docs/tutorials/faq/

**Architecture implication:** Do not assume the entire Quran dataset can be bundled into the APK just because Content Sync supports offline use. Confirm the permitted delivery model. If using Content APIs that require confidential client credentials, keep the client secret on a backend; never embed it in the Flutter application. See https://api-docs.quran.com/docs/quickstart/.

### 6.3 Hadith: Sahih al-Bukhari and Sahih Muslim

Do not assume that the Arabic text, English translation, chapter titles, explanatory notes, numbering, or grading metadata share one license.

For each selected collection/edition, verify:
- Provider, publisher, edition, and source URL.
- Whether the dataset is complete for that declared edition.
- Whether repeated narrations are included.
- Arabic text integrity.
- English translator and edition.
- Numbering convention and mapping between editions.
- Book/chapter metadata provenance.
- Grading source and applicability, if displayed.
- Offline storage, bundling, modification, and redistribution rights.
- Required attribution.
- Update and correction mechanism.

Sunnah.com is a potential source to investigate, not an assumption of permission:
- https://sunnah.com/
- https://sunnah.com/developers

**Release gate:** No Hadith collection ships until source provenance, edition identity, completeness, attribution, and offline redistribution permission are documented.

### 6.4 Content import pipeline

1. Acquire content only through a permitted source method.
2. Preserve original source files in a controlled, versioned location.
3. Verify the rights record before import.
4. Parse into a staging format without changing source text.
5. Validate IDs, record counts, duplicates, missing fields, and encoding.
6. Compare reviewed samples against the primary edition.
7. Run automated integrity checks.
8. Review category assignments separately from text import.
9. Generate a versioned update package or compliant sync operation.
10. Record source version, checksum, import date, and review status.

Keep these separate:
- `source_text`: the exact imported text.
- `display_text`: the text shown to the user, without silent edits.
- `search_normalized_text`: a derived search-only representation.

Never silently auto-correct scripture or Hadith text through Unicode normalization or text cleanup.

### 6.5 Content corrections

- Provide a clear correction-reporting path.
- Triage Arabic source errors, translation issues, numbering mismatches, and category disagreements separately.
- Keep a changelog and provenance for every correction.
- Do not overwrite source content without traceability.
- Distribute corrections through a rights-compliant update mechanism.
- Show content version and last successful update in Settings.
- A reported issue is not proof that a source is wrong; verify against the named edition.

---

## 7. Offline-first strategy

### 7.1 Offline acceptance requirement

After content has been provisioned, users must be able to:
- Read installed Quran and Hadith text.
- Browse installed categories.
- Search installed text.
- Bookmark and resume reading.
- Change preferences.
- Generate and export share cards.
- Use the app in airplane mode without blank screens or crashes.

Be precise in the store listing if a first-time content download requires internet.

### 7.2 Packaging options

**Option A: Bundle permitted text data**
- Benefits: content available immediately after install.
- Costs: larger download; corrections may require app updates or a separate permitted update path.
- Gate: explicit rights to bundle the selected data.

**Option B: App plus separate content provisioning**
- Benefits: app binary remains smaller; data versions can be managed independently.
- Costs: initial download needs internet; requires progress, retry, storage, and recovery UX.
- Gate: explicit rights to distribute/download and retain the selected data.

**Recommended design:** Make the content repository support versioned local datasets and atomic updates, while choosing the actual distribution method separately for each provider/resource based on its terms. Do not promise a final app size until real data and indexes are measured.

### 7.3 Sync and update behavior

- Local database is the read source for the UI.
- Normal reading must not wait on the network.
- Updates are resumable, integrity-checked, and atomic.
- Apply changes in a transaction or staging database; never expose a half-updated library.
- Keep prior valid content if an update fails.
- Persist sync tokens/cursors only after all required pages and snapshots are applied successfully.
- Follow provider-specific sync cadence and retention terms.
- Do not use a generic timer that ignores provider rules or wastes battery.
- Show update state without blocking reading.
- Test long network outages and reconnect behavior.

Flutter’s offline-first and SQL architecture guides are useful implementation references:
- https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- https://docs.flutter.dev/app-architecture/design-patterns/sql

---

## 8. Flutter architecture

Use a testable separation between UI, domain logic, and data sources. Flutter’s official architecture guide recommends clear UI/data layers and repositories; keep the implementation proportionate rather than creating abstractions for every widget.  
Reference: https://docs.flutter.dev/app-architecture/guide

### 8.1 Proposed stack

Pin compatible stable versions during implementation.

- **UI:** Flutter and Dart.
- **Navigation:** `go_router` or a similarly maintained declarative router.
- **State:** Riverpod or another consistent, testable state solution; choose one.
- **Local database:** SQLite via a maintained Flutter package; consider Drift for typed queries and migrations.
- **Settings:** maintained key-value storage for small preferences.
- **Search:** SQLite FTS5 if supported by the chosen build and validated for Arabic and the target languages; otherwise use a tested local index.
- **Networking:** maintained HTTP client for permitted update/donation flows only.
- **Card export:** Flutter rendering plus a tested image-export path.
- **Testing:** unit, widget, integration, and golden tests.
- **Static checks:** formatter, `flutter_lints`, CI, and dependency/license checks.
- **Fonts:** redistribution-cleared fonts with verified Arabic glyph coverage.

Review package maintenance, Android support, license, accessibility, and SDK compatibility before adopting a dependency.

### 8.2 Suggested directory layout

```text
lib/
  app/
    app.dart
    router.dart
    bootstrap.dart
    theme/
  core/
    errors/
    localization/
    typography/
    accessibility/
    logging/
  data/
    database/
      app_database.dart
      migrations/
      tables/
      daos/
    content_import/
    content_updates/
    repositories/
    sources/
  domain/
    models/
    repositories/
    use_cases/
  features/
    discover/
    quran/
    hadith/
    search/
    categories/
    bookmarks/
    share_cards/
    settings/
    donations/
  visual_engine/
    palette/
    generator/
    presets/
    rendering/
    export/
  l10n/
assets/
  fonts/
  visual_presets/
  seed_metadata/
test/
  unit/
  widget/
  integration/
  golden/
tool/
  content_validation/
  fixtures/
docs/
  content-rights/
  architecture/
  decisions/
```

Keep licensed source datasets out of public source control unless the relevant license explicitly permits committing and redistributing them. Use synthetic fixtures for tests.

### 8.3 Data flow

```text
Flutter View
  -> ViewModel / State Controller
  -> Use case (when business logic warrants it)
  -> Repository interface
  -> Local SQLite database
  <- permitted import/update pipeline

Immutable domain models
  -> view state
  -> UI
```

Rules:
- Widgets must not make API requests directly.
- Widgets must not parse large data files during scrolling.
- Local storage is the source of truth for reading.
- Keep content schema migrations separate from content-version updates.
- Network failures must not break already-installed reading flows.

---

## 9. Database design

Use stable source identifiers; never use translated display strings as primary keys.

### Core tables

**`surahs`**
- `id`, `source_key`, `arabic_name`, localized-name references, verse count, canonical metadata, `source_version`.

**`ayahs`**
- `id`, `surah_id`, `ayah_number`, `arabic_text`, canonical source identifier.
- Unique constraint on `(surah_id, ayah_number)`.

**`translation_editions`**
- `id`, language tag, title, translator/publisher, edition, source URL, license reference, attribution, version, rights status.

**`quran_translations`**
- `id`, `ayah_id`, `translation_edition_id`, text.
- Unique constraint on `(ayah_id, translation_edition_id)`.

**`hadith_collections`**
- `id`, stable collection key, edition metadata, source and license references, completeness/version status.

**`hadiths`**
- `id`, `collection_id`, stable source identifier, source numbering string, book/chapter references, Arabic text, provenance metadata.

**`hadith_translations`**
- `id`, `hadith_id`, `translation_edition_id`, translated text, translator/edition provenance.

**`categories`**
- Stable ID, localized name/description references, review status, version, last-reviewed date.

**`category_content`**
- Category ID, content type, content ID, exact source reference, relationship type, editorial rationale, review metadata.

**`bookmarks`**
- Content type, content ID, creation timestamp, optional private-list ID.

**`reading_progress`**
- Content type, source ID, verse/narration position, update timestamp.

**`user_preferences`**
- Selected categories, language/translation IDs, content-type filters, theme, visual settings, accessibility settings.

**`content_source_versions`**
- Resource ID, provider, source version, checksum, last verified time, update state, permitted sync token/cursor.

### Database requirements

- Use schema migrations.
- Add indexes for source IDs, surah/ayah positions, collection/number, category joins, and search.
- Use foreign keys where appropriate.
- Use transactions for import/update.
- Keep raw source text separate from normalized search text.
- Do not store confidential API credentials in the client database.
- Validate performance using the full representative dataset before finalizing indexes.

---

## 10. Search and Arabic text handling

### V1 search

- Search Arabic Quran text.
- Search selected Quran translations.
- Search Arabic and English Hadith text.
- Filter by content type, collection, language, and topic.
- Open the exact source location from a result.
- Highlight matches without altering source text.

### Arabic normalization

Arabic search requires deliberate design and testing.

- Use a defined Unicode normalization policy.
- Optionally support diacritic-insensitive matching.
- Optionally handle common alif/hamza variants.
- Preserve exact display text.
- Keep indexing, matching, and highlighting normalization consistent.
- Do not conflate search normalization with content correction.
- Test Arabic morphology and tokenization expectations; do not promise advanced semantic search in V1.

Start with dependable full-text search and curated categories. Semantic/AI search is out of scope until accuracy, privacy, and religious review requirements are separately defined.

---

## 11. Procedural visual engine

The app’s signature visual feature is a color-only background system: mathematically generated gradients, organic shapes, soft blur, and restrained texture. It must improve the reading experience rather than compete with it.

### 11.1 Visual goals

- Premium, calm, contemporary appearance.
- Stable visual identity across the app.
- Enough variety to make discovery cards feel fresh.
- Legible Arabic and translation at different lengths.
- Low rendering cost on modest Android hardware.
- Plain high-contrast alternative available instantly.

Potential visual families:
- Aurora.
- Warm dawn.
- Deep night.
- Oceanic.
- Botanical abstract.
- Soft paper/minimal.
- Monochrome.
- High contrast.

Names are working labels, not fixed requirements.

### 11.2 Generator inputs

- Stable content ID.
- Preset family.
- Light/dark mode.
- User-selected visual intensity.
- Text block geometry and content density.
- Contrast target and accessibility settings.
- Generator version.
- Optional curated mood label, if explicitly selected.

Do not imply that a color has an authoritative religious meaning. Mood-based palettes are design choices, not religious interpretation.

### 11.3 Deterministic generation

Use a seeded pseudo-random generator. The same content ID, preset, and generator version should produce the same composition.

Algorithm:
1. Derive a stable seed from content ID, preset, and generator version.
2. Select a palette from curated, contrast-tested color families.
3. Generate a small number of organic shapes using normalized coordinates.
4. Vary shape scale, position, gradient center, opacity, and blur within bounded ranges.
5. Keep visually active shapes away from critical text regions.
6. Add a contrast scrim or text panel when needed.
7. Measure text layout and adjust composition.
8. Verify contrast on the final composition.
9. Cache compact parameters by seed.
10. Render at the target size only when needed.

Do not use unseeded random values in widget rebuilds. Do not regenerate every card during every scroll frame.

### 11.4 Palette and contrast optimization

- Maintain curated palettes for light, dark, and high-contrast modes.
- Evaluate contrast against the composited background or a conservative overlay.
- Use a text scrim/panel when a complex gradient cannot guarantee contrast.
- Support a plain background.
- Never use color alone to distinguish Quran from Hadith.
- Test final rendered pixels, not just palette swatches.
- Validate both Arabic and translation blocks at large font sizes.
- If contrast cannot be guaranteed, choose a safer composition rather than a more colorful one.

### 11.5 Texture and blur

- Prefer subtle, low-amplitude texture; avoid noisy patterns behind small text.
- Limit the number of large blur layers.
- Keep texture generation inexpensive and reproducible.
- Ensure blur cannot overflow into unsafe areas or cause clipping.
- Do not animate backgrounds by default.
- Respect reduced-motion preferences.

### 11.6 Flutter performance rules

- Profile blur and shader cost on real Android devices.
- Avoid expensive calculations inside repeated build methods.
- Use `RepaintBoundary` only where profiling supports it.
- Cache parameters, not necessarily full-resolution images.
- Export high-resolution cards outside the scrolling critical path.
- Limit simultaneous shape layers.
- Measure frame time, raster time, memory, and jank with Flutter DevTools.
- Test mid-range and low-memory devices.

---

## 12. Typography and reading UX

### Arabic typography

- Select a font with appropriate Arabic shaping, joining, diacritics, and glyph coverage.
- Test Quranic marks, ligatures, punctuation, mixed Arabic/Latin references, and line wrapping.
- Prevent clipping above and below glyphs.
- Provide comfortable line-height and independent font-size controls.
- Test right-to-left flow and bidirectional text.
- Support Android system font scaling.
- Confirm font redistribution rights before bundling.

### Quran reader

- Clear surah and verse hierarchy.
- Arabic text with selected translation.
- Translation attribution visible and accessible.
- Adjustable Arabic and translation sizes independently.
- Bookmark, share, and open-context actions.
- Jump to surah and verse.
- Persist reading position locally.
- No silent truncation.

### Hadith reader

- Collection and source reference are always clear.
- Arabic and English have independent typography controls.
- Preserve source numbering; label alternate numbering systems.
- Show book/chapter metadata only when verified.
- Display grading only with provenance.
- Provide surrounding-context navigation.
- Keep app decoration visually separate from the source text.

---

## 13. Shareable wallpaper cards

Sharing is a core feature, not an afterthought.

### Requirements

- Export crisp images at common social-media dimensions.
- Preserve exact Arabic or selected translation text.
- Include exact source reference and required translation attribution.
- Keep text readable with contrast-safe backgrounds.
- Adapt font size and card height to content length.
- Never silently crop a verse or narration.
- Offer plain-text sharing as a fallback.
- Keep branding subtle; do not imply the visual card is part of the original scripture.
- Test different aspect ratios, device densities, and long passages.
- Reuse the same source text and formatting logic as the reader to avoid mismatches.

For text too long to fit legibly, offer plain-text sharing or a multi-card export rather than shrinking it beyond readability. Include a source reference on every exported card.

---

## 14. Privacy and donation funding

### Privacy

- No account required.
- Keep bookmarks, progress, topic choices, and visual preferences on-device.
- Do not send reading history to a remote service.
- Avoid analytics and marketing SDKs by default.
- If crash diagnostics are added later, disclose them accurately and obtain any required consent.
- Request no unnecessary permissions.
- Provide a local-data reset option.
- Publish a privacy policy matching actual app behavior, including update requests and external donation links.
- Audit dependency behavior and network requests before claiming zero data collection.

### Donations

- Donations are optional.
- No feature or content is locked behind payment.
- Do not use guilt, religious pressure, intrusive prompts, or artificial countdowns.
- Explain what donations support, such as maintenance, accessibility, and content verification.
- Use a reputable provider; assess payment, privacy, regional availability, and platform-policy implications.
- Disclose when the user leaves the app for an external donation provider.
- Do not store payment credentials in the app.
- Donation flow may require internet; reading must not.

Review current Google Play policies and applicable legal/tax obligations before release. This plan is not legal or tax advice.

---

## 15. Localization and accessibility

- Use Flutter localization infrastructure.
- Store stable IDs separately from localized labels.
- Support right-to-left layouts and mixed-direction content.
- Ensure Arabic remains correctly directed when surrounded by English UI.
- Test long translations and text expansion.
- Never hard-code English category labels into content records.
- Support system text scaling and screen readers.
- Provide meaningful accessible labels and focus order.
- Make interactive targets comfortably tappable.
- Do not convey state using color alone.
- Provide a plain reading theme.
- Add languages only when the exact translation rights and quality are verified.

Initial launch scope is Arabic text plus English translation. Additional languages are an architectural capability, not an assumption that online translations may be redistributed.

---

## 16. Security and reliability

- Never embed confidential API secrets in the APK.
- Verify checksums/signatures for update packages where supported.
- Validate package structure and size before import.
- Use transactions, staging, and rollback for updates.
- Treat downloaded metadata as untrusted input.
- Never execute code from content packages.
- Separate religious content from user preferences.
- Provide recovery behavior for failed migrations or corrupted updates.
- Minimize dependencies and review their licenses.
- Document response steps for reported content errors.
- Do not make the reader dependent on network connectivity.

---

## 17. Testing strategy

### 17.1 Unit tests

Test:
- Feed ranking and diversity.
- Manual preference filters and reset.
- Seeded generator determinism.
- Palette constraints and contrast calculations.
- Search normalization and highlighting.
- Source-reference formatting.
- Translation selection and fallback.
- Database repositories and migrations.
- Content package validation.
- Import integrity and duplicate detection.
- Bookmark and reading-progress persistence.
- Long-text card layout.

### 17.2 Content integrity tests

For each content build:
- Verify expected Quran surah/ayah coverage against the chosen edition.
- Verify identifiers are unique.
- Verify translation coverage and missing records.
- Verify Hadith completeness against the declared edition and numbering system.
- Verify category links point to real content.
- Verify every visible text has source/edition metadata and required attribution.
- Compare reviewed samples against the primary source.
- Check replacement characters, Unicode corruption, unexpected whitespace changes, and truncation.
- Produce machine-readable and human-readable QA reports.
- Fail release builds on unresolved critical integrity defects.

Do not use one hard-coded Hadith count as proof of completeness. Counts and numbering vary by edition and treatment of repeated narrations.

### 17.3 Widget and golden tests

Cover:
- Light/dark themes.
- Long Arabic verses and long translations.
- Long Hadith text.
- Large system text scaling.
- Right-to-left navigation.
- Small and large screens.
- Plain and procedural backgrounds.
- Export dimensions and safe areas.
- Contrast regression.
- Loading, empty, and error states.
- Screen-reader labels and focus order.

### 17.4 Integration tests

- Fresh install and first launch.
- Read all installed content in airplane mode.
- Search while offline.
- Bookmark and restore reading position after restart.
- Open source context from a discovery card.
- Switch translation.
- Update content successfully.
- Recover from interrupted download and interrupted update.
- Share a card with correct text, reference, and attribution.
- Clear local user data.
- Confirm donations/external links do not block reading.

### 17.5 Performance acceptance goals

Treat these as targets to validate, not guarantees:
- No network call on the critical path for opening installed content.
- Smooth scrolling on representative mid-range Android devices.
- No large-file parsing on the UI thread.
- No repeated expensive background regeneration during normal rebuilds.
- Search remains responsive on the complete local library.
- App remains responsive during content updates.
- Memory usage stays stable through long feed sessions.
- Card export does not freeze the reader.

Use Flutter DevTools and real-device profiling to set final budgets after a representative prototype exists.

---

## 18. Implementation roadmap

Work in milestones with exit criteria, not arbitrary dates. Content rights and review can be the longest dependency.

### Phase 0 — Content feasibility and rights (release blocker)

**Deliverables**
- Candidate Quran Arabic source and script edition.
- Candidate English translation.
- Candidate Bukhari and Muslim Arabic/English editions.
- Rights matrix for every resource.
- Provider access and offline-storage decision.
- Bundled-data versus content-package decision.
- Edition, completeness, and numbering policy.
- Content correction/update plan.

**Exit criteria**
- No core source is marked approved without evidence.
- The team knows what can be displayed, cached, bundled, downloaded, and updated.

### Phase 1 — Product and visual prototype

**Deliverables**
- Navigation and reader wireframes.
- Arabic typography test screen.
- Discovery-card designs.
- Seeded background generator.
- Contrast and accessibility tests.
- Share-card export proof of concept.

**Exit criteria**
- Long text remains readable on real Android devices.
- Background rendering does not cause visible jank.
- Users can identify content type and source reference.

### Phase 2 — Flutter foundation

**Deliverables**
- App scaffold and navigation.
- Theme and localization infrastructure.
- Database schema and migrations.
- Repository layer.
- Settings and local preferences.
- CI, linting, and test scaffolding.

**Exit criteria**
- App launches without a network.
- Synthetic fixtures load through repositories.
- UI is not coupled directly to remote services.

### Phase 3 — Content pipeline and Quran reader

**Deliverables**
- Approved Quran import or permitted Content Sync integration.
- Source/version metadata.
- Quran index and reader.
- Translation selection.
- Local bookmarks and reading progress.
- Search prototype and integrity reports.

**Exit criteria**
- Complete Quran coverage for the chosen edition is validated.
- Offline reading works.
- Source and translation attribution are visible.

### Phase 4 — Hadith library

**Deliverables**
- Rights-approved Bukhari and Muslim data.
- Arabic-English reader.
- Collection/book/chapter navigation where verified.
- Source reference handling.
- Completeness and duplicate checks.
- Local search.

**Exit criteria**
- Edition and numbering are documented.
- No unresolved critical text-integrity or rights issue remains.

### Phase 5 — Discovery and editorial taxonomy

**Deliverables**
- Reviewed category taxonomy.
- Reviewed category-to-content mappings.
- Locally personalized feed.
- Diversity and repetition rules.
- Topic filters and source-context navigation.

**Exit criteria**
- Every card resolves to a real source record.
- Editorial review status is documented.
- Users can adjust or reset preferences.

### Phase 6 — Visual engine and sharing

**Deliverables**
- Seeded procedural generator.
- Curated visual families.
- Contrast-aware composition.
- Parameter caching.
- Share-card export.
- Plain-text fallback.

**Exit criteria**
- Visual tests pass.
- Exported text is complete and accurate.
- Performance is acceptable on target devices.

### Phase 7 — Hardening and closed testing

**Deliverables**
- Accessibility and localization pass.
- Offline and update-failure testing.
- Performance profiling.
- Content QA report.
- Privacy/dependency audit.
- Store assets and support information.

**Exit criteria**
- Release checklist passes.
- No open critical rights, content, privacy, or data-loss issue.

### Phase 8 — Public Android launch

**Deliverables**
- Signed release build.
- Accurate store listing and offline requirements.
- Privacy policy and support contact.
- Optional donation link.
- Versioned content correction/update process.
- Feedback triage process.

**Exit criteria**
- Fresh install completes the documented setup.
- Core reading works offline after content provisioning.
- Support and correction reporting are operational.

---

## 19. AI-agent work breakdown

Use agents with explicit boundaries. Do not ask an agent to invent, scrape, or silently acquire religious datasets.

### Agent A — Product and UX
- Implement navigation, screens, states, and accessibility.
- Use synthetic fixtures until real content is approved.
- Never invent religious quotations.

### Agent B — Rights and provenance
- Research provider terms and translation rights.
- Produce a resource-by-resource rights matrix with source links and review dates.
- Do not mark content cleared based only on public accessibility.

### Agent C — Data architecture
- Implement schema, repositories, migrations, import validation, and update safety.
- Use synthetic fixtures.
- Preserve source IDs and edition metadata.

### Agent D — Visual engine
- Implement seeded backgrounds, palettes, contrast checks, caching, and profiling.
- Keep generation independent from religious interpretation.

### Agent E — Content QA tooling
- Build count, missing-reference, Unicode, duplicate, and sample-comparison checks.
- Never automatically modify source text.

### Agent F — Testing and release
- Implement offline integration, widget/golden, performance, and release-checklist tests.
- Verify behavior with networking disabled.

### Coordination rules
- Maintain one shared architecture document and decision log.
- Agree on schema and interfaces before parallel work.
- Require code review for Arabic rendering, content parsing, and update logic.
- Keep licensed source data out of public repositories unless explicitly permitted.
- Never turn unresolved rights questions into assumptions.

---

## 20. Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Translation or dataset rights unclear | Legal and distribution risk | Written permission/rights matrix before shipping |
| Offline provider rules misunderstood | Compliance risk | Follow exact documented sync/storage method |
| Incomplete Hadith data or numbering mismatch | Accuracy and trust risk | Validate against named edition; document numbering |
| Categories remove source context | Misleading interpretation | Human review, relationship labels, context links |
| Arabic marks render incorrectly | Serious readability issue | Font coverage and device tests |
| Backgrounds reduce contrast | Accessibility failure | Contrast checks, scrim, plain theme |
| Blur causes jank | Poor UX | Limit effects, cache parameters, profile |
| Update interrupted | Corrupt local data | Staging, checksums, transaction, rollback |
| Too many languages expand scope | Delayed launch | Arabic + English first; add verified editions incrementally |
| Donation flow creates policy/privacy issues | Launch delay | Optional flow; review current policies and disclosures |
| App package grows too large | Installation friction | Measure real assets and choose permitted packaging strategy |

---

## 21. Release acceptance checklist

### Product
- [ ] No ads, subscriptions, or paid feature gates.
- [ ] No account required.
- [ ] Minimal onboarding.
- [ ] Quran, Hadith, discovery, search, saved items, settings, and sharing work.
- [ ] Manual preferences can be changed and reset.
- [ ] Empty, loading, and error states are handled.

### Content and rights
- [ ] Quran source and edition documented.
- [ ] Every translation’s rights and attribution documented.
- [ ] Hadith provenance, edition, and completeness verified.
- [ ] Offline storage/distribution rights verified for every shipped resource.
- [ ] Provider-specific sync rules implemented.
- [ ] Editorial mappings reviewed.
- [ ] Content integrity report passes.
- [ ] Correction/update process documented.

### Visuals and accessibility
- [ ] Procedural backgrounds are deterministic and contrast-tested.
- [ ] Plain high-legibility theme exists.
- [ ] Arabic shaping and diacritics tested.
- [ ] Text scaling works.
- [ ] Cards preserve complete text and references.
- [ ] Low-end Android performance tested.

### Engineering and privacy
- [ ] No confidential credentials in the app binary.
- [ ] Database migrations tested.
- [ ] Offline integration tests pass.
- [ ] Interrupted updates recover safely.
- [ ] Dependency licenses reviewed.
- [ ] Privacy policy matches actual behavior.
- [ ] Donation flow is optional and clearly disclosed.
- [ ] Any diagnostics or analytics are disclosed accurately.

---

## 22. Decisions still open

1. Exact Quran Arabic source and script edition.
2. Exact English Quran translation and offline redistribution rights.
3. Exact Arabic and English editions for Bukhari and Muslim.
4. Whether the selected Hadith source permits offline bundling or downloadable copies.
5. Whether Quran Foundation Content Sync is appropriate for each intended resource.
6. Initial content packaging and update model.
7. Additional language rollout order.
8. Who reviews category mappings and content corrections.
9. Donation provider and current Play Store policy implications.
10. Minimum Android version and performance budget.

Use synthetic content for UI and visual work while resolving these. Do not ship unapproved content to meet a deadline.

---

## 23. Definition of success

Optimize for trust and usefulness, not raw scrolling time.

Potential success measures:
- Users can find relevant source material in a few steps.
- Users can verify the reference of a shared quote.
- Reading position is restored reliably.
- Search is useful offline.
- Language and text-size controls are easy to find.
- The app is responsive on modest Android devices.
- Users can identify the source and translation edition.
- No critical text-integrity defect exists at release.
- No core reading flow depends on donation, account, or network.

Avoid collecting detailed religious reading histories for analytics. Usability testing can answer product questions without building remote profiles of what users read.

---

## 24. Reference links

Review current provider terms immediately before implementation and release; terms and APIs may change.

### Quran Foundation
- Developer Terms: https://api-docs.quran.com/legal/developer-terms/
- Content Sync getting started: https://api-docs.quran.com/docs/tutorials/content-sync/getting-started/
- Offline cache patterns: https://api-docs.quran.com/docs/tutorials/content-sync/offline-cache-patterns/
- FAQ: https://api-docs.quran.com/docs/tutorials/faq/
- Content API quickstart: https://api-docs.quran.com/docs/quickstart/
- API reference: https://api-docs.quran.com/docs/api-reference/

### Hadith source investigation
- Sunnah.com: https://sunnah.com/
- Sunnah.com API: https://sunnah.com/developers

These are research starting points, not proof that all required Hadith content is licensed for offline redistribution.

### Flutter
- Architecture guide: https://docs.flutter.dev/app-architecture/guide
- Offline-first pattern: https://docs.flutter.dev/app-architecture/design-patterns/offline-first
- SQL persistence: https://docs.flutter.dev/app-architecture/design-patterns/sql

---

## Final direction

Build a **trustworthy offline library first, discovery second, and a beautiful visual layer that supports both**.

The visual engine can make the app distinctive. Local-first architecture can make it dependable. Verified source data, careful editorial categorization, and transparent rights are what make it worthy of users’ trust.

Start Phase 0 and the visual prototype in parallel. Use synthetic fixtures for design and performance work while real-content rights are reviewed. Do not treat a polished interface as evidence that the content pipeline is ready.
