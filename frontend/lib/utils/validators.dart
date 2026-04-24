class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email adresi gereklidir';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir email adresi giriniz';
    }
    return null;
  }

  static String? sifre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gereklidir';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'En az bir büyük harf içermelidir';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'En az bir küçük harf içermelidir';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'En az bir rakam içermelidir';
    }
    return null;
  }

  static String? sifreTekrar(String? value, String sifre) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gereklidir';
    }
    if (value != sifre) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  static String? adSoyad(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ad soyad gereklidir';
    }
    if (value.trim().length < 3) {
      return 'Ad soyad en az 3 karakter olmalıdır';
    }
    return null;
  }

  static String? telefon(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Geçerli bir telefon numarası giriniz';
    }
    return null;
  }

  static String? zorunluAlan(String? value, String alanAdi) {
    if (value == null || value.trim().isEmpty) {
      return '$alanAdi gereklidir';
    }
    return null;
  }
}
