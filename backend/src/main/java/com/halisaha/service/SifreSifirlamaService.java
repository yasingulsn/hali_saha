package com.halisaha.service;

import com.halisaha.entity.Isletme;
import com.halisaha.entity.Kullanici;
import com.halisaha.entity.SifreSifirlama;
import com.halisaha.exception.AuthException;
import io.quarkus.mailer.Mail;
import io.quarkus.mailer.Mailer;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.mindrot.jbcrypt.BCrypt;

import java.time.OffsetDateTime;
import java.util.UUID;

@ApplicationScoped
public class SifreSifirlamaService {

    @Inject
    Mailer mailer;

    @Transactional
    public void sifirlamaIstegiOlustur(String email, String kullaniciTipi) {
        System.out.println("DEBUG: Sifre sifirlama istegi geldi. Email: " + email + ", Tip: " + kullaniciTipi);
        UUID id = null;
        String adSoyad = "";

        if ("KULLANICI".equals(kullaniciTipi)) {
            Kullanici k = Kullanici.findByEmail(email);
            if (k != null) {
                id = k.id;
                adSoyad = k.adSoyad;
            }
        } else if ("ISLETME".equals(kullaniciTipi)) {
            Isletme i = Isletme.findByEmail(email);
            if (i != null) {
                id = i.id;
                adSoyad = i.isletmeAdi;
            }
        }

        if (id == null) {
            System.out.println("DEBUG: Kullanici/Isletme bulunamadi (ID null). Email: " + email + ", Tip: " + kullaniciTipi);
        }

        // Kullanıcı bulunmasa bile güvenlik için "Gönderildi" mesajı döneriz
        // Ama içeride işlemi sadece kullanıcı varsa yaparız
        if (id != null) {
            System.out.println("DEBUG: Kullanici bulundu. ID: " + id);
            // Eski aktif tokenları iptal et
            SifreSifirlama.update("kullanildiMi = true where (kullaniciId = ?1 or isletmeId = ?1) and kullanildiMi = false", id);

            String token = UUID.randomUUID().toString();
            SifreSifirlama sifirlama = new SifreSifirlama();
            if ("KULLANICI".equals(kullaniciTipi)) {
                sifirlama.kullaniciId = id;
            } else {
                sifirlama.isletmeId = id;
            }
            sifirlama.kullaniciTipi = kullaniciTipi;
            sifirlama.token = token;
            sifirlama.gecerlilikTarihi = OffsetDateTime.now().plusHours(1);
            sifirlama.olusturulmaTarihi = OffsetDateTime.now();
            sifirlama.persist();

            // Mail gönder
            System.out.println("**************************************************");
            System.out.println("SIFRE SIFIRLAMA KODU: " + token);
            System.out.println("**************************************************");
            sendResetEmail(email, adSoyad, token);
        }
    }

    private void sendResetEmail(String email, String adSoyad, String token) {
        String resetLink = "halisaha://reset-password?token=" + token;
        
        String htmlContent = "<html><body>" +
                "<h3>Şifre Sıfırlama İsteği</h3>" +
                "<p>Merhaba " + adSoyad + ",</p>" +
                "<p>Hesabınız için şifre sıfırlama isteğinde bulundunuz. Aşağıdaki kodu uygulamaya girerek veya linke tıklayarak şifrenizi sıfırlayabilirsiniz:</p>" +
                "<p style='font-size: 20px; color: #00ff88;'><b>" + token + "</b></p>" +
                "<p><a href='" + resetLink + "'>Şifremi Sıfırla</a></p>" +
                "<p>Bu istek size ait değilse lütfen bu e-postayı dikkate almayınız. Kod 1 saat geçerlidir.</p>" +
                "</body></html>";

        mailer.send(Mail.withHtml(email, "Halı Saha - Şifre Sıfırlama", htmlContent));
    }

    @Transactional
    public void sifreSifirla(String token, String yeniSifre) {
        SifreSifirlama s = SifreSifirlama.find("token = ?1 and kullanildiMi = false", token).firstResult();
        
        if (s == null) {
            throw new AuthException("Geçersiz veya kullanılmış token", 400);
        }
        
        if (s.gecerlilikTarihi.isBefore(OffsetDateTime.now())) {
            throw new AuthException("Token süresi dolmuş", 400);
        }

        String hash = BCrypt.hashpw(yeniSifre, BCrypt.gensalt());

        if ("KULLANICI".equals(s.kullaniciTipi)) {
            Kullanici k = Kullanici.findById(s.kullaniciId);
            if (k != null) {
                k.sifre = hash;
                k.persist();
            }
        } else {
            Isletme i = Isletme.findById(s.isletmeId);
            if (i != null) {
                i.sifre = hash;
                i.persist();
            }
        }

        s.kullanildiMi = true;
        s.persist();
    }
}
