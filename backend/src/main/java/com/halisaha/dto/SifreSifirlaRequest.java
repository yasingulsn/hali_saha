package com.halisaha.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class SifreSifirlaRequest {
    @NotBlank(message = "Token alanı boş olamaz")
    public String token;

    @NotBlank(message = "Yeni şifre alanı boş olamaz")
    @Size(min = 6, message = "Şifre en az 6 karakter olmalıdır")
    public String yeniSifre;
}
