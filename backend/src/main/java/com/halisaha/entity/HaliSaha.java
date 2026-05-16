package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "hali_saha_tb")
public class HaliSaha extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "isletme_id", nullable = false, columnDefinition = "uuid")
    public UUID isletmeId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "isletme_id", insertable = false, updatable = false)
    public Isletme isletme;

    @Column(name = "saha_adi", nullable = false, length = 200)
    public String sahaAdi;

    @Column(nullable = false)
    public String adres;

    public Double enlem;
    public Double boylam;

    @Column(name = "saha_formati", nullable = false, length = 10)
    public String sahaFormati; // 5v5, 6v6, 7v7

    @Column(name = "saatlik_ucret", nullable = false, precision = 10, scale = 2)
    public BigDecimal saatlikUcret;

    @Column(name = "kapali_mi")
    public Boolean kapaliMi = false;

    @Column(length = 500)
    public String ozellikler; // virgülle ayrılmış: DUS,OTOPARK,KAFETERYA,AYDINLATMA,TRIBUN

    @Column(name = "puan_ortalamasi", precision = 3, scale = 2)
    public BigDecimal puanOrtalamasi = BigDecimal.ZERO;

    @Column(name = "yorum_sayisi")
    public Integer yorumSayisi = 0;

    @Column(name = "fotograf_url")
    public String fotografUrl;

    @Column(name = "aktif_mi")
    public Boolean aktifMi = true;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi;

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<HaliSaha> findByIsletmeId(UUID isletmeId) {
        return list("isletmeId", isletmeId);
    }

    public static List<HaliSaha> findAktifSahalar() {
        return list("aktifMi", true);
    }

    public static List<HaliSaha> findAktifSahalarPaged(int pageIndex, int pageSize) {
        return find("aktifMi = true").page(pageIndex, pageSize).list();
    }

    public static long countAktifSahalar() {
        return count("aktifMi", true);
    }

    public static List<HaliSaha> ara(String query) {
        return list("aktifMi = true AND (LOWER(sahaAdi) LIKE ?1 OR LOWER(adres) LIKE ?1)",
                "%" + query.toLowerCase() + "%");
    }

    public static List<HaliSaha> findByKonum(String il, String ilce) {
        if (ilce != null && !ilce.isEmpty()) {
            return list("aktifMi = true AND (LOWER(adres) LIKE ?1 AND LOWER(adres) LIKE ?2)",
                    "%" + il.toLowerCase() + "%", "%" + ilce.toLowerCase() + "%");
        }
        return list("aktifMi = true AND LOWER(adres) LIKE ?1",
                "%" + il.toLowerCase() + "%");
    }
}
