import 'package:flutter/material.dart';
import '../models/rezervasyon.dart';
import '../models/saha.dart';
import '../services/api_client.dart';
import '../services/rezervasyon_service.dart';
import '../utils/theme.dart';

class RezervasyonScreen extends StatefulWidget {
  final Saha saha;
  const RezervasyonScreen({super.key, required this.saha});

  @override
  State<RezervasyonScreen> createState() => _RezervasyonScreenState();
}

class _RezervasyonScreenState extends State<RezervasyonScreen> {
  late final RezervasyonService _service = RezervasyonService(ApiClient());

  DateTime _secilenTarih = DateTime.now().add(const Duration(days: 1));
  String? _secilenBaslangic;
  String? _secilenBitis;
  final _notCtrl = TextEditingController();
  bool _yukleniyor = false;
  bool _dolulukYukleniyor = false;

  List<Rezervasyon> _doluSlotlar = [];

  // 07:00 - 23:00 arası 1 saatlik slotlar
  final List<String> _saatler = List.generate(17, (i) {
    final saat = i + 7;
    return '${saat.toString().padLeft(2, '0')}:00';
  });

  @override
  void initState() {
    super.initState();
    _dolulukYukle();
  }

  @override
  void dispose() {
    _notCtrl.dispose();
    super.dispose();
  }

  Future<void> _dolulukYukle() async {
    setState(() => _dolulukYukleniyor = true);
    final tarihStr = _formatDate(_secilenTarih);
    final res = await _service.sahaGunlukDolu(widget.saha.id, tarihStr);
    if (mounted) {
      setState(() {
        _dolulukYukleniyor = false;
        _doluSlotlar = res.veri ?? [];
        _secilenBaslangic = null;
        _secilenBitis = null;
      });
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  bool _slotDoluMu(String saat) {
    final slotStart = _parseTime(saat);
    final slotEnd = slotStart.add(const Duration(hours: 1));
    for (final r in _doluSlotlar) {
      final rStart = _parseTime(r.baslangicSaati.substring(0, 5));
      final rEnd = _parseTime(r.bitisSaati.substring(0, 5));
      if (slotStart.isBefore(rEnd) && slotEnd.isAfter(rStart)) return true;
    }
    return false;
  }

  DateTime _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  bool get _secimiTamamMi => _secilenBaslangic != null && _secilenBitis != null;

  double? get _hesaplananUcret {
    if (!_secimiTamamMi) return null;
    final baslangic = _parseTime(_secilenBaslangic!);
    final bitis = _parseTime(_secilenBitis!);
    final saat = bitis.difference(baslangic).inHours;
    return saat * widget.saha.saatlikUcret;
  }

  void _saatSec(String saat) {
    if (_slotDoluMu(saat)) return;

    if (_secilenBaslangic == null) {
      setState(() {
        _secilenBaslangic = saat;
        _secilenBitis = null;
      });
      return;
    }

    // İkinci tıklamada bitis seç
    final baslangicDt = _parseTime(_secilenBaslangic!);
    final tiklanenDt = _parseTime(saat);

    if (tiklanenDt.isBefore(baslangicDt) || tiklanenDt.isAtSameMomentAs(baslangicDt)) {
      // Başlangıç olarak yeniden seç
      setState(() {
        _secilenBaslangic = saat;
        _secilenBitis = null;
      });
      return;
    }

    // Aralarında dolu slot var mı kontrol et
    final indeks = _saatler.indexOf(_secilenBaslangic!);
    final hedefIndeks = _saatler.indexOf(saat);
    for (int i = indeks + 1; i <= hedefIndeks; i++) {
      if (_slotDoluMu(_saatler[i])) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Seçilen aralıkta dolu slot var'),
          backgroundColor: AppTheme.errorRed,
        ));
        setState(() { _secilenBaslangic = null; _secilenBitis = null; });
        return;
      }
    }

    // Bitis = seçilen slot + 1 saat
    final bitisIndeks = _saatler.indexOf(saat);
    if (bitisIndeks + 1 < _saatler.length) {
      setState(() => _secilenBitis = _saatler[bitisIndeks + 1]);
    } else {
      setState(() => _secilenBitis = '23:00');
    }
  }

  Future<void> _rezervasyonYap() async {
    if (!_secimiTamamMi) return;
    setState(() => _yukleniyor = true);

    final res = await _service.rezervasyonOlustur(
      sahaId: widget.saha.id,
      tarih: _formatDate(_secilenTarih),
      baslangic: _secilenBaslangic!,
      bitis: _secilenBitis!,
      notlar: _notCtrl.text.trim().isEmpty ? null : _notCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _yukleniyor = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.mesaj),
      backgroundColor: res.basarili ? AppTheme.primaryGreen : AppTheme.errorRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));

    if (res.basarili) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.saha.sahaAdi, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saha bilgi özeti
            _buildSahaBilgi(),
            const SizedBox(height: 24),

            // Takvim
            _buildSectionLabel('Tarih Seç'),
            const SizedBox(height: 12),
            _buildTakvim(),
            const SizedBox(height: 24),

            // Saat seçimi
            _buildSectionLabel('Saat Seç'),
            const SizedBox(height: 8),
            Text(
              'İlk tıklamada başlangıç, ikinci tıklamada bitiş saati seçilir.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.6)),
            ),
            const SizedBox(height: 12),
            _dolulukYukleniyor
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppTheme.primaryGreen),
                  ))
                : _buildSaatGrid(),
            const SizedBox(height: 24),

            // Seçim özeti
            if (_secimiTamamMi) ...[
              _buildSecimOzeti(),
              const SizedBox(height: 16),
            ],

            // Not alanı
            _buildSectionLabel('Not (Opsiyonel)'),
            const SizedBox(height: 12),
            TextField(
              controller: _notCtrl,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Saha sahibine not ekleyebilirsiniz...',
                hintStyle: TextStyle(color: AppTheme.textHint.withOpacity(0.5), fontSize: 13),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Rezervasyon butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _secimiTamamMi ? AppTheme.primaryGreen : AppTheme.cardDark,
                  foregroundColor: _secimiTamamMi ? AppTheme.backgroundDark : AppTheme.textSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: (_secimiTamamMi && !_yukleniyor) ? _rezervasyonYap : null,
                child: _yukleniyor
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        _secimiTamamMi ? 'Rezervasyon Yap' : 'Saat Seçiniz',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSahaBilgi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.stadium_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.saha.sahaAdi, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(widget.saha.adres, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₺${widget.saha.saatlikUcret.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
              Text('/saat', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTakvim() {
    final bugun = DateTime.now();
    final ayBaslangic = DateTime(_secilenTarih.year, _secilenTarih.month, 1);
    final ayBitis = DateTime(_secilenTarih.year, _secilenTarih.month + 1, 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          // Ay navigasyonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final oncekiAy = DateTime(_secilenTarih.year, _secilenTarih.month - 1, 1);
                  if (!oncekiAy.isBefore(DateTime(bugun.year, bugun.month, 1))) {
                    setState(() => _secilenTarih = oncekiAy);
                    _dolulukYukle();
                  }
                },
                icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary),
              ),
              Text(
                '${_ayAdi(_secilenTarih.month)} ${_secilenTarih.year}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              IconButton(
                onPressed: () {
                  setState(() => _secilenTarih = DateTime(_secilenTarih.year, _secilenTarih.month + 1, 1));
                  _dolulukYukle();
                },
                icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Gün başlıkları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz']
                .map((g) => SizedBox(
                      width: 36,
                      child: Text(g, textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary.withOpacity(0.5))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Günler grid
          Builder(builder: (context) {
            final baslangicOffset = (ayBaslangic.weekday - 1) % 7;
            final toplamHucre = baslangicOffset + ayBitis.day;
            final satirSayisi = (toplamHucre / 7).ceil();

            return Column(
              children: List.generate(satirSayisi, (satir) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (sutun) {
                    final index = satir * 7 + sutun;
                    final gun = index - baslangicOffset + 1;
                    if (gun < 1 || gun > ayBitis.day) return const SizedBox(width: 36, height: 36);

                    final tarih = DateTime(_secilenTarih.year, _secilenTarih.month, gun);
                    final gecmis = tarih.isBefore(DateTime(bugun.year, bugun.month, bugun.day));
                    final secili = tarih.year == _secilenTarih.year &&
                        tarih.month == _secilenTarih.month &&
                        tarih.day == _secilenTarih.day;

                    return GestureDetector(
                      onTap: gecmis ? null : () {
                        setState(() => _secilenTarih = tarih);
                        _dolulukYukle();
                      },
                      child: Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: secili ? AppTheme.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$gun',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: secili ? FontWeight.w800 : FontWeight.w500,
                            color: secili
                                ? AppTheme.backgroundDark
                                : gecmis
                                    ? AppTheme.textSecondary.withOpacity(0.25)
                                    : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSaatGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _saatler.map((saat) {
        final dolu = _slotDoluMu(saat);
        final seciliBaslangic = _secilenBaslangic == saat;
        final aralikte = _secilenBaslangic != null && _secilenBitis != null &&
            _parseTime(saat).isAfter(_parseTime(_secilenBaslangic!).subtract(const Duration(minutes: 1))) &&
            _parseTime(saat).isBefore(_parseTime(_secilenBitis!));

        Color bgColor;
        Color textColor;
        Color borderColor;

        if (dolu) {
          bgColor = AppTheme.errorRed.withOpacity(0.08);
          textColor = AppTheme.errorRed.withOpacity(0.4);
          borderColor = AppTheme.errorRed.withOpacity(0.15);
        } else if (seciliBaslangic) {
          bgColor = AppTheme.primaryGreen;
          textColor = AppTheme.backgroundDark;
          borderColor = AppTheme.primaryGreen;
        } else if (aralikte) {
          bgColor = AppTheme.primaryGreen.withOpacity(0.15);
          textColor = AppTheme.primaryGreen;
          borderColor = AppTheme.primaryGreen.withOpacity(0.3);
        } else {
          bgColor = AppTheme.cardDark;
          textColor = AppTheme.textPrimary;
          borderColor = Colors.white.withOpacity(0.08);
        }

        return GestureDetector(
          onTap: dolu ? null : () => _saatSec(saat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Text(saat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
                if (dolu)
                  Text('Dolu', style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSecimOzeti() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen.withOpacity(0.1), AppTheme.primaryGreen.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_gunAdi(_secilenTarih.weekday)}, ${_secilenTarih.day} ${_ayAdi(_secilenTarih.month)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                Text('$_secilenBaslangic – $_secilenBitis', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (_hesaplananUcret != null)
            Text('₺${_hesaplananUcret!.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textSecondary));
  }

  String _ayAdi(int ay) {
    const aylar = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return aylar[ay];
  }

  String _gunAdi(int gun) {
    const gunler = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return gunler[gun];
  }
}
