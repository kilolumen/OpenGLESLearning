precision highp float;

varying vec3 fragPosition;
varying vec3 fragNormal;
varying vec2 fragUV;

uniform float elapsedTime;
uniform vec3 lightDirection;
uniform mat4 normalMatrix;
uniform sampler2D grassMap;
uniform sampler2D dirtMap;

void main(void)
{
    vec3 normalizedLightDirection = normalize(-lightDirection);
    vec3 transformedNormal = normalize((normalMatrix * vec4(fragNormal, 1.0)).xyz);
    
    float diffuseStrength = dot(normalizedLightDirection, transformedNormal);
    diffuseStrength = clamp(diffuseStrength, 0.0, 1.0);
    vec3 diffuse = vec3(diffuseStrength);
    
    vec3 ambient = vec3(0.3);
    
    vec4 finialightStrength = vec4(ambient + diffuse, 1.0);
    
    vec4 grassColor = texture2D(grassMap, fragUV);
    vec4 dirtColor = texture2D(dirtMap, fragUV);
    
    vec4 materialColor = vec4(0.0);
    
    if (fragPosition.y <= 15.0) {
        materialColor = dirtColor;
    }else if(fragPosition.y > 15.0 && fragPosition.y < 30.0){
        float dirtFactor = (30.0 - fragPosition.y) / 15.0;
        materialColor = dirtColor * dirtFactor + grassColor * (1.0 - dirtFactor);
    }else{
        materialColor = grassColor;
    }
    gl_FragColor = vec4(materialColor.rgb * finialightStrength.rgb, 1.0);
}
