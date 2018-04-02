#extension GL_APPLE_clip_distance : require

attribute vec4 position;//模型顶点
attribute vec3 normal;//法线
attribute vec2 uv;//纹理坐标
attribute vec3 tangent;//
attribute vec3 bitangent;//用来确定发现空间

uniform float elapsedTime;//更新
uniform mat4 projectionMatrix;//投影矩阵
uniform mat4 cameraMatrix;//观察矩阵
uniform mat4 modelMatrix;//模型矩阵

varying vec3 fragPosition;
varying vec3 fragNormal;
varying vec2 fragUV;
varying vec3 fragTangent;
varying vec3 fragBitangent;

uniform bool clipplaneEnabled;
uniform vec4 clipplane;
varying highp float gl_ClipDistance[1];

void main(void){
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    fragNormal = normal;
    fragUV = uv;
    fragPosition = position.xyz;
    fragTangent = tangent;
    fragBitangent = bitangent;
    if (clipplaneEnabled) {
        gl_ClipDistance[0] = dot((modelMatrix * position).xyz, clipplane.xyz) + clipplane.w;
    }
    gl_Position = mvp * position;
}

