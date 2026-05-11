package com.halisaha.dto;

import com.halisaha.entity.TakimIlaniIstek;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

public class TakimIlaniIstekResponse {
    public UUID id;
    public UUID ilanId;
    public String ilanBasligi;
    public UUID gonderenId;
    public String gonderenAdSoyad;
    public String mesaj;
    public String durum;
    public String olusturulmaTarihi;

    public static TakimIlaniIstekResponse fromEntity(TakimIlaniIstek istek) {
        TakimIlaniIstekResponse res = new TakimIlaniIstekResponse();
        res.id = istek.id;
        res.ilanId = istek.ilanId;
        res.ilanBasligi = istek.ilan != null ? istek.ilan.ilanBasligi : "Bilinmeyen İlan";
        res.gonderenId = istek.gonderenId;
        res.gonderenAdSoyad = istek.gonderen != null ? istek.gonderen.adSoyad : "Bilinmeyen Oyuncu";
        res.mesaj = istek.mesaj;
        res.durum = istek.durum;
        if (istek.olusturulmaTarihi != null) {
            res.olusturulmaTarihi = istek.olusturulmaTarihi.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
        }
        return res;
    }
}
