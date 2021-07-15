Shader "PAT/04_RampColor"
{
    Properties
    {
        _ColorH("ColorH", Color) = (1, 1, 0, 1) //亮部颜色
        _ColorL("ColorL", Color) = (0, 1, 0, 1) //暗部颜色
        _ColorM("ColorM", Color) = (0, 0.1, 0.1, 1) //灰部颜色
        
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

            float4 _ColorH;
            float4 _ColorL;
            float4 _ColorM;
            
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

                //黑到灰着色
                fixed3 ColorLow  = lerp(_ColorL, _ColorM, saturate(gray * 2));

                //灰到白着色
                fixed3 ColorHigh = lerp(_ColorM, _ColorH, saturate(gray - 0.5));

                //使用灰度图像控制显示亮度或暗色
                col.rgb = lerp(ColorLow, ColorHigh, gray);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
