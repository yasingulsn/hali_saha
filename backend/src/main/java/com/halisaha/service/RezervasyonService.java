package com.halisaha.service;

import com.halisaha.dto.RezervasyonRequest;
import com.halisaha.dto.RezervasyonResponse;
import com.halisaha.entity.HaliSaha;
import com.halisaha.entity.Rezervasyon;
import com.halisaha.exception.AuthException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
public class RezervasyonService {

    @Inject
    BildirimService bildirimService;

    public List<RezervasyonResponse> isletmeRezervasyonlari(UUID isletmeId) {
        return Rezervasyon.findByIsletmeId(isletmeId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<RezervasyonResponse> kullaniciRezervasyonlari(UUID kullaniciId) {
        return Rezervasyon.findByKullaniciId(kullaniciId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<RezervasyonResponse> sahaRezervasyonlari(UUID sahaId) {
        return Rezervasyon.findBySahaId(sahaId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<RezervasyonResponse> sahaGunlukRezervasyonlar(UUID sahaId, String tarihStr) {
        LocalDate tarih = LocalDate.parse(tarihStr, DateTimeFormatter.ISO_LOCAL_DATE);
        return Rezervasyon.findBySahaAndTarih(sahaId, tarih)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public RezervasyonResponse rezervasyonOlustur(RezervasyonRequest req, UUID kullaniciId) {
        HaliSaha saha = HaliSaha.findById(req.sahaId);
        if (saha == null) throw new AuthException("Saha bulunamadı", 404);
        if (Boolean.TRUE.equals(saha.kapaliMi)) throw new AuthException("Bu saha şu an kapalı", 400);

        LocalDate tarih = LocalDate.parse(req.rezervasyonTarihi, DateTimeFormatter.ISO_LOCAL_DATE);
        LocalTime baslangic = LocalTime.parse(req.baslangicSaati, DateTimeFormatter.ofPattern("HH:mm"));
        LocalTime bitis = LocalTime.parse(req.bitisSaati, DateTimeFormatter.ofPattern("HH:mm"));

        if (!tarih.isAfter(LocalDate.now().minusDays(1))) {
            throw new AuthException("Geçmiş tarihe rezervasyon yapılamaz", 400);
        }
        if (!bitis.isAfter(baslangic)) {
            throw new AuthException("Bitiş saati başlangıç saatinden sonra olmalı", 400);
        }

        if (Rezervasyon.cakismaVarMi(req.sahaId, tarih, baslangic, bitis, null)) {
            throw new AuthException("Bu saat aralığı zaten dolu", 409);
        }

        long saat = ChronoUnit.HOURS.between(baslangic, bitis);
        if (saat == 0) saat = 1;
        BigDecimal toplamUcret = saha.saatlikUcret.multiply(BigDecimal.valueOf(saat));

        Rezervasyon rezervasyon = new Rezervasyon();
        rezervasyon.sahaId = req.sahaId;
        rezervasyon.kullaniciId = kullaniciId;
        rezervasyon.rezervasyonTarihi = tarih;
        rezervasyon.baslangicSaati = baslangic;
        rezervasyon.bitisSaati = bitis;
        rezervasyon.toplamUcret = toplamUcret;
        rezervasyon.notlar = req.notlar;
        rezervasyon.durum = "BEKLEMEDE";
        rezervasyon.persist();
        rezervasyon.saha = saha;
        return toResponse(rezervasyon);
    }

    @Transactional
    public void rezervasyonIptal(UUID rezervasyonId, UUID kullaniciId) {
        Rezervasyon r = Rezervasyon.findById(rezervasyonId);
        if (r == null) throw new AuthException("Rezervasyon bulunamadı", 404);
        if (!r.kullaniciId.equals(kullaniciId)) throw new AuthException("Bu rezervasyonu iptal etme yetkiniz yok", 403);
        if ("TAMAMLANDI".equals(r.durum)) throw new AuthException("Tamamlanan rezervasyon iptal edilemez", 400);
        r.durum = "IPTAL";
        r.persist();
    }

    @Transactional
    public void rezervasyonOnayla(UUID rezervasyonId, UUID isletmeId) {
        Rezervasyon r = Rezervasyon.findById(rezervasyonId);
        if (r == null) throw new AuthException("Rezervasyon bulunamadı", 404);

        HaliSaha saha = HaliSaha.findById(r.sahaId);
        if (saha == null || !saha.isletmeId.equals(isletmeId)) {
            throw new AuthException("Bu rezervasyonu onaylama yetkiniz yok", 403);
        }
        r.durum = "ONAYLANDI";
        r.persist();

        bildirimService.bildirimOlustur(
            r.kullaniciId,
            "Rezervasyonunuz Onaylandı!",
            (saha.sahaAdi != null ? saha.sahaAdi : "Saha") + " için " + r.rezervasyonTarihi + " tarihli rezervasyonunuz onaylandı.",
            "REZERVASYON",
            r.id.toString()
        );
    }

    @Transactional
    public void rezervasyonReddet(UUID rezervasyonId, UUID isletmeId) {
        Rezervasyon r = Rezervasyon.findById(rezervasyonId);
        if (r == null) throw new AuthException("Rezervasyon bulunamadı", 404);

        HaliSaha saha = HaliSaha.findById(r.sahaId);
        if (saha == null || !saha.isletmeId.equals(isletmeId)) {
            throw new AuthException("Bu rezervasyonu reddetme yetkiniz yok", 403);
        }
        r.durum = "IPTAL";
        r.persist();
    }

    private RezervasyonResponse toResponse(Rezervasyon r) {
        if (r.saha == null) r.saha = HaliSaha.findById(r.sahaId);
        if (r.kullanici == null) r.kullanici = com.halisaha.entity.Kullanici.findById(r.kullaniciId);
        return RezervasyonResponse.from(r);
    }
}
