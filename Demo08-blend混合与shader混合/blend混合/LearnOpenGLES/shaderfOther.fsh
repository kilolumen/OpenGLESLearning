#version 300 es

precision highp float;

in vec2 varyTextCoord;
in vec2 varyOtherPostion;

uniform sampler2D myTexture1;

//output
out vec4 FragColor;

void main()
{
    vec4 text = texture(myTexture1, 1.0 - varyTextCoord);
    text.a = 0.8;
    FragColor = text;
}
