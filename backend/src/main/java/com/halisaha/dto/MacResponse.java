package com.halisaha.dto;

import com.halisaha.entity.Mac;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public class MacResponse {

    public UUID id;
    public UUID olusturanId;
    public String olusturanAdi;
    public UUID sahaId;
    public String sahaAdi;
    public String macBasligi;
    public LocalDate macTarihi;
    public LocalTime baslangicSaati;
    public LocalTime bitisSaati;
    public String format;
    public Integer maxOyuncuSayisi;
    public Integer mevcutOyuncuSayisi;
    public String macDurumu;
    public String aciklama;
    public String seviye;
    public BigDecimal ucretPerKisi;
    public BigDecimal minDisiplinPuani;
    public String macTipi;
    public Integer eksikOyuncuSayisi;
    public String takimAdi;
    public String rakipNotu;
    public String il;
    public String ilce;
    public List<KatilimciBilgi> katilimcilar;

    public MacResponse() {}

    public static MacResponse from(Mac mac, String olusturanAdi, String sahaAdi,
                                    List<KatilimciBilgi> katilimcilar) {
        MacResponse r = new MacResponse();
        r.id = mac.id;
        r.olusturanId = mac.olusturanId;
        r.olusturanAdi = olusturanAdi;
        r.sahaId = mac.sahaId;
        r.sahaAdi = sahaAdi;
        r.macBasligi = mac.macBasligi;
        r.macTarihi = mac.macTarihi;
        r.baslangicSaati = mac.baslangicSaati;
        r.bitisSaati = mac.bitisSaati;
        r.format = mac.format;
        r.maxOyuncuSayisi = mac.maxOyuncuSayisi;
        r.mevcutOyuncuSayisi = mac.mevcutOyuncuSayisi;
        r.macDurumu = mac.macDurumu;
        r.aciklama = mac.aciklama;
        r.seviye = mac.seviye;
        r.ucretPerKisi = mac.ucretPerKisi;
        r.minDisiplinPuani = mac.minDisiplinPuani;
        r.macTipi = mac.macTipi;
        r.eksikOyuncuSayisi = mac.eksikOyuncuSayisi;
        r.takimAdi = mac.takimAdi;
        r.rakipNotu = mac.rakipNotu;
        r.il = mac.il;
        r.ilce = mac.ilce;
        r.katilimcilar = katilimcilar;
        return r;
    }

    public static class KatilimciBilgi {
        public UUID id;
        public String adSoyad;
        public String profilFotoUrl;
        public String katilimDurumu;

        public KatilimciBilgi() {}

        public BigDecimal disiplinPuani;

        public KatilimciBilgi(UUID id, String adSoyad, String profilFotoUrl, String katilimDurumu, BigDecimal disiplinPuani) {
            this.id = id;
            this.adSoyad = adSoyad;
            this.profilFotoUrl = profilFotoUrl;
            this.katilimDurumu = katilimDurumu;
            this.disiplinPuani = disiplinPuani;
        }
    }
}
