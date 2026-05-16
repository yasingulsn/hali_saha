package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.RezervasyonRequest;
import com.halisaha.dto.RezervasyonResponse;
import com.halisaha.service.RezervasyonService;
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

@Path("/api/rezervasyonlar")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class RezervasyonResource {

    @Inject
    RezervasyonService rezervasyonService;

    @Inject
    JsonWebToken jwt;

    @GET
    @Path("/isletme")
    @RolesAllowed("ISLETME")
    public Response isletmeRezervasyonlari() {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        List<RezervasyonResponse> liste = rezervasyonService.isletmeRezervasyonlari(isletmeId);
        return Response.ok(ApiResponse.basarili("İşletme rezervasyonları", liste)).build();
    }

    @GET
    @Path("/benim")
    @RolesAllowed("KULLANICI")
    public Response benimRezervasyonlarim() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<RezervasyonResponse> liste = rezervasyonService.kullaniciRezervasyonlari(kullaniciId);
        return Response.ok(ApiResponse.basarili("Rezervasyonlarınız", liste)).build();
    }

    @GET
    @Path("/saha/{sahaId}")
    @PermitAll
    public Response sahaRezervasyonlari(@PathParam("sahaId") UUID sahaId) {
        List<RezervasyonResponse> liste = rezervasyonService.sahaRezervasyonlari(sahaId);
        return Response.ok(ApiResponse.basarili("Saha rezervasyonları", liste)).build();
    }

    @GET
    @Path("/saha/{sahaId}/gun")
    @PermitAll
    public Response sahaGunlukRezervasyonlar(
            @PathParam("sahaId") UUID sahaId,
            @QueryParam("tarih") String tarih) {
        if (tarih == null || tarih.isBlank()) {
            return Response.status(400).entity(ApiResponse.hata("Tarih parametresi gerekli")).build();
        }
        List<RezervasyonResponse> liste = rezervasyonService.sahaGunlukRezervasyonlar(sahaId, tarih);
        return Response.ok(ApiResponse.basarili("Günlük rezervasyonlar", liste)).build();
    }

    @POST
    @RolesAllowed("KULLANICI")
    public Response rezervasyonOlustur(@Valid RezervasyonRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        RezervasyonResponse r = rezervasyonService.rezervasyonOlustur(request, kullaniciId);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("Rezervasyon oluşturuldu", r))
                .build();
    }

    @POST
    @Path("/{id}/iptal")
    @RolesAllowed("KULLANICI")
    public Response iptalEt(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        rezervasyonService.rezervasyonIptal(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("Rezervasyon iptal edildi")).build();
    }

    @POST
    @Path("/{id}/onayla")
    @RolesAllowed("ISLETME")
    public Response onayla(@PathParam("id") UUID id) {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        rezervasyonService.rezervasyonOnayla(id, isletmeId);
        return Response.ok(ApiResponse.basarili("Rezervasyon onaylandı")).build();
    }

    @POST
    @Path("/{id}/reddet")
    @RolesAllowed("ISLETME")
    public Response reddet(@PathParam("id") UUID id) {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        rezervasyonService.rezervasyonReddet(id, isletmeId);
        return Response.ok(ApiResponse.basarili("Rezervasyon reddedildi")).build();
    }
}
