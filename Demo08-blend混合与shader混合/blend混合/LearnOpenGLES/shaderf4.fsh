precision highp float;

uniform sampler2D OpenGL;
uniform sampler2D noiseTexture;

uniform float uQuantLevel;   // 2-6
uniform float uWaterPower;   // 8-64

uniform vec2 texSize;

varying vec2 vUV;

vec4 quant(vec4 cl, float n)
{
    cl.x = floor(cl.x * 255./n)*n/255.;
    cl.y = floor(cl.y * 255./n)*n/255.;
    cl.z = floor(cl.z * 255./n)*n/255.;
    
    return cl;
}


void main(void)
{
    vec4 noiseColor = 40.0 * texture2D(noiseTexture, vUV);
    vec2 newUV = vec2(vUV.x + noiseColor.x / texSize.x, vUV.y + noiseColor.y / texSize.y);
    vec4 fColor = texture2D(OpenGL, newUV);
    
    vec4 color = quant(fColor, 255./pow(2., 4.0));
    //vec4 color = vec4(1., 1., .5, 1.);
    gl_FragColor = color;
}
