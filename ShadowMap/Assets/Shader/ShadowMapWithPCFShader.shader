Shader "ShadowMap/ShadowMapWithPCFShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Bias("bias", Range(-0.005,0.005)) = 0.001
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
				UNITY_FOG_COORDS(1)
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORDS2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Bias;
			sampler2D _DepthTexture;
			float4x4 _LightSpaceMatrix;
			float _TexturePixelWidth;
			float _TexturePixelHeight;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				float4 lightPos = mul(_LightSpaceMatrix, float4(i.worldPos, 1));
				lightPos.xyz /= lightPos.w;
				float2 uv = lightPos.xy * 0.5 + 0.5;
				float2 depthTexel = float2(1.0 / _TexturePixelWidth, 1.0 / _TexturePixelHeight);
				float shadow = 0.0;
				for (int x=-1; x<=1 ; ++x){
					for (int y=-1; y<=1; ++y){
						float2 temp = uv + float2(x,y) * depthTexel;
						fixed4 depCol = tex2D(_DepthTexture, temp);
						float depth = DecodeFloatRGBA(depCol);
				 		shadow += (lightPos.z + _Bias) < depth  ? 1.0 : 0.0;
					}
				}
				shadow /= 9.0;

				// apply fog

				col = (1.0 - shadow) * col;
				return col;
			}
			ENDCG
		}
	}
}
