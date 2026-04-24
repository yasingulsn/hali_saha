package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "giris_gecmisi_tb")
public class GirisGecmisi extends PanacheEntityBase {

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

    @Column(name = "ip_adresi", length = 50)
    public String ipAdresi;

    @Column(name = "cihaz_bilgisi")
    public String cihazBilgisi;

    @Column(name = "basarili_mi", nullable = false)
    public Boolean basariliMi;

    @Column(name = "hata_mesaji")
    public String hataMesaji;

    @Column(name = "giris_tarihi")
    public OffsetDateTime girisTarihi;
}
