package com.halisaha.dto;

public class ApiResponse<T> {

    public boolean basarili;
    public String mesaj;
    public T veri;

    public ApiResponse() {}

    public ApiResponse(boolean basarili, String mesaj, T veri) {
        this.basarili = basarili;
        this.mesaj = mesaj;
        this.veri = veri;
    }

    public static <T> ApiResponse<T> basarili(String mesaj, T veri) {
        return new ApiResponse<>(true, mesaj, veri);
    }

    public static <T> ApiResponse<T> basarili(String mesaj) {
        return new ApiResponse<>(true, mesaj, null);
    }

    public static <T> ApiResponse<T> hata(String mesaj) {
        return new ApiResponse<>(false, mesaj, null);
    }
}
