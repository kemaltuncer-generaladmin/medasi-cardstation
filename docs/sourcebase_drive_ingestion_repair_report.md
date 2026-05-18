# SourceBase Drive Ingestion Repair Report

Tarih: 2026-05-19

## 1. Kök Neden Analizi

- Dosya tipi kararları upload validation, client fallback MIME mapping ve extraction router arasında merkezi değildi.
- `.doc` upload tipi backend tarafında desteklenen listeye alınmamıştı; bu yüzden legacy DOC dosyaları doğru sınırlı-destek mesajı yerine unsupported davranışına düşebiliyordu.
- MIME kontrolü bazı gerçek dünya upload senaryoları için fazla katıydı. `application/octet-stream` veya zip tabanlı OOXML dosyalarında extension fallback ihtiyacı vardı.
- Extraction hataları ortak kullanıcı dostu kodlarla normalize edilmiyordu. PDF boş metin, scanned/image PDF ve parse failure ayrımı net değildi.
- `complete_upload` extraction fail durumunu `ok` response içinde `processing_failed` olarak dönebiliyordu; client bunu başarı akışı gibi yorumlayabiliyordu.

## 2. Değiştirilen Dosyalar

- `supabase/functions/sourcebase/services/file-types.ts`
- `supabase/functions/sourcebase/services/file-types.test.ts`
- `supabase/functions/sourcebase/services/extraction.ts`
- `supabase/functions/sourcebase/services/extraction.test.ts`
- `supabase/functions/sourcebase/actions/ai-generation.ts`
- `supabase/functions/sourcebase/index.ts`
- `lib/features/drive/data/drive_upload_payload.dart`
- `lib/features/drive/data/drive_upload_service_io.dart`
- `lib/features/drive/data/drive_upload_service_web.dart`
- `lib/features/drive/presentation/screens/drive_workspace_screen.dart`
- `test/fixtures/sourcebase/*`

## 3. Desteklenen Format Matrisi

| Format | Status | Extractor | Notes |
|---|---|---|---|
| PDF | Destekleniyor | Pure TS PDF text operators + Flate stream pass | Text PDF non-empty test edildi. Scanned PDF OCR mesajına düşer. |
| PPTX | Destekleniyor | OOXML zip parser, `ppt/slides` + `notesSlides` | Slide sırası korunur, slayt başlığı eklenir. |
| PPT | Sınırlı destek | Legacy binary parser yok | Kullanıcıya `.pptx` olarak kaydedip tekrar yükleme mesajı döner. |
| DOCX | Destekleniyor | OOXML zip parser, `document.xml` + header/footer | Paragraph separation korunur. |
| DOC | Sınırlı destek | Legacy binary parser yok | Kullanıcıya `.docx` olarak kaydedip tekrar yükleme mesajı döner. |

## 4. Korunan Güvenlik Kontrolleri

- `complete_upload` halen GCS object metadata doğrulaması yapıyor.
- User object path `user/{userId}/drive/uploads/{uuid}/{safeName}` prefix ve filename ile doğrulanıyor.
- Object missing ve 0 KB object completed/ready olamıyor.
- Başka kullanıcı path’i `FORBIDDEN_OBJECT` ile reddediliyor.
- Service account JSON, signed URL, token veya private key loglanmadı.
- AI pipeline’daki `create_generation_job -> process_generation_job -> polling` akışı değiştirilmedi.

## 5. complete_upload Fake Upload Koruması

- `getGcsObjectMetadata` object varlığını GCS JSON API ile doğrulamaya devam ediyor.
- Missing object artık `FILE_OBJECT_MISSING` koduna normalize ediliyor.
- `size <= 0` object artık `FILE_OBJECT_EMPTY` koduna normalize ediliyor.
- Content type doğrulaması canonical, generic MIME fallback ve related Office mismatch mantığıyla yapılıyor.
- Extraction fail olursa row `ai_status=failed` olarak patchleniyor ve action hata fırlatıyor; client bunu başarı gibi göstermiyor.

## 6. process_generation_job Patch Durumu

- `f4d2e58` ile gelen fire-and-forget kaldırılmış pipeline korunmuştur.
- `create_generation_job` sadece queued job + MC reservation döndürmeye devam eder.
- `process_generation_job` ayrı action olarak kalmıştır.
- Structured AI logging çağrıları korunmuştur.
- Provider/process failure ve MC refund path kodlarına dokunulmamıştır.

## 7. Test Sonuçları

- `deno test --no-check --allow-all supabase/functions/sourcebase/services/file-types.test.ts supabase/functions/sourcebase/services/extraction.test.ts`: geçti, 9/9.
- `deno check supabase/functions/sourcebase`: geçti.
- `deno check supabase/functions/ai-services`: geçti.
- `flutter analyze`: geçti.
- `flutter test`: geçti.
- `flutter build web`: geçti.
- `git diff --check`: geçti.

## 8. Canlı Deploy İçin Ayrı Komutlar

Canlı deploy bu patch kapsamında yapılmadı. Edge Functions deploy için ayrıca açık onay gerekir.

Örnek ayrı adımlar:

```bash
supabase functions deploy sourcebase
supabase functions deploy ai-services
```

Coolify volume tabanlı canlı ortam kullanılıyorsa Edge Functions web deploy’dan ayrı senkronize edilmelidir. `rsync --delete` kullanılacaksa önce canlı function backup alınmalıdır.

## 9. Kalan Riskler

- Full binary `.ppt` ve `.doc` parsing Edge runtime içinde güvenilir şekilde eklenmedi.
- PDF extractor pure TS seviyesinde text operators ve Flate stream parsing yapıyor; çok kompleks font encoding/CMap kullanan bazı PDF’lerde OCR veya daha gelişmiş parser gerekebilir.
- GCS complete_upload integration testi canlı bucket gerektirdiği için local unit seviyesinde doğrulandı; canlı QA ayrı yapılmalıdır.

## 10. Legacy PPT/DOC Teknik Not

Eski `.ppt` ve `.doc` formatları OLE Compound File binary formatıdır. Edge Function runtime’da external binary araç veya ağır native parser kullanmadan güvenilir metin çıkarımı risklidir. Bu nedenle bu patch bu formatları bilinmeyen dosya gibi göstermeyip açık sınırlı-destek mesajı döndürür:

- PPT: “Eski .ppt formatı şu anda sınırlı destekleniyor. Lütfen dosyayı .pptx olarak kaydedip tekrar yükleyin.”
- DOC: “Eski .doc formatı şu anda sınırlı destekleniyor. Lütfen dosyayı .docx olarak kaydedip tekrar yükleyin.”
