precision highp float;
lowp
uniform sampler2D Texture0;

uniform vec2 texSize;
uniform vec2 mosaicSize;

varying vec2 vUV;

void main(void)
{
//    vec2 xy = vec2(vUV.x * texSize.x, vUV.y * texSize.y);// 取值范围换算到图像尺寸大小
//    // 计算某一个小mosaic的中心坐标
//    vec2 xyMosaic = vec2(floor(xy.x / mosaicSize.x) * mosaicSize.x,
//                         floor(xy.y / mosaicSize.y) * mosaicSize.y )
//    + .5*mosaicSize;
//    // 计算距离中心的长度
//    vec2 delXY = xyMosaic - xy;
//    float delL = length(delXY);
//    // 换算回纹理坐标系
//    vec2 uvMosaic = vec2(xyMosaic.x / texSize.x, xyMosaic.y / texSize.y);
//
//    vec4 finalColor;
//    if(delL<0.5*mosaicSize.x)
//    {
//        finalColor = texture2D(Texture0, uvMosaic);
//    }
//    else
//    {
//        //finalColor = texture2D(Texture0, vUV);
//        finalColor = vec4(0., 0., 0., 1.);
//    }
//
//    gl_FragColor = finalColor;
    
    vec4 color;
    //float ratio = texSize.y/texSize.x;
    
    vec2 xy = vec2(vUV.x * texSize.x /** ratio */, vUV.y * texSize.y);
    
    vec2 xyMosaic = vec2(floor(xy.x / mosaicSize.x) * mosaicSize.x,
                         floor(xy.y / mosaicSize.y) * mosaicSize.y );
    
    //第几块mosaic
    vec2 xyFloor = vec2(floor(mod(xy.x, mosaicSize.x)),
                        floor(mod(xy.y, mosaicSize.y)));
#if 0
    if((xyFloor.x == 0 || xyFloor.y == 0))
    {
        color = vec4(1., 1., 1., 1.);
    }
    else
#endif
    {
        vec2 uvMosaic = vec2(xyMosaic.x / texSize.x, xyMosaic.y / texSize.y);
        color = texture2D( Texture0, uvMosaic );
    }
    
    gl_FragColor = color;
}
