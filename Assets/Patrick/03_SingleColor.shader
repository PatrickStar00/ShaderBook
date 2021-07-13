Shader "PAT/01_SingleColor"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            float4 _Color;
            fixed _GrayEffect;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                //点乘获取灰度
                float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));

                //颜色用“乘法”来影响灰度颜色的白色
                fixed3 ColorLow  = gray * _Color.rgb;

                //颜色用“加法”来影响灰度颜色的黑色
                fixed3 ColorHigh = gray + _Color.rgb;

                //使用灰度图像控制显示亮度或暗色
                col.rgb = lerp(ColorLow, ColorHigh, gray)

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
