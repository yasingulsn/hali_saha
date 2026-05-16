package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "saha_yorum_tb")
public class SahaYorum extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "saha_id", nullable = false, columnDefinition = "uuid")
    public UUID sahaId;

    @Column(name = "kullanici_id", nullable = false, columnDefinition = "uuid")
    public UUID kullaniciId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kullanici_id", insertable = false, updatable = false)
    public Kullanici kullanici;

    @Column(nullable = false)
    public int puan; // 1-5

    @Column(length = 500)
    public String yorum;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);

    public static List<SahaYorum> findBySahaId(UUID sahaId) {
        return list("sahaId = ?1 ORDER BY olusturulmaTarihi DESC", sahaId);
    }

    public static boolean kullaniciZatenYorumYaptiMi(UUID sahaId, UUID kullaniciId) {
        return count("sahaId = ?1 AND kullaniciId = ?2", sahaId, kullaniciId) > 0;
    }

    public static double ortalamaPuan(UUID sahaId) {
        Object result = getEntityManager()
                .createQuery("SELECT AVG(y.puan) FROM SahaYorum y WHERE y.sahaId = :sahaId")
                .setParameter("sahaId", sahaId)
                .getSingleResult();
        return result != null ? ((Number) result).doubleValue() : 0.0;
    }
}
