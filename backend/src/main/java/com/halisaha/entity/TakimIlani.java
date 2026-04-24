package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "takim_ilani_tb")
public class TakimIlani extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "olusturan_id", nullable = false, columnDefinition = "uuid")
    public UUID olusturanId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "olusturan_id", insertable = false, updatable = false)
    public Kullanici olusturan;

    @Column(name = "takim_adi", nullable = false, length = 100)
    public String takimAdi;

    @Column(name = "ilan_basligi", nullable = false, length = 200)
    public String ilanBasligi;

    @Column(length = 500)
    public String aciklama;

    @Column(name = "aranan_pozisyon", length = 50)
    public String arananPozisyon; // KALECI, DEFANS, ORTASAHA, FORVET, FARKETMEZ

    @Column(name = "aranan_oyuncu_sayisi")
    public Integer arananOyuncuSayisi = 1;

    @Column(name = "min_disiplin_puani", precision = 4, scale = 2)
    public BigDecimal minDisiplinPuani;

    @Column(length = 20)
    public String seviye = "KARMA"; // BASLANGIC, ORTA, ILERI, KARMA

    @Column(length = 100)
    public String konum;

    @Column(name = "ilan_durumu", length = 20)
    public String ilanDurumu = "AKTIF"; // AKTIF, KAPALI, DOLDU

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi;

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<TakimIlani> findAktifIlanlar() {
        return list("ilanDurumu = 'AKTIF' ORDER BY olusturulmaTarihi DESC");
    }

    public static List<TakimIlani> findByOlusturanId(UUID olusturanId) {
        return list("olusturanId = ?1 ORDER BY olusturulmaTarihi DESC", olusturanId);
    }

    public static List<TakimIlani> ara(String query) {
        String like = "%" + query.toLowerCase() + "%";
        return list(
                "ilanDurumu = 'AKTIF' AND (" +
                        "LOWER(ilanBasligi) LIKE ?1 OR " +
                        "LOWER(takimAdi) LIKE ?1 OR " +
                        "LOWER(COALESCE(aciklama, '')) LIKE ?1 OR " +
                        "LOWER(COALESCE(konum, '')) LIKE ?1 OR " +
                        "LOWER(COALESCE(arananPozisyon, '')) LIKE ?1 OR " +
                        "LOWER(CASE COALESCE(arananPozisyon, '') " +
                        "WHEN 'KALECI' THEN 'kaleci' " +
                        "WHEN 'DEFANS' THEN 'defans' " +
                        "WHEN 'ORTASAHA' THEN 'orta saha' " +
                        "WHEN 'FORVET' THEN 'forvet' " +
                        "ELSE 'farketmez' END) LIKE ?1 OR " +
                        "LOWER(COALESCE(seviye, '')) LIKE ?1 OR " +
                        "LOWER(CASE COALESCE(seviye, '') " +
                        "WHEN 'BASLANGIC' THEN 'başlangıç' " +
                        "WHEN 'ORTA' THEN 'orta' " +
                        "WHEN 'ILERI' THEN 'ileri' " +
                        "ELSE 'karma' END) LIKE ?1 OR " +
                        "olusturanId IN (SELECT k.id FROM Kullanici k WHERE LOWER(k.adSoyad) LIKE ?1)" +
                        ") ORDER BY olusturulmaTarihi DESC",
                like);
    }
}
