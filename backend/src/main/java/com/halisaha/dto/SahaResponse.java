package com.halisaha.dto;

import com.halisaha.entity.HaliSaha;
import java.math.BigDecimal;
import java.util.UUID;

public class SahaResponse {

    public UUID id;
    public UUID isletmeId;
    public String sahaAdi;
    public String adres;
    public Double enlem;
    public Double boylam;
    public String sahaFormati;
    public BigDecimal saatlikUcret;
    public Boolean kapaliMi;
    public String ozellikler;
    public BigDecimal puanOrtalamasi;
    public Integer yorumSayisi;
    public String fotografUrl;
    public String isletmeAdi;

    public SahaResponse() {}

    public static SahaResponse from(HaliSaha saha, String isletmeAdi) {
        SahaResponse r = new SahaResponse();
        r.id = saha.id;
        r.isletmeId = saha.isletmeId;
        r.sahaAdi = saha.sahaAdi;
        r.adres = saha.adres;
        r.enlem = saha.enlem;
        r.boylam = saha.boylam;
        r.sahaFormati = saha.sahaFormati;
        r.saatlikUcret = saha.saatlikUcret;
        r.kapaliMi = saha.kapaliMi;
        r.ozellikler = saha.ozellikler;
        r.puanOrtalamasi = saha.puanOrtalamasi;
        r.yorumSayisi = saha.yorumSayisi;
        r.fotografUrl = saha.fotografUrl;
        r.isletmeAdi = isletmeAdi;
        return r;
    }
}
