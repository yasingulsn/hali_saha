package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Entity
@Table(name = "takip_tb",
       uniqueConstraints = @UniqueConstraint(columnNames = {"takipci_id", "takip_edilen_id"}))
public class Takip extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "takipci_id", nullable = false, columnDefinition = "uuid")
    public UUID takipciId;

    @Column(name = "takip_edilen_id", nullable = false, columnDefinition = "uuid")
    public UUID takipEdilenId;

    @Column(name = "takip_tarihi")
    public OffsetDateTime takipTarihi = OffsetDateTime.now();

    public static boolean zatenTakipEdiyor(UUID takipciId, UUID takipEdilenId) {
        return count("takipciId = ?1 AND takipEdilenId = ?2", takipciId, takipEdilenId) > 0;
    }

    public static long takipEdilenSayisi(UUID kullaniciId) {
        return count("takipciId", kullaniciId);
    }

    public static long takipciSayisi(UUID kullaniciId) {
        return count("takipEdilenId", kullaniciId);
    }

    public static List<UUID> takipEdilenIdler(UUID takipciId) {
        return find("takipciId", takipciId).<Takip>list()
                .stream().map(t -> t.takipEdilenId).collect(Collectors.toList());
    }

    public static List<UUID> takipciIdler(UUID takipEdilenId) {
        return find("takipEdilenId", takipEdilenId).<Takip>list()
                .stream().map(t -> t.takipciId).collect(Collectors.toList());
    }
}
