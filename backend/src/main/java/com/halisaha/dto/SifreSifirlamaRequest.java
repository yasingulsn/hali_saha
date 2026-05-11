package com.halisaha.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class SifreSifirlamaRequest {
    @NotBlank(message = "Email alanı boş olamaz")
    @Email(message = "Geçersiz email formatı")
    public String email;

    @NotBlank(message = "Kullanıcı tipi alanı boş olamaz")
    public String kullaniciTipi; // KULLANICI veya ISLETME
}
