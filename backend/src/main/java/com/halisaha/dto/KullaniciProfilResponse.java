package com.halisaha.dto;

import com.halisaha.entity.Kullanici;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public class KullaniciProfilResponse {

    public UUID id;
    public String adSoyad;
    public String profilFotoUrl;
    public BigDecimal disiplinPuani;
    public Integer yorumSayisi;
    public String tercihEdilenPozisyon;
    public String il;
    public String ilce;
    public LocalDate kayitTarihi;
    public long toplamMacSayisi;

    public static KullaniciProfilResponse from(Kullanici k, long toplamMac) {
        KullaniciProfilResponse r = new KullaniciProfilResponse();
        r.id = k.id;
        r.adSoyad = k.adSoyad;
        r.profilFotoUrl = k.profilFotoUrl;
        r.disiplinPuani = k.disiplinPuani;
        r.yorumSayisi = k.yorumSayisi;
        r.tercihEdilenPozisyon = k.tercihEdilenPozisyon;
        r.il = k.il;
        r.ilce = k.ilce;
        r.kayitTarihi = k.kayitTarihi != null ? k.kayitTarihi.toLocalDate() : null;
        r.toplamMacSayisi = toplamMac;
        return r;
    }
}
