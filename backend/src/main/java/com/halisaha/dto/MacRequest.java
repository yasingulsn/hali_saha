package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public class MacRequest {

    @NotBlank(message = "Maç başlığı boş olamaz")
    public String macBasligi;

    public UUID sahaId;

    @NotNull(message = "Maç tarihi boş olamaz")
    public LocalDate macTarihi;

    @NotNull(message = "Başlangıç saati boş olamaz")
    public LocalTime baslangicSaati;

    @NotNull(message = "Bitiş saati boş olamaz")
    public LocalTime bitisSaati;

    @NotBlank(message = "Format boş olamaz")
    public String format; // 5v5, 6v6, 7v7

    @NotNull(message = "Maksimum oyuncu sayısı boş olamaz")
    public Integer maxOyuncuSayisi;

    public String aciklama;
    public String seviye = "KARMA";
    public BigDecimal ucretPerKisi = BigDecimal.ZERO;
    public BigDecimal minDisiplinPuani;
    public String macTipi = "NORMAL"; // NORMAL, RAKIP_ARANIYOR, EKSIK_OYUNCU
    public Integer eksikOyuncuSayisi;
    public String takimAdi;
    public String rakipNotu;
    public String il;
    public String ilce;
}
