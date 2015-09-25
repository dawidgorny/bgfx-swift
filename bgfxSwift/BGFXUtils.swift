//
//  BGFXUtils.swift
//
//  Created by Dawid Górny on 15/06/15.
//  Copyright © 2015 Dawid Górny. All rights reserved.
//


func mtxRotateXY( ax:Float, ay:Float) -> [Float] {

    let sx = sinf(ax);
    let cx = cosf(ax);
    let sy = sinf(ay);
    let cy = cosf(ay);

    var result:[Float] = [Float](count: 16, repeatedValue: 0)
    result[ 0] = cy
    result[ 2] = sy
    result[ 4] = sx*sy
    result[ 5] = cx
    result[ 6] = -sx*cy
    result[ 8] = -cx*sy
    result[ 9] = sx
    result[10] = cx*cy
    result[15] = 1.0
    return result
}


func mtxLookAt(at:[Float], eye:[Float]) -> [Float] {

    var result:[Float] = [Float](count: 16, repeatedValue: 0)

    var tmp = vec3Sub(at, b: eye)
    var view = vec3Norm(tmp)

    var up:[Float] = [ 0.0, 1.0, 0.0 ]
    tmp = vec3Cross(up, b: view)

    let right = vec3Norm(tmp)

    up = vec3Cross(view, b: right)

    result[ 0] = right[0]
    result[ 1] = up[0]
    result[ 2] = view[0]

    result[ 4] = right[1]
    result[ 5] = up[1]
    result[ 6] = view[1]

    result[ 8] = right[2]
    result[ 9] = up[2]
    result[10] = view[2]

    result[12] = -vec3Dot(right, b: eye)
    result[13] = -vec3Dot(up, b: eye)
    result[14] = -vec3Dot(view, b: eye)
    result[15] = 1.0

    return result
}

func mtxProj(fovy:Float, aspect:Float, near:Float, far:Float) -> [Float] {
    let pi:Float        = 3.14159265358979323846
    let _height:Float   = 1.0 / tanf( (fovy * pi / 180.0) * 0.5 )
    let _width:Float    = _height * 1.0 / aspect
    let diff:Float      = far - near
    let aa:Float        = far / diff

    var result:[Float] = [Float](count: 16, repeatedValue: 0)
    result[ 0] = _width
    result[ 5] = _height
    result[ 8] = 0
    result[ 9] = 0
    result[10] = aa
    result[11] = 1.0
    result[14] = -near * aa
    return result
}


// ------------

func vec3Dot(a:[Float], b:[Float]) -> Float {
    return a[0]*b[0] + a[1]*b[1] + a[2]*b[2]
}

func vec3Cross(a:[Float], b:[Float]) -> [Float] {
    var result:[Float] = [Float](count: 3, repeatedValue: 0)
    result[0] = a[1]*b[2] - a[2]*b[1]
    result[1] = a[2]*b[0] - a[0]*b[2]
    result[2] = a[0]*b[1] - a[1]*b[0]
    return result
}

func vec3Sub(a:[Float], b:[Float]) -> [Float] {
    var result:[Float] = [Float](count: 3, repeatedValue: 0)
    result[0] = a[0] - b[0]
    result[1] = a[1] - b[1]
    result[2] = a[2] - b[2]
    return result
}

func vec3Length(a:[Float]) -> Float {
    return sqrtf(vec3Dot(a, b: a) )
}

func vec3Norm(a:[Float]) -> [Float] {
    var result:[Float] = [Float](count: 3, repeatedValue: 0)
    let len = vec3Length(a)
    let invLen:Float = 1.0/len
    result[0] = a[0] * invLen
    result[1] = a[1] * invLen
    result[2] = a[2] * invLen
    return result;
}


// ------------

func loadFileToMem( filePath:String ) -> UnsafePointer<bgfx_memory_t> {
    let data = NSMutableData(contentsOfFile: filePath)!
    let c = "\0"
    c.withCString {
        data.appendBytes($0, length: 1)
    }
    let mem = bgfx_alloc(UInt32(data.length))
    data.getBytes(mem.memory.data, length: Int(mem.memory.size))

    return mem
}

func bgfx_utils_loadShader( name:String ) -> bgfx_shader_handle_t {

    let bundle = NSBundle.mainBundle()
    var filePath:String = bundle.resourcePath! + "/"

    switch bgfx_get_renderer_type().rawValue {
        case BGFX_RENDERER_TYPE_DIRECT3D11.rawValue, BGFX_RENDERER_TYPE_DIRECT3D12.rawValue:
            filePath += "shaders/dx11/"
        case BGFX_RENDERER_TYPE_OPENGL.rawValue:
            filePath += "shaders/glsl/"
        case BGFX_RENDERER_TYPE_OPENGLES.rawValue:
            filePath += "shaders/gles/"
        default:
            filePath += "shaders/dx9/"
    }

    filePath += name + ".bin"

    print("Loading shader: " + filePath)

    return bgfx_create_shader( loadFileToMem(filePath) )
}

func bgfx_utils_loadProgram(vsName:String, fsName:String) -> bgfx_program_handle_t {

    let vsh = bgfx_utils_loadShader(vsName);
    let fsh = bgfx_utils_loadShader(fsName);

    return bgfx_create_program(vsh, fsh, true)
}
