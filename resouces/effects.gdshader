shader_type canvas_item;

uniform float color_shift : hint_range(-180, 180); // Hue shift in degrees
uniform float fisheye : hint_range(0.0, 1.0);        // Fisheye effect intensity
uniform float whirl : hint_range(0.0, 10.0);         // Whirl effect intensity
uniform float pixelate : hint_range(0, 100);           // Pixelation level: 0 = no effect, 100 = maximum effect
uniform float mosaic : hint_range(0, 100);             // Mosaic effect parameter (defines grid in discrete steps)
uniform float brightness : hint_range(-100, 100);      // Brightness adjustment
uniform float ghost : hint_range(0.0, 1.0);            // Ghost effect (transparency)
uniform float sprite_size : hint_range(1, 100) = 10.0;   // Sprite resolution (e.g. 10x10 pixels)

// Function to shift hue using YIQ conversion
vec3 hueShift(vec3 col, float shift) {
    const mat3 rgb2yiq = mat3(
        vec3(0.299,  0.587,  0.114),
        vec3(0.596, -0.274, -0.322),
        vec3(0.211, -0.523,  0.312)
    );
    const mat3 yiq2rgb = mat3(
        vec3(1.0,  0.956,  0.621),
        vec3(1.0, -0.272, -0.647),
        vec3(1.0, -1.107,  1.705)
    );

    vec3 yiq = rgb2yiq * col;
    float angle = radians(shift);
    float cosA = cos(angle);
    float sinA = sin(angle);
    mat3 rot = mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cosA, -sinA),
        vec3(0.0, sinA, cosA)
    );
    yiq = rot * yiq;
    return clamp(yiq2rgb * yiq, 0.0, 1.0);
}

// Ang
vec2 applyFisheye(vec2 uv, float intensity) {
    vec2 normCoord = (uv - 0.5) / 0.5; // Normierte Koordinaten [-1,1]
    float r = length(normCoord);
    float factor = 1.0 - intensity * (1.0 - r); // Linearer Übergang: maximum im Zentrum, 1 am Rand
    normCoord *= factor;
    return 2.5 + normCoord * 0.5;
}

// Apply whirl effect to UV coordinates
vec2 applyWhirl(vec2 uv, float intensity) {
    vec2 centered = uv - 0.5;
    float angle = length(centered) * intensity;
    float s = sin(angle);
    float c = cos(angle);
    mat2 rotation = mat2(vec2(c, -s), vec2(s, c));
    return 0.5 + rotation * centered;
}

void fragment() {
    vec2 uv = UV;

    // Apply Fisheye effect if enabled
    if (fisheye > 0.0) {
        uv = applyFisheye(uv, fisheye);
    }

    // Apply whirl effect if enabled
    if (whirl > 0.0) {
        uv = applyWhirl(uv, whirl);
    }

    // Apply pixelation effect (quantize UV coordinates)
    if (pixelate > 0.0) {
        float factor = mix(sprite_size, 1.0, pixelate / 100.0);
        uv = floor(uv * factor) / factor;
    }

    // Apply mosaic effect: Wiederhole das Original-Sprite in einem Gittermuster.
    // Diskrete Stufen: 
    // 0-4: 1x1, 5-14: 2x2, 15-24: 3x3, 25-34: 4x4, 35-44: 5x5, ab 45: jeweils +1 pro 10 Einheiten.
    float tileCount;
    if (mosaic < 5.0) {
        tileCount = 1.0;
    } else {
        tileCount = floor((mosaic - 5.0) / 10.0) + 2.0;
    }
    uv = fract(uv * tileCount);

    vec4 col = texture(TEXTURE, uv);

    // Apply hue shift (color effect)
    col.rgb = hueShift(col.rgb, color_shift);

    // Apply brightness adjustment
    col.rgb += brightness / 100.0;
    col.rgb = clamp(col.rgb, 0.0, 1.0);

    // Apply ghost effect (transparency)
    col.a *= (1.0 - ghost);

    COLOR = col;
}