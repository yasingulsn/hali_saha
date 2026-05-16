package com.halisaha.service;

import com.halisaha.dto.TakimIlaniRequest;
import com.halisaha.dto.TakimIlaniResponse;
import com.halisaha.entity.Kullanici;
import com.halisaha.entity.TakimIlani;
import com.halisaha.exception.AuthException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
public class TakimIlaniService {

    @jakarta.inject.Inject
    BildirimService bildirimService;

    public List<TakimIlaniResponse> aktifIlanlar() {
        List<TakimIlani> ilanlar = TakimIlani.findAktifIlanlar();
        return ilanlar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public TakimIlaniResponse ilanDetay(UUID ilanId) {
        TakimIlani ilan = TakimIlani.findById(ilanId);
        if (ilan == null) {
            throw new AuthException("İlan bulunamadı", 404);
        }
        return toResponse(ilan);
    }

    public List<TakimIlaniResponse> kullaniciIlanlari(UUID kullaniciId) {
        List<TakimIlani> ilanlar = TakimIlani.findByOlusturanId(kullaniciId);
        return ilanlar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public TakimIlaniResponse ilanOlustur(TakimIlaniRequest req, UUID kullaniciId) {
        TakimIlani ilan = new TakimIlani();
        ilan.olusturanId = kullaniciId;
        ilan.takimAdi = req.takimAdi.trim();
        ilan.ilanBasligi = req.ilanBasligi.trim();
        ilan.aciklama = req.aciklama;
        ilan.arananPozisyon = req.arananPozisyon != null ? req.arananPozisyon : "FARKETMEZ";
        ilan.arananOyuncuSayisi = req.arananOyuncuSayisi != null ? req.arananOyuncuSayisi : 1;
        ilan.minDisiplinPuani = req.minDisiplinPuani;
        ilan.seviye = req.seviye != null ? req.seviye : "KARMA";
        ilan.konum = req.konum;
        ilan.ilanDurumu = "AKTIF";
        ilan.olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        ilan.persist();

        // Yakındaki kullanıcılara bildirim gönder
        if (ilan.konum != null && ilan.konum.contains("/")) {
            String[] parts = ilan.konum.split("/");
            if (parts.length >= 3) {
                String il = parts[1].trim();
                String ilce = parts[2].trim();
                bildirimService.yakinIlanBildirimiGonder(
                    il, 
                    ilce, 
                    "Yeni Takım İlanı!", 
                    ilce + " bölgesinde yeni bir ilan verildi: " + ilan.ilanBasligi,
                    ilan.id.toString(),
                    kullaniciId,
                    "YAKIN_TAKIM"
                );
            }
        }

        return toResponse(ilan);
    }

    @Transactional
    public void ilanKapat(UUID ilanId, UUID kullaniciId) {
        TakimIlani ilan = TakimIlani.findById(ilanId);
        if (ilan == null) {
            throw new AuthException("İlan bulunamadı", 404);
        }
        if (!ilan.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Bu ilanı kapatma yetkiniz yok", 403);
        }
        ilan.ilanDurumu = "KAPALI";
        ilan.persist();
    }

    @Transactional
    public TakimIlaniResponse ilanGuncelle(UUID ilanId, TakimIlaniRequest req, UUID kullaniciId) {
        TakimIlani ilan = TakimIlani.findById(ilanId);
        if (ilan == null) {
            throw new AuthException("İlan bulunamadı", 404);
        }
        if (!ilan.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Bu ilanı düzenleme yetkiniz yok", 403);
        }

        ilan.takimAdi = req.takimAdi.trim();
        ilan.ilanBasligi = req.ilanBasligi.trim();
        ilan.aciklama = req.aciklama;
        ilan.arananPozisyon = req.arananPozisyon != null ? req.arananPozisyon : "FARKETMEZ";
        ilan.arananOyuncuSayisi = req.arananOyuncuSayisi != null ? req.arananOyuncuSayisi : 1;
        ilan.minDisiplinPuani = req.minDisiplinPuani;
        ilan.seviye = req.seviye != null ? req.seviye : "KARMA";
        ilan.konum = req.konum;
        ilan.persist();
        return toResponse(ilan);
    }

    @Transactional
    public void ilanSil(UUID ilanId, UUID kullaniciId) {
        TakimIlani ilan = TakimIlani.findById(ilanId);
        if (ilan == null) {
            throw new AuthException("İlan bulunamadı", 404);
        }
        if (!ilan.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Bu ilanı silme yetkiniz yok", 403);
        }
        ilan.delete();
    }

    public List<TakimIlaniResponse> ilanlarAra(String query) {
        List<TakimIlani> ilanlar = TakimIlani.ara(query);
        return ilanlar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<TakimIlaniResponse> ilanlarKonumaGore(String il, String ilce) {
        List<TakimIlani> ilanlar = TakimIlani.findByKonum(il, ilce);
        return ilanlar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public void katilmaIstegiGonder(UUID ilanId, String mesaj, UUID gonderenId) {
        TakimIlani ilan = TakimIlani.findById(ilanId);
        if (ilan == null) {
            throw new AuthException("İlan bulunamadı", 404);
        }
        if (ilan.olusturanId.equals(gonderenId)) {
            throw new AuthException("Kendi ilanınıza istek gönderemezsiniz", 400);
        }

        com.halisaha.entity.TakimIlaniIstek mevcut = com.halisaha.entity.TakimIlaniIstek.findByIlanAndGonderen(ilanId, gonderenId);
        if (mevcut != null) {
            throw new AuthException("Bu ilana zaten bir isteğiniz bulunuyor", 409);
        }

        com.halisaha.entity.TakimIlaniIstek istek = new com.halisaha.entity.TakimIlaniIstek();
        istek.ilanId = ilanId;
        istek.gonderenId = gonderenId;
        istek.mesaj = mesaj;
        istek.persist();

        // İlan sahibine bildirim gönder
        Kullanici gonderen = Kullanici.findById(gonderenId);
        bildirimService.bildirimOlustur(
            ilan.olusturanId,
            "Yeni Takım İsteği",
            (gonderen != null ? gonderen.adSoyad : "Bir oyuncu") + " '" + ilan.ilanBasligi + "' ilanınıza katılmak istiyor.",
            "MAC_ISTEK",
            ilanId.toString(),
            istek.id.toString()
        );
    }

    public List<com.halisaha.dto.TakimIlaniIstekResponse> gelenIstekler(UUID kullaniciId) {
        List<com.halisaha.entity.TakimIlaniIstek> istekler = com.halisaha.entity.TakimIlaniIstek.find(
            "SELECT i FROM TakimIlaniIstek i JOIN i.ilan ilan WHERE ilan.olusturanId = ?1 AND i.durum = 'BEKLEMEDE' ORDER BY i.olusturulmaTarihi DESC",
            kullaniciId
        ).list();
        return istekler.stream().map(com.halisaha.dto.TakimIlaniIstekResponse::fromEntity).collect(Collectors.toList());
    }

    public List<com.halisaha.dto.TakimIlaniIstekResponse> gonderdigimIstekler(UUID kullaniciId) {
        List<com.halisaha.entity.TakimIlaniIstek> istekler = com.halisaha.entity.TakimIlaniIstek.find(
            "SELECT i FROM TakimIlaniIstek i JOIN FETCH i.ilan WHERE i.gonderenId = ?1 ORDER BY i.olusturulmaTarihi DESC",
            kullaniciId
        ).list();
        return istekler.stream().map(com.halisaha.dto.TakimIlaniIstekResponse::fromEntity).collect(Collectors.toList());
    }

    @Transactional
    public void istekOnayla(UUID istekId, UUID kullaniciId) {
        com.halisaha.entity.TakimIlaniIstek istek = com.halisaha.entity.TakimIlaniIstek.findById(istekId);
        if (istek == null) throw new AuthException("İstek bulunamadı", 404);
        
        TakimIlani ilan = TakimIlani.findById(istek.ilanId);
        if (!ilan.olusturanId.equals(kullaniciId)) throw new AuthException("Bu işlemi yapmaya yetkiniz yok", 403);
        
        istek.durum = "ONAYLANDI";
        istek.persist();
        
        // İstek sahibine bildirim gönder
        bildirimService.bildirimOlustur(
            istek.gonderenId,
            "İsteğiniz Onaylandı!",
            "'" + ilan.ilanBasligi + "' ilanı için gönderdiğiniz istek onaylandı.",
            "MAC_KATILIM",
            ilan.id.toString()
        );
    }

    @Transactional
    public void istekReddet(UUID istekId, UUID kullaniciId) {
        com.halisaha.entity.TakimIlaniIstek istek = com.halisaha.entity.TakimIlaniIstek.findById(istekId);
        if (istek == null) throw new AuthException("İstek bulunamadı", 404);
        
        TakimIlani ilan = TakimIlani.findById(istek.ilanId);
        if (!ilan.olusturanId.equals(kullaniciId)) throw new AuthException("Bu işlemi yapmaya yetkiniz yok", 403);
        
        istek.durum = "REDDEDILDI";
        istek.persist();
    }

    private TakimIlaniResponse toResponse(TakimIlani ilan) {
        Kullanici k = ilan.olusturan != null ? ilan.olusturan : Kullanici.findById(ilan.olusturanId);
        String ad = k != null ? k.adSoyad : "Bilinmeyen";
        return TakimIlaniResponse.from(ilan, ad);
    }
}
