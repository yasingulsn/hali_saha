

-- Kullanıcı tablosuna yeni kolonlar
ALTER TABLE kullanici_tb ADD COLUMN IF NOT EXISTS disiplin_puani NUMERIC(4, 2) DEFAULT 5.00;
ALTER TABLE kullanici_tb ADD COLUMN IF NOT EXISTS tercih_edilen_pozisyon VARCHAR(30);

-- Maç tablosuna yeni kolonlar
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS min_disiplin_puani NUMERIC(4, 2);
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS mac_tipi VARCHAR(20) DEFAULT 'NORMAL';
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS eksik_oyuncu_sayisi INTEGER;
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS takim_adi VARCHAR(100);
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS rakip_notu VARCHAR(300);
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS il VARCHAR(100);
ALTER TABLE mac_tb ADD COLUMN IF NOT EXISTS ilce VARCHAR(100);

-- Takım İlanı tablosu
CREATE TABLE IF NOT EXISTS takim_ilani_tb (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    olusturan_id UUID NOT NULL,
    takim_adi VARCHAR(100) NOT NULL,
    ilan_basligi VARCHAR(200) NOT NULL,
    aciklama VARCHAR(500),
    aranan_pozisyon VARCHAR(50) DEFAULT 'FARKETMEZ',
    aranan_oyuncu_sayisi INTEGER DEFAULT 1,
    min_disiplin_puani NUMERIC(4, 2),
    seviye VARCHAR(20) DEFAULT 'KARMA',
    konum VARCHAR(100),
    ilan_durumu VARCHAR(20) DEFAULT 'AKTIF',
    olusturulma_tarihi TIMESTAMPTZ DEFAULT NOW()
);

-- İndeksler
CREATE INDEX IF NOT EXISTS idx_hali_saha_isletme ON hali_saha_tb(isletme_id);
CREATE INDEX IF NOT EXISTS idx_hali_saha_aktif ON hali_saha_tb(aktif_mi);
CREATE INDEX IF NOT EXISTS idx_mac_durum_tarih ON mac_tb(mac_durumu, mac_tarihi);
CREATE INDEX IF NOT EXISTS idx_mac_olusturan ON mac_tb(olusturan_id);
CREATE INDEX IF NOT EXISTS idx_mac_saha ON mac_tb(saha_id);
CREATE INDEX IF NOT EXISTS idx_mac_katilimci_mac ON mac_katilimci_tb(mac_id);
CREATE INDEX IF NOT EXISTS idx_mac_katilimci_kullanici ON mac_katilimci_tb(kullanici_id);
CREATE INDEX IF NOT EXISTS idx_mac_tipi ON mac_tb(mac_tipi);
CREATE INDEX IF NOT EXISTS idx_takim_ilani_durumu ON takim_ilani_tb(ilan_durumu);
CREATE INDEX IF NOT EXISTS idx_takim_ilani_olusturan ON takim_ilani_tb(olusturan_id);
