package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "takim_ilani_istek_tb")
public class TakimIlaniIstek extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "ilan_id", nullable = false, columnDefinition = "uuid")
    public UUID ilanId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ilan_id", insertable = false, updatable = false)
    public TakimIlani ilan;

    @Column(name = "gonderen_id", nullable = false, columnDefinition = "uuid")
    public UUID gonderenId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "gonderen_id", insertable = false, updatable = false)
    public Kullanici gonderen;

    @Column(length = 500)
    public String mesaj; // İletişim bilgisi veya not

    @Column(length = 20)
    public String durum = "BEKLEMEDE"; // BEKLEMEDE, ONAYLANDI, REDDEDILDI

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi = OffsetDateTime.now();

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<TakimIlaniIstek> findByIlanId(UUID ilanId) {
        return list("ilanId = ?1 ORDER BY olusturulmaTarihi DESC", ilanId);
    }

    public static List<TakimIlaniIstek> findByGonderenId(UUID gonderenId) {
        return list("gonderenId = ?1 ORDER BY olusturulmaTarihi DESC", gonderenId);
    }

    public static TakimIlaniIstek findByIlanAndGonderen(UUID ilanId, UUID gonderenId) {
        return find("ilanId = ?1 AND gonderenId = ?2", ilanId, gonderenId).firstResult();
    }
}
