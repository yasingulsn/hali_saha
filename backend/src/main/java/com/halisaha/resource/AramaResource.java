package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.MacResponse;
import com.halisaha.dto.SahaResponse;
import com.halisaha.dto.TakimIlaniResponse;
import com.halisaha.entity.HaliSaha;
import com.halisaha.entity.Kullanici;
import com.halisaha.entity.Mac;
import com.halisaha.entity.TakimIlani;
import com.halisaha.service.MacService;
import com.halisaha.service.SahaService;
import com.halisaha.service.TakimIlaniService;
import jakarta.annotation.security.PermitAll;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Path("/api/arama")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AramaResource {

    @Inject
    SahaService sahaService;

    @Inject
    MacService macService;

    @Inject
    TakimIlaniService takimIlaniService;

    @GET
    @PermitAll
    public Response birlesikArama(
            @QueryParam("q") String query,
            @QueryParam("tip") String tip,
            @QueryParam("il") String il,
            @QueryParam("ilce") String ilce) {

        String q = query != null ? query.trim() : "";
        String ilParam = il != null ? il.trim() : "";
        String ilceParam = ilce != null ? ilce.trim() : "";

        // Konum bazlı listeleme: q boş fakat il/ilce var
        boolean konumBazli = q.isEmpty() && (!ilParam.isEmpty() || !ilceParam.isEmpty());
        // Metin araması: q >= 2 karakter
        boolean metinAramasi = q.length() >= 2;

        if (!konumBazli && !metinAramasi) {
            return Response.ok(ApiResponse.basarili("Arama için en az 2 karakter gerekli veya konum seçin",
                    Map.of("sahalar", List.of(), "maclar", List.of(), "oyuncular", List.of(), "ilanlar", List.of()))).build();
        }

        Map<String, Object> sonuclar = new HashMap<>();

        if (konumBazli) {
            // Konum bazlı tam listeleme
            sonuclar = konumBazliListele(tip, ilParam, ilceParam);
        } else {
            // Metin araması (mevcut davranış)
            sonuclar = metinAramasi(q, tip);
        }

        return Response.ok(ApiResponse.basarili("Arama sonuçları", sonuclar)).build();
    }

    private Map<String, Object> konumBazliListele(String tip, String il, String ilce) {
        Map<String, Object> sonuclar = new HashMap<>();
        String konum = ilce.isEmpty() ? il : ilce;

        if (tip == null || "tumu".equals(tip) || "sahalar".equals(tip)) {
            sonuclar.put("sahalar", sahaService.sahalarKonumaGore(il, ilce));
        } else {
            sonuclar.put("sahalar", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "maclar".equals(tip)) {
            sonuclar.put("maclar", macService.maclarKonumaGore(il, ilce));
        } else {
            sonuclar.put("maclar", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "oyuncular".equals(tip)) {
            sonuclar.put("oyuncular", tumOyuncular());
        } else {
            sonuclar.put("oyuncular", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "ilanlar".equals(tip)) {
            sonuclar.put("ilanlar", takimIlaniService.ilanlarKonumaGore(il, ilce));
        } else {
            sonuclar.put("ilanlar", List.of());
        }

        return sonuclar;
    }

    private Map<String, Object> metinAramasi(String q, String tip) {
        Map<String, Object> sonuclar = new HashMap<>();

        if (tip == null || "tumu".equals(tip) || "sahalar".equals(tip)) {
            List<SahaResponse> sahalar = sahaService.sahalarAra(q);
            sonuclar.put("sahalar", sahalar);
        } else {
            sonuclar.put("sahalar", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "maclar".equals(tip)) {
            List<MacResponse> maclar = macService.maclarAra(q);
            sonuclar.put("maclar", maclar);
        } else {
            sonuclar.put("maclar", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "oyuncular".equals(tip)) {
            List<Map<String, Object>> oyuncular = oyuncuAra(q);
            sonuclar.put("oyuncular", oyuncular);
        } else {
            sonuclar.put("oyuncular", List.of());
        }

        if (tip == null || "tumu".equals(tip) || "ilanlar".equals(tip)) {
            List<TakimIlaniResponse> ilanlar = takimIlaniService.ilanlarAra(q);
            sonuclar.put("ilanlar", ilanlar);
        } else {
            sonuclar.put("ilanlar", List.of());
        }

        return sonuclar;
    }

    private List<Map<String, Object>> oyuncuAra(String query) {
        String like = "%" + query.toLowerCase() + "%";
        List<Kullanici> kullanicilar = Kullanici.list(
                "aktifMi = true AND (" +
                        "LOWER(adSoyad) LIKE ?1 OR " +
                        "LOWER(COALESCE(tercihEdilenPozisyon, '')) LIKE ?1 OR " +
                        "LOWER(email) LIKE ?1" +
                        ")",
                like);

        return kullanicilar.stream()
                .limit(20)
                .map(this::kullaniciToMap)
                .collect(Collectors.toList());
    }

    private List<Map<String, Object>> tumOyuncular() {
        List<Kullanici> kullanicilar = Kullanici.list(
                "aktifMi = true ORDER BY kayitTarihi DESC");

        return kullanicilar.stream()
                .limit(50)
                .map(this::kullaniciToMap)
                .collect(Collectors.toList());
    }

    private Map<String, Object> kullaniciToMap(Kullanici k) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", k.id);
        map.put("adSoyad", k.adSoyad);
        map.put("profilFotoUrl", k.profilFotoUrl);
        map.put("puanOrtalamasi", k.puanOrtalamasi);
        map.put("disiplinPuani", k.disiplinPuani);
        map.put("tercihEdilenPozisyon", k.tercihEdilenPozisyon);
        return map;
    }
}
