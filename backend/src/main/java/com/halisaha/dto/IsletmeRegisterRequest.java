package com.halisaha.dto;

import jakarta.validation.constraints.*;

public class IsletmeRegisterRequest {

    @NotBlank(message = "İşletme adı boş olamaz")
    @Size(min = 2, max = 200)
    public String isletmeAdi;

    @NotBlank(message = "Yetkili ad soyad boş olamaz")
    @Size(min = 3, max = 100)
    public String yetkiliAdSoyad;

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

    @NotBlank(message = "Telefon boş olamaz")
    @Size(max = 20)
    public String telefon;

    @Size(max = 50)
    public String vergiNo;

    public String adres;

    public Double konumEnlem;
    public Double konumBoylam;

    public String cihazBilgisi;
}
