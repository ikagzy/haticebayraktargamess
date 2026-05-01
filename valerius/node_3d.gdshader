shader_type canvas_item;

// Ekranı yakalama
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Ayarlar (Sağ panelden değiştirebilirsin)
uniform float balik_gozu_gucu : hint_range(0.0, 0.5) = 0.05; // Çok hafif bükülme
uniform float renk_kaymasi : hint_range(0.0, 0.05) = 0.0015;  // Göz yormayan VHS renk ayrılması
uniform float kumlanma : hint_range(0.0, 0.1) = 0.015;        // Yok denecek kadar az kaset tozu
uniform float cizgi_gucu : hint_range(0.0, 0.1) = 0.01;       // Hafif TV çizgileri

// Rastgelelik fonksiyonu
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // --- 1. BALIK GÖZÜ (FISHEYE) EFEKTİ ---
    // UV'yi merkeze (0.0) çekiyoruz
    vec2 d_uv = uv - 0.5;
    // Merkezden uzaklığı ölçüyoruz (köşelere gittikçe artar)
    float mesafe = length(d_uv);
    // Köşeleri büküyoruz
    vec2 bukulmus_uv = uv + d_uv * mesafe * balik_gozu_gucu;
    
    // --- 2. VHS RENK KAYMASI (CHROMATIC ABERRATION) ---
    // Kırmızı, yeşil ve mavi kanalları minicik ayırarak bükülmüş ekrana basıyoruz
    float r = texture(screen_texture, bukulmus_uv + vec2(renk_kaymasi, 0.0)).r;
    float g = texture(screen_texture, bukulmus_uv).g;
    float b = texture(screen_texture, bukulmus_uv - vec2(renk_kaymasi, 0.0)).b;
    
    vec3 sonuc_renk = vec3(r, g, b);
    
    // --- 3. HAFİF TV ÇİZGİLERİ VE KUMLANMA ---
    float cizgi = sin(bukulmus_uv.y * 800.0) * cizgi_gucu;
    sonuc_renk -= cizgi;
    
    float kaset_tozu = rand(bukulmus_uv + vec2(TIME)) * kumlanma;
    sonuc_renk -= kaset_tozu;
    
    COLOR = vec4(sonuc_renk, 1.0);
}