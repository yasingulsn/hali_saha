package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.TakimIlaniRequest;
import com.halisaha.dto.TakimIlaniResponse;
import com.halisaha.dto.TakimIlaniIstekRequest;
import com.halisaha.service.TakimIlaniService;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.List;
import java.util.UUID;

@Path("/api/takim-ilanlari")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class TakimIlaniResource {

    @Inject
    TakimIlaniService takimIlaniService;

    @Inject
    JsonWebToken jwt;

    @GET
    @PermitAll
    public Response aktifIlanlar() {
        List<TakimIlaniResponse> ilanlar = takimIlaniService.aktifIlanlar();
        return Response.ok(ApiResponse.basarili("Takım ilanları listelendi", ilanlar)).build();
    }

    @GET
    @Path("/{id}")
    @PermitAll
    public Response ilanDetay(@PathParam("id") UUID id) {
        TakimIlaniResponse ilan = takimIlaniService.ilanDetay(id);
        return Response.ok(ApiResponse.basarili("İlan detayı", ilan)).build();
    }

    @GET
    @Path("/benim")
    @RolesAllowed("KULLANICI")
    public Response benimIlanlarim() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<TakimIlaniResponse> ilanlar = takimIlaniService.kullaniciIlanlari(kullaniciId);
        return Response.ok(ApiResponse.basarili("İlanlarınız", ilanlar)).build();
    }

    @POST
    @RolesAllowed("KULLANICI")
    public Response ilanOlustur(@Valid TakimIlaniRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        TakimIlaniResponse ilan = takimIlaniService.ilanOlustur(request, kullaniciId);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("İlan oluşturuldu", ilan))
                .build();
    }

    @POST
    @Path("/{id}/kapat")
    @RolesAllowed("KULLANICI")
    public Response ilanKapat(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        takimIlaniService.ilanKapat(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("İlan kapatıldı")).build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed("KULLANICI")
    public Response ilanGuncelle(@PathParam("id") UUID id, @Valid TakimIlaniRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        TakimIlaniResponse ilan = takimIlaniService.ilanGuncelle(id, request, kullaniciId);
        return Response.ok(ApiResponse.basarili("İlan güncellendi", ilan)).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("KULLANICI")
    public Response ilanSil(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        takimIlaniService.ilanSil(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("İlan silindi")).build();
    }

    @GET
    @Path("/ara")
    @PermitAll
    public Response ilanlarAra(@QueryParam("q") String query) {
        if (query == null || query.trim().isEmpty()) {
            return Response.ok(ApiResponse.basarili("Arama sonucu", List.of())).build();
        }
        List<TakimIlaniResponse> sonuclar = takimIlaniService.ilanlarAra(query.trim());
        return Response.ok(ApiResponse.basarili("Arama sonuçları", sonuclar)).build();
    }

    @POST
    @Path("/istek")
    @RolesAllowed("KULLANICI")
    public Response katilmaIstegiGonder(@Valid TakimIlaniIstekRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        takimIlaniService.katilmaIstegiGonder(request.ilanId, request.mesaj, kullaniciId);
        return Response.ok(ApiResponse.basarili("Katılma isteğiniz gönderildi")).build();
    }

    @GET
    @Path("/gelen-istekler")
    @RolesAllowed("KULLANICI")
    public Response gelenIstekler() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<com.halisaha.dto.TakimIlaniIstekResponse> istekler = takimIlaniService.gelenIstekler(kullaniciId);
        return Response.ok(ApiResponse.basarili("Gelen istekler listelendi", istekler)).build();
    }

    @GET
    @Path("/gonderdigim-istekler")
    @RolesAllowed("KULLANICI")
    public Response gonderdigimIstekler() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<com.halisaha.dto.TakimIlaniIstekResponse> istekler = takimIlaniService.gonderdigimIstekler(kullaniciId);
        return Response.ok(ApiResponse.basarili("Gönderilen istekler listelendi", istekler)).build();
    }

    @POST
    @Path("/istek/{id}/onayla")
    @RolesAllowed("KULLANICI")
    public Response istekOnayla(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        takimIlaniService.istekOnayla(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("İstek onaylandı")).build();
    }

    @POST
    @Path("/istek/{id}/reddet")
    @RolesAllowed("KULLANICI")
    public Response istekReddet(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        takimIlaniService.istekReddet(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("İstek reddedildi")).build();
    }
}
