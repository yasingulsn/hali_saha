package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.BildirimResponse;
import com.halisaha.service.BildirimService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.SecurityContext;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Path("/api/bildirimler")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@RolesAllowed({"KULLANICI", "ISLETME"})
public class BildirimResource {

    @Inject
    BildirimService bildirimService;

    @Inject
    SecurityContext securityContext;

    @GET
    public ApiResponse<List<BildirimResponse>> getBildirimler() {
        UUID kullaniciId = UUID.fromString(securityContext.getUserPrincipal().getName());
        List<BildirimResponse> bildirimler = bildirimService.kullaniciBildirimleri(kullaniciId)
                .stream().map(BildirimResponse::fromEntity).collect(Collectors.toList());
        return new ApiResponse<>(true, "Bildirimler yüklendi", bildirimler);
    }

    @GET
    @Path("/okunmamis-sayisi")
    public ApiResponse<Long> getOkunmamisSayisi() {
        UUID kullaniciId = UUID.fromString(securityContext.getUserPrincipal().getName());
        return new ApiResponse<>(true, "Okunmamış bildirim sayısı", bildirimService.okunmamisSayisi(kullaniciId));
    }

    @POST
    @Path("/{id}/oku")
    public ApiResponse<Void> okunduIsaretle(@PathParam("id") UUID id) {
        bildirimService.okunduIsaretle(id);
        return new ApiResponse<>(true, "Bildirim okundu işaretlendi", null);
    }

    @POST
    @Path("/hepsini-oku")
    public ApiResponse<Void> hepsiniOkunduIsaretle() {
        UUID kullaniciId = UUID.fromString(securityContext.getUserPrincipal().getName());
        bildirimService.tumunuOkunduIsaretle(kullaniciId);
        return new ApiResponse<>(true, "Tüm bildirimler okundu işaretlendi", null);
    }

    @DELETE
    @Path("/{id}")
    public ApiResponse<Void> bildirimSil(@PathParam("id") UUID id) {
        bildirimService.bildirimSil(id);
        return new ApiResponse<>(true, "Bildirim silindi", null);
    }
}
