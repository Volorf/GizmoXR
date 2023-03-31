Shader "Unlit/Boxel"
{
    Properties
    {
        _ShowWires("Show Wires", Int) = 1
        _WireMaskTex ("Wire Mask Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BorderColorKoef("Border Color Koef", Float) = 0.2
        _ShadowKoef("Shadow Koef", Float) = 0.3
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque"
            "LightMode" = "ForwardBase"
	        "PassFlags" = "OnlyDirectional"
        }
        
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            int _ShowWires;
            sampler2D _WireMaskTex;
            float4 _WireMaskTex_ST;
            float4 _Color;
            float _ShadowKoef;
            float _BorderColorKoef;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                if (_ShowWires)
                {
                    o.uv = TRANSFORM_TEX(v.uv, _WireMaskTex);
                }
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col;
                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0, normal);
                float intensity = NdotL > _ShadowKoef ? NdotL : _ShadowKoef;
                
                col = _Color * intensity;
                
                
                if (_ShowWires)
                {
                    float koef = tex2D(_WireMaskTex, i.uv).a;
                    float4 borderColor = col * _BorderColorKoef;
                    col = lerp(borderColor, col, koef);
                }
                
                col.a = 1;
                return col;
            }
            
            ENDCG
        }
    }
}
