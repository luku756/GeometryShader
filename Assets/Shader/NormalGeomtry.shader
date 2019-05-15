Shader "Unlit/NormalGeomtry"
{
	Properties
	{
		_Color("Color", Color) = (1,1,0,0)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2g {
				float4 objPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct g2f {
				float4 worldPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};

			fixed4 _Color;

			v2g vert(appdata v)
			{
				v2g o;
				o.objPos = v.vertex;
				o.normal = v.normal;
				return o;
			}

			//normal vector 를 그려서 보여준다.
			[maxvertexcount(6)]
			void geom(triangle v2g input[3], inout LineStream<g2f> linestream) {
				//들어오는 mesh 데이터가 삼각형이므로 triangle, input[3]를 받는다.
				//세 점에서 선분 하나씩, 총 6개의 정점을 사용하므로 maxvertexcount(6) 이다.
				g2f o;
				for (int i = 0; i < 3; i++) {
					o.worldPos = UnityObjectToClipPos(input[i].objPos);
					o.uv = input[i].uv;
					o.col = _Color;
					linestream.Append(o);

					o.worldPos = UnityObjectToClipPos(input[i].objPos + input[i].normal);
					o.uv = input[i].uv;
					o.col = _Color;
					linestream.Append(o);

					//두 개의 선분이 모였으므로 그린다. 이것을 생략하면 6개의 점이 전부 1-2,2-3,3-4 등으로 이어진다.
					linestream.RestartStrip();
				}

			}

			fixed4 frag(g2f i) : SV_Target
			{
				fixed4 col = i.col;
				return col;
			}
			ENDCG
		}
	}
}
