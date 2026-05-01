shader_type canvas_item;

// filter_nearest ÇOK ÖNEMLİ: Pikselleri bulanıklaştırmaz, keskin retro yapar!
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

// Ayarı buradan artırabilirsin, varsayılanı 4.0 yaptım (daha iri pikseller)
uniform float piksel_boyutu : hint_range(1.0, 10.0, 0.1) = 4.0; 

void fragment() {
	// Ekranın anlık gerçek çözünürlüğünü alıyoruz
	vec2 ekran_cozunurlugu = vec2(textureSize(SCREEN_TEXTURE, 0));
	
	// PİKSELLEŞTİRME MATEMATİĞİ (Sadece ızgara, sıfır VHS)
	vec2 piksel_uv = floor(SCREEN_UV * ekran_cozunurlugu / piksel_boyutu) / (ekran_cozunurlugu / piksel_boyutu);
	
	// Piksellenmiş görüntüyü ekrana bas
	COLOR = texture(SCREEN_TEXTURE, piksel_uv);
}