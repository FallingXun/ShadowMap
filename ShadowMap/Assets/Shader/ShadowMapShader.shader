Shader "ShadowMap/ShadowMapShader"
{
	Properties
	{
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
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _DepthTexture;
			float4x4 _LightSpaceMatrix;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float4 lightPos = mul(_LightSpaceMatrix, float4(i.worldPos,1));
				lightPos.xyz /= lightPos.w;
				float3 pos = lightPos * 0.5 + 0.5;
				fixed4 depthCol = tex2D(_DepthTexture, pos.xy);
				float depth = DecodeFloatRGBA(depthCol);
				float shadow = 0.0;
				float currentDepth = lightPos.z;
				shadow = currentDepth < depth ? 1.0 : 0.0;
				col = (1 - shadow) * col;
				// apply fog
				return col;
			}
			ENDCG
		}
	}
}
