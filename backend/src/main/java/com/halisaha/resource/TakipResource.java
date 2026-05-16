package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.ProfilResponse;
import com.halisaha.entity.Kullanici;
import com.halisaha.entity.Takip;
import io.quarkus.panache.common.Sort;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Path("/api/takip")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@RolesAllowed("KULLANICI")
public class TakipResource {

    @Inject
    JsonWebToken jwt;

    @POST
    @Path("/{kullaniciId}")
    @Transactional
    public Response takipEt(@PathParam("kullaniciId") UUID hedefId) {
        UUID benId = UUID.fromString(jwt.getSubject());
        if (benId.equals(hedefId)) {
            return Response.status(400).entity(ApiResponse.hata("Kendinizi takip edemezsiniz")).build();
        }
        if (Takip.zatenTakipEdiyor(benId, hedefId)) {
            return Response.status(409).entity(ApiResponse.hata("Zaten takip ediyorsunuz")).build();
        }
        Kullanici hedef = Kullanici.findById(hedefId);
        if (hedef == null) {
            return Response.status(404).entity(ApiResponse.hata("Kullanıcı bulunamadı")).build();
        }
        Takip takip = new Takip();
        takip.takipciId = benId;
        takip.takipEdilenId = hedefId;
        takip.persist();
        return Response.ok(ApiResponse.basarili("Takip edildi")).build();
    }

    @DELETE
    @Path("/{kullaniciId}")
    @Transactional
    public Response takiptenCik(@PathParam("kullaniciId") UUID hedefId) {
        UUID benId = UUID.fromString(jwt.getSubject());
        long silinen = Takip.delete("takipciId = ?1 AND takipEdilenId = ?2", benId, hedefId);
        if (silinen == 0) {
            return Response.status(404).entity(ApiResponse.hata("Takip kaydı bulunamadı")).build();
        }
        return Response.ok(ApiResponse.basarili("Takip bırakıldı")).build();
    }

    @GET
    @Path("/takip-ettiklerim")
    public Response takipEttiklerim() {
        UUID benId = UUID.fromString(jwt.getSubject());
        List<UUID> idler = Takip.takipEdilenIdler(benId);
        List<ProfilResponse> liste = idler.stream()
                .map(id -> Kullanici.<Kullanici>findById(id))
                .filter(k -> k != null)
                .map(this::kullaniciyiResponse)
                .collect(Collectors.toList());
        return Response.ok(ApiResponse.basarili("Takip ettiklerim", liste)).build();
    }

    @GET
    @Path("/takipcilerim")
    public Response takipcilerim() {
        UUID benId = UUID.fromString(jwt.getSubject());
        List<UUID> idler = Takip.takipciIdler(benId);
        List<ProfilResponse> liste = idler.stream()
                .map(id -> Kullanici.<Kullanici>findById(id))
                .filter(k -> k != null)
                .map(this::kullaniciyiResponse)
                .collect(Collectors.toList());
        return Response.ok(ApiResponse.basarili("Takipçilerim", liste)).build();
    }

    @GET
    @Path("/durum/{kullaniciId}")
    public Response takipDurumu(@PathParam("kullaniciId") UUID hedefId) {
        UUID benId = UUID.fromString(jwt.getSubject());
        boolean takipEdiyorum = Takip.zatenTakipEdiyor(benId, hedefId);
        boolean beniTakipEdiyor = Takip.zatenTakipEdiyor(hedefId, benId);
        var sonuc = new java.util.HashMap<String, Object>();
        sonuc.put("takipEdiyorum", takipEdiyorum);
        sonuc.put("beniTakipEdiyor", beniTakipEdiyor);
        sonuc.put("takipEdilenSayisi", Takip.takipEdilenSayisi(hedefId));
        sonuc.put("takipciSayisi", Takip.takipciSayisi(hedefId));
        return Response.ok(ApiResponse.basarili("Takip durumu", sonuc)).build();
    }

    private ProfilResponse kullaniciyiResponse(Kullanici k) {
        ProfilResponse r = new ProfilResponse();
        r.id = k.id.toString();
        r.adSoyad = k.adSoyad;
        r.email = k.email;
        r.profilFotoUrl = k.profilFotoUrl;
        r.tercihEdilenPozisyon = k.tercihEdilenPozisyon;
        r.disiplinPuani = k.disiplinPuani;
        r.il = k.il;
        r.ilce = k.ilce;
        r.takipEdilenSayisi = Takip.takipEdilenSayisi(k.id);
        r.takipciSayisi = Takip.takipciSayisi(k.id);
        return r;
    }
}
