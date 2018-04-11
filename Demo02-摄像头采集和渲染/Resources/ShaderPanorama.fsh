precision mediump float;
varying  vec2 texCoordVarying;
uniform sampler2D sam2D;
void main(){
    
    gl_FragColor = texture2D(sam2D,texCoordVarying);
}
