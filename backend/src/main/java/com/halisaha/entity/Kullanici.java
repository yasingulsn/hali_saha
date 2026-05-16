package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "kullanici_tb")
public class Kullanici extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "ad_soyad", nullable = false, length = 100)
    public String adSoyad;

    @Column(nullable = false, unique = true, length = 150)
    public String email;

    @Column(nullable = false)
    public String sifre;

    @Column(length = 20)
    public String telefon;

    @Column(name = "profil_foto_url")
    public String profilFotoUrl;

    @Column(name = "kayit_tarihi")
    public OffsetDateTime kayitTarihi;

    @Column(name = "aktif_mi")
    public Boolean aktifMi = true;

    @Column(name = "dogum_tarihi")
    public LocalDate dogumTarihi;

    @Column(name = "puan_ortalaması", precision = 3, scale = 2)
    public BigDecimal puanOrtalamasi = BigDecimal.ZERO;

    @Column(name = "disiplin_puani", precision = 4, scale = 2)
    public BigDecimal disiplinPuani = new BigDecimal("5.00");

    @Column(name = "yorum_sayisi")
    public Integer yorumSayisi = 0;

    @Column(name = "tercih_edilen_pozisyon", length = 30)
    public String tercihEdilenPozisyon;

    @Column(name = "son_enlem")
    public Double sonEnlem;

    @Column(name = "son_boylam")
    public Double sonBoylam;

    @Column(name = "son_giris_tarihi")
    public OffsetDateTime sonGirisTarihi;

    @Column(name = "email_dogrulanmis")
    public Boolean emailDogrulanmis = false;

    @Column(name = "email_dogrulama_token", length = 100)
    public String emailDogrulamaToken;

    @Column(name = "hesap_durumu", length = 20)
    public String hesapDurumu = "AKTIF";

    @Column(name = "il", length = 50)
    public String il;

    @Column(name = "ilce", length = 50)
    public String ilce;

    public static Kullanici findByEmail(String email) {
        return find("email", email).firstResult();
    }
}
