# Agent 2 BaseForce Report

## Teşhis Özeti

- BaseForce API client: `SourceBaseDriveApi` (`lib/features/drive/data/sourcebase_drive_api.dart`) üzerinden `sourcebase` Edge Function çağrılıyor.
- Üretim hattı: `create_generation_job -> process_generation_job -> get_job_status/get_generated_content` korunuyor.
- Backend job type seti: `flashcard`, `quiz`, `summary`, `exam_morning_summary`, `algorithm`, `comparison`, `podcast`, `clinical_scenario`, `learning_plan`, `infographic`, `mind_map`.
- BaseForce kapsamındaki aktif modlar: Flashcard Fabrikası, Soru Fabrikası, Sınav Sabahı Özeti, Akış Şeması / Algoritma, Karşılaştırma Tablosu.
- Drive source selector tüm BaseForce modları için ortak. `completed` ve 0 KB olmayan kaynaklar seçilebilir; 0 KB, failed, processing, uploading, draft kaynaklar disabled görünür.
- Queued kalma riski en çok provider/process hatası, timeout veya deploy edilmemiş `exam_morning_summary` DB constraint’i tarafındaydı.

## Mod Bazlı Durum Matrisi

| Mod | Job type | Kaynak seçimi | Count | Quality tier | MC görünümü | Sonuç görünürlüğü | Durum |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Flashcard Fabrikası | `flashcard` | Ortak selector, invalid kaynak disabled | UI stepper, 1-100 clamp | difficulty -> economy/standard/premium | Üretim öncesi güvenli hesaplama metni, sonuç meta alanı | Polling sonrası sonuç ekranı | Stabilize edildi |
| Soru Fabrikası | `quiz` | Ortak selector, invalid kaynak disabled | UI stepper, 1-100 clamp | difficulty -> economy/standard/premium | Üretim öncesi güvenli hesaplama metni, sonuç meta alanı | Polling sonrası sonuç ekranı | Stabilize edildi |
| Sınav Sabahı Özeti | `exam_morning_summary` | Ortak selector, invalid kaynak disabled | Yok, tek özet | `standard` | Üretim öncesi güvenli hesaplama metni, sonuç meta alanı | Polling sonrası sonuç ekranı | Eksik kaynak gate ve job type düzeltildi |
| Akış Şeması / Algoritma | `algorithm` | Ortak selector, invalid kaynak disabled | Yok, tek çıktı | UI kalite seçimi | Üretim öncesi uyarı, sonuç meta alanı | Özel algoritma result view | Stabilize edildi |
| Karşılaştırma Tablosu | `comparison` | Ortak selector, invalid kaynak disabled | Yok, tek çıktı | UI kalite seçimi | Üretim öncesi uyarı, sonuç meta alanı | Özel karşılaştırma result view | Stabilize edildi |

## Değişen Dosyalar

- `lib/features/baseforce/presentation/screens/baseforce_screen.dart`
- `supabase/functions/sourcebase/actions/ai-generation.ts`
- `supabase/functions/sourcebase/services/job-processor.ts`
- `supabase/functions/sourcebase/services/vertex-ai.ts`
- `supabase/migrations/20260519090000_allow_exam_morning_generation_jobs.sql`
- `maestro/flows/baseforce_agent2.yaml`
- `docs/agent-2-baseforce-report.md`

## Test Sonuçları

- `flutter analyze`: geçti, no issues found.
- `flutter test`: geçti, 5 test passed.
- `flutter build web`: geçti.
- `deno check supabase/functions/sourcebase`: geçti. İlk deneme macOS `._*` metadata dosyaları nedeniyle parse aşamasında durdu; metadata dosyaları temizlenip tekrar çalıştırıldı.
- `git diff --check`: geçti.

## Maestro Mini Flow

- Flow dosyası: `maestro/flows/baseforce_agent2.yaml`
- Komut: `maestro test maestro/flows/baseforce_agent2.yaml`
- Sonuç: çalıştırılamadı.
- Neden: yerel ortamda Java Runtime bulunamadı; Maestro CLI Java Runtime hatasıyla başlamadan çıktı.

## Kalan P0/P1 Riskler

- P0 yok.
- P1: Üretimlerin gerçek uçtan uca doğrulaması canlı Supabase/GCS/AI provider ve gerçek kullanıcı oturumu gerektiriyor.
- P1: Eski production DB’lerde yeni `exam_morning_summary` constraint migration uygulanmadan Sınav Sabahı Özeti job oluşturma başarısız olur.

## Agent 1 Drive’a Bağımlı Noktalar

- Drive ingestion tamamlanmış kaynakları `DriveItemStatus.completed` ve 0 KB olmayan size label ile sağlamalı.
- `drive_files` kayıtlarında `gcs_bucket`, `gcs_object_name`, mime/file type ve owner bilgisi doğru olmalı; BaseForce üretimi backend extraction hattında buna bağımlı.
- 0 KB, failed, processing, uploading ve draft durumlarının UI modeline doğru yansıması Agent 1 Drive pipeline verisine bağlı.
