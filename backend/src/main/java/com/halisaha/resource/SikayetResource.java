package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.dto.SikayetRequest;
import com.halisaha.dto.SikayetResponse;
import com.halisaha.service.SikayetService;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.List;
import java.util.UUID;

@Path("/api/sikayetler")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class SikayetResource {

    @Inject
    SikayetService sikayetService;

    @Inject
    JsonWebToken jwt;

    @GET
    @RolesAllowed("KULLANICI")
    public Response benimSikayetlerim() {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        List<SikayetResponse> liste = sikayetService.benimSikayetlerim(kullaniciId);
        return Response.ok(ApiResponse.basarili("Şikayetleriniz", liste)).build();
    }

    @POST
    @RolesAllowed("KULLANICI")
    public Response sikayetOlustur(@Valid SikayetRequest request) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        SikayetResponse sikayet = sikayetService.sikayetOlustur(request, kullaniciId);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("Şikayetiniz alındı", sikayet)).build();
    }
}
