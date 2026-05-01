shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float shatter_amount : hint_range(0.0, 1.0) = 0.0;
uniform float aberration_amount : hint_range(0.0, 10.0) = 0.0;
uniform float desaturation_amount : hint_range(0.0, 1.0) = 0.0;

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

void fragment() {
	// Kırık cam hissiyatı için rastgele üçgensel / hücresel dalgalanma
	vec2 grid = floor(SCREEN_UV * 8.0);
	vec2 offset = vec2(rand(grid) - 0.5, rand(grid + vec2(1.0)) - 0.5) * 0.05 * shatter_amount;
	
	// Chromatic Aberration (Zamanın kırılması sırasındaki kırmızı/mavi ayrılması)
	float r = texture(screen_texture, SCREEN_UV + offset + vec2(aberration_amount * 0.005, 0.0)).r;
	float g = texture(screen_texture, SCREEN_UV + offset).g;
	float b = texture(screen_texture, SCREEN_UV + offset - vec2(aberration_amount * 0.005, 0.0)).b;
	
	vec3 color = vec3(r, g, b);
	
	// Renkleri Solgunlaştırma (Desaturation)
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	vec3 final_color = mix(color, vec3(gray), desaturation_amount);
	
	COLOR = vec4(final_color, 1.0);
}
