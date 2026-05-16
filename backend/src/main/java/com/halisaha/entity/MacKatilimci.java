package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "mac_katilimci_tb",
       uniqueConstraints = @UniqueConstraint(columnNames = {"mac_id", "kullanici_id"}))
public class MacKatilimci extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "mac_id", nullable = false, columnDefinition = "uuid")
    public UUID macId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "mac_id", insertable = false, updatable = false)
    public Mac mac;

    @Column(name = "kullanici_id", nullable = false, columnDefinition = "uuid")
    public UUID kullaniciId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "kullanici_id", insertable = false, updatable = false)
    public Kullanici kullanici;

    @Column(name = "katilim_durumu", nullable = false, length = 20)
    public String katilimDurumu = "ONAYLANDI"; // ONAYLANDI, BEKLEMEDE, AYRILDI

    @Column(name = "katilim_tarihi")
    public OffsetDateTime katilimTarihi;

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<MacKatilimci> findByMacId(UUID macId) {
        return list("macId = ?1 AND katilimDurumu != 'AYRILDI'", macId);
    }

    public static MacKatilimci findByMacIdAndKullaniciId(UUID macId, UUID kullaniciId) {
        return find("macId = ?1 AND kullaniciId = ?2", macId, kullaniciId).firstResult();
    }

    public static List<MacKatilimci> findByKullaniciId(UUID kullaniciId) {
        return list("kullaniciId = ?1 AND katilimDurumu = 'ONAYLANDI'", kullaniciId);
    }

    public static long countAktifKatilimcilar(UUID macId) {
        return count("macId = ?1 AND katilimDurumu = 'ONAYLANDI'", macId);
    }

}
