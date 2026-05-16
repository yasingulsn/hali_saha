package com.halisaha.resource;

import com.halisaha.dto.ApiResponse;
import com.halisaha.entity.HaliSaha;
import com.halisaha.entity.Kullanici;
import com.halisaha.exception.AuthException;
import jakarta.annotation.security.PermitAll;
import jakarta.annotation.security.RolesAllowed;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.jwt.JsonWebToken;
import org.jboss.resteasy.reactive.RestForm;
import org.jboss.resteasy.reactive.multipart.FileUpload;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.UUID;

@Path("/api/upload")
@Produces(MediaType.APPLICATION_JSON)
public class FotografResource {

    @Inject
    JsonWebToken jwt;

    @ConfigProperty(name = "halisaha.upload.dir", defaultValue = "/app/uploads")
    String uploadDir;

    @ConfigProperty(name = "halisaha.upload.base-url", defaultValue = "http://localhost:8080/api/upload/dosya")
    String baseUrl;

    // ─── PROFIL FOTO ─────────────────────────────────────────────

    @POST
    @Path("/profil-foto")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @RolesAllowed({"KULLANICI", "ISLETME"})
    @Transactional
    public Response profilFotoYukle(@RestForm("dosya") FileUpload dosya) throws IOException {
        UUID kullaniciId = UUID.fromString(jwt.getSubject());
        String url = kaydet(dosya, "profil");

        Kullanici k = Kullanici.findById(kullaniciId);
        if (k == null) throw new AuthException("Kullanıcı bulunamadı", 404);
        k.profilFotoUrl = url;
        k.persist();

        return Response.ok(ApiResponse.basarili("Fotoğraf yüklendi", Map.of("url", url))).build();
    }

    // ─── SAHA FOTO ───────────────────────────────────────────────

    @POST
    @Path("/saha-foto/{sahaId}")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @RolesAllowed("ISLETME")
    @Transactional
    public Response sahaFotoYukle(@PathParam("sahaId") UUID sahaId,
                                   @RestForm("dosya") FileUpload dosya) throws IOException {
        UUID isletmeId = UUID.fromString(jwt.getSubject());
        String url = kaydet(dosya, "saha");

        HaliSaha saha = HaliSaha.findById(sahaId);
        if (saha == null) throw new AuthException("Saha bulunamadı", 404);
        if (!saha.isletmeId.equals(isletmeId)) throw new AuthException("Bu sahaya erişim yetkiniz yok", 403);
        saha.fotografUrl = url;
        saha.persist();

        return Response.ok(ApiResponse.basarili("Fotoğraf yüklendi", Map.of("url", url))).build();
    }

    // ─── DOSYA GETIR ─────────────────────────────────────────────

    @GET
    @Path("/dosya/{klasor}/{dosyaAdi}")
    @PermitAll
    @Produces({"image/jpeg", "image/png", "image/webp", MediaType.APPLICATION_OCTET_STREAM})
    public Response dosyaGetir(@PathParam("klasor") String klasor,
                                @PathParam("dosyaAdi") String dosyaAdi) {
        // path traversal önleme
        if (klasor.contains("..") || dosyaAdi.contains("..") ||
                klasor.contains("/") || dosyaAdi.contains("/")) {
            return Response.status(400).build();
        }
        java.nio.file.Path dosyaYolu = Paths.get(uploadDir, klasor, dosyaAdi);
        File dosya = dosyaYolu.toFile();
        if (!dosya.exists() || !dosya.isFile()) {
            return Response.status(404).build();
        }
        String contentType = dosyaAdi.toLowerCase().endsWith(".png") ? "image/png"
                : dosyaAdi.toLowerCase().endsWith(".webp") ? "image/webp"
                : "image/jpeg";
        return Response.ok(dosya).header("Content-Type", contentType)
                .header("Cache-Control", "public, max-age=86400").build();
    }

    // ─── YARDIMCI ────────────────────────────────────────────────

    private String kaydet(FileUpload dosya, String klasor) throws IOException {
        if (dosya == null) throw new AuthException("Dosya boş olamaz", 400);

        String orijinalAd = dosya.fileName();
        String uzanti = ".jpg";
        if (orijinalAd != null && orijinalAd.contains(".")) {
            String ext = orijinalAd.substring(orijinalAd.lastIndexOf('.')).toLowerCase();
            if (ext.equals(".png") || ext.equals(".jpg") || ext.equals(".jpeg") || ext.equals(".webp")) {
                uzanti = ext.equals(".jpeg") ? ".jpg" : ext;
            }
        }

        long boyut = Files.size(dosya.uploadedFile());
        if (boyut > 5 * 1024 * 1024) throw new AuthException("Dosya 5MB'ı geçemez", 400);

        String dosyaAdi = UUID.randomUUID() + uzanti;
        java.nio.file.Path hedef = Paths.get(uploadDir, klasor, dosyaAdi);
        Files.createDirectories(hedef.getParent());
        Files.copy(dosya.uploadedFile(), hedef, StandardCopyOption.REPLACE_EXISTING);

        return baseUrl + "/" + klasor + "/" + dosyaAdi;
    }
}
