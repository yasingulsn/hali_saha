package com.halisaha.dto;

import com.halisaha.entity.Sikayet;

import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class SikayetResponse {

    public UUID id;
    public UUID sikayetEdilenId;
    public String sikayetEdilenAdi;
    public UUID macId;
    public String kategori;
    public String aciklama;
    public String durum;
    public String tarih;

    public static SikayetResponse from(Sikayet s) {
        SikayetResponse r = new SikayetResponse();
        r.id = s.id;
        r.sikayetEdilenId = s.sikayetEdilenId;
        r.sikayetEdilenAdi = s.sikayetEdilen != null ? s.sikayetEdilen.adSoyad : null;
        r.macId = s.macId;
        r.kategori = s.kategori;
        r.aciklama = s.aciklama;
        r.durum = s.durum;
        r.tarih = s.olusturulmaTarihi != null
                ? s.olusturulmaTarihi.format(DateTimeFormatter.ofPattern("dd.MM.yyyy"))
                : null;
        return r;
    }
}
