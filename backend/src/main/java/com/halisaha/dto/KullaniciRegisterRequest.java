package com.halisaha.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class KullaniciRegisterRequest {

    @NotBlank(message = "Ad soyad boş olamaz")
    @Size(min = 3, max = 100, message = "Ad soyad 3-100 karakter arasında olmalıdır")
    public String adSoyad;

    @NotBlank(message = "Email boş olamaz")
    @Email(message = "Geçerli bir email adresi giriniz")
    public String email;

    @NotBlank(message = "Şifre boş olamaz")
    @Size(min = 8, max = 128, message = "Şifre en az 8 karakter olmalıdır")
    @Pattern(
        regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$",
        message = "Şifre en az bir büyük harf, bir küçük harf ve bir rakam içermelidir"
    )
    public String sifre;

    @Size(max = 20, message = "Telefon numarası en fazla 20 karakter olabilir")
    public String telefon;

    public LocalDate dogumTarihi;

    public String cihazBilgisi;
}
