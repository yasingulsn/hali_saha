package com.halisaha.service;

import com.halisaha.entity.Bildirim;
import com.halisaha.entity.Kullanici;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
public class BildirimService {

    @Transactional
    public void bildirimOlustur(UUID aliciId, String baslik, String mesaj, String bildirimTipi, String hedefId, String aksiyonId) {
        Bildirim bildirim = new Bildirim();
        bildirim.aliciId = aliciId;
        bildirim.baslik = baslik;
        bildirim.mesaj = mesaj;
        bildirim.bildirimTipi = bildirimTipi;
        bildirim.hedefId = hedefId;
        bildirim.aksiyonId = aksiyonId;
        bildirim.persist();
    }

    @Transactional
    public void bildirimOlustur(UUID aliciId, String baslik, String mesaj, String bildirimTipi, String hedefId) {
        bildirimOlustur(aliciId, baslik, mesaj, bildirimTipi, hedefId, null);
    }

    public List<Bildirim> kullaniciBildirimleri(UUID aliciId) {
        return Bildirim.findByAliciId(aliciId);
    }

    public long okunmamisSayisi(UUID aliciId) {
        return Bildirim.countUnread(aliciId);
    }

    @Transactional
    public void okunduIsaretle(UUID bildirimId) {
        Bildirim.markAsRead(bildirimId);
    }

    @Transactional
    public void tumunuOkunduIsaretle(UUID aliciId) {
        Bildirim.markAllAsRead(aliciId);
    }

    @Transactional
    public void bildirimSil(UUID id) {
        Bildirim.deleteById(id);
    }

    @Transactional
    public void yakinIlanBildirimiGonder(String il, String ilce, String baslik, String mesaj, String hedefId, UUID haricKullaniciId, String bildirimTipi) {
        // Bu il ve ilcedeki kullanıcıları bul (oluşturan hariç)
        List<Kullanici> kullanicilar = Kullanici.list("il = ?1 AND ilce = ?2 AND id != ?3", il, ilce, haricKullaniciId);
        for (Kullanici k : kullanicilar) {
            bildirimOlustur(k.id, baslik, mesaj, bildirimTipi, hedefId);
        }
    }
}
