package com.halisaha.dto;

import com.halisaha.entity.SahaYorum;

import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class SahaYorumResponse {

    public UUID id;
    public UUID kullaniciId;
    public String kullaniciAdSoyad;
    public int puan;
    public String yorum;
    public String tarih;

    public static SahaYorumResponse from(SahaYorum y) {
        SahaYorumResponse r = new SahaYorumResponse();
        r.id = y.id;
        r.kullaniciId = y.kullaniciId;
        r.kullaniciAdSoyad = y.kullanici != null ? y.kullanici.adSoyad : null;
        r.puan = y.puan;
        r.yorum = y.yorum;
        r.tarih = y.olusturulmaTarihi != null
                ? y.olusturulmaTarihi.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"))
                : null;
        return r;
    }
}
