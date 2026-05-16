package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "mac_puanlama_tb",
       uniqueConstraints = @UniqueConstraint(columnNames = {"mac_id", "puanlayan_id", "hedef_id"}))
public class MacPuanlama extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "mac_id", nullable = false, columnDefinition = "uuid")
    public UUID macId;

    @Column(name = "puanlayan_id", nullable = false, columnDefinition = "uuid")
    public UUID puanlayanId;

    @Column(name = "hedef_id", nullable = false, columnDefinition = "uuid")
    public UUID hedefId;

    @Column(nullable = false)
    public Integer puan;

    @Column(name = "tarih")
    public OffsetDateTime tarih = OffsetDateTime.now();

    public static boolean zatenPuanladi(UUID macId, UUID puanlayanId, UUID hedefId) {
        return count("macId = ?1 AND puanlayanId = ?2 AND hedefId = ?3",
                macId, puanlayanId, hedefId) > 0;
    }

    public static java.util.List<UUID> puanlananIdler(UUID macId, UUID puanlayanId) {
        return find("macId = ?1 AND puanlayanId = ?2", macId, puanlayanId)
                .<MacPuanlama>list()
                .stream()
                .map(p -> p.hedefId)
                .collect(java.util.stream.Collectors.toList());
    }
}
