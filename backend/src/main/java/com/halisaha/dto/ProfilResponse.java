package com.halisaha.dto;

import java.math.BigDecimal;

public class ProfilResponse {

    public String id;
    public String adSoyad;
    public String email;
    public String telefon;
    public String profilFotoUrl;
    public String tercihEdilenPozisyon;
    public BigDecimal disiplinPuani;
    public BigDecimal puanOrtalamasi;
    public Integer yorumSayisi;
    public String dogumTarihi;   // "yyyy-MM-dd"
    public String kayitTarihi;   // ISO-8601
    public String hesapDurumu;
    public String il;
    public String ilce;
    public Boolean emailDogrulanmis;

    // İstatistikler
    public long toplamMacSayisi;       // Katıldığı maçlar
    public long olusturduguMacSayisi;  // Oluşturduğu maçlar
    public long toplamIlanSayisi;      // Oluşturduğu takım ilanları
    public long sonOtuzGunMacSayisi;   // Son 30 günde oynanan maçlar
    public long aldiguPuanSayisi;      // Kaç kez puanlandı
    public String sonMacTarihi;        // Son oynadığı maç tarihi

    // Takip istatistikleri
    public long takipEdilenSayisi;
    public long takipciSayisi;

    public ProfilResponse() {}
}
