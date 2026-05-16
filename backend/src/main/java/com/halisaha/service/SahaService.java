package com.halisaha.service;

import com.halisaha.dto.SahaRequest;
import com.halisaha.dto.SahaResponse;
import com.halisaha.dto.SahaYorumRequest;
import com.halisaha.dto.SahaYorumResponse;
import com.halisaha.entity.HaliSaha;
import com.halisaha.entity.Isletme;
import com.halisaha.entity.SahaYorum;
import com.halisaha.exception.AuthException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
public class SahaService {

    public List<SahaResponse> tumSahalar() {
        List<HaliSaha> sahalar = HaliSaha.findAktifSahalar();
        return sahalar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<SahaResponse> tumSahalarPaged(int page, int size) {
        List<HaliSaha> sahalar = HaliSaha.findAktifSahalarPaged(page, size);
        return sahalar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public SahaResponse sahaDetay(UUID sahaId) {
        HaliSaha saha = HaliSaha.findById(sahaId);
        if (saha == null || !saha.aktifMi) {
            throw new AuthException("Saha bulunamadı", 404);
        }
        return toResponse(saha);
    }

    public List<SahaResponse> isletmeSahalari(UUID isletmeId) {
        List<HaliSaha> sahalar = HaliSaha.findByIsletmeId(isletmeId);
        return sahalar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public SahaResponse sahaEkle(SahaRequest req, UUID isletmeId) {
        Isletme isletme = Isletme.findById(isletmeId);
        if (isletme == null) {
            throw new AuthException("İşletme bulunamadı", 404);
        }

        HaliSaha saha = new HaliSaha();
        saha.isletmeId = isletmeId;
        saha.sahaAdi = req.sahaAdi.trim();
        saha.adres = req.adres.trim();
        saha.enlem = req.enlem;
        saha.boylam = req.boylam;
        saha.sahaFormati = req.sahaFormati;
        saha.saatlikUcret = req.saatlikUcret;
        saha.kapaliMi = req.kapaliMi != null ? req.kapaliMi : false;
        saha.ozellikler = req.ozellikler;
        saha.fotografUrl = req.fotografUrl;
        saha.aktifMi = true;
        saha.puanOrtalamasi = java.math.BigDecimal.ZERO;
        saha.yorumSayisi = 0;
        saha.olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        saha.persist();

        return toResponse(saha);
    }

    @Transactional
    public SahaResponse sahaGuncelle(UUID sahaId, SahaRequest req, UUID isletmeId) {
        HaliSaha saha = HaliSaha.findById(sahaId);
        if (saha == null) {
            throw new AuthException("Saha bulunamadı", 404);
        }
        if (!saha.isletmeId.equals(isletmeId)) {
            throw new AuthException("Bu sahayı düzenleme yetkiniz yok", 403);
        }

        saha.sahaAdi = req.sahaAdi.trim();
        saha.adres = req.adres.trim();
        saha.enlem = req.enlem;
        saha.boylam = req.boylam;
        saha.sahaFormati = req.sahaFormati;
        saha.saatlikUcret = req.saatlikUcret;
        saha.kapaliMi = req.kapaliMi != null ? req.kapaliMi : false;
        saha.ozellikler = req.ozellikler;
        saha.fotografUrl = req.fotografUrl;
        saha.persist();

        return toResponse(saha);
    }

    public List<SahaYorumResponse> sahaYorumlari(UUID sahaId) {
        return SahaYorum.findBySahaId(sahaId)
                .stream().map(SahaYorumResponse::from).collect(Collectors.toList());
    }

    @Transactional
    public SahaYorumResponse yorumEkle(UUID sahaId, SahaYorumRequest req, UUID kullaniciId) {
        HaliSaha saha = HaliSaha.findById(sahaId);
        if (saha == null) throw new AuthException("Saha bulunamadı", 404);
        if (SahaYorum.kullaniciZatenYorumYaptiMi(sahaId, kullaniciId)) {
            throw new AuthException("Bu sahayı zaten değerlendirdiniz", 409);
        }

        SahaYorum y = new SahaYorum();
        y.sahaId = sahaId;
        y.kullaniciId = kullaniciId;
        y.puan = req.puan;
        y.yorum = req.yorum;
        y.persist();

        double ort = SahaYorum.ortalamaPuan(sahaId);
        long sayi = SahaYorum.count("sahaId = ?1", sahaId);
        saha.puanOrtalamasi = java.math.BigDecimal.valueOf(ort).setScale(2, java.math.RoundingMode.HALF_UP);
        saha.yorumSayisi = (int) sayi;
        saha.persist();

        y.kullanici = com.halisaha.entity.Kullanici.findById(kullaniciId);
        return SahaYorumResponse.from(y);
    }

    public List<SahaResponse> sahalarAra(String query) {
        List<HaliSaha> sahalar = HaliSaha.ara(query);
        return sahalar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<SahaResponse> sahalarKonumaGore(String il, String ilce) {
        List<HaliSaha> sahalar = HaliSaha.findByKonum(il, ilce);
        return sahalar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private SahaResponse toResponse(HaliSaha saha) {
        Isletme isletme = saha.isletme != null ? saha.isletme : Isletme.findById(saha.isletmeId);
        String isletmeAdi = isletme != null ? isletme.isletmeAdi : "Bilinmeyen";
        return SahaResponse.from(saha, isletmeAdi);
    }
}
