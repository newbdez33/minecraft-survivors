shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 0.84, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_speed : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (tex.a < 0.5) {
        // Check neighboring pixels for outline with early exit
        float outline = 0.0;
        for (float x = -outline_width; x <= outline_width; x += 1.0) {
            for (float y = -outline_width; y <= outline_width; y += 1.0) {
                vec2 offset = vec2(x, y) / vec2(textureSize(TEXTURE, 0));
                if (texture(TEXTURE, UV + offset).a > 0.5) {
                    outline = 1.0;
                    break;
                }
            }
            if (outline > 0.0) break;
        }

        if (outline > 0.0) {
            float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
            COLOR = outline_color * (0.7 + pulse * 0.3);
        } else {
            COLOR = tex;
        }
    } else {
        COLOR = tex;
    }
}
