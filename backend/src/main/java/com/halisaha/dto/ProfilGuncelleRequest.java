package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ProfilGuncelleRequest {

    @NotBlank(message = "Ad soyad boş olamaz")
    @Size(max = 100, message = "Ad soyad en fazla 100 karakter olabilir")
    public String adSoyad;

    @Size(max = 20, message = "Telefon en fazla 20 karakter olabilir")
    public String telefon;

    @Size(max = 30, message = "Pozisyon en fazla 30 karakter olabilir")
    public String tercihEdilenPozisyon; // KALECI, DEFANS, ORTASAHA, FORVET

    public String dogumTarihi; // "yyyy-MM-dd" formatında
    public String il;
    public String ilce;

    @Size(max = 1000, message = "Fotoğraf URL en fazla 1000 karakter olabilir")
    public String profilFotoUrl;
}
