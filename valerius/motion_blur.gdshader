shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec2 motion_vector = vec2(0.0, 0.0); 
uniform int samples = 10;

void fragment() {
    float strength = length(motion_vector);
    if (strength < 0.001) {
        COLOR = texture(screen_texture, SCREEN_UV);
    } else {
        // Hareket vektorune gore geriye dogru ofset aliyoruz
        vec2 dir = motion_vector * 0.15; // Gücü 0.05'ten 0.15'e çıkararak daha yoğun bir efekt sağlıyoruz
        
        for (int i = 0; i < samples; i++) {
            float t = float(i) / float(samples - 1);
            color += texture(screen_texture, SCREEN_UV + (dir * t));
        }
        COLOR = color / float(samples);
    }
}
