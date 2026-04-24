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

    private TakimIlaniResponse toResponse(TakimIlani ilan) {
        Kullanici k = ilan.olusturan != null ? ilan.olusturan : Kullanici.findById(ilan.olusturanId);
        String ad = k != null ? k.adSoyad : "Bilinmeyen";
        return TakimIlaniResponse.from(ilan, ad);
    }
}
