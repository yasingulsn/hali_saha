package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "mac_tb")
public class Mac extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "olusturan_id", nullable = false, columnDefinition = "uuid")
    public UUID olusturanId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "olusturan_id", insertable = false, updatable = false)
    public Kullanici olusturan;

    @Column(name = "saha_id", columnDefinition = "uuid")
    public UUID sahaId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "saha_id", insertable = false, updatable = false)
    public HaliSaha saha;

    @Column(name = "mac_basligi", nullable = false, length = 200)
    public String macBasligi;

    @Column(name = "mac_tarihi", nullable = false)
    public LocalDate macTarihi;

    @Column(name = "baslangic_saati", nullable = false)
    public LocalTime baslangicSaati;

    @Column(name = "bitis_saati", nullable = false)
    public LocalTime bitisSaati;

    @Column(nullable = false, length = 10)
    public String format; // 3v3, 4v4, 5v5, 6v6, 7v7, 8v8, 9v9, 10v10, 11v11

    @Column(name = "max_oyuncu_sayisi", nullable = false)
    public Integer maxOyuncuSayisi;

    @Column(name = "mevcut_oyuncu_sayisi")
    public Integer mevcutOyuncuSayisi = 0;

    @Column(name = "mac_durumu", nullable = false, length = 20)
    public String macDurumu = "ACIK"; // ACIK, DOLU, TAMAMLANDI, IPTAL

    @Column(length = 500)
    public String aciklama;

    @Column(length = 20)
    public String seviye = "KARMA"; // BASLANGIC, ORTA, ILERI, KARMA

    @Column(name = "ucret_per_kisi", precision = 10, scale = 2)
    public BigDecimal ucretPerKisi = BigDecimal.ZERO;

    @Column(name = "min_disiplin_puani", precision = 4, scale = 2)
    public BigDecimal minDisiplinPuani;

    @Column(name = "mac_tipi", length = 20)
    public String macTipi = "NORMAL"; // NORMAL, RAKIP_ARANIYOR, EKSIK_OYUNCU

    @Column(name = "eksik_oyuncu_sayisi")
    public Integer eksikOyuncuSayisi;

    @Column(name = "takim_adi", length = 100)
    public String takimAdi;

    @Column(name = "rakip_notu", length = 300)
    public String rakipNotu;

    @Column(name = "il", length = 100)
    public String il;

    @Column(name = "ilce", length = 100)
    public String ilce;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi;

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<Mac> findAcikMaclar() {
        return list("macDurumu = 'ACIK' AND macTarihi >= ?1 ORDER BY macTarihi ASC, baslangicSaati ASC",
                LocalDate.now());
    }

    public static List<Mac> findByOlusturanId(UUID olusturanId) {
        return list("olusturanId = ?1 ORDER BY olusturulmaTarihi DESC", olusturanId);
    }

    public static List<Mac> findBySahaId(UUID sahaId) {
        return list("sahaId = ?1 AND macDurumu = 'ACIK' AND macTarihi >= ?2 ORDER BY macTarihi ASC",
                sahaId, LocalDate.now());
    }

    public static List<Mac> ara(String query) {
        String like = "%" + query.toLowerCase() + "%";
        return list(
                "macDurumu = 'ACIK' AND macTarihi >= ?1 AND (" +
                        "LOWER(macBasligi) LIKE ?2 OR " +
                        "LOWER(COALESCE(aciklama, '')) LIKE ?2 OR " +
                        "LOWER(COALESCE(format, '')) LIKE ?2 OR " +
                        "LOWER(COALESCE(seviye, '')) LIKE ?2 OR " +
                        "LOWER(CASE COALESCE(seviye, '') " +
                        "WHEN 'BASLANGIC' THEN 'başlangıç' " +
                        "WHEN 'ORTA' THEN 'orta' " +
                        "WHEN 'ILERI' THEN 'ileri' " +
                        "ELSE 'karma' END) LIKE ?2 OR " +
                        "LOWER(COALESCE(macTipi, '')) LIKE ?2 OR " +
                        "LOWER(REPLACE(COALESCE(macTipi, ''), '_', ' ')) LIKE ?2 OR " +
                        "LOWER(CASE COALESCE(macTipi, '') " +
                        "WHEN 'RAKIP_ARANIYOR' THEN 'rakip aranıyor' " +
                        "WHEN 'EKSIK_OYUNCU' THEN 'eksik oyuncu' " +
                        "ELSE 'normal maç' END) LIKE ?2 OR " +
                        "LOWER(COALESCE(takimAdi, '')) LIKE ?2 OR " +
                        "LOWER(COALESCE(il, '')) LIKE ?2 OR " +
                        "LOWER(COALESCE(ilce, '')) LIKE ?2 OR " +
                        "olusturanId IN (SELECT k.id FROM Kullanici k WHERE LOWER(k.adSoyad) LIKE ?2) OR " +
                        "sahaId IN (SELECT s.id FROM HaliSaha s WHERE LOWER(s.sahaAdi) LIKE ?2 OR LOWER(s.adres) LIKE ?2)" +
                        ") ORDER BY macTarihi ASC, baslangicSaati ASC",
                LocalDate.now(), like);
    }
}
