shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 1000.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture; // Read pixel colors from entire game screen

void fragment() {
    vec2 size = 1.0 / SCREEN_PIXEL_SIZE; // Converts to UV space
    vec4 color = vec4(0.0);
    vec2 uv = SCREEN_UV;

    // Simple blur that looks at 9 x 9 grid around it
    for (float x = -4.0; x <= 4.0; x++) {
        for (float y = -4.0; y <= 4.0; y++) {
            color += texture(screen_texture, uv + vec2(x, y) * blur_amount / size) / 81.0;
        }
    }

    COLOR = color; // Final blurred pixel
}