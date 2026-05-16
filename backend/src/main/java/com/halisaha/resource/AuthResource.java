package com.halisaha.resource;

import com.halisaha.dto.*;
import com.halisaha.exception.AuthException;
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
    com.halisaha.service.SifreSifirlamaService sifreSifirlamaService;

    @Inject
    com.halisaha.service.EmailDogrulamaService emailDogrulamaService;

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

    // ─── ŞİFRE SIFIRLAMA ────────────────────────────────────────

    @POST
    @Path("/sifre-sifirlama-istegi")
    @PermitAll
    public Response sifreSifirlamaIstegi(@Valid SifreSifirlamaRequest request) {
        sifreSifirlamaService.sifirlamaIstegiOlustur(request.email, request.kullaniciTipi);
        return Response.ok(ApiResponse.basarili("Eğer hesap mevcutsa sıfırlama linki gönderilmiştir")).build();
    }

    @POST
    @Path("/sifre-sifirla")
    @PermitAll
    public Response sifreSifirla(@Valid SifreSifirlaRequest request) {
        sifreSifirlamaService.sifreSifirla(request.token, request.yeniSifre);
        return Response.ok(ApiResponse.basarili("Şifreniz başarıyla güncellendi")).build();
    }

    // ─── PROFİL ──────────────────────────────────────────────────

    @GET
    @Path("/profil")
    @RolesAllowed({"KULLANICI"})
    public Response profilDetay() {
        try {
            UUID userId = UUID.fromString(jwt.getSubject());
            ProfilResponse profil = authService.profilDetay(userId);
            return Response.ok(ApiResponse.basarili("Profil bilgileri", profil)).build();
        } catch (AuthException e) {
            throw e;
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(ApiResponse.hata("Profil bilgileri alınırken hata: " + e.getMessage()))
                    .build();
        }
    }

    @PUT
    @Path("/profil")
    @RolesAllowed({"KULLANICI"})
    public Response profilGuncelle(@Valid ProfilGuncelleRequest request) {
        try {
            UUID userId = UUID.fromString(jwt.getSubject());
            ProfilResponse profil = authService.profilGuncelle(userId, request);
            return Response.ok(ApiResponse.basarili("Profil güncellendi", profil)).build();
        } catch (AuthException e) {
            throw e; // ExceptionMapper yakalasın
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(ApiResponse.hata("Profil güncellenirken bir hata oluştu: " + e.getMessage()))
                    .build();
        }
    }

    @PUT
    @Path("/profil/konum")
    @RolesAllowed({"KULLANICI"})
    public Response konumGuncelle(@Valid KonumGuncelleRequest request) {
        try {
            UUID userId = UUID.fromString(jwt.getSubject());
            authService.konumGuncelle(userId, request);
            return Response.ok(ApiResponse.basarili("Konum güncellendi")).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(ApiResponse.hata("Konum güncellenirken hata: " + e.getMessage()))
                    .build();
        }
    }

    // ─── EMAIL DOĞRULAMA ─────────────────────────────────────────

    @POST
    @Path("/email-dogrulama-gonder")
    @RolesAllowed({"KULLANICI"})
    public Response emailDogrulamaGonder() {
        UUID userId = UUID.fromString(jwt.getSubject());
        emailDogrulamaService.dogrulamaMailiGonder(userId);
        return Response.ok(ApiResponse.basarili("Doğrulama kodu gönderildi")).build();
    }

    @POST
    @Path("/email-dogrula")
    @RolesAllowed({"KULLANICI"})
    public Response emailDogrula(@QueryParam("token") String token) {
        if (token == null || token.isBlank()) {
            return Response.status(400).entity(ApiResponse.hata("Token gerekli")).build();
        }
        UUID userId = UUID.fromString(jwt.getSubject());
        emailDogrulamaService.emailDogrula(userId, token);
        return Response.ok(ApiResponse.basarili("Email başarıyla doğrulandı")).build();
    }

    // ─── PUBLIC PROFİL ───────────────────────────────────────────

    @GET
    @Path("/kullanici/{id}")
    @PermitAll
    public Response kullaniciPublicProfil(@PathParam("id") UUID id) {
        com.halisaha.entity.Kullanici k = com.halisaha.entity.Kullanici.findById(id);
        if (k == null) throw new AuthException("Kullanıcı bulunamadı", 404);
        long toplamMac = com.halisaha.entity.MacKatilimci.count("kullaniciId = ?1 AND katilimDurumu = 'ONAYLANDI'", id);
        return Response.ok(ApiResponse.basarili("Kullanıcı profili",
                KullaniciProfilResponse.from(k, toplamMac))).build();
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
