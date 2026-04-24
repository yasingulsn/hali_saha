package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "refresh_token_tb")
public class RefreshToken extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "kullanici_id")
    public UUID kullaniciId;

    @Column(name = "isletme_id")
    public UUID isletmeId;

    @Column(name = "kullanici_tipi", nullable = false, length = 20)
    public String kullaniciTipi;

    @Column(name = "token_hash", nullable = false)
    public String tokenHash;

    @Column(name = "cihaz_bilgisi")
    public String cihazBilgisi;

    @Column(name = "ip_adresi", length = 50)
    public String ipAdresi;

    @Column(name = "son_kullanim_tarihi")
    public OffsetDateTime sonKullanimTarihi;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi;

    @Column(name = "gecerlilik_tarihi", nullable = false)
    public OffsetDateTime gecerlilikTarihi;

    @Column(name = "iptal_edildi_mi")
    public Boolean iptalEdildiMi = false;

    public static RefreshToken findByTokenHash(String hash) {
        return find("tokenHash = ?1 AND iptalEdildiMi = false", hash).firstResult();
    }

    public static List<RefreshToken> findActiveByKullaniciId(UUID kullaniciId) {
        return list("kullaniciId = ?1 AND iptalEdildiMi = false", kullaniciId);
    }

    public static List<RefreshToken> findActiveByIsletmeId(UUID isletmeId) {
        return list("isletmeId = ?1 AND iptalEdildiMi = false", isletmeId);
    }

    public static int revokeAllByKullaniciId(UUID kullaniciId) {
        return update("iptalEdildiMi = true WHERE kullaniciId = ?1 AND iptalEdildiMi = false", kullaniciId);
    }

    public static int revokeAllByIsletmeId(UUID isletmeId) {
        return update("iptalEdildiMi = true WHERE isletmeId = ?1 AND iptalEdildiMi = false", isletmeId);
    }
}
