precision highp float;

uniform sampler2D texture0;
uniform sampler2D texDownSample;

uniform vec2 texSize;

varying vec2 vUV;

vec4 xPosure(vec4 color, float gray, float ex)
{
    //重新调整场景的亮度
    float b = (4.0 * ex - 1.0);
    float a = 1.0 - b;
    float f = gray * (a * gray + b);
    return f * color;
}


void main(void)
{
    vec4 dsColor = texture2D(texDownSample, vUV);
    float lum = 0.3 * dsColor.x + 0.59 * dsColor.y + 0.11 * dsColor.z;
    vec4 fColor = texture2D(texture0, vUV);
    gl_FragColor = xPosure(fColor, lum, 1.1);
}
