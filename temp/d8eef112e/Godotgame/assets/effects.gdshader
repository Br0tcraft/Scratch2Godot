shader_type canvas_item;

// --- Unrestricted User Controls ---
uniform float color_shift;       // Hue shift in degrees (unclamped, internally modulo 360)
uniform float fisheye;           // Fisheye distortion (clamped 0.0–1.0)
uniform float whirl;             // Whirl effect (any value)
uniform float pixelate;          // Pixelation amount (min 0.0)
uniform float mosaic;            // Mosaic tile size (min 0.0)
uniform float brightness;        // Brightness adjustment (-∞ to ∞)
uniform float ghost;             // Transparency fade (0.0–1.0 internally)
uniform float sprite_size = 10.0; // Base pixelation size (default 10)
uniform float saturation;        // Saturation adjustment (-100 to +100)
uniform float opaque;           // Final opaque adjustment (0 to 100)
uniform float red;        // Red channel adjustment (-100 to +100)
uniform float green;      // Green channel adjustment (-100 to +100)
uniform float blue;       // Blue channel adjustment (-100 to +100)
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // RGBA tint color

// --- Function: Hue Shift (using YIQ color space) ---
vec3 hueShift(vec3 col, float shift_deg) {
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
    float angle = radians(mod(shift_deg, 360.0));
    float cosA = cos(angle);
    float sinA = sin(angle);
    mat3 rot = mat3(
        vec3(1.0, 0.0, 0.0),
        vec3(0.0, cosA, -sinA),
        vec3(0.0, sinA,  cosA)
    );
    yiq = rot * yiq;
    return clamp(yiq2rgb * yiq, 0.0, 1.0);
}

// --- Function: Fisheye Effect ---
vec2 applyFisheye(vec2 uv, float intensity) {
    intensity = clamp(intensity, 0.0, 1.0);
    vec2 normCoord = (uv - 0.5) / 0.5;
    float r = length(normCoord);
    float factor = 1.0 - intensity * (1.0 - r);
    normCoord *= factor;
    return 0.5 + normCoord * 0.5;
}

// --- Function: Whirl Effect ---
vec2 applyWhirl(vec2 uv, float intensity) {
    vec2 centered = uv - 0.5;
    float angle = length(centered) * intensity;
    float s = sin(angle);
    float c = cos(angle);
    mat2 rotation = mat2(vec2(c, -s), vec2(s, c));
    return 0.5 + rotation * centered;
}

// --- Function: Adjust Saturation ---
vec3 adjustSaturation(vec3 col, float sat) {
    float gray = dot(col, vec3(0.299, 0.587, 0.114));
    float factor = 1.0 + (sat / 100.0);
    return mix(vec3(gray), col, clamp(factor, 0.0, 2.0));
}

// --- Function: Adjust Individual RGB Channels ---
vec3 adjustRGB(vec3 col, float r, float g, float b) {
    col.r += r / 100.0;
    col.g += g / 100.0;
    col.b += b / 100.0;
    return clamp(col, 0.0, 1.0);
}

// --- Main Shader Fragment ---
void fragment() {
    vec2 uv = UV;

    // Apply Fisheye
    if (abs(fisheye) > 0.001) {
        uv = applyFisheye(uv, fisheye);
    }

    // Apply Whirl
    if (abs(whirl) > 0.001) {
        uv = applyWhirl(uv, whirl / 50.0);
    }

    // Apply Pixelation
    if (pixelate > 0.0) {
        float pxSize = max(sprite_size, 1.0);
        vec2 texSize = vec2(1.0) / TEXTURE_PIXEL_SIZE;
        float pxFactor = texSize.x / pxSize;
        uv = floor(uv * pxFactor) / pxFactor;
    }

    // Apply Mosaic
    if (mosaic > 0.0) {
        float tileCount = 1.0;
        if (mosaic >= 5.0) {
            tileCount = floor((mosaic - 5.0) / 10.0) + 2.0;
        }
        uv = fract(uv * tileCount);
    }

    // Sample texture color
    vec4 col = texture(TEXTURE, uv);

    // Apply hue shift
    col.rgb = hueShift(col.rgb, color_shift);

    // Apply saturation
    col.rgb = adjustSaturation(col.rgb, saturation);

    // Adjust individual RGB channels
    col.rgb = adjustRGB(col.rgb, red, green, blue);

    // Adjust brightness
    col.rgb += brightness / 100.0;
    col.rgb = clamp(col.rgb, 0.0, 1.0);

    // Ghost (fade alpha)
    col.a *= (1.0 - clamp(ghost / 100.0, 0.0, 1.0));

    // Final opaque
    float alpha_effect = clamp(opaque / 100.0, 0.0, 1.0);
    if (col.a > 0.0) {
    col.a = mix(col.a, 1.0, alpha_effect);
    }
    col.rgb *= tint_color.rgb;
    COLOR = vec4(col.rgb, col.a);

}

