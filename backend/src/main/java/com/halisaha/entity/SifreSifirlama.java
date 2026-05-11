package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "sifre_sifirlama_tb")
public class SifreSifirlama extends PanacheEntityBase {

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

    @Column(name = "token", nullable = false)
    public String token;

    @Column(name = "gecerlilik_tarihi", nullable = false)
    public OffsetDateTime gecerlilikTarihi;

    @Column(name = "kullanildi_mi")
    public Boolean kullanildiMi = false;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi;
}
