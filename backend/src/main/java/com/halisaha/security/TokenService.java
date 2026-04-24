package com.halisaha.security;

import io.smallrye.jwt.build.Jwt;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@ApplicationScoped
public class TokenService {

    @ConfigProperty(name = "halisaha.jwt.access-token-suresi-dakika", defaultValue = "15")
    int accessTokenSuresiDakika;

    @ConfigProperty(name = "halisaha.jwt.refresh-token-suresi-gun", defaultValue = "30")
    int refreshTokenSuresiGun;

    @ConfigProperty(name = "mp.jwt.verify.issuer", defaultValue = "halisaha-api")
    String issuer;

    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    public String generateAccessToken(UUID userId, String email, String adSoyad,
                                       String kullaniciTipi) {
        Set<String> groups = new HashSet<>();
        groups.add(kullaniciTipi);

        Instant now = Instant.now();
        Instant expiry = now.plus(Duration.ofMinutes(accessTokenSuresiDakika));

        return Jwt.issuer(issuer)
                .subject(userId.toString())
                .groups(groups)
                .claim("email", email)
                .claim("ad_soyad", adSoyad)
                .claim("kullanici_tipi", kullaniciTipi)
                .issuedAt(now)
                .expiresAt(expiry)
                .sign();
    }

    public String generateRefreshToken() {
        byte[] randomBytes = new byte[64];
        SECURE_RANDOM.nextBytes(randomBytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
    }

    public String hashToken(String token) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 desteklenmiyor", e);
        }
    }

    public long getAccessTokenSuresiSaniye() {
        return (long) accessTokenSuresiDakika * 60;
    }

    public Instant getRefreshTokenGecerlilikTarihi() {
        return Instant.now().plus(Duration.ofDays(refreshTokenSuresiGun));
    }

    public Instant getRefreshTokenGecerlilikTarihi(boolean beniHatirla) {
        int gun = beniHatirla ? refreshTokenSuresiGun * 3 : refreshTokenSuresiGun;
        return Instant.now().plus(Duration.ofDays(gun));
    }
}
