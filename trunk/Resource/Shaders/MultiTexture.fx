// globals
float4x4	gWorld;
float4x4	gWVP;
float3      gLightDirection;
float3      gViewPosition;
int			nTexNum = 1;
texture     Tex;
texture		Tex2;
texture		Tex3;
texture		Tex4;
texture		Tex5;
	
float4 gAmbientMtrl;		// ambient material color
float4 gAmbientLight;		// ambient light color
							
float4 diffuseMtrlColor;	// the diffuse color of the material
float4 diffuseLightColor;	// the color of the diffuse light	

// texture sampler
sampler		samp1
{
	Texture = <Tex>;
	// texture filtering
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	//MaxAnisotropy = 4;
	// texture address modes
	AddressU  = WRAP;
	AddressV  = WRAP;
};

sampler		samp2
{
	Texture = <Tex2>;
	// texture filtering
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	// texture address modes (available options are WRAP, MIRROR, BORDER, and CLAMP)
	AddressU  = WRAP;
	AddressV  = WRAP;
};

sampler		samp3
{
	Texture = <Tex3>;
	// texture filtering
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	// texture address modes (available options are WRAP, MIRROR, BORDER, and CLAMP)
	AddressU  = WRAP;
	AddressV  = WRAP;
};

sampler		samp4
{
	Texture = <Tex4>;
	// texture filtering
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	// texture address modes (available options are WRAP, MIRROR, BORDER, and CLAMP)
	AddressU  = WRAP;
	AddressV  = WRAP;
};

sampler		samp5
{
	Texture = <Tex5>;
	// texture filtering
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	// texture address modes (available options are WRAP, MIRROR, BORDER, and CLAMP)
	AddressU  = WRAP;
	AddressV  = WRAP;
};

// Define a vertex shader output structure;
struct OutputVS
{
    float4 posH      : POSITION0;
    float4 color     : COLOR0;
    float2 texCoord0 : TEXCOORD0;
    float2 texCoord1 : TEXCOORD1;
};

// Vertex shader -------------------------------------------------------------------------------------
OutputVS TransformVS(float3 position:POSITION0, float3 normal:NORMAL0, float2 uv0:TEXCOORD0)
{
	// output structure
	OutputVS outVS;
	
	outVS.posH = mul(float4(position, 1.0f), gWVP);	
	
	//outVS.normal = normal;
	
	outVS.color = float4(1,1,1,1);
	
	outVS.texCoord0 = uv0;
	outVS.texCoord1 = position.xy;
	
    return outVS;
}

OutputVS OutlineVS(float3 position:POSITION0, float3 normal:NORMAL0, float2 uv0:TEXCOORD0)
{
	// output structure
	OutputVS outVS;
	
	outVS.posH = mul(float4(position, 1.0f), gWVP);	
	
	//outVS.normal = float4(normal, 1.0);
	
	outVS.color.a = dot(normal, gViewPosition);
	outVS.color.r = 0.0;
	outVS.color.g = 0.0;
	outVS.color.b = 0.0;
	
	outVS.texCoord0 = uv0;
	outVS.texCoord1.x = dot(normal, gViewPosition);
	outVS.texCoord1.y = 0.0;
	if(outVS.texCoord1.x < 0.0f)
		outVS.texCoord1 *= -1.0f;
	
    return outVS;
}

OutputVS DiffuseVS(float3 posLocal : POSITION0, float3 normalL : NORMAL0, float2 uv0:TEXCOORD0)
{
    OutputVS Out = (OutputVS)0;
    Out.posH = mul(float4(posLocal, 1.0f), gWVP); // transform Position

	// calculate the world position of the vertex    
    float4 worldPosition = mul(float4(posLocal, 1.0f), gWorld);
    
    // normalize the light vector
    //gLightDirection = normalize(gLightDirection);
    
    // multiply the normal by the world matrix to put the normal into the same
    // space as the light
    float3 normalW = mul(float4(normalL, 1.0f), gWorld).xyz;
	normalW = normalize(normalW);
    
    // calculate how much light is hitting this vertex
	float lightAmount = saturate(dot(gLightDirection, normalW));
	
	// amount of light * (material color * light color)
	Out.color.rgb = (diffuseMtrlColor*diffuseLightColor).rgb * lightAmount;
	
	//Out.color.rgb = normalW;
	
	// set the alpha to 1.0
	Out.color.a   = 1.0;
	
	// pass through the texture coordinates
	Out.texCoord0 = uv0;
	Out.texCoord1 = normalL.xy;

    return Out;
}

// Pixel Shader ---------------------------------------------------------------------------
float4 TransformPS(float2 uv0:TEXCOORD0):COLOR
{
	// determine the pixel to sampler from
	//return float4(1,1,1,1);
    float4 texCol = tex2D(samp1, uv0);
    
    //if(texCol.a < 0.6)
	//	discard;
    
    return texCol;
}

float4 ChangePS(float2 uv0:TEXCOORD0):COLOR
{
	// determine the pixel to sampler from
	//return float4(1,1,1,1);
    float4 texCol;
    
    if(nTexNum == 1)
		texCol = tex2D(samp1, uv0);
	if(nTexNum == 2)
		texCol = tex2D(samp2, uv0);
	if(nTexNum == 3)
		texCol = tex2D(samp3, uv0);
	if(nTexNum == 4)
		texCol = tex2D(samp4, uv0);
	if(nTexNum == 5)
		texCol = tex2D(samp5, uv0);
    
    //if(texCol.a <= 0.3)
		//discard;
    
    return texCol;
}

float4 DiffusePS(float4 color : COLOR0, float2 uv0:TEXCOORD0) : COLOR
{
	//return float4(uv0, 1, 1);
	
	float4 ambient = gAmbientMtrl * gAmbientLight;
	
	float4 texCol = tex2D(samp1, uv0);
	
	if(texCol.a < 0.6)
		discard;
	
	return  (color + ambient) * texCol;
}

float4 AlphaPS(float4 color : COLOR0, float2 uv0:TEXCOORD0) : COLOR
{
	//return float4(uv0, 1, 1);
	
	float4 ambient = gAmbientMtrl * gAmbientLight;
	
	float4 texCol = tex2D(samp1, uv0);
	
	if(texCol.a <= 0.6)
		discard;
	
	return  texCol;
}

// Pixel Shader ---------------------------------------------------------------------------
float4 DiffuseMultPS(float4 color:COLOR0, float2 uv0:TEXCOORD0, float2 uv1:TEXCOORD1):COLOR
{	
	// prime texture
    float4 texCol1 = tex2D(samp1, uv0);
    
    // texture2
    float4 texCol2 = tex2D(samp2, uv0);
    
    // texture3
    float4 texCol3 = tex2D(samp3, uv1 / 512);
    
    // create the final color
    //float4 outColor = texCol1 * texCol2;
    
    // blend between both by a percentage
    float4 fTexColor = lerp(texCol1, texCol2, texCol3);
    //fTexColor = lerp(fTexColor, texCol3, 0.35f);
    
    // Diffuse
	float4 ambient = gAmbientMtrl * gAmbientLight;
    
    // produce the final color additionally using vertex colors
    float4 outColor = fTexColor * (color + ambient);
    
    return outColor;
}

float4 BlackPS(float4 color : COLOR0, float2 uv0:TEXCOORD0, float2 uv1:TEXCOORD1) : COLOR
{
	float4 texCol = tex2D(samp1, uv0);
	
	if(texCol.a <= 0.6)
		discard;
	
	float4 outCol = texCol;
	
	if(uv1.x <= 0.1)
		outCol = float4(0.0, 0.0, 0.0, 1.0);
		
	return outCol;
}

// ----------------------------------------------------------------------------------------
technique Tex2D
{
    pass P0
    {
        vertexShader = compile vs_2_0 TransformVS();
        pixelShader  = compile ps_2_0 TransformPS();
      
		//ShadeMode = Flat;
        //FillMode = Wireframe;
        CullMode = NONE;
        
        ZWriteEnable = true;
        ZEnable = true;
    }
}

technique AlphaTest
{
	pass P0
    {
        vertexShader = compile vs_2_0 TransformVS();
        pixelShader  = compile ps_2_0 AlphaPS();
        
        //AlphaTestEnable = true;
        //AlphaRef = 1.0f;
        //AlphaFunc = Greater;
        
        SrcBlend = 2;
		DestBlend = 1;
      
		ShadeMode = Flat;
        FillMode = Solid;
        CullMode = NONE;
        
        ZWriteEnable = true;
        ZEnable = true;
    }
}

technique TextureChange
{
	pass P0
    {
        vertexShader = compile vs_2_0 TransformVS();
        pixelShader  = compile ps_2_0 ChangePS();
        
        //AlphaTestEnable = true;
        //AlphaRef = 1.0f;
        //AlphaFunc = Greater;
        
        SrcBlend = 2;
		DestBlend = 1;
      
		ShadeMode = Flat;
        FillMode = Solid;
        CullMode = NONE;
        
        ZWriteEnable = true;
        ZEnable = true;
    }
}

technique BlueLight
{
	pass P0
    {
        vertexShader = compile vs_2_0 TransformVS();
        pixelShader  = compile ps_2_0 ChangePS();
        
        //AlphaTestEnable = true;
        //AlphaRef = 0.3f;
        //AlphaFunc = Greater;
        
        AlphaBlendEnable = true;
		SrcBlend = 5;		// 3, 1, 4,  5, 5, 5,  8, 9, 9, 9,  12, 12
		DestBlend = 6;		// 5, 3, 14, 3, 6, 13, 3, 1, 5, 12, 1,  4
        
        ZWriteEnable = false;
        ZEnable = true;
      
		ShadeMode = Flat;
        FillMode = Solid;
        CullMode = NONE;
    }
    //pass P1
    //{
        //vertexShader = compile vs_2_0 TransformVS();
        //pixelShader  = compile ps_2_0 ChangePS();
        //
        //AlphaTestEnable = true;
        //AlphaRef = 0.3f;
        //AlphaFunc = Greater;
        //
        //AlphaBlendEnable = true;
		//SrcBlend = 3;
		//DestBlend = 6;
		//
        ////ZWriteEnable = false;
        ////ZEnable = true;
      //
		//ShadeMode = Flat;
        //FillMode = Solid;
        //CullMode = CW;
    //}
}

technique Outline
{
    pass P0
    {
        vertexShader = compile vs_2_0 OutlineVS();
        pixelShader  = compile ps_2_0 BlackPS();
        
        //AlphaTestEnable = true;
        //AlphaRef = 1.0f;
        //AlphaFunc = Greater;
        
        SrcBlend = 2;
		DestBlend = 1;
      
		ShadeMode = Flat;
        FillMode = Solid;
        CullMode = NONE;
        
        ZWriteEnable = true;
        ZEnable = true;
    }
}

technique Tex2DDiffuse
{
    pass P0
    {
        // Specify the vertex and pixel shader associated with this pass.
        vertexShader = compile vs_3_0 DiffuseVS();
        pixelShader  = compile ps_3_0 DiffusePS();
        
        
        //fillmode = wireframe;
        //shademode = flat;
        CullMode = CW;
        ZWriteEnable = true;
        ZEnable = true;
    }
}

technique MultiTexDiffuse
{
    pass P0
    {
        // Specify the vertex and pixel shader associated with this pass.
        vertexShader = compile vs_3_0 DiffuseVS();
        pixelShader  = compile ps_3_0 DiffuseMultPS();
        
        //fillmode = wireframe;
        //shademode = flat;
        CullMode = CW;
        ZWriteEnable = true;
        ZEnable = true;
    }
}