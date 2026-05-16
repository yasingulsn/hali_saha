package com.halisaha.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class MacSkorRequest {

    @NotNull
    @Min(0)
    public Integer takim1Skor;

    @NotNull
    @Min(0)
    public Integer takim2Skor;
}
