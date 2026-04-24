package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "isletme_tb")
public class Isletme extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "isletme_adi", nullable = false, length = 200)
    public String isletmeAdi;

    @Column(name = "yetkili_ad_soyad", nullable = false, length = 100)
    public String yetkiliAdSoyad;

    @Column(nullable = false, unique = true, length = 150)
    public String email;

    @Column(nullable = false)
    public String sifre;

    @Column(nullable = false, length = 20)
    public String telefon;

    @Column(name = "vergi_no", length = 50)
    public String vergiNo;

    public String adres;

    @Column(name = "onayli_mi")
    public Boolean onayliMi = false;

    @Column(name = "kayit_tarihi")
    public OffsetDateTime kayitTarihi;

    @Column(name = "konum_enlem")
    public Double konumEnlem;

    @Column(name = "konum_boylam")
    public Double konumBoylam;

    @Column(name = "son_giris_tarihi")
    public OffsetDateTime sonGirisTarihi;

    @Column(name = "email_dogrulanmis")
    public Boolean emailDogrulanmis = false;

    @Column(name = "hesap_durumu", length = 20)
    public String hesapDurumu = "AKTIF";

    public static Isletme findByEmail(String email) {
        return find("email", email).firstResult();
    }
}
