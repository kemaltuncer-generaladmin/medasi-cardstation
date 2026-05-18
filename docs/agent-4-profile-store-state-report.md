# Agent 4 Profile Store State Report

## Paket Fiyat Doğrulama Matrisi

| Paket | Beklenen | Uygulama gösterimi | Durum |
| --- | ---: | ---: | --- |
| 10 MC | 40 TL | 40 TL | Doğrulandı |
| 20 MC | 65 TL | 65 TL | Doğrulandı |
| 50 MC | 180 TL | 180 TL | Doğrulandı |
| Weekly | 100 TRY | 100 TRY | Doğrulandı |
| Monthly | 500 TRY | 500 TRY | Doğrulandı |

Store ekranı artık bilinen QA paketlerini doğrulanmış katalogdan gösterir. Backend `store_products` veya `products` tablosundan ek aktif ürün dönerse bilinen katalog dışındaki ürünler listeye eklenir; bilinen beş paketin fiyatı lokal doğrulanmış katalogla sabitlenir.

## Logout / Protected Route Analizi

- Logout akışı `ProfileScreen._signOut()` içinde Supabase sign-out sonrası login route'una temiz stack ile döner.
- Protected route guard `SourceBaseApp._AuthProtectedRoute` içinde build-time session/profile/email durumunu kontrol eder.
- Runtime 401 sorunu workspace bootstrap sırasında oluşabiliyordu. `DriveWorkspaceScreen._load()` artık `UNAUTHORIZED` / 401 durumunu teknik hata paneline düşürmeden session temizleyip login ekranına yönlendirir.
- `SourceBaseApiException` için `isUnauthorized` helper eklendi.

## Payment / Refund Hata Mesajı Analizi

- Payment link çağrısı frontend'de `sourcebase` edge function'a `purchase_medasicoin` action'ı ile yapılıyor.
- Backend `supabase/functions/sourcebase/index.ts` içinde bu action yok; mevcut beklenen backend yanıtı 400 `UNKNOWN_ACTION`.
- Frontend artık bu durumda kullanıcıya "kartından ücret alınmadı" bilgisini içeren net ödeme linki hatası gösterir.
- Fake success kaldırıldı: checkout URL veya paid status yoksa bakiye yenileme / başarı mesajı çalışmaz.
- Refund/MC iade mesajı workspace hata normalize katmanında netleştirildi: işlem tamamlanamazsa rezerve MC varsa otomatik iade edileceği belirtilir.

## Değişen Dosyalar

- `lib/features/profile/presentation/screens/profile_screen.dart`
- `lib/features/drive/presentation/screens/drive_workspace_screen.dart`
- `lib/features/drive/data/sourcebase_drive_api.dart`
- `maestro/flows/profile_store_agent4.yaml`
- `docs/agent-4-profile-store-state-report.md`

## Test Sonuçları

- `flutter analyze`: geçti, no issues.
- `flutter test`: geçti, 5/5 test.
- `flutter build web`: geçti.
- `git diff --check`: geçti.
- `deno check supabase/functions/sourcebase`: çalıştırılmadı; backend action/source dosyası değişmedi.
- Secret/token/private key diff kontrolü: eşleşme yok.

## Maestro Mini Flow

- Flow eklendi: `maestro/flows/profile_store_agent4.yaml`
- Çalıştırma denemesi: başarısız.
- Neden: lokal ortamda Java Runtime bulunamadı; Maestro CLI Java başlatamadı.

## Kalan P0 / P1 Riskler

- P0: Yok.
- P1: Gerçek ödeme linki için backend `purchase_medasicoin` action/provider entegrasyonu hala eksik; frontend bunu kullanıcı dostu hata olarak gösteriyor.
- P1: Maestro flow cihaz + Java Runtime olan ortamda tekrar çalıştırılmalı.
