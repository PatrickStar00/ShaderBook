Shader "PAT/01_Gray"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _GrayEffect("_GrayEffect", Range(0, 1)) = 0.5
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
                
                //RGBֱ����ƽ����
                //col.rgb = (col.r + col.g + col.b)/3;

                //����ɫƵ�׵�Ȩ�غ�ƽ��
                //col.rgb = (col.r * 0.299 + col.g * 0.587 + col.b * 0.114) / 3;

                //��˻�ȡ�Ҷ�
                float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
                float _G = fixed4(gray, gray, gray, col.a);

                //�����ɫ = ���Բ�ֵ������0ʱ���ԭʼ��ɫ��1ʱ����ڰ����ݣ�
                col = lerp(col, _G, _GrayEffect);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
