Shader "Unlit/GeometryTest"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
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

			sampler2D _MainTex;
			float4 _MainTex_ST;

			
			v2g vert(appdata v)
			{
				v2g o;

				o.objPos = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			//기존의 삼각형과, 삼각형의 normal 방향(세 vertex의 normal의 평균) 으로 띄운 삼각형을 하나 더 그린다.
			//이 geom 함수 안에서 최대 6개의 꼭지점을 사용할 수 있다.
			[maxvertexcount(6)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream) {
				//삼각형이므로 3개의 vertex input을 받는다. 또한 tristream에 넣은 것이 inout이므로 fragment shader로 전달된다.
				//스트림에 1,2,3,4,5 가 들어온다면 1-2-3, 2-3-4, 3-4-5 세 개의 삼각형을 그리게 된다.

				g2f o;
				//기존의 삼각형
				for (int i = 0; i < 3; i++) {
					o.worldPos = UnityObjectToClipPos(input[i].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(1,1,1,0);
					tristream.Append(o);//스트림에 추가.
				}
				tristream.RestartStrip();//모인 삼각형으로 그리기. 이전에 들어있던 점은 이 이후에 들어오는 점과 이어지지 않는다.

				//삼각형의 평균 노말 계산
				float3 normal_center = input[0].normal + input[1].normal + input[2].normal;
				normal_center = normalize(normal_center);

				//normal 만큼 띄우기
				o.worldPos = UnityObjectToClipPos(input[0].objPos+ normal_center);
				o.uv = input[0].uv;
				o.col = fixed4(1, 1, 1, 1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[1].objPos + normal_center);
				o.uv = input[1].uv;
				o.col = fixed4(0, 0, 1, 1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[2].objPos + normal_center);
				o.uv = input[2].uv;
				o.col = fixed4(1, 0, 0, 1);
				tristream.Append(o);

				tristream.RestartStrip();//띄운 삼각형 그리기
							   
			}

			fixed4 frag(g2f i) : SV_Target
			{
				//fixed4 col = i.col;
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
