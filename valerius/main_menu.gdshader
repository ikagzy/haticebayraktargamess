shader_type canvas_item;

// Ekrandaki görüntüyü yakalıyoruz (Godot 4 için özel kod)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Sağ taraftan ayarlayabileceğin özellikler
uniform float titreme_miktari : hint_range(0.0, 0.05) = 0.003;
uniform float renk_kaymasi : hint_range(0.0, 0.05) = 0.002;
uniform float kumlanma_miktari : hint_range(0.0, 0.5) = 0.04;

// Rastgele sayı üreteci (TV karıncalanması için)
float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // 1. Ufak Titreme (Jitter / Kaset bozulması)
    uv.x += (rand(vec2(TIME, uv.y)) - 0.5) * titreme_miktari;

    // 2. Renk Kayması (Kırmızı ve Mavi kanalları hafifçe sağa sola ayırma)
    float r = texture(screen_texture, uv + vec2(renk_kaymasi, 0.0)).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - vec2(renk_kaymasi, 0.0)).b;
    
    vec3 renk = vec3(r, g, b);
    
    // 3. Kumlanma (Static Noise)
    float noise = rand(uv + vec2(TIME));
    renk -= noise * kumlanma_miktari;
    
    // 4. Eski TV Çizgileri (Scanlines)
    float cizgi = sin(uv.y * 800.0) * 0.03;
    renk -= cizgi;

    // Sonucu ekrana bas
    COLOR = vec4(renk, 1.0);
}