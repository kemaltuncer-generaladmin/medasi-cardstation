# AJAN 2 — DRIVE / STORAGE / INGESTION RAPORU

## 1. Branch ve Repo Doğrulaması

- Repo kökü: `/Volumes/driveand/sourcebase-agents/sb-drive`
- Branch: `agent/drive-storage-ingestion`
- Status:
  - `M lib/features/drive/data/drive_models.dart`
  - `M lib/features/drive/data/drive_repository.dart`
  - `M lib/features/drive/presentation/screens/drive_search_screen.dart`
  - `M lib/features/drive/presentation/screens/drive_workspace_screen.dart`
  - `M lib/features/drive/presentation/screens/file_detail_screen.dart`
  - `M lib/features/drive/presentation/screens/uploads_screen.dart`
  - `M lib/features/drive/presentation/widgets/drive_ui.dart`

## 2. İncelediğim Alanlar

- Drive upload
- File status
- File detail
- Upload listesi
- Search status UI
- Source readiness
- Scanned PDF/OCR mesajları
- PPT/PPTX/DOC/DOCX kullanıcı mesajları

## 3. Bulduğum Sorunlar

- Failed/processing/uploading/draft dosyalar bazı ekranlarda sadece kısa status etiketiyle görünüyordu; kullanıcı dosyanın neden hazır olmadığını veya ne yapması gerektiğini net göremiyordu.
- Extraction hata nedeni Drive UI tarafına yeterince taşınmıyordu. Scanned PDF/OCR, eski PPT/DOC, 0 KB, unsupported ve no-readable-text durumları kullanıcı açısından ayrışmıyordu.
- File detail ekranında BaseForce ve SourceLab girişleri, kaynak hazır değilken de aktif aksiyon gibi görünüyordu.
- Upload listesinde failed satırlar her zaman gerçek hata nedenini göstermeyebiliyordu.
- Upload listesi üst özet paneli dar mobil genişlikte yatay taşma riski taşıyordu.
- Bilinmeyen file status fallback'i hazır kaynak gibi yorumlanma riski taşıyordu.
- Upload adımı hataları kullanıcı mesajına teknik upload-step kodu ekleyebiliyordu.

## 4. Yaptığım Değişiklikler

- Dosya yolu: `lib/features/drive/data/drive_models.dart`
  - Ne değişti: `DriveFile` modeline `statusMessage` alanı ve `isReadyForGeneration` getter'ı eklendi.
  - Neden değişti: Dosya durumunun kullanıcıya tek bir status etiketiyle değil, açıklayıcı readiness mesajıyla taşınması gerekiyordu.
  - Kullanıcıya etkisi: Kullanıcı dosyanın hazır, işleniyor, başarısız, taslak veya geçersiz olduğunu daha net görür.
  - Telefon/tablet/web etkisi: Veri modeli değişikliği; layout etkisi yok.

- Dosya yolu: `lib/features/drive/data/drive_repository.dart`
  - Ne değişti: Backend row metadata'sındaki `extractionErrorCode` ve `extractionError` değerleri Drive UI için Türkçe `statusMessage` değerlerine çevrildi. Bilinmeyen status fallback'i `draft` yapıldı.
  - Neden değişti: Scanned PDF/OCR, eski PPT/DOC, 0 KB, unsupported ve boş metin durumları profesyonel ve eylem odaklı mesajlarla ayrışmalıydı. Bilinmeyen status hazır kaynak gibi görünmemeliydi.
  - Kullanıcıya etkisi: Kullanıcı OCR gerektiğini, PPTX/DOCX olarak yeniden kaydetmesi gerektiğini veya dosyanın neden kaynak olarak kullanılamadığını anlayabilir.
  - Telefon/tablet/web etkisi: Mesajlar UI tarafından ellipsis/wrap ile kullanılıyor; doğrudan layout kırıcı veri eklenmedi.

- Dosya yolu: `lib/features/drive/presentation/screens/file_detail_screen.dart`
  - Ne değişti: Hazır olmayan dosyalar için readiness notice eklendi. Üretim alanındaki boş durum mesajları status'a göre ayrıştırıldı. BaseForce/SourceLab girişleri sadece `isReadyForGeneration` true iken aktif olacak şekilde pasifleştirildi. Dosya özeti grid'i sabit `mainAxisExtent` ile daha stabil hale getirildi.
  - Neden değişti: Kullanıcı hazır olmayan kaynaktan üretim başlatabileceğini düşünmemeli ve dosyanın sonraki adımını açıkça görmeliydi.
  - Kullanıcıya etkisi: Hazır olmayan dosyada üretim merkezleri kilitli görünür; kullanıcı nedenini aynı kart üzerinde görür.
  - Telefon/tablet/web etkisi: Kompakt görünümde üretim merkezleri zaten kolon dizilimine geçiyor; sabit grid yüksekliği mobil/tablet/web'de metin taşması riskini azaltır.

- Dosya yolu: `lib/features/drive/presentation/screens/uploads_screen.dart`
  - Ne değişti: Upload özet paneli mobilde kolon düzenine geçecek şekilde `LayoutBuilder` ile düzenlendi. Failed upload satırları `errorLabel` yoksa `file.statusMessage` gösteriyor. “Tamamlandı” dili “Hazır” olarak güncellendi.
  - Neden değişti: Upload listesi dar ekranda taşmamalı ve failed dosya için gerçek neden görünmeliydi.
  - Kullanıcıya etkisi: Kullanıcı upload/metin çıkarımı/hata durumlarını daha net takip eder.
  - Telefon/tablet/web etkisi: Mobilde yatay overflow riski azaltıldı; tablet/web'de mevcut iki kolonlu sunum korundu.

- Dosya yolu: `lib/features/drive/presentation/screens/drive_search_screen.dart`
  - Ne değişti: Status filtre dili “Hazır” olarak güncellendi. Hazır olmayan search sonuçlarında kısa `statusMessage` gösterildi.
  - Neden değişti: Search sonuçlarında dosya hazır değilse sadece status pill yeterli değildi.
  - Kullanıcıya etkisi: Kullanıcı arama sonucunda dosyanın neden üretime uygun olmadığını hızlıca anlar.
  - Telefon/tablet/web etkisi: Mesaj tek satır ellipsis ile sınırlandı; taşma riski düşük tutuldu.

- Dosya yolu: `lib/features/drive/presentation/screens/drive_workspace_screen.dart`
  - Ne değişti: Upload step hataları `_UploadStepFailure` ile orijinal hata nedeni korunarak taşındı. Local upload failure durumunda `statusMessage` dolduruldu.
  - Neden değişti: Kullanıcıya teknik `Kod: upload-session/storage-upload/complete-upload` eki yerine gerçek hata nedeni gösterilmeli.
  - Kullanıcıya etkisi: Hata mesajları daha temiz ve eyleme dönük görünür.
  - Telefon/tablet/web etkisi: Layout etkisi yok.

- Dosya yolu: `lib/features/drive/presentation/widgets/drive_ui.dart`
  - Ne değişti: `StatusPill` içinde completed label'ı “Tamamlandı” yerine “Hazır” yapıldı.
  - Neden değişti: Drive kaynak bağlamında “Hazır”, dosyanın üretime uygun olduğunu daha net anlatıyor.
  - Kullanıcıya etkisi: Kullanıcı hazır kaynakları daha hızlı ayırt eder.
  - Telefon/tablet/web etkisi: Kısa label olduğu için responsive risk eklemez.

## 5. Değişen Dosyalar

- `lib/features/drive/data/drive_models.dart`
- `lib/features/drive/data/drive_repository.dart`
- `lib/features/drive/presentation/screens/drive_search_screen.dart`
- `lib/features/drive/presentation/screens/drive_workspace_screen.dart`
- `lib/features/drive/presentation/screens/file_detail_screen.dart`
- `lib/features/drive/presentation/screens/uploads_screen.dart`
- `lib/features/drive/presentation/widgets/drive_ui.dart`

## 6. Test ve Kontrol Komutları

- `pwd`
  - Sonuç: `/Volumes/driveand/sourcebase-agents/sb-drive`
- `git rev-parse --show-toplevel`
  - Sonuç: `/Volumes/driveand/sourcebase-agents/sb-drive`
- `git branch --show-current`
  - Sonuç: `agent/drive-storage-ingestion`
- `git status --short`
  - Sonuç: Yukarıdaki 7 Drive dosyasında değişiklik var.
- `deno test --no-check --allow-all supabase/functions/sourcebase/services/file-types.test.ts supabase/functions/sourcebase/services/extraction.test.ts`
  - Sonuç: Geçti, 10 test geçti.
- `deno check supabase/functions/sourcebase`
  - Sonuç: Geçti.
- `git diff --check`
  - Sonuç: Geçti, whitespace/diff format hatası yok.
- `flutter analyze`
  - Sonuç: Çalıştırılamadı; bu ortamda `flutter` komutu bulunamadı.
- `which dart`
  - Sonuç: `dart not found`
- `which flutter`
  - Sonuç: `flutter not found`

Not: Deno extraction testi `test/fixtures/sourcebase/valid_cmap_pdf.pdf` fixture artefaktını çalışma ağacında oluşturdu; rapora dahil edilmeden temizlendi.

## 7. Kalan Riskler

- Flutter analyze çalıştı mı?
  - Hayır. Bu ortamda `flutter` ve `dart` komutları PATH'te yoktu.
- Ready olmayan kaynaklar hala bir yerde seçilebilir mi?
  - Drive file detail tarafında BaseForce/SourceLab girişleri pasifleştirildi. Folder, SourceLab ve BaseForce tarafında mevcut readiness kontrolleri incelendi; ancak bu patch BaseForce/SourceLab business logic'e dokunmadığı için QA ajanının uçtan uca kontrol etmesi gerekir.
- Extraction hata mesajları her yerde görünür mü?
  - Drive file detail, upload listesi ve search sonuçlarında görünür hale getirildi. Diğer Drive kart/listelerinde status pill görünümü korunmuştur; gerekirse QA sonrası ek küçük iyileştirme yapılabilir.
- Mobil/tablet/web canlı test gerekli mi?
  - Evet. Mobil overflow riski azaltıldı ancak Flutter analyzer ve gerçek cihaz/simülatör/web ekran testi bu ortamda çalıştırılamadı.

## 8. Diğer Ajanlara Handoff

- BaseForce ajanı:
  - Drive tarafında `DriveFile.isReadyForGeneration` kullanılabilir hale geldi. BaseForce kendi business logic'ini değiştirmeden mevcut status kontrollerini korumalı. Hazır olmayan dosya BaseForce kaynak seçicide hala aksiyon başlatabiliyorsa UI tarafında ayrıca kapatılmalı.
- SourceLab ajanı:
  - Drive dosyalarında `statusMessage` artık OCR, legacy PPT/DOC, 0 KB ve processing/draft nedenlerini taşıyor. SourceLab source picker bu mesajları kullanarak disabled reason dilini daha ayrıntılı gösterebilir.
- QA ajanı:
  - Text tabanlı PDF, scanned PDF, PPTX, eski PPT, DOCX, eski DOC, 0 KB, failed, processing, uploading ve draft senaryolarını Drive file detail, upload listesi, search ve generation center girişlerinde test etmeli.
  - Telefon, tablet ve web viewport'larında upload listesi üst paneli, file detail readiness notice ve search result satırları overflow açısından kontrol edilmeli.

## 9. Merge Kararı

- Merge için güvenli mi?
  - Şu an tam güvenli değil.
- Hangi şartlarla güvenli?
  - Flutter/Dart statik kontrolü ve temel responsive smoke testler geçerse güvenli kabul edilebilir.
- Hangi testler geçmeli?
  - `flutter analyze`
  - `flutter test`
  - Drive upload/file detail/search/upload listesi için mobil, tablet ve web smoke test
  - Text PDF, scanned PDF/OCR, PPTX, eski PPT, DOCX, eski DOC ve 0 KB fixture akışları
  - `deno test --no-check --allow-all supabase/functions/sourcebase/services/file-types.test.ts supabase/functions/sourcebase/services/extraction.test.ts`
  - `deno check supabase/functions/sourcebase`
  - `git diff --check`
