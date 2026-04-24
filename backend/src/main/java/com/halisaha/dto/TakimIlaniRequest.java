package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import java.math.BigDecimal;

public class TakimIlaniRequest {

    @NotBlank(message = "Takım adı boş olamaz")
    public String takimAdi;

    @NotBlank(message = "İlan başlığı boş olamaz")
    public String ilanBasligi;

    public String aciklama;
    public String arananPozisyon = "FARKETMEZ";
    public Integer arananOyuncuSayisi = 1;
    public BigDecimal minDisiplinPuani;
    public String seviye = "KARMA";
    public String konum;
}
