shader_type canvas_item;

uniform vec2 player_pos;           // Player screen position (0-1 normalized)
uniform float visibility_radius;   // Visible radius (0-1 screen proportion)
uniform float soft_edge = 0.05;    // Edge softening amount
uniform float darkness = 0.9;      // Darkness level (90%)
uniform bool enabled = false;      // Whether fog is active
uniform bool has_torch = false;    // Whether player has torch (clear vision inside)
uniform vec2 screen_size = vec2(1280.0, 720.0);  // Screen resolution for aspect ratio

void fragment() {
    if (enabled) {
        vec2 uv = UV;

        // Correct for aspect ratio to make a perfect circle
        float aspect = screen_size.x / screen_size.y;
        vec2 adjusted_uv = vec2(uv.x * aspect, uv.y);
        vec2 adjusted_player = vec2(player_pos.x * aspect, player_pos.y);

        float dist = distance(adjusted_uv, adjusted_player);

        float alpha;
        if (has_torch) {
            // With torch: completely clear inside, dark outside
            alpha = smoothstep(visibility_radius - soft_edge, visibility_radius + soft_edge, dist);
            alpha *= darkness;
        } else {
            // Without torch: gradual darkness, small clear center
            float inner_radius = visibility_radius * 0.3;  // Small clear center
            if (dist < inner_radius) {
                alpha = 0.0;
            } else {
                alpha = smoothstep(inner_radius, visibility_radius, dist);
                alpha *= darkness;
            }
        }

        COLOR = vec4(0.0, 0.0, 0.0, alpha);
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
