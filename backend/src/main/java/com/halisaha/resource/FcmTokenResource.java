package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.entity.FcmToken;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@Path("/api/fcm")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class FcmTokenResource {

    @Inject
    JsonWebToken jwt;

    @POST
    @Path("/token")
    @RolesAllowed({"KULLANICI", "ISLETME"})
    @Transactional
    public Response tokenKaydet(Map<String, String> body) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        String token = body.get("token");
        String platform = body.getOrDefault("platform", "android");

        if (token == null || token.isBlank()) {
            return Response.status(400)
                    .entity(ApiResponse.hata("Token boş olamaz"))
                    .build();
        }

        FcmToken mevcut = FcmToken.findByKullaniciAndPlatform(kullaniciId, platform);
        if (mevcut != null) {
            mevcut.token = token;
            mevcut.guncellemeTarihi = OffsetDateTime.now();
            mevcut.persist();
        } else {
            FcmToken yeni = new FcmToken();
            yeni.kullaniciId = kullaniciId;
            yeni.token = token;
            yeni.platform = platform;
            yeni.persist();
        }

        return Response.ok(ApiResponse.basarili("FCM token kaydedildi")).build();
    }

    @DELETE
    @Path("/token")
    @RolesAllowed({"KULLANICI", "ISLETME"})
    @Transactional
    public Response tokenSil(@QueryParam("platform") @DefaultValue("android") String platform) {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        FcmToken mevcut = FcmToken.findByKullaniciAndPlatform(kullaniciId, platform);
        if (mevcut != null) mevcut.delete();
        return Response.ok(ApiResponse.basarili("FCM token silindi")).build();
    }
}
