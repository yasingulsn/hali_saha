package com.halisaha.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class SahaYorumRequest {

    @NotNull
    @Min(1)
    @Max(5)
    public Integer puan;

    public String yorum;
}
