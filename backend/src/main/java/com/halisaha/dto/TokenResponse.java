package com.halisaha.dto;

public class TokenResponse {

    public String accessToken;
    public String refreshToken;
    public String tokenTipi = "Bearer";
    public long accessTokenSuresi;
    public String kullaniciTipi;
    public KullaniciBilgi kullaniciBilgi;

    public static class KullaniciBilgi {
        public String id;
        public String adSoyad;
        public String email;
        public String profilFotoUrl;

        public KullaniciBilgi() {}

        public KullaniciBilgi(String id, String adSoyad, String email, String profilFotoUrl) {
            this.id = id;
            this.adSoyad = adSoyad;
            this.email = email;
            this.profilFotoUrl = profilFotoUrl;
        }
    }

    public TokenResponse() {}

    public TokenResponse(String accessToken, String refreshToken, long sureSaniye,
                         String kullaniciTipi, KullaniciBilgi bilgi) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.accessTokenSuresi = sureSaniye;
        this.kullaniciTipi = kullaniciTipi;
        this.kullaniciBilgi = bilgi;
    }
}
