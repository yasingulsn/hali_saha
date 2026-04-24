package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "hesap_kilitleme_tb")
public class HesapKilitleme extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(nullable = false, length = 150)
    public String email;

    @Column(name = "basarisiz_deneme_sayisi")
    public Integer basarisizDenemeSayisi = 0;

    @Column(name = "son_basarisiz_deneme")
    public OffsetDateTime sonBasarisizDeneme;

    @Column(name = "kilitleme_tarihi")
    public OffsetDateTime kilitlemeTarihi;

    @Column(name = "kilit_bitis_tarihi")
    public OffsetDateTime kilitBitisTarihi;

    @Column(name = "kilitli_mi")
    public Boolean kilitliMi = false;

    public static HesapKilitleme findByEmail(String email) {
        return find("email", email).firstResult();
    }
}
