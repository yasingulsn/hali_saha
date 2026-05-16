package com.halisaha.dto;

import com.halisaha.entity.Rezervasyon;
import java.util.UUID;

public class RezervasyonResponse {

    public UUID id;
    public UUID sahaId;
    public String sahaAdi;
    public String sahaAdresi;
    public UUID kullaniciId;
    public String kullaniciAdSoyad;
    public String rezervasyonTarihi;
    public String baslangicSaati;
    public String bitisSaati;
    public Double toplamUcret;
    public String durum;
    public String notlar;
    public String olusturulmaTarihi;

    public static RezervasyonResponse from(Rezervasyon r) {
        RezervasyonResponse res = new RezervasyonResponse();
        res.id = r.id;
        res.sahaId = r.sahaId;
        res.kullaniciId = r.kullaniciId;
        res.rezervasyonTarihi = r.rezervasyonTarihi.toString();
        res.baslangicSaati = r.baslangicSaati.toString();
        res.bitisSaati = r.bitisSaati.toString();
        res.toplamUcret = r.toplamUcret != null ? r.toplamUcret.doubleValue() : null;
        res.durum = r.durum;
        res.notlar = r.notlar;
        res.olusturulmaTarihi = r.olusturulmaTarihi != null ? r.olusturulmaTarihi.toString() : null;

        if (r.saha != null) {
            res.sahaAdi = r.saha.sahaAdi;
            res.sahaAdresi = r.saha.adres;
        }
        if (r.kullanici != null) {
            res.kullaniciAdSoyad = r.kullanici.adSoyad;
        }
        return res;
    }
}
