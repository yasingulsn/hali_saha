package com.halisaha.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.halisaha.entity.FcmToken;
import jakarta.annotation.PostConstruct;
import jakarta.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.jboss.logging.Logger;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@ApplicationScoped
public class FcmService {

    private static final Logger LOG = Logger.getLogger(FcmService.class);

    @ConfigProperty(name = "halisaha.fcm.service-account-path")
    Optional<String> serviceAccountPath;

    private boolean aktif = false;

    @PostConstruct
    void init() {
        String path = serviceAccountPath.orElse("").trim();
        if (path.isBlank()) {
            LOG.warn("FCM devre dışı: halisaha.fcm.service-account-path ayarlanmamış");
            return;
        }
        try {
            InputStream stream;
            if (path.startsWith("classpath:")) {
                String cp = path.substring("classpath:".length());
                stream = getClass().getResourceAsStream("/" + cp);
            } else {
                stream = new FileInputStream(path);
            }
            if (stream == null) {
                LOG.warn("FCM servis hesabı dosyası bulunamadı: " + path);
                return;
            }
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(stream))
                    .build();
            if (FirebaseApp.getApps().isEmpty()) {
                FirebaseApp.initializeApp(options);
            }
            aktif = true;
            LOG.info("Firebase başarıyla başlatıldı");
        } catch (IOException e) {
            LOG.error("Firebase başlatılamadı: " + e.getMessage());
        }
    }

    public void pushGonder(UUID kullaniciId, String baslik, String mesaj, String tip, String hedefId) {
        if (!aktif) return;
        List<FcmToken> tokenler = FcmToken.findByKullaniciId(kullaniciId);
        for (FcmToken ft : tokenler) {
            try {
                Message msg = Message.builder()
                        .setToken(ft.token)
                        .setNotification(Notification.builder()
                                .setTitle(baslik)
                                .setBody(mesaj)
                                .build())
                        .putData("tip", tip != null ? tip : "")
                        .putData("hedefId", hedefId != null ? hedefId : "")
                        .build();
                FirebaseMessaging.getInstance().send(msg);
            } catch (Exception e) {
                LOG.warn("FCM gönderilemedi (token: " + ft.token.substring(0, Math.min(10, ft.token.length())) + "...): " + e.getMessage());
            }
        }
    }
}
