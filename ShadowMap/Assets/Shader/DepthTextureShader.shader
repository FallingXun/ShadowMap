Shader "ShadowMap/DepthTextureShader"
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
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float2 depth : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.depth = o.pos.zw;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float depth = i.depth.x / i.depth.y;
				fixed4 col = EncodeFloatRGBA(depth);

				return col;
			}
			ENDCG
		}
	}
}
