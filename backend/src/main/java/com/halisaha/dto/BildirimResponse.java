package com.halisaha.dto;

import com.halisaha.entity.Bildirim;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class BildirimResponse {
    public UUID id;
    public String baslik;
    public String mesaj;
    public String bildirimTipi;
    public String hedefId;
    public String aksiyonId;
    public boolean okunduMu;
    public String olusturulmaTarihi;

    public static BildirimResponse fromEntity(Bildirim bildirim) {
        BildirimResponse res = new BildirimResponse();
        res.id = bildirim.id;
        res.baslik = bildirim.baslik;
        res.mesaj = bildirim.mesaj;
        res.bildirimTipi = bildirim.bildirimTipi;
        res.hedefId = bildirim.hedefId;
        res.aksiyonId = bildirim.aksiyonId;
        res.okunduMu = bildirim.okunduMu;
        if (bildirim.olusturulmaTarihi != null) {
            res.olusturulmaTarihi = bildirim.olusturulmaTarihi.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
        }
        return res;
    }
}
