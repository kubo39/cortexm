module core.bitop;

version(ARM_Thumb):
@nogc:
nothrow:

version(LDC)
{
    pragma(LDC_no_moduleinfo);
    pragma(LDC_no_typeinfo);
}

/**
volatileLoad/volatileStore intrinsic.
 */
version (LDC)
{
    pragma(LDC_intrinsic, "ldc.bitop.vld")
        ubyte volatileLoad(ubyte * ptr);
    pragma(LDC_intrinsic, "ldc.bitop.vld")
        ushort volatileLoad(ushort* ptr);
    pragma(LDC_intrinsic, "ldc.bitop.vld")
        uint volatileLoad(uint* ptr);
    pragma(LDC_intrinsic, "ldc.bitop.vld")
        ulong volatileLoad(ulong * ptr);

    pragma(LDC_intrinsic, "ldc.bitop.vst")
        void volatileStore(ubyte * ptr, ubyte value);
    pragma(LDC_intrinsic, "ldc.bitop.vst")
        void volatileStore(ushort* ptr, ushort value);
    pragma(LDC_intrinsic, "ldc.bitop.vst")
        void volatileStore(uint  * ptr, uint value);
    pragma(LDC_intrinsic, "ldc.bitop.vst")
        void volatileStore(ulong * ptr, ulong value);
}
