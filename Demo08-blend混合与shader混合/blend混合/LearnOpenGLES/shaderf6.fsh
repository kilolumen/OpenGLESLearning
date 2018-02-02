precision highp float;

uniform sampler2D texture0;

uniform vec2 texSize;

varying vec2 vUV;

void main(void)
{
    vec2 xy = vec2(uUV.x * texSize.x + vUV.y * texSize.y); 
    mat3 filter = mat3(-0.5, -1.0, 0.0,
                       -1.0,  0.0, 1.0,
                       0.0,  1.0, 0.5);
    vec4 Color = filter
}

