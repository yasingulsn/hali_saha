package com.halisaha.service;

import com.halisaha.entity.Kullanici;
import com.halisaha.exception.AuthException;
import io.quarkus.mailer.Mail;
import io.quarkus.mailer.Mailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;

import java.util.UUID;

@ApplicationScoped
public class EmailDogrulamaService {

    @Inject
    Mailer mailer;

    @Transactional
    public void dogrulamaMailiGonder(UUID kullaniciId) {
        Kullanici k = Kullanici.findById(kullaniciId);
        if (k == null) throw new AuthException("Kullanıcı bulunamadı", 404);
        if (Boolean.TRUE.equals(k.emailDogrulanmis)) throw new AuthException("Email zaten doğrulanmış", 400);

        String token = UUID.randomUUID().toString().replace("-", "");
        k.emailDogrulamaToken = token;
        k.persist();

        try {
            String html = "<div style='font-family:sans-serif;max-width:500px;margin:auto;padding:24px'>"
                    + "<h2 style='color:#00BFA5'>Email Doğrulama</h2>"
                    + "<p>Merhaba " + k.adSoyad + ",</p>"
                    + "<p>Hesabınızı doğrulamak için aşağıdaki kodu kullanın:</p>"
                    + "<div style='background:#0D1117;border-radius:12px;padding:20px;text-align:center;margin:20px 0'>"
                    + "<span style='font-size:28px;font-weight:bold;color:#00BFA5;letter-spacing:4px'>" + token.substring(0, 6).toUpperCase() + "</span>"
                    + "</div>"
                    + "<p style='color:#666;font-size:12px'>Bu kod 24 saat geçerlidir.</p>"
                    + "</div>";
            mailer.send(Mail.withHtml(k.email, "Halı Saha - Email Doğrulama", html));
        } catch (Exception e) {
            System.out.println("Email gönderilemedi: " + e.getMessage());
        }
    }

    @Transactional
    public void emailDogrula(UUID kullaniciId, String token) {
        Kullanici k = Kullanici.findById(kullaniciId);
        if (k == null) throw new AuthException("Kullanıcı bulunamadı", 404);
        if (Boolean.TRUE.equals(k.emailDogrulanmis)) throw new AuthException("Email zaten doğrulanmış", 400);
        if (k.emailDogrulamaToken == null || !k.emailDogrulamaToken.equalsIgnoreCase(token.replaceAll("-", ""))
                && !k.emailDogrulamaToken.substring(0, 6).equalsIgnoreCase(token)) {
            throw new AuthException("Geçersiz doğrulama kodu", 400);
        }
        k.emailDogrulanmis = true;
        k.emailDogrulamaToken = null;
        k.persist();
    }
}
