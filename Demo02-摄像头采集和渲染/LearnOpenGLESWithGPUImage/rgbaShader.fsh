varying highp vec2 texCoordVarying;
precision mediump float;
uniform sampler2D videoFrame;
void main()
{
    gl_FragColor = texture2D(videoFrame, texCoordVarying);
}
