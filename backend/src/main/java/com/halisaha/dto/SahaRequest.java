package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;

public class SahaRequest {

    @NotBlank(message = "Saha adı boş olamaz")
    public String sahaAdi;

    @NotBlank(message = "Adres boş olamaz")
    public String adres;

    public Double enlem;
    public Double boylam;

    @NotBlank(message = "Saha formatı boş olamaz")
    public String sahaFormati; // 5v5, 6v6, 7v7

    @NotNull(message = "Saatlik ücret boş olamaz")
    public BigDecimal saatlikUcret;

    public Boolean kapaliMi = false;
    public String ozellikler;
    public String fotografUrl;
}
