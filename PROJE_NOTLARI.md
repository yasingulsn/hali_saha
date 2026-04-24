# Halı Saha Uygulaması - Proje Notları

> Son güncelleme: 20 Nisan 2026

---

## Proje Genel Bakış

**Proje Adı:** Halı Saha Rezervasyon ve Maç Yönetim Uygulaması  
**Teknolojiler:**
- **Frontend:** Flutter (Dart SDK >=3.2.0 <4.0.0)
- **Backend:** Quarkus 3.17.5 (Java 21, Maven)
- **Veritabanı:** PostgreSQL (localhost:5432/halisaha)
- **Kimlik Doğrulama:** JWT (SmallRye JWT, RSA key pair)
- **State Management:** Provider (ChangeNotifier)
- **HTTP Client:** Dio
- **Token Saklama:** flutter_secure_storage

---

## Proje Yapısı

```
halisaha_1/
├── frontend/                          # Flutter mobil uygulama
│   └── lib/
│       ├── main.dart                  # Uygulama giriş noktası
│       ├── screens/
│       │   ├── splash_screen.dart     # Açılış ekranı
│       │   ├── login_screen.dart      # Giriş ekranı (modern kart)
│       │   ├── register_screen.dart   # Kayıt ekranı
│       │   ├── home_screen.dart       # Ana shell + Bottom Navigation
│       │   ├── saha_detay_screen.dart # Saha detay ekranı
│       │   ├── mac_olustur_screen.dart# Maç oluşturma ekranı (genişletilmiş)
│       │   ├── mac_detay_screen.dart  # Maç detay ekranı (genişletilmiş)
│       │   ├── arama_screen.dart      # Birleşik arama ekranı
│       │   ├── takim_ilanlari_screen.dart    # ★ Takım ilanları listele + detay
│       │   ├── takim_ilani_olustur_screen.dart # ★ Takım ilanı oluştur
│       │   └── tabs/
│       │       ├── kesfet_tab.dart    # Keşfet (Takım İlanları butonu eklendi)
│       │       ├── sahalar_tab.dart   # Sahalar (API bağlı)
│       │       ├── maclar_tab.dart    # Maçlar (Takım İlanı banneri eklendi)
│       │       └── profil_tab.dart    # Profil sekmesi
│       ├── services/
│       │   ├── api_client.dart        # Dio HTTP client
│       │   ├── auth_service.dart      # Auth API
│       │   ├── secure_storage_service.dart
│       │   ├── saha_service.dart      # Saha API servisi
│       │   ├── mac_service.dart       # Maç API servisi
│       │   ├── arama_service.dart     # Arama API servisi
│       │   └── takim_ilani_service.dart # ★ Takım ilanı API servisi
│       ├── providers/
│       │   └── auth_provider.dart     # Auth state
│       ├── models/
│       │   ├── token_response.dart    # TokenResponse, ApiResponse
│       │   ├── saha.dart             # Saha modeli
│       │   ├── mac.dart              # Mac + KatilimciBilgi modeli (genişletilmiş)
│       │   └── takim_ilani.dart      # ★ TakimIlani modeli
│       └── utils/
│           ├── theme.dart             # Tema (halısaha konsepti)
│           └── constants.dart         # API URL'leri + storage key'leri
│
├── backend/
│   └── src/main/java/com/halisaha/
│       ├── resource/
│       │   ├── AuthResource.java      # Auth endpoint'leri
│       │   ├── SahaResource.java      # Saha CRUD endpoint'leri
│       │   ├── MacResource.java       # Maç endpoint'leri
│       │   ├── AramaResource.java     # Birleşik arama endpoint'i
│       │   └── TakimIlaniResource.java # ★ Takım ilanı endpoint'leri
│       ├── service/
│       │   ├── AuthService.java       # Auth iş mantığı
│       │   ├── SahaService.java       # Saha iş mantığı
│       │   ├── MacService.java        # Maç iş mantığı (genişletilmiş)
│       │   └── TakimIlaniService.java # ★ Takım ilanı iş mantığı
│       ├── security/
│       │   ├── TokenService.java
│       │   └── PasswordService.java
│       ├── entity/
│       │   ├── Kullanici.java         # (disiplinPuani, tercihEdilenPozisyon eklendi)
│       │   ├── Isletme.java
│       │   ├── RefreshToken.java
│       │   ├── GirisGecmisi.java
│       │   ├── HesapKilitleme.java
│       │   ├── SifreSifirlama.java
│       │   ├── HaliSaha.java         # Halı saha entity
│       │   ├── Mac.java              # Maç entity (genişletilmiş)
│       │   ├── MacKatilimci.java     # Maç katılımcı entity
│       │   └── TakimIlani.java       # ★ Takım ilanı entity
│       ├── dto/
│       │   ├── ApiResponse.java
│       │   ├── TokenResponse.java
│       │   ├── LoginRequest.java
│       │   ├── KullaniciRegisterRequest.java
│       │   ├── IsletmeRegisterRequest.java
│       │   ├── RefreshTokenRequest.java
│       │   ├── SahaRequest.java       # Saha ekleme DTO
│       │   ├── SahaResponse.java      # Saha yanıt DTO
│       │   ├── MacRequest.java        # Maç oluşturma DTO (genişletilmiş)
│       │   ├── MacResponse.java       # Maç yanıt DTO (genişletilmiş)
│       │   ├── TakimIlaniRequest.java # ★ Takım ilanı oluşturma DTO
│       │   └── TakimIlaniResponse.java # ★ Takım ilanı yanıt DTO
│       └── exception/
│
│   └── src/main/resources/
│       ├── application.properties
│       ├── publicKey.pem / privateKey.pem
│       └── db_migration.sql           # Tablo SQL'leri (genişletilmiş)
│
└── PROJE_NOTLARI.md
```

> ★ ile işaretlenen dosyalar bu oturumda (20 Nisan 2026, Oturum 4) oluşturuldu/güncellendi.

---

## Yapılan İşler (Kronolojik)

### Oturum 1 — Backend JWT Hatası Çözümü (14 Nisan 2026)

**Sorun:** Kayıt ol butonuna tıklayınca bağlantı hatası.
**Sebep:** `publicKey.pem` dosyası eksik, `application.properties`'de `classpath:` prefix'i yok.
**Çözüm:** Key oluşturuldu, path'ler düzeltildi, backend yeniden başlatıldı.

---

### Oturum 2 — Login Modernizasyonu & Ana Sayfa (15 Nisan 2026)

1. **Backend: "Beni Hatırla"** — `beniHatirla=true` ise refresh token 3x (90 gün)
2. **Tema** — Neon yeşil + turuncu, koyu arka plan, glassmorphism
3. **Login Ekranı** — Modern kart, dekoratif saha çizgileri, toggle (Kullanıcı/İşletme)
4. **Ana Shell** — Custom Bottom Navigation (4 sekme: Keşfet, Sahalar, Maçlar, Profil)
5. **Keşfet Tabı** — Selamlama, hızlı erişim, yaklaşan maçlar, popüler sahalar
6. **Sahalar Tabı** — Arama, filtre, saha listesi
7. **Maçlar Tabı** — Toggle (Açık/Maçlarım), maç oluştur banner, maç listesi
8. **Profil Tabı** — Avatar, istatistik, menü, çıkış

---

### Oturum 3 — Saha + Maç + Arama Sistemi (20 Nisan 2026)

- Backend: HaliSaha, Mac, MacKatilimci entity'leri + service + resource + DTO
- Backend: SahaResource, MacResource, AramaResource endpoint'leri
- Frontend: saha.dart, mac.dart modelleri + saha_service, mac_service, arama_service
- Frontend: SahaDetayScreen, MacOlusturScreen, MacDetayScreen, AramaScreen
- Frontend: Keşfet, Sahalar, Maçlar tabları API entegrasyonu
- SQL: db_migration.sql (hali_saha_tb, mac_tb, mac_katilimci_tb)

---

### Oturum 4 — Maç Tipi, Disiplin Puanı, Takım İlanları (20 Nisan 2026)

#### Kullanıcı Entity Güncellemesi

**`Kullanici` tablosuna eklenen alanlar:**
| Alan | Tip | Açıklama |
|------|-----|----------|
| disiplinPuani | BigDecimal(4,2) | 1.0-5.0 arası, varsayılan 5.00 |
| tercihEdilenPozisyon | String(30) | KALECI, DEFANS, ORTASAHA, FORVET |

#### Maç Entity Güncellemesi

**`Mac` tablosuna eklenen alanlar:**
| Alan | Tip | Açıklama |
|------|-----|----------|
| minDisiplinPuani | BigDecimal(4,2) | Bu puanın altındaki oyuncular katılamaz |
| macTipi | String(20) | NORMAL, RAKIP_ARANIYOR, EKSIK_OYUNCU |
| eksikOyuncuSayisi | Integer | Kaç oyuncu eksik (EKSIK_OYUNCU tipi) |
| takimAdi | String(100) | Takım adı (takım maçları) |
| rakipNotu | String(300) | Rakip takıma not (RAKIP_ARANIYOR tipi) |

**Format güncellendi:** 3v3, 4v4, 5v5, 6v6, 7v7, 8v8, 9v9, 10v10, 11v11

#### Yeni Entity: TakimIlani (takim_ilani_tb)

| Alan | Tip | Açıklama |
|------|-----|----------|
| id | UUID | PK |
| olusturanId | UUID | İlanı oluşturan kullanıcı |
| takimAdi | String(100) | Takım adı |
| ilanBasligi | String(200) | İlan başlığı |
| aciklama | String(500) | İlan açıklaması |
| arananPozisyon | String(50) | KALECI, DEFANS, ORTASAHA, FORVET, FARKETMEZ |
| arananOyuncuSayisi | Integer | Kaç oyuncu aranıyor |
| minDisiplinPuani | BigDecimal(4,2) | Minimum disiplin puanı filtresi |
| seviye | String(20) | BASLANGIC, ORTA, ILERI, KARMA |
| konum | String(100) | Semt/konum bilgisi |
| ilanDurumu | String(20) | AKTIF, KAPALI, DOLDU |

#### Yeni API Endpoint'leri

| Method | Endpoint | Auth | Açıklama |
|--------|----------|------|----------|
| GET | `/api/takim-ilanlari` | Hayır | Aktif takım ilanları |
| GET | `/api/takim-ilanlari/{id}` | Hayır | İlan detayı |
| GET | `/api/takim-ilanlari/benim` | KULLANICI | Kullanıcının ilanları |
| POST | `/api/takim-ilanlari` | KULLANICI | Yeni ilan oluştur |
| POST | `/api/takim-ilanlari/{id}/kapat` | KULLANICI | İlanı kapat |
| GET | `/api/takim-ilanlari/ara?q=...` | Hayır | İlan arama |

#### Disiplin Puanı Kontrol Mekanizması

Maça katılma isteğinde, eğer maçın `minDisiplinPuani` değeri set edilmişse:
- Katılmak isteyen kullanıcının `disiplinPuani` kontrol edilir
- Yetersizse `403 Forbidden` ile reddedilir
- Hata mesajı: "Disiplin puanınız (X) bu maç için gereken minimum puanın (Y) altında"

#### Frontend Yeni Ekranlar

**Maç Oluştur Ekranı (genişletilmiş)**
- Maç Tipi seçimi: Normal / Rakip Aranıyor / Eksik Oyuncu
- Format: 3v3'den 11v11'e kadar (Wrap layout)
- Disiplin puanı filtresi (Switch + Slider, 1.0-5.0)
- Takım adı alanı (Normal dışı tiplerde)
- Eksik oyuncu sayısı (EKSIK_OYUNCU tipinde)
- Rakibe not alanı (RAKIP_ARANIYOR tipinde)

**Maç Detay Ekranı (genişletilmiş)**
- Maç tipi badge (Normal olmayan maçlarda)
- Maç tipi banner (takım adı, eksik sayısı, rakip notu)
- Disiplin puanı gereksinimi banner
- Katılımcı listesinde disiplin puanı gösterimi

**Takım İlanları Ekranı (`takim_ilanlari_screen.dart`)**
- Tab: Tüm İlanlar / İlanlarım
- İlan kartı: takım adı, başlık, açıklama, aranan bilgi, konum, disiplin
- Bottom sheet detay görünümü
- FloatingActionButton ile yeni ilan oluşturma

**Takım İlanı Oluştur Ekranı (`takim_ilani_olustur_screen.dart`)**
- Takım adı, ilan başlığı
- Aranan pozisyon seçimi (Kaleci/Defans/Orta Saha/Forvet/Farketmez)
- Aranan oyuncu sayısı (+/- stepper)
- Seviye seçimi
- Disiplin puanı filtresi
- Konum/semt bilgisi
- Açıklama

#### Frontend Güncellenen Ekranlar

**Keşfet Tabı** — "Takım İlanları" hızlı erişim butonu eklendi (Takımım → Takım İlanları)
**Maçlar Tabı** — Takım İlanları banner'ı eklendi, maç kartlarında maç tipi ve disiplin ikonu gösterimi

---

## Maç Sistemi İş Mantığı

1. **Maç oluşturma:** Sadece KULLANICI rolü. Oluşturan otomatik katılımcı olur (`mevcutOyuncuSayisi=1`).
2. **Katılma:** Kullanıcı `ACIK` durumlu maça katılabilir. Dolunca `macDurumu=DOLU` olur.
3. **Disiplin kontrolü:** Maçın `minDisiplinPuani` set ise, kullanıcı puanı kontrol edilir.
4. **Ayrılma:** Oluşturan kişi ayrılamaz (maçı iptal etmeli). Diğerleri ayrılabilir.
5. **Saha seçimi:** Maç oluşturulurken saha opsiyonel. Saha seçilirse format otomatik uyar.
6. **Maç Tipleri:**
   - **NORMAL:** Bireysel oyuncular katılır
   - **RAKIP_ARANIYOR:** Takım olarak rakip arıyorsunuz, rakip notu yazılabilir
   - **EKSIK_OYUNCU:** Takıma kaç oyuncu eksik belirtilir
7. **Format:** 3v3'den 11v11'e kadar (6-22 kişi)

---

## Takım İlanı Sistemi

1. **İlan oluşturma:** Kullanıcı takımına kalıcı oyuncu arayabilir.
2. **Filtreler:** Pozisyon, seviye, disiplin puanı, konum bazlı filtreleme.
3. **Durumlar:** AKTIF (görünür), KAPALI (sahibi kapattı), DOLDU (oyuncu bulundu).
4. **İlan kapatma:** Sadece oluşturan kapatabilir.

---

## Veritabanı Tabloları

| Tablo | Açıklama |
|-------|----------|
| `kullanici_tb` | Kullanıcılar (disiplinPuani, tercihEdilenPozisyon eklendi) |
| `isletme_tb` | İşletmeler |
| `refresh_token_tb` | Refresh token'lar |
| `giris_gecmisi_tb` | Giriş geçmişi |
| `hesap_kilitleme_tb` | Brute-force koruması |
| `sifre_sifirlama_tb` | Şifre sıfırlama |
| `hali_saha_tb` | Halı sahalar |
| `mac_tb` | Maçlar (macTipi, minDisiplinPuani, takimAdi, rakipNotu, eksikOyuncuSayisi eklendi) |
| `mac_katilimci_tb` | Maç katılımcıları |
| `takim_ilani_tb` | ★ Takım ilanları |

> SQL: `backend/src/main/resources/db_migration.sql`

---

## Kullanılan Flutter Paketleri

| Paket | Kullanım |
|-------|----------|
| `dio` | HTTP istekleri |
| `provider` | State management |
| `flutter_secure_storage` | Token güvenli saklama |
| `google_fonts` | Font desteği |
| `email_validator` | Email doğrulama |
| `cupertino_icons` | İkonlar |

---

## Oturum 5: Genel Arama Ekranı Güncelleme

### Yapılanlar:
- **Backend `AramaResource`** — Birleşik aramaya `takım ilanları` kategorisi eklendi (`ilanlar` tip filtresi)
- **Backend oyuncu araması** — `disiplinPuani` ve `tercihEdilenPozisyon` alanları sonuçlara dahil edildi
- **Frontend `AramaSonuc` modeli** — `List<TakimIlani> ilanlar` alanı eklendi
- **Frontend `OyuncuSonuc` modeli** — `disiplinPuani`, `tercihEdilenPozisyon` alanları eklendi
- **Frontend `AramaScreen`** — Tamamen yeniden yazıldı:
  - 5 kategori filtresi: Tümü, Sahalar, Maçlar, Oyuncular, İlanlar (ikonlu chip'ler)
  - Boş durum ekranı: öneri chip'leri ("Halı saha", "6v6", "Forvet") ile hızlı arama
  - Sonuç bulunamadı ekranı: aranan terimi gösterir
  - Takım ilanı sonuç kartları: takım adı, pozisyon, seviye bilgisi
  - Oyuncu kartlarına disiplin puanı gösterimi eklendi
  - Maç kartlarına format badge'i eklendi
- **Keşfet tab** — "Saha Bul" → "Genel Arama" olarak güncellendi, arama placeholder metni güncellendi

---

## Oturum 6: UI Modernleştirme & Bug Fix

### Bug Fix:
- **HQL Sorgu Hatası (KRİTİK)** — `Mac.findByOlusturanId()` ve `TakimIlani.findByOlusturanId()` sorgularında `= ?1` eksikti. Bu yüzden "Maçlarım" ve "İlanlarım" sayfaları boş görünüyordu. Düzeltildi: `"olusturanId ORDER BY..."` → `"olusturanId = ?1 ORDER BY..."`

### Yapılanlar:
- **Maçlar Tab** — İlanlarım sekmesi kaldırıldı. Artık sadece "Açık Maçlar" ve "Maçlarım" olmak üzere 2 tab var
- **Maç Detay** — Eksik Oyuncu tipindeki maçlarda "Doluluk" yerine "Eksik Oyuncu Durumu" gösterimi eklendi:
  - Aranan / Katılan / Kalan istatistik kutuları
  - Özel progress bar (doluluk yerine eksik oyuncu bazlı)
- **Maç kartları** — Eksik Oyuncu ilanlarında "X kişi aranıyor" yazısı (kesfet + maçlar tabı)
- **Tema** — `accentBlue` ve `lightBlue` renkleri eklendi. Border'lar `Colors.white.withOpacity(0.03)` ile daha subtle yapıldı
- **UI Modernleştirme** — Tüm ekranlarda:
  - Daha yumuşak border renkleri
  - AnimatedContainer ile geçiş efektleri (filtre chip'leri)
  - Tutarlı badge sistemi (`_buildBadge` helper)
  - Boş durum ekranları iyileştirildi (ikon + açıklama metni)
  - Renk uyumu düzeltildi (her yerde tutarlı opacity değerleri)

---

## Sırada Yapılacaklar

1. **Profil düzenleme ekranı** — Kullanıcı bilgi güncelleme (pozisyon, profil foto)
2. **Rezervasyon sistemi** — Takvim, saat seçimi, backend entity + endpoint
3. **Değerlendirme & yorum** — Sahaya ve oyuncuya puan ve yorum
4. **Bildirim sistemi** — Push notification (maç hatırlatma, ilan bildirimi)
5. **Harita entegrasyonu** — Konum bazlı arama, yakın sahalar
6. **Fotoğraf yükleme** — Saha ve profil fotoğrafı
7. **Takım ilanı başvuru sistemi** — İlana başvurma, kabul/red mekanizması
8. **Disiplin puanı yönetimi** — Maç sonrası puanlama, otomatik hesaplama

---

## Önemli Notlar

- **API Base URL:** `http://10.0.2.2:8080` (Android emülatör → host)
- **JWT Key'ler:** `classpath:publicKey.pem` / `classpath:privateKey.pem` (RSA 2048-bit)
- **Veritabanı:** Hibernate `validate` — tablo önceden oluşturulmalı
- **Yeni tablolar/kolonlar için:** `db_migration.sql` dosyasını PostgreSQL'de çalıştırın
- **Beni Hatırla:** Aktifken refresh token 3x (90 gün)
- **Tema:** Koyu mod, neon yeşil + turuncu, glassmorphism
- **Maç sistemi:** Oluşturan otomatik katılır, dolu olunca durum değişir
- **Disiplin puanı:** Varsayılan 5.00, maçlarda minimum puan filtresi uygulanabilir
- **Maç formatları:** 3v3'den 11v11'e kadar desteklenir
- **Maç tipleri:** Normal, Rakip Aranıyor, Eksik Oyuncu
- **Arama:** Debounce (400ms), birleşik sonuç (saha+maç+oyuncu+takım ilanı), kategori filtreleri (Tümü/Sahalar/Maçlar/Oyuncular/İlanlar), öneri chip'leri
