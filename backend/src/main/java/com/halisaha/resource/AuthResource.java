package com.halisaha.resource;

import com.halisaha.dto.*;
import com.halisaha.service.AuthService;
import io.vertx.core.http.HttpServerRequest;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.validation.Valid;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.jwt.JsonWebToken;

import java.util.UUID;

@Path("/api/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class AuthResource {

    @Inject
    AuthService authService;

    @Inject
    JsonWebToken jwt;

    @Context
    HttpServerRequest httpRequest;

    // ─── KULLANICI ENDPOINTS ────────────────────────────────────

    @POST
    @Path("/kayit")
    @PermitAll
    public Response kullaniciKayit(@Valid KullaniciRegisterRequest request) {
        String ip = getClientIp();
        TokenResponse token = authService.kullaniciKayit(request, ip);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("Kayıt başarılı", token))
                .build();
    }

    @POST
    @Path("/giris")
    @PermitAll
    public Response kullaniciGiris(@Valid LoginRequest request) {
        String ip = getClientIp();
        TokenResponse token = authService.kullaniciGiris(request, ip);
        return Response.ok(ApiResponse.basarili("Giriş başarılı", token)).build();
    }

    // ─── İŞLETME ENDPOINTS ──────────────────────────────────────

    @POST
    @Path("/isletme/kayit")
    @PermitAll
    public Response isletmeKayit(@Valid IsletmeRegisterRequest request) {
        String ip = getClientIp();
        TokenResponse token = authService.isletmeKayit(request, ip);
        return Response.status(Response.Status.CREATED)
                .entity(ApiResponse.basarili("İşletme kaydı başarılı", token))
                .build();
    }

    @POST
    @Path("/isletme/giris")
    @PermitAll
    public Response isletmeGiris(@Valid LoginRequest request) {
        String ip = getClientIp();
        TokenResponse token = authService.isletmeGiris(request, ip);
        return Response.ok(ApiResponse.basarili("Giriş başarılı", token)).build();
    }

    // ─── TOKEN YENİLEME ─────────────────────────────────────────

    @POST
    @Path("/token-yenile")
    @PermitAll
    public Response tokenYenile(@Valid RefreshTokenRequest request) {
        String ip = getClientIp();
        TokenResponse token = authService.tokenYenile(request.refreshToken, ip);
        return Response.ok(ApiResponse.basarili("Token yenilendi", token)).build();
    }

    // ─── ÇIKIŞ ──────────────────────────────────────────────────

    @POST
    @Path("/cikis")
    @RolesAllowed({"KULLANICI", "ISLETME"})
    public Response cikis(@Valid RefreshTokenRequest request) {
        authService.cikis(request.refreshToken);
        return Response.ok(ApiResponse.basarili("Çıkış başarılı")).build();
    }

    @POST
    @Path("/tum-cihazlardan-cikis")
    @RolesAllowed({"KULLANICI", "ISLETME"})
    public Response tumCihazlardanCikis() {
        UUID userId = UUID.fromString(jwt.getSubject());
        String kullaniciTipi = jwt.getClaim("kullanici_tipi");
        authService.tumCihazlardanCikis(userId, kullaniciTipi);
        return Response.ok(ApiResponse.basarili("Tüm cihazlardan çıkış yapıldı")).build();
    }

    // ─── PROFIL (token test endpoint) ───────────────────────────

    @GET
    @Path("/profil")
    @RolesAllowed({"KULLANICI", "ISLETME"})
    public Response profil() {
        String userId = jwt.getSubject();
        String email = jwt.getClaim("email");
        String adSoyad = jwt.getClaim("ad_soyad");
        String kullaniciTipi = jwt.getClaim("kullanici_tipi");

        var bilgi = new TokenResponse.KullaniciBilgi(userId, adSoyad, email, null);
        return Response.ok(ApiResponse.basarili("Profil bilgileri", bilgi)).build();
    }

    // ─── YARDIMCI ───────────────────────────────────────────────

    private String getClientIp() {
        if (httpRequest == null) return "unknown";
        String xForwardedFor = httpRequest.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return httpRequest.remoteAddress() != null
                ? httpRequest.remoteAddress().host()
                : "unknown";
    }
}
