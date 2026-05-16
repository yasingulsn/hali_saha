package com.halisaha.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class OyuncuPuanlaRequest {

    @NotNull(message = "Oyuncu ID boş olamaz")
    public UUID hedefKullaniciId;

    @NotNull(message = "Puan boş olamaz")
    @Min(value = 1, message = "Puan en az 1 olabilir")
    @Max(value = 5, message = "Puan en fazla 5 olabilir")
    public Integer puan; // 1-5 arası
}
