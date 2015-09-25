//
//  BGFXBinding.swift
//
//  Created by Dawid Górny on 20/08/15.
//  Copyright © 2015 Dawid Górny. All rights reserved.
//

class bgfx {

    static let CLEAR_COLOR:Int = 0x0001
    static let CLEAR_DEPTH:Int = 0x0002

    static func setViewClear(id: Int, flags: Int, rgba: Int, depth: Double, stencil: Int) {
        bgfx_set_view_clear(UInt8(id), UInt16(flags), UInt32(rgba), Float(depth), UInt8(stencil))
    }


}
