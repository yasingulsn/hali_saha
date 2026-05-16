package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class RezervasyonRequest {

    @NotNull(message = "Saha ID boş olamaz")
    public UUID sahaId;

    @NotBlank(message = "Rezervasyon tarihi boş olamaz")
    public String rezervasyonTarihi; // yyyy-MM-dd

    @NotBlank(message = "Başlangıç saati boş olamaz")
    public String baslangicSaati; // HH:mm

    @NotBlank(message = "Bitiş saati boş olamaz")
    public String bitisSaati; // HH:mm

    public String notlar;
}
