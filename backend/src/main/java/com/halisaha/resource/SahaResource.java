package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.SahaRequest;
import com.halisaha.dto.SahaResponse;
import com.halisaha.service.SahaService;
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

@Path("/api/sahalar")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SahaResource {

    @Inject
    SahaService sahaService;

    @Inject
    JsonWebToken jwt;

    @GET
    @PermitAll
    public Response tumSahalar() {
        List<SahaResponse> sahalar = sahaService.tumSahalar();
        return Response.ok(ApiResponse.basarili("Sahalar listelendi", sahalar)).build();
    }

    @GET
    @Path("/{id}")
    @PermitAll
    public Response sahaDetay(@PathParam("id") UUID id) {
        SahaResponse saha = sahaService.sahaDetay(id);
        return Response.ok(ApiResponse.basarili("Saha detayı", saha)).build();
    }

    @GET
    @Path("/isletme/{isletmeId}")
    @PermitAll
    public Response isletmeSahalari(@PathParam("isletmeId") UUID isletmeId) {
        List<SahaResponse> sahalar = sahaService.isletmeSahalari(isletmeId);
        return Response.ok(ApiResponse.basarili("İşletme sahaları", sahalar)).build();
    }

    @POST
    @RolesAllowed("ISLETME")
    public Response sahaEkle(@Valid SahaRequest request) {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        SahaResponse saha = sahaService.sahaEkle(request, isletmeId);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("Saha eklendi", saha))
                .build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed("ISLETME")
    public Response sahaGuncelle(@PathParam("id") UUID id, @Valid SahaRequest request) {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        SahaResponse saha = sahaService.sahaGuncelle(id, request, isletmeId);
        return Response.ok(ApiResponse.basarili("Saha güncellendi", saha)).build();
    }

    @GET
    @Path("/ara")
    @PermitAll
    public Response sahalarAra(@QueryParam("q") String query) {
        if (query == null || query.trim().isEmpty()) {
            return Response.ok(ApiResponse.basarili("Arama sonucu", List.of())).build();
        }
        List<SahaResponse> sonuclar = sahaService.sahalarAra(query.trim());
        return Response.ok(ApiResponse.basarili("Arama sonuçları", sonuclar)).build();
    }
}
