package com.halisaha.service;

import com.halisaha.dto.MacRequest;
import com.halisaha.dto.MacResponse;
import com.halisaha.entity.*;
import com.halisaha.exception.AuthException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
public class MacService {

    @jakarta.inject.Inject
    BildirimService bildirimService;

    // ─── MAC LİSTELEME ──────────────────────────────────────────

    public List<MacResponse> acikMaclar() {
        List<Mac> maclar = Mac.findAcikMaclar();
        return maclar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public List<MacResponse> acikMaclarPaged(int page, int size) {
        List<Mac> maclar = Mac.findAcikMaclarPaged(page, size);
        return maclar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public long acikMacSayisi() {
        return Mac.countAcikMaclar();
    }

    public MacResponse macDetay(UUID macId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) {
            throw new AuthException("Maç bulunamadı", 404);
        }
        return toResponseWithKatilimcilar(mac);
    }

    public List<MacResponse> kullaniciMaclari(UUID kullaniciId) {
        List<MacKatilimci> katilimlar = MacKatilimci.findByKullaniciId(kullaniciId);
        List<MacResponse> sonuc = new ArrayList<>();
        java.time.LocalDate bugun = java.time.LocalDate.now();

        for (MacKatilimci k : katilimlar) {
            Mac mac = k.mac != null ? k.mac : Mac.findById(k.macId);
            if (mac != null && !mac.macTarihi.isBefore(bugun)) {
                sonuc.add(toResponse(mac));
            }
        }

        List<Mac> olusturduklari = Mac.findByOlusturanId(kullaniciId);
        for (Mac m : olusturduklari) {
            boolean zatenVar = sonuc.stream().anyMatch(r -> r.id.equals(m.id));
            if (!zatenVar) {
                sonuc.add(toResponse(m));
            }
        }
        return sonuc;
    }

    public List<MacResponse> kullaniciGecmisMaclari(UUID kullaniciId) {
        List<MacKatilimci> katilimlar = MacKatilimci.findByKullaniciId(kullaniciId);
        List<MacResponse> sonuc = new ArrayList<>();
        java.time.LocalDate bugun = java.time.LocalDate.now();

        for (MacKatilimci k : katilimlar) {
            Mac mac = k.mac != null ? k.mac : Mac.findById(k.macId);
            if (mac != null && mac.macTarihi.isBefore(bugun)) {
                sonuc.add(toResponse(mac));
            }
        }

        List<Mac> olusturduklari = Mac.findGecmisByOlusturanId(kullaniciId);
        for (Mac m : olusturduklari) {
            boolean zatenVar = sonuc.stream().anyMatch(r -> r.id.equals(m.id));
            if (!zatenVar) {
                sonuc.add(toResponse(m));
            }
        }
        sonuc.sort((a, b) -> b.macTarihi.compareTo(a.macTarihi));
        return sonuc;
    }

    public List<MacResponse> sahaMaclari(UUID sahaId) {
        List<Mac> maclar = Mac.findBySahaId(sahaId);
        return maclar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public MacResponse macGuncelle(UUID macId, MacRequest req, UUID kullaniciId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) {
            throw new AuthException("Maç bulunamadı", 404);
        }
        if (!mac.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Bu maçı düzenleme yetkiniz yok", 403);
        }
        if (!"ACIK".equals(mac.macDurumu)) {
            throw new AuthException("Sadece açık maçlar düzenlenebilir", 400);
        }

        if (req.sahaId != null) {
            HaliSaha saha = HaliSaha.findById(req.sahaId);
            if (saha == null || !saha.aktifMi) {
                throw new AuthException("Saha bulunamadı", 404);
            }
        }

        mac.sahaId = req.sahaId;
        mac.macBasligi = req.macBasligi.trim();
        mac.macTarihi = req.macTarihi;
        mac.baslangicSaati = req.baslangicSaati;
        mac.bitisSaati = req.bitisSaati;
        mac.format = req.format;
        mac.maxOyuncuSayisi = req.maxOyuncuSayisi;
        mac.aciklama = req.aciklama;
        mac.seviye = req.seviye != null ? req.seviye : "KARMA";
        mac.ucretPerKisi = req.ucretPerKisi;
        mac.minDisiplinPuani = req.minDisiplinPuani;
        mac.macTipi = req.macTipi != null ? req.macTipi : "NORMAL";
        mac.eksikOyuncuSayisi = req.eksikOyuncuSayisi;
        mac.takimAdi = req.takimAdi;
        mac.rakipNotu = req.rakipNotu;
        mac.il = req.il;
        mac.ilce = req.ilce;
        mac.persist();
        return toResponseWithKatilimcilar(mac);
    }

    @Transactional
    public void macSil(UUID macId, UUID kullaniciId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) {
            throw new AuthException("Maç bulunamadı", 404);
        }
        if (!mac.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Bu maçı silme yetkiniz yok", 403);
        }
        MacKatilimci.delete("macId = ?1", macId);
        mac.delete();
    }

    // ─── MAC OLUŞTURMA ──────────────────────────────────────────

    @Transactional
    public MacResponse macOlustur(MacRequest req, UUID kullaniciId) {
        if (req.sahaId != null) {
            HaliSaha saha = HaliSaha.findById(req.sahaId);
            if (saha == null || !saha.aktifMi) {
                throw new AuthException("Saha bulunamadı", 404);
            }
        }

        Mac mac = new Mac();
        mac.olusturanId = kullaniciId;
        mac.sahaId = req.sahaId;
        mac.macBasligi = req.macBasligi.trim();
        mac.macTarihi = req.macTarihi;
        mac.baslangicSaati = req.baslangicSaati;
        mac.bitisSaati = req.bitisSaati;
        mac.format = req.format;
        mac.maxOyuncuSayisi = req.maxOyuncuSayisi;
        mac.mevcutOyuncuSayisi = 1; // Oluşturan kişi otomatik katılır
        mac.macDurumu = "ACIK";
        mac.aciklama = req.aciklama;
        mac.seviye = req.seviye != null ? req.seviye : "KARMA";
        mac.ucretPerKisi = req.ucretPerKisi;
        mac.minDisiplinPuani = req.minDisiplinPuani;
        mac.macTipi = req.macTipi != null ? req.macTipi : "NORMAL";
        mac.eksikOyuncuSayisi = req.eksikOyuncuSayisi;
        mac.takimAdi = req.takimAdi;
        mac.rakipNotu = req.rakipNotu;
        mac.il = req.il;
        mac.ilce = req.ilce;
        mac.olusturulmaTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        mac.persist();

        // Yakındaki kullanıcılara bildirim gönder
        if (mac.il != null) {
            bildirimService.yakinIlanBildirimiGonder(
                mac.il, 
                mac.ilce, 
                "Yakınında Yeni Maç!", 
                mac.ilce + " bölgesinde yeni bir maç oluşturuldu: " + mac.macBasligi,
                mac.id.toString(),
                kullaniciId,
                "YAKIN_MAC"
            );
        }

        // Oluşturanı otomatik katılımcı yap
        MacKatilimci katilimci = new MacKatilimci();
        katilimci.macId = mac.id;
        katilimci.kullaniciId = kullaniciId;
        katilimci.katilimDurumu = "ONAYLANDI";
        katilimci.katilimTarihi = OffsetDateTime.now(ZoneOffset.UTC);
        katilimci.persist();

        return toResponseWithKatilimcilar(mac);
    }

    // ─── KATILIM ─────────────────────────────────────────────────

    @Transactional
    public MacResponse macaKatil(UUID macId, UUID kullaniciId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) {
            throw new AuthException("Maç bulunamadı", 404);
        }

        if ("DOLU".equals(mac.macDurumu) || "IPTAL".equals(mac.macDurumu)
                || "TAMAMLANDI".equals(mac.macDurumu)) {
            throw new AuthException("Bu maça katılım mümkün değil", 400);
        }

        // Disiplin puanı kontrolü
        if (mac.minDisiplinPuani != null) {
            Kullanici katilimci = Kullanici.findById(kullaniciId);
            if (katilimci != null && katilimci.disiplinPuani != null
                    && katilimci.disiplinPuani.compareTo(mac.minDisiplinPuani) < 0) {
                throw new AuthException(
                        "Disiplin puanınız (" + katilimci.disiplinPuani + ") bu maç için gereken minimum puanın ("
                                + mac.minDisiplinPuani + ") altında", 403);
            }
        }

        MacKatilimci mevcut = MacKatilimci.findByMacIdAndKullaniciId(macId, kullaniciId);
        if (mevcut != null && "ONAYLANDI".equals(mevcut.katilimDurumu)) {
            throw new AuthException("Zaten bu maça katılmışsınız", 409);
        }

        if (mevcut != null && "AYRILDI".equals(mevcut.katilimDurumu)) {
            mevcut.katilimDurumu = "ONAYLANDI";
            mevcut.katilimTarihi = OffsetDateTime.now(ZoneOffset.UTC);
            mevcut.persist();
        } else {
            MacKatilimci yeni = new MacKatilimci();
            yeni.macId = macId;
            yeni.kullaniciId = kullaniciId;
            yeni.katilimDurumu = "ONAYLANDI";
            yeni.katilimTarihi = OffsetDateTime.now(ZoneOffset.UTC);
            yeni.persist();
        }

        mac.mevcutOyuncuSayisi = (int) MacKatilimci.countAktifKatilimcilar(macId);
        if (mac.mevcutOyuncuSayisi >= mac.maxOyuncuSayisi) {
            mac.macDurumu = "DOLU";
        }
        mac.persist();

        // Maç sahibine bildirim gönder
        Kullanici katilan = Kullanici.findById(kullaniciId);
        bildirimService.bildirimOlustur(
            mac.olusturanId,
            "Maçına Yeni Katılım",
            (katilan != null ? katilan.adSoyad : "Bir oyuncu") + " '" + mac.macBasligi + "' maçına katıldı.",
            "MAC_KATILIM",
            mac.id.toString()
        );

        return toResponseWithKatilimcilar(mac);
    }

    @Transactional
    public MacResponse mactanAyril(UUID macId, UUID kullaniciId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) {
            throw new AuthException("Maç bulunamadı", 404);
        }

        if (mac.olusturanId.equals(kullaniciId)) {
            throw new AuthException("Maçı oluşturan kişi maçtan ayrılamaz. Maçı iptal edebilirsiniz.", 400);
        }

        MacKatilimci katilimci = MacKatilimci.findByMacIdAndKullaniciId(macId, kullaniciId);
        if (katilimci == null || !"ONAYLANDI".equals(katilimci.katilimDurumu)) {
            throw new AuthException("Bu maça katılmamışsınız", 400);
        }

        katilimci.katilimDurumu = "AYRILDI";
        katilimci.persist();

        mac.mevcutOyuncuSayisi = (int) MacKatilimci.countAktifKatilimcilar(macId);
        if ("DOLU".equals(mac.macDurumu)) {
            mac.macDurumu = "ACIK";
        }
        mac.persist();

        return toResponseWithKatilimcilar(mac);
    }

    // ─── PUANLAMA ────────────────────────────────────────────────

    @Transactional
    public void oyuncuPuanla(UUID macId, UUID hedefId, int puan, UUID puanlayanId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) throw new AuthException("Maç bulunamadı", 404);

        // Puanlayan kişi bu maçta katılımcı olmalı
        MacKatilimci puanlayan = MacKatilimci.findByMacIdAndKullaniciId(macId, puanlayanId);
        if (puanlayan == null) throw new AuthException("Bu maçta katılımcı değilsiniz", 403);

        // Hedef oyuncu da bu maçta katılımcı olmalı
        MacKatilimci hedef = MacKatilimci.findByMacIdAndKullaniciId(macId, hedefId);
        if (hedef == null) throw new AuthException("Bu oyuncu maçta katılımcı değil", 400);

        if (puanlayanId.equals(hedefId)) throw new AuthException("Kendinize puan veremezsiniz", 400);

        // Hedef kullanıcının disiplin puanını güncelle (ağırlıklı ortalama)
        Kullanici kullanici = Kullanici.findById(hedefId);
        if (kullanici == null) throw new AuthException("Kullanıcı bulunamadı", 404);

        int mevcutYorumSayisi = kullanici.yorumSayisi != null ? kullanici.yorumSayisi : 0;
        double mevcutPuan = kullanici.disiplinPuani != null ? kullanici.disiplinPuani.doubleValue() : 5.0;
        double yeniPuan = (mevcutPuan * mevcutYorumSayisi + puan) / (mevcutYorumSayisi + 1);
        yeniPuan = Math.max(1.0, Math.min(5.0, yeniPuan));

        kullanici.disiplinPuani = new java.math.BigDecimal(yeniPuan).setScale(2, java.math.RoundingMode.HALF_UP);
        kullanici.yorumSayisi = mevcutYorumSayisi + 1;
        kullanici.persist();

        bildirimService.bildirimOlustur(
            hedefId,
            "Disiplin Puanınız Güncellendi",
            "Bir oyuncu sizi " + puan + " yıldız ile değerlendirdi. Güncel puanınız: " + String.format("%.2f", yeniPuan),
            "PUAN",
            macId.toString()
        );
    }

    // ─── ARAMA ───────────────────────────────────────────────────

    public List<MacResponse> maclarAra(String query) {
        List<Mac> maclar = Mac.ara(query);
        return maclar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public MacResponse skorGir(UUID macId, com.halisaha.dto.MacSkorRequest req, UUID kullaniciId) {
        Mac mac = Mac.findById(macId);
        if (mac == null) throw new com.halisaha.exception.AuthException("Maç bulunamadı", 404);
        if (!mac.olusturanId.equals(kullaniciId))
            throw new com.halisaha.exception.AuthException("Sadece maç organizatörü skor girebilir", 403);
        mac.takim1Skor = req.takim1Skor;
        mac.takim2Skor = req.takim2Skor;
        mac.persist();
        return toResponseWithKatilimcilar(mac);
    }

    public List<MacResponse> maclarKonumaGore(String il, String ilce) {
        List<Mac> maclar = Mac.findByKonum(il, ilce);
        return maclar.stream().map(this::toResponse).collect(Collectors.toList());
    }

    // ─── YARDIMCI ────────────────────────────────────────────────

    private MacResponse toResponse(Mac mac) {
        String olusturanAdi = getOlusturanAdi(mac);
        String sahaAdi = getSahaAdi(mac);
        return MacResponse.from(mac, olusturanAdi, sahaAdi, null);
    }

    private MacResponse toResponseWithKatilimcilar(Mac mac) {
        String olusturanAdi = getOlusturanAdi(mac);
        String sahaAdi = getSahaAdi(mac);

        List<MacKatilimci> katilimcilar = MacKatilimci.findByMacId(mac.id);
        List<MacResponse.KatilimciBilgi> bilgiler = katilimcilar.stream()
                .map(k -> {
                    Kullanici user = k.kullanici != null ? k.kullanici : Kullanici.findById(k.kullaniciId);
                    return new MacResponse.KatilimciBilgi(
                            k.kullaniciId,
                            user != null ? user.adSoyad : "Bilinmeyen",
                            user != null ? user.profilFotoUrl : null,
                            k.katilimDurumu,
                            user != null ? user.disiplinPuani : null
                    );
                })
                .collect(Collectors.toList());

        return MacResponse.from(mac, olusturanAdi, sahaAdi, bilgiler);
    }

    private String getOlusturanAdi(Mac mac) {
        if (mac.olusturan != null) {
            return mac.olusturan.adSoyad;
        }
        if (mac.olusturanId == null) {
            return "Bilinmeyen";
        }
        Kullanici k = Kullanici.findById(mac.olusturanId);
        return k != null ? k.adSoyad : "Bilinmeyen";
    }

    private String getSahaAdi(Mac mac) {
        if (mac.sahaId == null) {
            return null;
        }
        if (mac.saha != null) {
            return mac.saha.sahaAdi;
        }
        HaliSaha saha = HaliSaha.findById(mac.sahaId);
        return saha != null ? saha.sahaAdi : "Bilinmeyen";
    }
}
