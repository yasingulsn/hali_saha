package com.halisaha.entity;

import io.quarkus.hibernate.orm.panache.PanacheEntityBase;
import jakarta.persistence.*;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "bildirim_tb")
public class Bildirim extends PanacheEntityBase {

    @Id
    @GeneratedValue
    @Column(columnDefinition = "uuid")
    public UUID id;

    @Column(name = "alici_id", nullable = false, columnDefinition = "uuid")
    public UUID aliciId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alici_id", insertable = false, updatable = false)
    public Kullanici alici;

    @Column(nullable = false, length = 200)
    public String baslik;

    @Column(nullable = false, length = 500)
    public String mesaj;

    @Column(name = "bildirim_tipi", nullable = false, length = 50)
    public String bildirimTipi; // MAC_KATILIM, MAC_ISTEK, YAKIN_ILAN, SISTEM

    @Column(name = "hedef_id", length = 100)
    public String hedefId; // Mac ID, Takım İlanı ID vb.

    @Column(name = "aksiyon_id", length = 100)
    public String aksiyonId; // İstek ID vb. aksiyonlar için

    @Column(name = "okundu_mu")
    public boolean okunduMu = false;

    @Column(name = "olusturulma_tarihi")
    public OffsetDateTime olusturulmaTarihi = OffsetDateTime.now();

    // ─── QUERY METHODS ──────────────────────────────────────────

    public static List<Bildirim> findByAliciId(UUID aliciId) {
        return list("aliciId = ?1 ORDER BY olusturulmaTarihi DESC", aliciId);
    }

    public static long countUnread(UUID aliciId) {
        return count("aliciId = ?1 AND okunduMu = false", aliciId);
    }

    public static void markAsRead(UUID id) {
        update("okunduMu = true WHERE id = ?1", id);
    }

    public static void markAllAsRead(UUID aliciId) {
        update("okunduMu = true WHERE aliciId = ?1", aliciId);
    }
}
