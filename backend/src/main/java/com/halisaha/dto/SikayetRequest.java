package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public class SikayetRequest {

    @NotNull
    public UUID sikayetEdilenId;

    public UUID macId;

    @NotBlank
    public String kategori; // GELMEME, KAVGA, KURAL_IHLALI, DIGER

    public String aciklama;
}
