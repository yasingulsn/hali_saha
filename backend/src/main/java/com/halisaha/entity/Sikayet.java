package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "sikayet_tb")
public class Sikayet extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "sikayet_eden_id", nullable = false, columnDefinition = "uuid")
    public UUID sikayetEdenId;

    @Column(name = "sikayet_edilen_id", nullable = false, columnDefinition = "uuid")
    public UUID sikayetEdilenId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sikayet_edilen_id", insertable = false, updatable = false)
    public Kullanici sikayetEdilen;

    @Column(name = "mac_id", columnDefinition = "uuid")
    public UUID macId;

    @Column(nullable = false, length = 50)
    public String kategori; // GELMEME, KAVGA, KURAL_IHLALI, DIGER

    @Column(length = 500)
    public String aciklama;

    @Column(nullable = false, length = 20)
    public String durum = "BEKLEMEDE"; // BEKLEMEDE, INCELENIYOR, SONUCLANDI

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);

    public static List<Sikayet> findBySikayetEdenId(UUID kullaniciId) {
        return list("sikayetEdenId = ?1 ORDER BY olusturulmaTarihi DESC", kullaniciId);
    }
}
