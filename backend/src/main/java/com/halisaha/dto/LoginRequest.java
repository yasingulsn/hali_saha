package com.halisaha.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public class LoginRequest {

    @NotBlank(message = "Email boş olamaz")
    @Email(message = "Geçerli bir email adresi giriniz")
    public String email;

    @NotBlank(message = "Şifre boş olamaz")
    public String sifre;

    public String cihazBilgisi;

    public boolean beniHatirla = false;
}
