package com.halisaha.service;

import com.halisaha.dto.SikayetRequest;
import com.halisaha.dto.SikayetResponse;
import com.halisaha.entity.Kullanici;
import com.halisaha.entity.Sikayet;
import com.halisaha.exception.AuthException;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
public class SikayetService {

    public List<SikayetResponse> benimSikayetlerim(UUID kullaniciId) {
        return Sikayet.findBySikayetEdenId(kullaniciId)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public SikayetResponse sikayetOlustur(SikayetRequest req, UUID sikayetEdenId) {
        if (sikayetEdenId.equals(req.sikayetEdilenId)) {
            throw new AuthException("Kendiniz hakkında şikayet oluşturamazsınız", 400);
        }
        Kullanici hedef = Kullanici.findById(req.sikayetEdilenId);
        if (hedef == null) throw new AuthException("Kullanıcı bulunamadı", 404);

        Sikayet s = new Sikayet();
        s.sikayetEdenId = sikayetEdenId;
        s.sikayetEdilenId = req.sikayetEdilenId;
        s.macId = req.macId;
        s.kategori = req.kategori;
        s.aciklama = req.aciklama;
        s.persist();

        s.sikayetEdilen = hedef;
        return toResponse(s);
    }

    private SikayetResponse toResponse(Sikayet s) {
        if (s.sikayetEdilen == null) s.sikayetEdilen = Kullanici.findById(s.sikayetEdilenId);
        return SikayetResponse.from(s);
    }
}
