attribute vec4 position;
attribute vec3 normal;
attribute vec2 uv;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;

varying vec3 fragPosition;
varying vec2 fragUV;

void main(void) {
    mat4 mvp = projectionMatrix * modelMatrix;
    fragUV = uv;
    fragPosition = position.xyz;
    gl_Position = mvp * position;
}
