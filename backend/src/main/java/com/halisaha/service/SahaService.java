package com.halisaha.service;

import com.halisaha.dto.SahaRequest;
import com.halisaha.dto.SahaResponse;
import com.halisaha.entity.HaliSaha;
import com.halisaha.entity.Isletme;
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
