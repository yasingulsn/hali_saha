package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.MacRequest;
import com.halisaha.dto.MacResponse;
import com.halisaha.service.MacService;
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

@Path("/api/maclar")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class MacResource {

    @Inject
    MacService macService;

    @Inject
    JsonWebToken jwt;

    @GET
    @PermitAll
    public Response acikMaclar() {
        List<MacResponse> maclar = macService.acikMaclar();
        return Response.ok(ApiResponse.basarili("Açık maçlar listelendi", maclar)).build();
    }

    @GET
    @Path("/{id}")
    @PermitAll
    public Response macDetay(@PathParam("id") UUID id) {
        MacResponse mac = macService.macDetay(id);
        return Response.ok(ApiResponse.basarili("Maç detayı", mac)).build();
    }

    @GET
    @Path("/benim")
    @RolesAllowed("KULLANICI")
    public Response benimMaclarim() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<MacResponse> maclar = macService.kullaniciMaclari(kullaniciId);
        return Response.ok(ApiResponse.basarili("Maçlarınız", maclar)).build();
    }

    @GET
    @Path("/saha/{sahaId}")
    @PermitAll
    public Response sahaMaclari(@PathParam("sahaId") UUID sahaId) {
        List<MacResponse> maclar = macService.sahaMaclari(sahaId);
        return Response.ok(ApiResponse.basarili("Saha maçları", maclar)).build();
    }

    @POST
    @RolesAllowed("KULLANICI")
    public Response macOlustur(@Valid MacRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        MacResponse mac = macService.macOlustur(request, kullaniciId);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("Maç oluşturuldu", mac))
                .build();
    }

    @PUT
    @Path("/{id}")
    @RolesAllowed("KULLANICI")
    public Response macGuncelle(@PathParam("id") UUID id, @Valid MacRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        MacResponse mac = macService.macGuncelle(id, request, kullaniciId);
        return Response.ok(ApiResponse.basarili("Maç güncellendi", mac)).build();
    }

    @DELETE
    @Path("/{id}")
    @RolesAllowed("KULLANICI")
    public Response macSil(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        macService.macSil(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("Maç silindi")).build();
    }

    @POST
    @Path("/{id}/katil")
    @RolesAllowed("KULLANICI")
    public Response macaKatil(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        MacResponse mac = macService.macaKatil(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("Maça katıldınız", mac)).build();
    }

    @POST
    @Path("/{id}/ayril")
    @RolesAllowed("KULLANICI")
    public Response mactanAyril(@PathParam("id") UUID id) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        MacResponse mac = macService.mactanAyril(id, kullaniciId);
        return Response.ok(ApiResponse.basarili("Maçtan ayrıldınız", mac)).build();
    }

    @GET
    @Path("/ara")
    @PermitAll
    public Response maclarAra(@QueryParam("q") String query) {
        if (query == null || query.trim().isEmpty()) {
            return Response.ok(ApiResponse.basarili("Arama sonucu", List.of())).build();
        }
        List<MacResponse> sonuclar = macService.maclarAra(query.trim());
        return Response.ok(ApiResponse.basarili("Arama sonuçları", sonuclar)).build();
    }
}
