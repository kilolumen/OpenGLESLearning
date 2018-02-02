
precision highp float;

uniform sampler2D texture0;
uniform vec2 texSize;
varying vec2 vUV;

void main(void)
{
    
    vec2 xy = vec2(vUV.x * texSize.x, vUV.y * texSize.y);
    
    vec4 finalColor = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec2 xy_0 = vec2(xy.x + (-1.0), xy.y + (-1.0));//(-1.0, -1.0)
    vec2 uv_0 = vec2(xy_0.x / texSize.x, xy_0.y / texSize.y);
    finalColor += texture2D(texture0, uv_0) * -0.5;
    
    vec2 xy_1 = vec2(xy.x + ( 0.0), xy.y + (-1.0));//( 0.0, -1.0)
    vec2 uv_1 = vec2(xy_1.x / texSize.x, xy_1.y / texSize.y);
    finalColor += texture2D(texture0, uv_1) * -1.0;
    
    vec2 xy_2 = vec2(xy.x + ( 1.0), xy.y + (-1.0));//( 1.0, -1.0)
    vec2 uv_2 = vec2(xy_2.x / texSize.x, xy_2.y / texSize.y);
    finalColor += texture2D(texture0, uv_2) * 0.0;
    
    vec2 xy_3 = vec2(xy.x + (-1.0), xy.y + ( 0.0));//(-1.0,  0.0)
    vec2 uv_3 = vec2(xy_3.x / texSize.x, xy_3.y / texSize.y);
    finalColor += texture2D(texture0, uv_3) * -1.0;
    
    vec2 xy_4 = vec2(xy.x + ( 0.0), xy.y + ( 0.0));//( 0.0,  0.0)
    vec2 uv_4 = vec2(xy_4.x / texSize.x, xy_4.y / texSize.y);
    finalColor += texture2D(texture0, uv_4) * 0.0;
    
    vec2 xy_5 = vec2(xy.x + ( 1.0), xy.y + ( 0.0));//( 1.0,  0.0)
    vec2 uv_5 = vec2(xy_5.x / texSize.x, xy_5.y / texSize.y);
    finalColor += texture2D(texture0, uv_5) * 1.0;
    
    vec2 xy_6 = vec2(xy.x + (-1.0), xy.y + ( 1.0));//(-1.0,  1.0)
    vec2 uv_6 = vec2(xy_6.x / texSize.x, xy_6.y / texSize.y);
    finalColor += texture2D(texture0, uv_6) *  0.0;
    
    vec2 xy_7 = vec2(xy.x + ( 0.0), xy.y + ( 1.0));//( 0.0,  1.0)
    vec2 uv_7 = vec2(xy_7.x / texSize.x, xy_7.y / texSize.y);
    finalColor += texture2D(texture0, uv_7) * 1.0;
    
    vec2 xy_8 = vec2(xy.x + ( 1.0), xy.y + ( 1.0));//( 1.0,  1.0)
    vec2 uv_8 = vec2(xy_8.x / texSize.x, xy_8.y / texSize.y);
    finalColor += texture2D(texture0, uv_8) * 0.5;
    
    float Gray = 0.3 * finalColor.x + 0.59 * finalColor.y + 0.11 * finalColor.z;

    if (Gray < 0.0) {

        Gray = -1.0 * Gray;
    }

    Gray = 1.0 - Gray;

    gl_FragColor = vec4(Gray, Gray, Gray, 1.0);
}
