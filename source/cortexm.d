module cortexm;

import ldc.attributes;
import ldc.llvmasm;

version(ARM_Thumb):
extern(C):
@nogc:
nothrow:

pragma(LDC_no_moduleinfo);
pragma(LDC_no_typeinfo);

/**
 *  Entorypont.
 */

// User must define `main()` function.
extern void main();

void _reset()
{
    main();
    while (true) {
        wfi();
    }
}


/**
 *  Exceptions.
 */

@section(".rodata._EXCEPTIONS")
typeof(&handler)[14] _EXCEPTIONS = [
    &handler, // NMI
    &handler, // Hard fault
    &handler, // Memmanage fault
    &handler, // Bus fault
    &handler, // Usage fault
    null, // Reserved
    null, // Reserved
    null, // Reserved
    null, // Reserved
    &handler, // SVCall
    null, // Reserved for Debug
    null, // Reserved
    &handler, // PendSV
    &handler]; // Systick


void handler()
{
    pragma(LDC_never_inline);
    bkpt();
    while (true) {
        wfi();
    }
}


/**
 * Instructions.
 */

void bkpt()
{
    pragma(LDC_allow_inline);
    __asm("bkpt", "");
}

void nop()
{
    pragma(LDC_allow_inline);
    __asm("nop", "");
}

void wfi()
{
    pragma(LDC_allow_inline);
    __asm("wfi", "");
}
