# SourceBase UI Audit - Aşama 1

Tarih: 2026-05-20

Kapsam: `lib/app`, `lib/core`, `lib/features/auth`, `lib/features/drive`, `lib/features/baseforce`, `lib/features/sourcelab`, `lib/features/central_ai`, `lib/features/profile`.

Kapsam dışı: Qlinik tarafına dokunulmadı. Backend, Supabase, Edge Functions, API contract, auth iş akışları ve ödeme mantığı değiştirilmedi.

## Dosya Bazlı Bulgular

| Dosya / Bölge | Problem |
| --- | --- |
| `lib/core/widgets/responsive_layout.dart` | Breakpoint tanımı hedefle uyumlu olsa da max content width değerleri düşük ve tokenlaşmamıştı. Safe-area aware page padding ve responsive value helper yoktu. |
| `lib/features/drive/presentation/widgets/drive_ui.dart` | `WorkspaceScroll`, `WorkspacePage` ile birlikte yatay paddingi iki kez uyguluyordu. Empty state lokal ve uzun metinleri ellipsis ile kesme riski taşıyordu. |
| `lib/features/drive/presentation/widgets/sourcebase_bottom_nav.dart` | Bottom nav overlay olarak konumlanıyor. İçerik paddingi vardı ama çok yüksek buffer tutarsız boşluk üretiyordu. Etiketler mobilde fazla uzundu. |
| `lib/features/drive/presentation/screens/drive_workspace_screen.dart` | Shell ayrımı `responsive_builder` içinde lokal üç layout class'ı ile yönetiliyordu; ortak `ResponsiveScaffold` yoktu. Loading/error placeholder shell paddinginden bağımsızdı. |
| `lib/features/drive/presentation/screens/drive_home_screen.dart` | Çok sayıda lokal card/hero/action satırı var. Mobilde yan yana action Row ve geniş hero alanları ilk riskli bölgeler. |
| `lib/features/drive/presentation/screens/course_detail_screen.dart` | 1700+ satır içinde çok sayıda sabit spacing, lokal chip/card ve Row kombinasyonu var. Dosya satırları ve kontrol alanları küçük genişlikte taşma riski taşıyor. |
| `lib/features/drive/presentation/screens/folder_screen.dart` | Liste/grid görünüm geçişleri, header row ve dosya kartları farklı kırılım kuralları kullanıyor. Bazı bölücüler sabit yükseklik/genişlikte. |
| `lib/features/drive/presentation/screens/file_detail_screen.dart` | Üretim CTA alanları ve yatay preview listeleri mobilde sıkışabilir. Empty state tekrarları ortak değil. |
| `lib/features/drive/presentation/screens/uploads_screen.dart` | Upload durum kartları, retry/action alanları ve summary/action Row yapıları mobilde kırılmaya hassas. Kritik upload iş mantığına dokunulmamalı. |
| `lib/features/drive/presentation/screens/collections_screen.dart` | Preview + detay kartları desktop/tablet için iyi, ama mobilde sabit preview ölçüleri ve uzun metadata satırları taşma riski taşıyor. |
| `lib/features/drive/presentation/screens/drive_search_screen.dart` | Search input, sonuç satırı ve filtre alanları ayrı lokal stillerle yazılmış. Çok uzun dosya adları satırlarda sıkışabilir. |
| `lib/features/baseforce/presentation/screens/baseforce_screen.dart` | 9000+ satırlık tek dosyada çok sayıda sabit tablo, painter, geniş Row ve özel kart var. Mobilde ilk kırılacak ana modüllerden biri. Bu aşamada refactor edilmedi. |
| `lib/features/sourcelab/presentation/screens/source_lab_screen.dart` | 11000+ satırlık tek dosyada lokal empty/loading state, tool kartları, yatay selector ve üretim sonuç layoutları var. Mobil yoğunluk ve metin uzunluğu yüksek. |
| `lib/features/central_ai/presentation/screens/central_ai_screen.dart` | Mesaj composer, prompt chip listesi ve yatay öneri listeleri küçük ekranda yoğun. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | Profil, cüzdan, store ve settings kartları lokal `GlassPanel` / `_StatePanel` tekrarları ile yazılmış. Düşük riskli pilot için uygun. |
| `lib/features/auth/presentation/widgets/auth_widgets.dart` | Auth shell responsive davranıyor ancak sabit max width ve büyük dikey boşluklar küçük mobil yüksekliklerde sıkışabilir. Auth akışına bu aşamada dokunulmadı. |

## En Riskli 10 UI Problemi

1. `baseforce_screen.dart` ve `source_lab_screen.dart` çok büyük tek dosyalar; lokal layout kararları merkezi tokenlardan kopuk.
2. `WorkspaceScroll` + `WorkspacePage` çift yatay padding uyguluyordu; mobilde alan kaybı, desktopta düzensiz hizalama yaratıyordu.
3. Bottom nav overlay yapısı, tüm ekranların doğru bottom padding kullanmasına bağımlı.
4. Çok sayıda Row içinde uzun Türkçe başlık/metadata var; bazıları Wrap/Flexible kullanıyor, bazıları dosya adına göre taşabilir.
5. Empty/loading/error state tasarımları ekran bazında tekrar ediyor ve profesyonellik seviyesi değişiyor.
6. Card radius, padding ve shadow değerleri ekranlar arasında farklı.
7. Desktop içerik max width değerleri tutarsız; bazı ekranlar çok genişliyor, bazıları gereksiz dar kalıyor.
8. Mobilde CTA çiftleri bazı ekranlarda yan yana kalıyor; 390 px civarında etiketler ellipsis veya sıkışma riski taşıyor.
9. Auth ve store tarafında uzun açıklama metinleri kullanıcıyı boğuyor; Aşama 2'de sadeleştirilmeli.
10. Table/painter tabanlı BaseForce alanlarında sabit genişlik/yükseklikler mobil kırılıma hazır değil.

## Mobilde İlk Kırılacak Ekranlar

1. BaseForce ana üretim ve sonuç ekranları.
2. SourceLab araç seçimi, klinik senaryo builder ve sonuç ekranları.
3. Course detail dosya listesi + kontrol paneli.
4. Folder list/grid ekranı.
5. Collections preview kartları.
6. Profile store paket kartları.
7. Central AI composer ve öneri chip alanları.

## Ortak Component Olması Gereken Tekrarlar

- Card/panel: `GlassPanel`, lokal hero kartları, store paket kartları, Drive file/course kartları.
- Button: `SBPrimaryButton`, `SBSecondaryButton`, lokal `FilledButton` kullanımları.
- Input: Auth input, search input, dialog text input, Central AI composer input.
- Section header: `SectionTitle`, DriveTopBar alt başlıkları, Profile section başlıkları.
- Empty/loading/error: `EmptyState`, `_StatePanel`, `_LabEmptyState`, `_LabLoadingState`, `_EmptyBaseForceState`, workspace error placeholder.
- Page shell: `WorkspaceScroll`, auth shell, SourceLab/BaseForce scroll containerları.
- Content container: desktop max width, tablet max width, safe-area padding.

## Aşama 1 Kararı

Bu aşamada ekranlar komple yeniden tasarlanmadı. Ortak responsive helper, tokenlar, component altyapısı ve shell güvenliği kuruldu. Pilot uygulama düşük riskli profil/state alanları ve mevcut Drive empty state wrapper'ı ile sınırlı tutuldu.

## Aşama 2 Öncelik Önerisi

1. BaseForce: önce shell/section/card ayrımı, sonra tablo ve sonuç layoutları.
2. SourceLab: araç seçimi, builder formları, loading/empty/result state ayrımı.
3. Drive course/folder/file detail: dosya satırı ve CTA düzenleri.
4. Profile store paket kartları: ödeme mantığına dokunmadan sadece layout.
5. Central AI: composer, prompt chip ve mesaj bubble responsive düzeni.
