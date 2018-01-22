precision highp float;

struct DirectionLight {
    vec3 direction;
    vec3 color;
    float indensity;
    float ambientIndensity;
};

struct Material {
    vec3 diffuseColor;
    vec3 ambientColor;
    vec3 specularColor;
    float smothness;
};

varying vec3 fragNormal;
varying vec3 fragUV;
varying vec3 fragPosition;
varying vec3 fragTangent;
varying vec3 fragBitangent;

uniform float elapsedTime;
uniform DirectionLight light;
uniform Matrial material;
uniform vec3 eyePosition;
uniform mat4 normalMatrix;
uniform mat4 modelMatrix;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform bool useNormalMap;

//projectors
uniform mat4 projectorMatrix;
uniform sampler2D projectorMap;
uniform bool useProjector;

void main(void)
{
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);//坐标转换到世界坐标系
    vec3 normalizedLightDirection = normalize(-light.direction);//光线逆向并归一化
    vec3 transformedNormal = normalize((normalMatrix * vec4(fragNormal, 1.0)).xyz);
    vec3 transforedTangent = normalize((normalMatrix * vec4(fragTangent, 1.0)).xyz);
    vec3 transforedBitangent = normalize((normalMatrix * vec4(fragBitangent, 1.0)).xyz);
    mat3 TBN = mat3(
                    transformedTangent,
                    transformedBitangent,
                    transformedNormal);
    if (useNormalMap) {
        vec3 normalFromMap = (texture2D(normalMap, fragUV).rbg * 2 - 1.0);
        transormedNormal = TBN * normalFromMap;
    }
    
    //计算漫反射
    float diffuseStrength = dot(normalizedLightDirection, transformedNormal);
    diffuseStrength = clamp(diffuseStrength, 0.0, 1.0);
    vec3 diffuse = diffuseStrength * light.color * texture2D(diffuseMap, fragUV).rgb * light.indensity;
}
