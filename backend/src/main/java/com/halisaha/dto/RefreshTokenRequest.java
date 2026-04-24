package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;

public class RefreshTokenRequest {

    @NotBlank(message = "Refresh token boş olamaz")
    public String refreshToken;
}
