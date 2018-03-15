precision highp float;

// 点光源
struct PointLight {
    vec3 position;
    vec3 color;
    float indensity;
    float ambientIndensity;
};

// 平行光
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
    float smoothness; // 0 ~ 1000 越高显得越光滑
};

varying vec3 fragNormal;
varying vec2 fragUV;
varying vec3 fragPosition;
varying vec3 fragTangent;
varying vec3 fragBitangent;

uniform float elapsedTime;
uniform PointLight pointLight;
uniform DirectionLight direcionLight;
uniform Material material;
uniform vec3 eyePosition;
uniform mat4 normalMatrix;
uniform mat4 modelMatrix;

uniform sampler2D diffuseMap;
uniform sampler2D normalMap;
uniform bool useNormalMap;

// projectors
uniform mat4 projectorMatrix;
uniform sampler2D projectorMap;
uniform bool useProjector;

void main(void) {
    vec4 worldVertexPosition = modelMatrix * vec4(fragPosition, 1.0);
    
    vec3 normalizedLightDirection = normalize(-direcionLight.direction);
    vec3 transformedNormal = normalize((normalMatrix * vec4(fragNormal, 1.0)).xyz);
    vec3 transformedTangent = normalize((normalMatrix * vec4(fragTangent, 1.0)).xyz);
    vec3 transformedBitangent = normalize((normalMatrix * vec4(fragBitangent, 1.0)).xyz);
    mat3 TBN = mat3(
                    transformedTangent,
                    transformedBitangent,
                    transformedNormal
                    );
    if (useNormalMap) {
        vec3 normalFromMap = (texture2D(normalMap, fragUV).rgb * 2.0 - 1.0);
        transformedNormal = TBN * normalFromMap;
    }
    // 计算漫反射
    float diffuseStrength = dot(normalizedLightDirection, transformedNormal);
    diffuseStrength = clamp(diffuseStrength, 0.0, 1.0);
    vec3 diffuse = diffuseStrength * direcionLight.color * texture2D(diffuseMap, fragUV).rgb * direcionLight.indensity;
    
    // 计算环境光
    vec3 ambient = vec3(direcionLight.ambientIndensity) * material.ambientColor;
    
    // 计算高光
    vec3 eyeVector = normalize(eyePosition - worldVertexPosition.xyz);
    vec3 halfVector = normalize(normalizedLightDirection + eyeVector);
    float specularStrength = dot(halfVector, transformedNormal);
    specularStrength = pow(specularStrength, material.smoothness);
    vec3 specular = specularStrength * material.specularColor * direcionLight.color * direcionLight.indensity;
    
    // 最终颜色计算
    vec3 finalColor = diffuse + ambient + specular;
    
    if (useProjector) {
        // 计算投影器产生的颜色
        vec4 projectorColor = vec4(0.0);
        vec4 positionInProjectorSpace = projectorMatrix * modelMatrix * vec4(fragPosition, 1.0);
        positionInProjectorSpace /= positionInProjectorSpace.w;
        vec2 projectorUV = (positionInProjectorSpace.xy + 1.0) * 0.5;
        
        if (projectorUV.x >= 0.0 && projectorUV.x <= 1.0 && projectorUV.y >= 0.0 && projectorUV.y <= 1.0) {
            projectorColor = texture2D(projectorMap, projectorUV);
            gl_FragColor = vec4(finalColor * 0.4 + projectorColor.rgb * 0.6, 1.0);
        }else{
            gl_FragColor = vec4(finalColor, 1.0);
        }
    }else{
        gl_FragColor = vec4(finalColor, 1.0);
    }
}
