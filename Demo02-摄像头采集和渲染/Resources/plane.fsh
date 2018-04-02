precision highp float;

varying vec2 fragUV;

uniform sampler2D diffuseMap;

void main(void){

    vec4 materialColor = texture2D(diffuseMap, fragUV);
    gl_FragColor = vec4(materialColor.rgb, 1.0);
}


