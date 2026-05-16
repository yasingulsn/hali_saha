package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "fcm_token_tb",
       uniqueConstraints = @UniqueConstraint(columnNames = {"kullanici_id", "platform"}))
public class FcmToken extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "kullanici_id", nullable = false, columnDefinition = "uuid")
    public UUID kullaniciId;

    @Column(name = "token", nullable = false, length = 500)
    public String token;

    @Column(name = "platform", length = 20)
    public String platform = "android"; // android, ios, web

    @Column(name = "guncelleme_tarihi")
    public OffsetDateTime guncellemeTarihi = OffsetDateTime.now();

    public static List<FcmToken> findByKullaniciId(UUID kullaniciId) {
        return list("kullaniciId = ?1", kullaniciId);
    }

    public static FcmToken findByKullaniciAndPlatform(UUID kullaniciId, String platform) {
        return find("kullaniciId = ?1 AND platform = ?2", kullaniciId, platform).firstResult();
    }
}
