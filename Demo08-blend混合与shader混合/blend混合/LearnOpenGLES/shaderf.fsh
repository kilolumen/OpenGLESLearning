precision highp float;
//
////inputs
//in vec2 varyTextCoord;
//
////uniforms
//uniform sampler2D myTexture0;
//
////output
//out vec4 FragColor;
//
//void main()
//{
//    FragColor = texture(myTexture0, 1.0 - varyTextCoord);
//}

uniform float in_circle_radius;             //从客户端传入的放大镜圆半径
uniform float in_zoom_times;                 //从客户端传入的放大镜放大倍数

uniform float imageWidth;                  //从客户端传入的图片宽数据
uniform float imageHeight;                 //从客户端传入的图片高数据

uniform sampler2D Texture0;

varying vec2 vUV;
//varying vec2 vUV;

vec2 in_circle_pos = vec2(320, 320);    //从客户端传入的放大镜圆心位置

// 转换为纹理范围
vec2 transForTexPosition(vec2 pos)
{
    return vec2(float(pos.x/imageWidth), float(pos.y/imageHeight));
}

// Distance of Points
float getDistance(vec2 pos_src, vec2 pos_dist)
{
    float quadratic_sum = pow((pos_src.x - pos_dist.x), 2.) + pow((pos_src.y - pos_dist.y), 2.);
    return sqrt(quadratic_sum);
}

vec2 getZoomPosition()
{   // zoom_times>1. 是放大， 0.< zoom_times <1.是缩小
    float zoom_x = float(gl_FragCoord.x-in_circle_pos.x) / in_zoom_times;
    float zoom_y = float(gl_FragCoord.y-in_circle_pos.y) / in_zoom_times;
    
    return vec2(float(in_circle_pos.x + zoom_x), float(-in_circle_pos.y + zoom_y));
}

vec4 getColor()
{
    // ❤
    vec2 pos = getZoomPosition();
    
    float _x = floor(pos.x);
    float _y = floor(pos.y);
    
    float u = pos.x - _x;
    float v = pos.y - _y;
    //双线性插值采样
    vec4 data_00 = texture2D(Texture0, transForTexPosition(vec2(_x, _y)));
    
    vec4 data_01 = texture2D(Texture0, transForTexPosition(vec2(_x, _y + 1.)));
    
    vec4 data_10 = texture2D(Texture0, transForTexPosition(vec2(_x + 1., _y)));
    
    vec4 data_11 = texture2D(Texture0, transForTexPosition(vec2(_x + 1., _y + 1.)));
    
    return (1. - u) * (1. - v) * data_00 + (1. - u) * v * data_01 + u * (1. - v) * data_10 + u * v * data_11;
    
}

void main(void)
{
    vec2 frag_pos = vec2(gl_FragCoord.x, gl_FragCoord.y);
    //若当前片段位置距放大镜圆心距离大于圆半径时，直接从纹理中采样输出片段颜色
    
    if (getDistance(in_circle_pos, frag_pos) > in_circle_radius)
        gl_FragColor = texture2D(Texture0, vUV);
    else
        //距离小于半径的片段，二次线性插值获得顔色。
        gl_FragColor = getColor();
}
