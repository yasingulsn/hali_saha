package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "rezervasyon_tb")
public class Rezervasyon extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "saha_id", nullable = false, columnDefinition = "uuid")
    public UUID sahaId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "saha_id", insertable = false, updatable = false)
    public HaliSaha saha;

    @Column(name = "kullanici_id", nullable = false, columnDefinition = "uuid")
    public UUID kullaniciId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kullanici_id", insertable = false, updatable = false)
    public Kullanici kullanici;

    @Column(name = "rezervasyon_tarihi", nullable = false)
    public LocalDate rezervasyonTarihi;

    @Column(name = "baslangic_saati", nullable = false)
    public LocalTime baslangicSaati;

    @Column(name = "bitis_saati", nullable = false)
    public LocalTime bitisSaati;

    @Column(name = "toplam_ucret", precision = 10, scale = 2)
    public BigDecimal toplamUcret;

    @Column(length = 20)
    public String durum = "BEKLEMEDE"; // BEKLEMEDE, ONAYLANDI, IPTAL, TAMAMLANDI

    @Column(length = 500)
    public String notlar;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<Rezervasyon> findByKullaniciId(UUID kullaniciId) {
        return list("kullaniciId = ?1 ORDER BY rezervasyonTarihi DESC, baslangicSaati DESC", kullaniciId);
    }

    public static List<Rezervasyon> findBySahaId(UUID sahaId) {
        return list("sahaId = ?1 ORDER BY rezervasyonTarihi DESC, baslangicSaati DESC", sahaId);
    }

    public static List<Rezervasyon> findBySahaAndTarih(UUID sahaId, LocalDate tarih) {
        return list("sahaId = ?1 AND rezervasyonTarihi = ?2 AND durum != 'IPTAL' ORDER BY baslangicSaati", sahaId, tarih);
    }

    public static List<Rezervasyon> findByIsletmeId(UUID isletmeId) {
        return list("sahaId IN (SELECT s.id FROM HaliSaha s WHERE s.isletmeId = ?1) ORDER BY rezervasyonTarihi DESC, baslangicSaati DESC", isletmeId);
    }

    public static boolean cakismaVarMi(UUID sahaId, LocalDate tarih, LocalTime baslangic, LocalTime bitis, UUID excludeId) {
        String query = "sahaId = ?1 AND rezervasyonTarihi = ?2 AND durum != 'IPTAL' " +
                "AND baslangicSaati < ?4 AND bitisSaati > ?3";
        if (excludeId != null) {
            query += " AND id != ?5";
            return count(query, sahaId, tarih, baslangic, bitis, excludeId) > 0;
        }
        return count(query, sahaId, tarih, baslangic, bitis) > 0;
    }
}
