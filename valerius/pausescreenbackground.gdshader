shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_miktari : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV, blur_miktari);
    // İstersen ekranı biraz da karartmak için rengi de kısabiliriz:
    COLOR.rgb *= 0.5; 
}