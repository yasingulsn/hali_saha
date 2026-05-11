# Hali Saha

Bu proje Docker ile Mac/Windows farkindan bagimsiz calistirilabilir.

## Backend + PostgreSQL

Docker Desktop acikken proje kok dizininde:

```bash
docker compose up --build
```

Bu komut PostgreSQL'i ve Quarkus backend'i baslatir.

- Backend: http://localhost:8080
- Health check: http://localhost:8080/q/health
- PostgreSQL: `localhost:5432`
- Veritabani: `halisaha`
- Kullanici: `postgres`
- Sifre: `123456`

## Veritabani Dump'ini Yukleme

PostgreSQL container'i ilk kez bos volume ile acildiginda
`backend/db/init/001_halisaha.sql` otomatik yuklenir.

Daha once container'i calistirdiysen ve mevcut veritabani volume'u varsa,
dump'in bastan yuklenmesi icin once volume'u sil:

```bash
docker compose down -v
docker compose up --build
```

Bu islem mevcut Docker veritabanini siler ve dump dosyasindan yeniden kurar.

## Flutter Web'i de Docker ile calistirma

Frontend web container'i ilk kurulumda daha buyuk Flutter imaji indirdigi icin opsiyonel profile alindi:

```bash
docker compose --profile web up --build
```

Frontend acildiginda:

- Web app: http://localhost:3000
- API adresi: http://localhost:8080

## Android Emulator Ile Calistirma

Backend Docker'da calisirken Flutter'i Android emulator uzerinde yerel calistiracaksan:

```bash
cd frontend
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Tarayici veya iOS simulator icin varsayilan API adresi `http://localhost:8080` olarak ayarlidir.
