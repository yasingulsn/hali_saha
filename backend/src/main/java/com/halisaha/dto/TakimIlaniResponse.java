package com.halisaha.dto;

import com.halisaha.entity.TakimIlani;
import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

public class TakimIlaniResponse {

    public UUID id;
    public UUID olusturanId;
    public String olusturanAdi;
    public String takimAdi;
    public String ilanBasligi;
    public String aciklama;
    public String arananPozisyon;
    public Integer arananOyuncuSayisi;
    public BigDecimal minDisiplinPuani;
    public String seviye;
    public String konum;
    public String ilanDurumu;
    public OffsetDateTime olusturulmaTarihi;

    public TakimIlaniResponse() {}

    public static TakimIlaniResponse from(TakimIlani ilan, String olusturanAdi) {
        TakimIlaniResponse r = new TakimIlaniResponse();
        r.id = ilan.id;
        r.olusturanId = ilan.olusturanId;
        r.olusturanAdi = olusturanAdi;
        r.takimAdi = ilan.takimAdi;
        r.ilanBasligi = ilan.ilanBasligi;
        r.aciklama = ilan.aciklama;
        r.arananPozisyon = ilan.arananPozisyon;
        r.arananOyuncuSayisi = ilan.arananOyuncuSayisi;
        r.minDisiplinPuani = ilan.minDisiplinPuani;
        r.seviye = ilan.seviye;
        r.konum = ilan.konum;
        r.ilanDurumu = ilan.ilanDurumu;
        r.olusturulmaTarihi = ilan.olusturulmaTarihi;
        return r;
    }
}
