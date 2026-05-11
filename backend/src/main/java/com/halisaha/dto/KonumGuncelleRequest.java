package com.halisaha.dto;

import jakarta.validation.constraints.Size;

public class KonumGuncelleRequest {
    @Size(max = 50)
    public String il;

    @Size(max = 50)
    public String ilce;
}
