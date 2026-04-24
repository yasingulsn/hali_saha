package com.halisaha.service;

import com.halisaha.dto.*;
import com.halisaha.entity.*;
import com.halisaha.exception.AuthException;
import com.halisaha.security.PasswordService;
import com.halisaha.security.TokenService;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;

@ApplicationScoped
public class AuthService {

    @Inject
    TokenService tokenService;

    @Inject
    PasswordService passwordService;

    @ConfigProperty(name = "halisaha.security.max-basarisiz-deneme", defaultValue = "5")
    int maxBasarisizDeneme;

    @ConfigProperty(name = "halisaha.security.kilit-suresi-dakika", defaultValue = "15")
    int kilitSuresiDakika;

    // ─── KULLANICI KAYIT ─────────────────────────────────────────

    @Transactional
    public TokenResponse kullaniciKayit(KullaniciRegisterRequest req, String ipAdresi) {
        Kullanici mevcut = Kullanici.findByEmail(req.email.toLowerCase().trim());
        if (mevcut != null) {
            throw new AuthException("Bu email adresi ile kayıtlı bir hesap zaten mevcut", 409);
        }

        Kullanici kullanici = new Kullanici();
        kullanici.adSoyad = req.adSoyad.trim();
        kullanici.email = req.email.toLowerCase().trim();
        kullanici.sifre = passwordService.hashPassword(req.sifre);
        kullanici.telefon = req.telefon;
        kullanici.dogumTarihi = req.dogumTarihi;
        kullanici.kayitTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        kullanici.aktifMi = true;
        kullanici.emailDogrulanmis = false;
        kullanici.hesapDurumu = "AKTIF";
        kullanici.sonGirisTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        kullanici.persist();

        logGiris(kullanici.id, null, "KULLANICI", ipAdresi, req.cihazBilgisi, true, null);

        return generateTokenResponse(kullanici.id, kullanici.email, kullanici.adSoyad,
                kullanici.profilFotoUrl, "KULLANICI", req.cihazBilgisi, ipAdresi);
    }

    // ─── KULLANICI GİRİŞ ─────────────────────────────────────────

    @Transactional
    public TokenResponse kullaniciGiris(LoginRequest req, String ipAdresi) {
        String email = req.email.toLowerCase().trim();

        kontrolHesapKilitleme(email);

        Kullanici kullanici = Kullanici.findByEmail(email);
        if (kullanici == null) {
            logGiris(null, null, "KULLANICI", ipAdresi, req.cihazBilgisi, false, "Kullanıcı bulunamadı");
            kaydetBasarisizDeneme(email);
            throw new AuthException("Email veya şifre hatalı", 401);
        }

        if (!"AKTIF".equals(kullanici.hesapDurumu)) {
            logGiris(kullanici.id, null, "KULLANICI", ipAdresi, req.cihazBilgisi, false, "Hesap aktif değil");
            throw new AuthException("Hesabınız askıya alınmış veya devre dışı bırakılmış", 403);
        }

        if (!passwordService.verifyPassword(req.sifre, kullanici.sifre)) {
            logGiris(kullanici.id, null, "KULLANICI", ipAdresi, req.cihazBilgisi, false, "Hatalı şifre");
            kaydetBasarisizDeneme(email);
            throw new AuthException("Email veya şifre hatalı", 401);
        }

        sifirlaBasarisizDeneme(email);
        kullanici.sonGirisTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        kullanici.persist();

        logGiris(kullanici.id, null, "KULLANICI", ipAdresi, req.cihazBilgisi, true, null);

        return generateTokenResponse(kullanici.id, kullanici.email, kullanici.adSoyad,
                kullanici.profilFotoUrl, "KULLANICI", req.cihazBilgisi, ipAdresi, req.beniHatirla);
    }

    // ─── İŞLETME KAYIT ──────────────────────────────────────────

    @Transactional
    public TokenResponse isletmeKayit(IsletmeRegisterRequest req, String ipAdresi) {
        Isletme mevcut = Isletme.findByEmail(req.email.toLowerCase().trim());
        if (mevcut != null) {
            throw new AuthException("Bu email adresi ile kayıtlı bir işletme zaten mevcut", 409);
        }

        Isletme isletme = new Isletme();
        isletme.isletmeAdi = req.isletmeAdi.trim();
        isletme.yetkiliAdSoyad = req.yetkiliAdSoyad.trim();
        isletme.email = req.email.toLowerCase().trim();
        isletme.sifre = passwordService.hashPassword(req.sifre);
        isletme.telefon = req.telefon;
        isletme.vergiNo = req.vergiNo;
        isletme.adres = req.adres;
        isletme.konumEnlem = req.konumEnlem;
        isletme.konumBoylam = req.konumBoylam;
        isletme.kayitTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        isletme.onayliMi = false;
        isletme.emailDogrulanmis = false;
        isletme.hesapDurumu = "AKTIF";
        isletme.sonGirisTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        isletme.persist();

        logGiris(null, isletme.id, "ISLETME", ipAdresi, req.cihazBilgisi, true, null);

        return generateTokenResponse(isletme.id, isletme.email, isletme.yetkiliAdSoyad,
                null, "ISLETME", req.cihazBilgisi, ipAdresi);
    }

    // ─── İŞLETME GİRİŞ ──────────────────────────────────────────

    @Transactional
    public TokenResponse isletmeGiris(LoginRequest req, String ipAdresi) {
        String email = req.email.toLowerCase().trim();

        kontrolHesapKilitleme(email);

        Isletme isletme = Isletme.findByEmail(email);
        if (isletme == null) {
            logGiris(null, null, "ISLETME", ipAdresi, req.cihazBilgisi, false, "İşletme bulunamadı");
            kaydetBasarisizDeneme(email);
            throw new AuthException("Email veya şifre hatalı", 401);
        }

        if (!"AKTIF".equals(isletme.hesapDurumu)) {
            logGiris(null, isletme.id, "ISLETME", ipAdresi, req.cihazBilgisi, false, "Hesap aktif değil");
            throw new AuthException("Hesabınız askıya alınmış veya devre dışı bırakılmış", 403);
        }

        if (!passwordService.verifyPassword(req.sifre, isletme.sifre)) {
            logGiris(null, isletme.id, "ISLETME", ipAdresi, req.cihazBilgisi, false, "Hatalı şifre");
            kaydetBasarisizDeneme(email);
            throw new AuthException("Email veya şifre hatalı", 401);
        }

        sifirlaBasarisizDeneme(email);
        isletme.sonGirisTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        isletme.persist();

        logGiris(null, isletme.id, "ISLETME", ipAdresi, req.cihazBilgisi, true, null);

        return generateTokenResponse(isletme.id, isletme.email, isletme.yetkiliAdSoyad,
                null, "ISLETME", req.cihazBilgisi, ipAdresi, req.beniHatirla);
    }

    // ─── TOKEN YENİLEME ─────────────────────────────────────────

    @Transactional
    public TokenResponse tokenYenile(String refreshTokenRaw, String ipAdresi) {
        String tokenHash = tokenService.hashToken(refreshTokenRaw);
        RefreshToken storedToken = RefreshToken.findByTokenHash(tokenHash);

        if (storedToken == null) {
            throw new AuthException("Geçersiz refresh token", 401);
        }

        if (storedToken.gecerlilikTarihi.toInstant().isBefore(Instant.now())) {
            storedToken.iptalEdildiMi = true;
            storedToken.persist();
            throw new AuthException("Refresh token süresi dolmuş, lütfen tekrar giriş yapınız", 401);
        }

        // Eski token'ı iptal et (rotation)
        storedToken.iptalEdildiMi = true;
        storedToken.persist();

        if ("KULLANICI".equals(storedToken.kullaniciTipi)) {
            Kullanici kullanici = Kullanici.findById(storedToken.kullaniciId);
            if (kullanici == null || !"AKTIF".equals(kullanici.hesapDurumu)) {
                throw new AuthException("Hesap bulunamadı veya aktif değil", 401);
            }
            return generateTokenResponse(kullanici.id, kullanici.email, kullanici.adSoyad,
                    kullanici.profilFotoUrl, "KULLANICI", storedToken.cihazBilgisi, ipAdresi);
        } else {
            Isletme isletme = Isletme.findById(storedToken.isletmeId);
            if (isletme == null || !"AKTIF".equals(isletme.hesapDurumu)) {
                throw new AuthException("Hesap bulunamadı veya aktif değil", 401);
            }
            return generateTokenResponse(isletme.id, isletme.email, isletme.yetkiliAdSoyad,
                    null, "ISLETME", storedToken.cihazBilgisi, ipAdresi);
        }
    }

    // ─── ÇIKIŞ ──────────────────────────────────────────────────

    @Transactional
    public void cikis(String refreshTokenRaw) {
        if (refreshTokenRaw == null || refreshTokenRaw.isBlank()) return;
        String tokenHash = tokenService.hashToken(refreshTokenRaw);
        RefreshToken storedToken = RefreshToken.findByTokenHash(tokenHash);
        if (storedToken != null) {
            storedToken.iptalEdildiMi = true;
            storedToken.persist();
        }
    }

    @Transactional
    public void tumCihazlardanCikis(java.util.UUID userId, String kullaniciTipi) {
        if ("KULLANICI".equals(kullaniciTipi)) {
            RefreshToken.revokeAllByKullaniciId(userId);
        } else {
            RefreshToken.revokeAllByIsletmeId(userId);
        }
    }

    // ─── YARDIMCI METODLAR ──────────────────────────────────────

    private TokenResponse generateTokenResponse(java.util.UUID userId, String email,
                                                 String adSoyad, String profilFotoUrl,
                                                 String kullaniciTipi, String cihazBilgisi,
                                                 String ipAdresi) {
        return generateTokenResponse(userId, email, adSoyad, profilFotoUrl,
                kullaniciTipi, cihazBilgisi, ipAdresi, false);
    }

    private TokenResponse generateTokenResponse(java.util.UUID userId, String email,
                                                 String adSoyad, String profilFotoUrl,
                                                 String kullaniciTipi, String cihazBilgisi,
                                                 String ipAdresi, boolean beniHatirla) {
        String accessToken = tokenService.generateAccessToken(userId, email, adSoyad, kullaniciTipi);
        String refreshTokenRaw = tokenService.generateRefreshToken();

        RefreshToken refreshEntity = new RefreshToken();
        if ("KULLANICI".equals(kullaniciTipi)) {
            refreshEntity.kullaniciId = userId;
        } else {
            refreshEntity.isletmeId = userId;
        }
        refreshEntity.kullaniciTipi = kullaniciTipi;
        refreshEntity.tokenHash = tokenService.hashToken(refreshTokenRaw);
        refreshEntity.cihazBilgisi = cihazBilgisi;
        refreshEntity.ipAdresi = ipAdresi;
        refreshEntity.olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        refreshEntity.gecerlilikTarihi = OffsetDateTime.ofInstant(
                tokenService.getRefreshTokenGecerlilikTarihi(beniHatirla), ZoneOffset.UTC);
        refreshEntity.iptalEdildiMi = false;
        refreshEntity.persist();

        TokenResponse.KullaniciBilgi bilgi = new TokenResponse.KullaniciBilgi(
                userId.toString(), adSoyad, email, profilFotoUrl);

        return new TokenResponse(accessToken, refreshTokenRaw,
                tokenService.getAccessTokenSuresiSaniye(), kullaniciTipi, bilgi);
    }

    private void logGiris(java.util.UUID kullaniciId, java.util.UUID isletmeId,
                           String kullaniciTipi, String ipAdresi,
                           String cihazBilgisi, boolean basarili, String hataMesaji) {
        GirisGecmisi log = new GirisGecmisi();
        log.kullaniciId = kullaniciId;
        log.isletmeId = isletmeId;
        log.kullaniciTipi = kullaniciTipi;
        log.ipAdresi = ipAdresi;
        log.cihazBilgisi = cihazBilgisi;
        log.basariliMi = basarili;
        log.hataMesaji = hataMesaji;
        log.girisTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        log.persist();
    }

    // ─── BRUTE-FORCE KORUMASI ───────────────────────────────────

    private void kontrolHesapKilitleme(String email) {
        HesapKilitleme kilit = HesapKilitleme.findByEmail(email);
        if (kilit != null && kilit.kilitliMi) {
            if (kilit.kilitBitisTarihi != null
                    && kilit.kilitBitisTarihi.toInstant().isAfter(Instant.now())) {
                long kalanDakika = java.time.Duration.between(
                        Instant.now(), kilit.kilitBitisTarihi.toInstant()).toMinutes() + 1;
                throw new AuthException(
                        "Hesabınız çok fazla başarısız giriş denemesi nedeniyle kilitlendi. "
                        + kalanDakika + " dakika sonra tekrar deneyiniz.", 429);
            } else {
                kilit.kilitliMi = false;
                kilit.basarisizDenemeSayisi = 0;
                kilit.persist();
            }
        }
    }

    private void kaydetBasarisizDeneme(String email) {
        HesapKilitleme kilit = HesapKilitleme.findByEmail(email);
        if (kilit == null) {
            kilit = new HesapKilitleme();
            kilit.email = email;
            kilit.basarisizDenemeSayisi = 1;
        } else {
            kilit.basarisizDenemeSayisi++;
        }
        kilit.sonBasarisizDeneme = OffsetDateTime.now(ZoneOffset.UTC);

        if (kilit.basarisizDenemeSayisi >= maxBasarisizDeneme) {
            kilit.kilitliMi = true;
            kilit.kilitlemeTarihi = OffsetDateTime.now(ZoneOffset.UTC);
            kilit.kilitBitisTarihi = OffsetDateTime.now(ZoneOffset.UTC)
                    .plusMinutes(kilitSuresiDakika);
        }
        kilit.persist();
    }

    private void sifirlaBasarisizDeneme(String email) {
        HesapKilitleme kilit = HesapKilitleme.findByEmail(email);
        if (kilit != null) {
            kilit.basarisizDenemeSayisi = 0;
            kilit.kilitliMi = false;
            kilit.persist();
        }
    }
}
