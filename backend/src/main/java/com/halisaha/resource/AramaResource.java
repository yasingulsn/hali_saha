package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.MacResponse;
import com.halisaha.dto.SahaResponse;
import com.halisaha.dto.TakimIlaniResponse;
import com.halisaha.entity.Kullanici;
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
    public Response birlesikArama(@QueryParam("q") String query, @QueryParam("tip") String tip) {
        if (query == null || query.trim().length() < 2) {
            return Response.ok(ApiResponse.basarili("Arama için en az 2 karakter gerekli",
                    Map.of("sahalar", List.of(), "maclar", List.of(), "oyuncular", List.of()))).build();
        }

        String q = query.trim();
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

        return Response.ok(ApiResponse.basarili("Arama sonuçları", sonuclar)).build();
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
                .map(k -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", k.id);
                    map.put("adSoyad", k.adSoyad);
                    map.put("profilFotoUrl", k.profilFotoUrl);
                    map.put("puanOrtalamasi", k.puanOrtalamasi);
                    map.put("disiplinPuani", k.disiplinPuani);
                    map.put("tercihEdilenPozisyon", k.tercihEdilenPozisyon);
                    return map;
                })
                .collect(Collectors.toList());
    }
}
