extends ColorRect

# =====================================================
# Bunu sahnenize eklediğiniz ColorRect'e bağlayın.
# Başlangıç rengi: Color(0.6, 0, 0, 0) [Saydam kırmızı]
# Full Rect anchor preset yapın.
# =====================================================

# Diğer scriptlerden çağırmak için:
#   get_node("YolunuzColorRect").efekt_baslat()

func _ready():
	# Başlangıçta tamamen saydam olsun
	color.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Tıklamaları engellemesin

# === ANA TRAVMA EFEKTİ ===
func efekt_baslat():
	# Önceki tween varsa durdur
	var tw = create_tween()
	
	# Kırmızı efekt: Belir → Solar → Tekrar Belir → Yok Ol
	tw.tween_property(self, "color:a", 0.6, 0.12)
	tw.tween_property(self, "color:a", 0.05, 0.35)
	tw.tween_property(self, "color:a", 0.35, 0.15)
	tw.tween_property(self, "color:a", 0.15, 0.2)
	tw.tween_property(self, "color:a", 0.05, 0.25)
	tw.tween_property(self, "color:a", 0.25, 0.15)
	tw.tween_property(self, "color:a", 0.0, 0.5)

# === HIZLI FLAŞ (Ani çarpma hissi) ===
func flas_efekti():
	var tw = create_tween()
	tw.tween_property(self, "color:a", 0.85, 0.04)
	tw.tween_property(self, "color:a", 0.0, 0.4)

# === NABIZ (Kalp atışı gibi ritimli) ===
func nabiz_efekti(tekrar_sayisi: int = 3):
	var tw = create_tween()
	tw.set_loops(tekrar_sayisi)
	tw.tween_property(self, "color:a", 0.45, 0.18).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "color:a", 0.0, 0.35).set_trans(Tween.TRANS_SINE)
