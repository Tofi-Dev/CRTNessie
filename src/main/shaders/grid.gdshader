shader_type canvas_item;

uniform vec2 grid_resolution = vec2(10.0, 10.0); // Grid resolution in number of cells
uniform float spacing = 0.05; // Spacing as a fraction of cell size

void fragment() {
    // Calculate repeat based on resolution
    vec2 repeat = vec2(1.0) / grid_resolution;

    // Calculate UV transformed to grid space
    vec2 uvt = fract(UV / repeat);

    // Create the grid effect with spacing
    vec2 mask = vec2(spacing);
    vec2 t = step(uvt, mask) + step(vec2(1.0) - mask, uvt);
    COLOR.rgb = vec3(t.x + t.y);
}
