Shader "Shader Graphs/CardEffectShader"
    {
        Properties
        {
            _ColorDensity("ColorDensity", Float) = 2.61
            _PatternTiling("PatternTiling", Vector) = (1, 1, 0, 0)
            [NoScaleOffset]_Pattern1("Pattern1", 2D) = "white" {}
            [NoScaleOffset]_Pattern2("Pattern2", 2D) = "white" {}
            [NoScaleOffset]_Pattern3("Pattern3", 2D) = "white" {}
            _Bright("Bright", Float) = 1
            [NoScaleOffset]_CardSprite("CardSprite", 2D) = "white" {}
            [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
            [HideInInspector]_QueueControl("_QueueControl", Float) = -1
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Lit"
                "Queue"="Geometry"
                "DisableBatching"="False"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalLitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
            
            // Render State
            Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _LIGHT_LAYERS
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                #pragma multi_compile_fragment _ _LIGHT_COOKIES
                #pragma multi_compile _ _FORWARD_PLUS
                #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
                #define _FOG_FRAGMENT 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                     float4 probeOcclusion;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpaceViewDirection;
                     float3 TangentSpaceViewDirection;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                     float4 probeOcclusion : INTERP3;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP4;
                    #endif
                     float4 tangentWS : INTERP5;
                     float4 texCoord0 : INTERP6;
                     float4 fogFactorAndVertexLight : INTERP7;
                     float3 positionWS : INTERP8;
                     float3 normalWS : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
                {
                    // RGB to HSV
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                    float D = Q.x - min(Q.w, Q.y);
                    float E = 1e-10;
                    float V = (D == 0) ? Q.x : (Q.x + E);
                    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
                
                    float hue = hsv.x + Offset;
                    hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                                ? hue - 1
                                : hue;
                
                    // HSV to RGB
                    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CardSprite);
                    float4 _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.tex, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.samplerstate, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_R_4_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.r;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_G_5_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.g;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_B_6_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.b;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_A_7_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.a;
                    UnityTexture2D _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern1);
                    float2 _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2);
                    float4 _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.tex, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.samplerstate, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2) );
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_R_4_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_G_5_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_B_6_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_A_7_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.a;
                    float _Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float = _Bright;
                    float4 _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4, (_Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float.xxxx), _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4);
                    float4 Color_bf1edd044bc24900a4e714847bcdb76e = IsGammaSpace() ? float4(0.9728174, 1, 0, 0) : float4(SRGBToLinear(float3(0.9728174, 1, 0)), 0);
                    float _Property_8f21833e9693437786f4a8108be35321_Out_0_Float = _ColorDensity;
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_A_4_Float = 0;
                    float _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float;
                    Unity_Multiply_float_float(_Property_8f21833e9693437786f4a8108be35321_Out_0_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float, _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float);
                    float _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float, _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float);
                    float3 _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_bf1edd044bc24900a4e714847bcdb76e.xyz), _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float, _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3);
                    float3 _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4.xyz), _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3, _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3);
                    UnityTexture2D _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern2);
                    float2 _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2);
                    float4 _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.tex, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.samplerstate, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2) );
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_R_4_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.r;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_G_5_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.g;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_B_6_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.b;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_A_7_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.a;
                    float _Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float = _Bright;
                    float4 _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4, (_Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float.xxxx), _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4);
                    float4 Color_35cfe5ff0a30447cb34b135a8a58e154 = IsGammaSpace() ? float4(0.9860039, 0, 1, 0) : float4(SRGBToLinear(float3(0.9860039, 0, 1)), 0);
                    float _Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float = _ColorDensity;
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_A_4_Float = 0;
                    float _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float;
                    Unity_Multiply_float_float(_Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float, _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float);
                    float _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float, _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float);
                    float3 _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_35cfe5ff0a30447cb34b135a8a58e154.xyz), _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float, _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3);
                    float3 _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4.xyz), _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3);
                    float3 _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3;
                    Unity_Add_float3(_Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3, _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3);
                    float3 _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    Unity_Add_float3((_SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.xyz), _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3, _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3);
                    surface.BaseColor = _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = float(1);
                    surface.Smoothness = float(0.65);
                    surface.Occlusion = float(1);
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                    // use bitangent on the fly like in hdrp
                    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
                    float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                    output.WorldSpaceBiTangent = renormFactor * bitang;
                
                    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                    float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
                    output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }
            
            // Render State
            Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
                #pragma exclude_renderers gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                     float4 probeOcclusion;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 TangentSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpaceViewDirection;
                     float3 TangentSpaceViewDirection;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                     float4 probeOcclusion : INTERP3;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP4;
                    #endif
                     float4 tangentWS : INTERP5;
                     float4 texCoord0 : INTERP6;
                     float4 fogFactorAndVertexLight : INTERP7;
                     float3 positionWS : INTERP8;
                     float3 normalWS : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(USE_APV_PROBE_OCCLUSION)
                    output.probeOcclusion = input.probeOcclusion;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
                {
                    // RGB to HSV
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                    float D = Q.x - min(Q.w, Q.y);
                    float E = 1e-10;
                    float V = (D == 0) ? Q.x : (Q.x + E);
                    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
                
                    float hue = hsv.x + Offset;
                    hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                                ? hue - 1
                                : hue;
                
                    // HSV to RGB
                    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CardSprite);
                    float4 _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.tex, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.samplerstate, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_R_4_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.r;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_G_5_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.g;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_B_6_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.b;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_A_7_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.a;
                    UnityTexture2D _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern1);
                    float2 _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2);
                    float4 _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.tex, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.samplerstate, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2) );
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_R_4_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_G_5_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_B_6_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_A_7_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.a;
                    float _Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float = _Bright;
                    float4 _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4, (_Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float.xxxx), _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4);
                    float4 Color_bf1edd044bc24900a4e714847bcdb76e = IsGammaSpace() ? float4(0.9728174, 1, 0, 0) : float4(SRGBToLinear(float3(0.9728174, 1, 0)), 0);
                    float _Property_8f21833e9693437786f4a8108be35321_Out_0_Float = _ColorDensity;
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_A_4_Float = 0;
                    float _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float;
                    Unity_Multiply_float_float(_Property_8f21833e9693437786f4a8108be35321_Out_0_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float, _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float);
                    float _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float, _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float);
                    float3 _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_bf1edd044bc24900a4e714847bcdb76e.xyz), _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float, _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3);
                    float3 _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4.xyz), _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3, _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3);
                    UnityTexture2D _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern2);
                    float2 _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2);
                    float4 _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.tex, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.samplerstate, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2) );
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_R_4_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.r;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_G_5_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.g;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_B_6_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.b;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_A_7_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.a;
                    float _Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float = _Bright;
                    float4 _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4, (_Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float.xxxx), _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4);
                    float4 Color_35cfe5ff0a30447cb34b135a8a58e154 = IsGammaSpace() ? float4(0.9860039, 0, 1, 0) : float4(SRGBToLinear(float3(0.9860039, 0, 1)), 0);
                    float _Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float = _ColorDensity;
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_A_4_Float = 0;
                    float _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float;
                    Unity_Multiply_float_float(_Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float, _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float);
                    float _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float, _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float);
                    float3 _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_35cfe5ff0a30447cb34b135a8a58e154.xyz), _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float, _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3);
                    float3 _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4.xyz), _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3);
                    float3 _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3;
                    Unity_Add_float3(_Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3, _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3);
                    float3 _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    Unity_Add_float3((_SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.xyz), _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3, _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3);
                    surface.BaseColor = _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = float(1);
                    surface.Smoothness = float(0.65);
                    surface.Occlusion = float(1);
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                    // use bitangent on the fly like in hdrp
                    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
                    float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                    output.WorldSpaceBiTangent = renormFactor * bitang;
                
                    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                    float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
                    output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS : INTERP0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "MotionVectors"
                Tags
                {
                    "LightMode" = "MotionVectors"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask RG
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 3.5
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_MOTION_VECTORS
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask R
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormals"
                }
            
            // Render State
            Cull Back
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALS
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                     float4 tangentWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 TangentSpaceNormal;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 tangentWS : INTERP0;
                     float3 normalWS : INTERP1;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.tangentWS.xyzw = input.tangentWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.tangentWS = input.tangentWS.xyzw;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 NormalTS;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    surface.NormalTS = IN.TangentSpaceNormal;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "Meta"
                Tags
                {
                    "LightMode" = "Meta"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            #pragma shader_feature _ EDITOR_VISUALIZATION
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define ATTRIBUTES_NEED_INSTANCEID
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
                #define _FOG_FRAGMENT 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                     float4 texCoord1;
                     float4 texCoord2;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpaceViewDirection;
                     float3 TangentSpaceViewDirection;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 tangentWS : INTERP0;
                     float4 texCoord0 : INTERP1;
                     float4 texCoord1 : INTERP2;
                     float4 texCoord2 : INTERP3;
                     float3 positionWS : INTERP4;
                     float3 normalWS : INTERP5;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.texCoord1.xyzw = input.texCoord1;
                    output.texCoord2.xyzw = input.texCoord2;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.texCoord1 = input.texCoord1.xyzw;
                    output.texCoord2 = input.texCoord2.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
                {
                    // RGB to HSV
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                    float D = Q.x - min(Q.w, Q.y);
                    float E = 1e-10;
                    float V = (D == 0) ? Q.x : (Q.x + E);
                    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
                
                    float hue = hsv.x + Offset;
                    hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                                ? hue - 1
                                : hue;
                
                    // HSV to RGB
                    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 Emission;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CardSprite);
                    float4 _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.tex, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.samplerstate, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_R_4_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.r;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_G_5_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.g;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_B_6_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.b;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_A_7_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.a;
                    UnityTexture2D _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern1);
                    float2 _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2);
                    float4 _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.tex, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.samplerstate, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2) );
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_R_4_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_G_5_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_B_6_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_A_7_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.a;
                    float _Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float = _Bright;
                    float4 _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4, (_Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float.xxxx), _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4);
                    float4 Color_bf1edd044bc24900a4e714847bcdb76e = IsGammaSpace() ? float4(0.9728174, 1, 0, 0) : float4(SRGBToLinear(float3(0.9728174, 1, 0)), 0);
                    float _Property_8f21833e9693437786f4a8108be35321_Out_0_Float = _ColorDensity;
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_A_4_Float = 0;
                    float _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float;
                    Unity_Multiply_float_float(_Property_8f21833e9693437786f4a8108be35321_Out_0_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float, _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float);
                    float _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float, _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float);
                    float3 _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_bf1edd044bc24900a4e714847bcdb76e.xyz), _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float, _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3);
                    float3 _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4.xyz), _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3, _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3);
                    UnityTexture2D _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern2);
                    float2 _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2);
                    float4 _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.tex, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.samplerstate, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2) );
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_R_4_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.r;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_G_5_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.g;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_B_6_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.b;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_A_7_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.a;
                    float _Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float = _Bright;
                    float4 _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4, (_Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float.xxxx), _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4);
                    float4 Color_35cfe5ff0a30447cb34b135a8a58e154 = IsGammaSpace() ? float4(0.9860039, 0, 1, 0) : float4(SRGBToLinear(float3(0.9860039, 0, 1)), 0);
                    float _Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float = _ColorDensity;
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_A_4_Float = 0;
                    float _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float;
                    Unity_Multiply_float_float(_Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float, _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float);
                    float _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float, _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float);
                    float3 _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_35cfe5ff0a30447cb34b135a8a58e154.xyz), _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float, _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3);
                    float3 _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4.xyz), _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3);
                    float3 _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3;
                    Unity_Add_float3(_Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3, _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3);
                    float3 _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    Unity_Add_float3((_SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.xyz), _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3, _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3);
                    surface.BaseColor = _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    surface.Emission = float3(0, 0, 0);
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                    // use bitangent on the fly like in hdrp
                    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
                    float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                
                    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                    output.WorldSpaceBiTangent = renormFactor * bitang;
                
                    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                    float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
                    output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENESELECTIONPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            // GraphFunctions: <None>
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                
                
                
                
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpaceViewDirection;
                     float3 TangentSpaceViewDirection;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 tangentWS : INTERP0;
                     float4 texCoord0 : INTERP1;
                     float3 positionWS : INTERP2;
                     float3 normalWS : INTERP3;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
                {
                    // RGB to HSV
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                    float D = Q.x - min(Q.w, Q.y);
                    float E = 1e-10;
                    float V = (D == 0) ? Q.x : (Q.x + E);
                    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
                
                    float hue = hsv.x + Offset;
                    hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                                ? hue - 1
                                : hue;
                
                    // HSV to RGB
                    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CardSprite);
                    float4 _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.tex, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.samplerstate, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_R_4_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.r;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_G_5_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.g;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_B_6_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.b;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_A_7_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.a;
                    UnityTexture2D _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern1);
                    float2 _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2);
                    float4 _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.tex, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.samplerstate, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2) );
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_R_4_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_G_5_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_B_6_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_A_7_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.a;
                    float _Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float = _Bright;
                    float4 _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4, (_Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float.xxxx), _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4);
                    float4 Color_bf1edd044bc24900a4e714847bcdb76e = IsGammaSpace() ? float4(0.9728174, 1, 0, 0) : float4(SRGBToLinear(float3(0.9728174, 1, 0)), 0);
                    float _Property_8f21833e9693437786f4a8108be35321_Out_0_Float = _ColorDensity;
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_A_4_Float = 0;
                    float _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float;
                    Unity_Multiply_float_float(_Property_8f21833e9693437786f4a8108be35321_Out_0_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float, _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float);
                    float _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float, _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float);
                    float3 _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_bf1edd044bc24900a4e714847bcdb76e.xyz), _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float, _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3);
                    float3 _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4.xyz), _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3, _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3);
                    UnityTexture2D _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern2);
                    float2 _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2);
                    float4 _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.tex, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.samplerstate, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2) );
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_R_4_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.r;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_G_5_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.g;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_B_6_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.b;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_A_7_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.a;
                    float _Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float = _Bright;
                    float4 _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4, (_Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float.xxxx), _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4);
                    float4 Color_35cfe5ff0a30447cb34b135a8a58e154 = IsGammaSpace() ? float4(0.9860039, 0, 1, 0) : float4(SRGBToLinear(float3(0.9860039, 0, 1)), 0);
                    float _Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float = _ColorDensity;
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_A_4_Float = 0;
                    float _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float;
                    Unity_Multiply_float_float(_Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float, _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float);
                    float _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float, _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float);
                    float3 _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_35cfe5ff0a30447cb34b135a8a58e154.xyz), _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float, _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3);
                    float3 _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4.xyz), _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3);
                    float3 _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3;
                    Unity_Add_float3(_Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3, _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3);
                    float3 _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    Unity_Add_float3((_SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.xyz), _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3, _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3);
                    surface.BaseColor = _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                    // use bitangent on the fly like in hdrp
                    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
                    float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                
                    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                    output.WorldSpaceBiTangent = renormFactor * bitang;
                
                    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                    float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
                    output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "Universal 2D"
                Tags
                {
                    "LightMode" = "Universal2D"
                }
            
            // Render State
            Cull Back
                Blend One Zero
                ZTest LEqual
                ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
                #pragma vertex vert
                #pragma fragment frag
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
            #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpaceViewDirection;
                     float3 TangentSpaceViewDirection;
                     float4 uv0;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 tangentWS : INTERP0;
                     float4 texCoord0 : INTERP1;
                     float3 positionWS : INTERP2;
                     float3 normalWS : INTERP3;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
            
            PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.positionWS.xyz = input.positionWS;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.positionWS = input.positionWS.xyz;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
                float _ColorDensity;
                float2 _PatternTiling;
                float4 _Pattern1_TexelSize;
                float _Bright;
                float4 _CardSprite_TexelSize;
                float4 _Pattern2_TexelSize;
                float4 _Pattern3_TexelSize;
                UNITY_TEXTURE_STREAMING_DEBUG_VARS;
                CBUFFER_END
                
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Pattern1);
                SAMPLER(sampler_Pattern1);
                TEXTURE2D(_CardSprite);
                SAMPLER(sampler_CardSprite);
                TEXTURE2D(_Pattern2);
                SAMPLER(sampler_Pattern2);
                TEXTURE2D(_Pattern3);
                SAMPLER(sampler_Pattern3);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Power_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = pow(A, B);
                }
                
                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
                {
                    // RGB to HSV
                    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                    float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                    float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                    float D = Q.x - min(Q.w, Q.y);
                    float E = 1e-10;
                    float V = (D == 0) ? Q.x : (Q.x + E);
                    float3 hsv = float3(abs(Q.z + (Q.w - Q.y)/(6.0 * D + E)), D / (Q.x + E), V);
                
                    float hue = hsv.x + Offset;
                    hsv.x = (hue < 0)
                            ? hue + 1
                            : (hue > 1)
                                ? hue - 1
                                : hue;
                
                    // HSV to RGB
                    float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                    float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                    Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
                }
                
                void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
                {
                    float3 BaseColor;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_CardSprite);
                    float4 _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.tex, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.samplerstate, _Property_2d233efba2d54c158b36d1548006f276_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy) );
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_R_4_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.r;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_G_5_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.g;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_B_6_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.b;
                    float _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_A_7_Float = _SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.a;
                    UnityTexture2D _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern1);
                    float2 _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_b88c1df09ef54deead4f6d0ee9e37def_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2);
                    float4 _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.tex, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.samplerstate, _Property_5bfb6a36441c46b584024ce95d37cdca_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_dedfddf5513d468995f08c86a6a99c2b_Out_3_Vector2) );
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_R_4_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.r;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_G_5_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.g;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_B_6_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.b;
                    float _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_A_7_Float = _SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4.a;
                    float _Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float = _Bright;
                    float4 _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_f06c3c446b0c482ab49983e2f34fa079_RGBA_0_Vector4, (_Property_5c719a5641564ad68bcee42ba619d1e9_Out_0_Float.xxxx), _Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4);
                    float4 Color_bf1edd044bc24900a4e714847bcdb76e = IsGammaSpace() ? float4(0.9728174, 1, 0, 0) : float4(SRGBToLinear(float3(0.9728174, 1, 0)), 0);
                    float _Property_8f21833e9693437786f4a8108be35321_Out_0_Float = _ColorDensity;
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_41b0303bbf1f4ab58ae74b201515e3d4_A_4_Float = 0;
                    float _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float;
                    Unity_Multiply_float_float(_Property_8f21833e9693437786f4a8108be35321_Out_0_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_R_1_Float, _Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float);
                    float _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_b7e463108c8f4dbeb609976af6b582e2_Out_2_Float, _Split_41b0303bbf1f4ab58ae74b201515e3d4_G_2_Float, _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float);
                    float3 _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_bf1edd044bc24900a4e714847bcdb76e.xyz), _Multiply_1fbb1bd0d3f548ebaaa523573c623a99_Out_2_Float, _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3);
                    float3 _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_83fb6ee3cf7348b398c6f61f091f3716_Out_2_Vector4.xyz), _Hue_60dc9cdbc03d4aae915efd58cea9f1ba_Out_2_Vector3, _Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3);
                    UnityTexture2D _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Pattern2);
                    float2 _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2 = _PatternTiling;
                    float2 _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_a94d5245e6104d31be64e821f13c848b_Out_0_Vector2, float2 (0, 0), _TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2);
                    float4 _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.tex, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.samplerstate, _Property_a8f486a249d14f2ab737bca676b21fc6_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_58079aa8c30e4544a6798064c8a5d228_Out_3_Vector2) );
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_R_4_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.r;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_G_5_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.g;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_B_6_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.b;
                    float _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_A_7_Float = _SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4.a;
                    float _Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float = _Bright;
                    float4 _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4;
                    Unity_Power_float4(_SampleTexture2D_82f2fbee94a24d058f935017b1385e77_RGBA_0_Vector4, (_Property_e9175038e8944c4a8bffc7e3c61fe710_Out_0_Float.xxxx), _Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4);
                    float4 Color_35cfe5ff0a30447cb34b135a8a58e154 = IsGammaSpace() ? float4(0.9860039, 0, 1, 0) : float4(SRGBToLinear(float3(0.9860039, 0, 1)), 0);
                    float _Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float = _ColorDensity;
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float = IN.TangentSpaceViewDirection[0];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float = IN.TangentSpaceViewDirection[1];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_B_3_Float = IN.TangentSpaceViewDirection[2];
                    float _Split_18ea14a4c4b04060a28f8f75c7b3d452_A_4_Float = 0;
                    float _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float;
                    Unity_Multiply_float_float(_Property_304a7b3508a0440085d1f8b80d8ed7c3_Out_0_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_R_1_Float, _Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float);
                    float _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float;
                    Unity_Multiply_float_float(_Multiply_c4d22c70507e4fb2b34168405c69495d_Out_2_Float, _Split_18ea14a4c4b04060a28f8f75c7b3d452_G_2_Float, _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float);
                    float3 _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3;
                    Unity_Hue_Normalized_float((Color_35cfe5ff0a30447cb34b135a8a58e154.xyz), _Multiply_ccfc0a463cb043f68cc1e3941dd1830d_Out_2_Float, _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3);
                    float3 _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3;
                    Unity_Multiply_float3_float3((_Power_d8455333b3d44d5e981e0402980743c1_Out_2_Vector4.xyz), _Hue_735a9c91dba648e9a0d9e6209fb74d84_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3);
                    float3 _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3;
                    Unity_Add_float3(_Multiply_fc81ec4ab3384b488300bb728e3db887_Out_2_Vector3, _Multiply_4dac2737b800499fbd5f98cd17c662f0_Out_2_Vector3, _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3);
                    float3 _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    Unity_Add_float3((_SampleTexture2D_a55a4541e74f4320b26476201e57ffc4_RGBA_0_Vector4.xyz), _Add_cb6329842e614294a86c738255a81dc5_Out_2_Vector3, _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3);
                    surface.BaseColor = _Add_b6c1630302514ecb9a25ba1225efd471_Out_2_Vector3;
                    return surface;
                }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =                          input.normalOS;
                    output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                    output.ObjectSpacePosition =                        input.positionOS;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                
                    return output;
                }
                
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                #ifdef HAVE_VFX_MODIFICATION
                #if VFX_USE_GRAPH_VALUES
                    uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                    /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                #endif
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                
                #endif
                
                    
                
                    // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                    float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                    // use bitangent on the fly like in hdrp
                    // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                    float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0)* GetOddNegativeScale();
                    float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);
                
                    output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                
                    // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                    // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                    output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                    output.WorldSpaceBiTangent = renormFactor * bitang;
                
                    output.WorldSpaceViewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                    float3x3 tangentSpaceTransform = float3x3(output.WorldSpaceTangent, output.WorldSpaceBiTangent, output.WorldSpaceNormal);
                    output.TangentSpaceViewDirection = mul(tangentSpaceTransform, output.WorldSpaceViewDirection);
                
                    #if UNITY_UV_STARTS_AT_TOP
                    #else
                    #endif
                
                
                    output.uv0 = input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                        return output;
                }
                
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        FallBack "Hidden/Shader Graph/FallbackError"
    }