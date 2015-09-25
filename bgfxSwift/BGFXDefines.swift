//
//  BGFXDefines.swift
//
//  Created by Dawid Górny on 14/06/15.
//  Copyright © 2015 Dawid Górny. All rights reserved.
//

let BGFX_RESET_VSYNC = 0x00000080
let BGFX_PCI_ID_NONE = 0x0000

let BGFX_CLEAR_COLOR = 0x0001
let BGFX_CLEAR_DEPTH = 0x0002

let BGFX_DEBUG_TEXT:UInt32 = 0x00000008


let BGFX_STATE_RGB_WRITE        :UInt64 = 0x0000000000000001
let BGFX_STATE_ALPHA_WRITE      :UInt64 = 0x0000000000000002
let BGFX_STATE_DEPTH_TEST_LESS  :UInt64 = 0x0000000000000010
let BGFX_STATE_DEPTH_WRITE      :UInt64 = 0x0000000000000004
let BGFX_STATE_CULL_CW          :UInt64 = 0x0000001000000000
let BGFX_STATE_MSAA             :UInt64 = 0x1000000000000000

let BGFX_STATE_DEFAULT          :UInt64 = UInt64( 0 | BGFX_STATE_RGB_WRITE
                                                    | BGFX_STATE_ALPHA_WRITE
                                                    | BGFX_STATE_DEPTH_TEST_LESS
                                                    | BGFX_STATE_DEPTH_WRITE
                                                    | BGFX_STATE_CULL_CW
                                                    | BGFX_STATE_MSAA )
