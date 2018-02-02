//attribute vec4 position;
//attribute vec2 textCoordinate;
//
//uniform mat4 rotateMatrix;
//
//varying lowp vec2 varyTextCoord;
//
//void main()
//{
//    varyTextCoord = textCoordinate;
//
//    gl_Position = rotateMatrix * position;
//}
#version 300 es
layout (location = 0) in vec4 position;
layout (location = 1) in vec2 textCoordinate;

uniform mat4 rotateMatrix;

out vec2 varyTextCoord;

void main()
{
    varyTextCoord = textCoordinate;

    gl_Position = rotateMatrix * position;
}

