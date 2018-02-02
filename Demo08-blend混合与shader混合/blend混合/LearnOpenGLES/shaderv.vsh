//#version 300 es

//inputs
attribute vec4 position;
attribute vec2 textCoordinate;

//outputs
varying vec2 vUV;

void main()
{
    vUV = textCoordinate;
    gl_Position = position;
}
