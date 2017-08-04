module cortexm;

version(LDC) {
    import ldc.attributes;
    import ldc.llvmasm;
}

version(ARM_Thumb):
extern(C):
@nogc:
nothrow:

version(LDC) {
    pragma(LDC_no_moduleinfo);
    pragma(LDC_no_typeinfo);
}

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

extern {
    void NMIExceptionHandler();
    void HardFaultExceptionHandler();
    void MemmanageFaultExceptionHandler();
    void BusFaultExceptionHandler();
    void UsageFaultExceptionHandler();
    void SVCallExceptionHandler();
    void PendSVExceptionHandler();
    void SystickExceptionHandler();
}

@section(".rodata._EXCEPTIONS")
typeof(&defaultExceptionHandler)[14] _EXCEPTIONS = [
    &NMIExceptionHandler, // NMI
    &HardFaultExceptionHandler, // Hard fault
    &MemmanageFaultExceptionHandler, // Memmanage fault
    &BusFaultExceptionHandler, // Bus fault
    &UsageFaultExceptionHandler, // Usage fault
    null, // Reserved
    null, // Reserved
    null, // Reserved
    null, // Reserved
    &SVCallExceptionHandler, // SVCall
    null, // Reserved for Debug
    null, // Reserved
    &PendSVExceptionHandler, // PendSV
    &SystickExceptionHandler]; // Systick


void defaultExceptionHandler()
{
    pragma(LDC_never_inline);
    bkpt();
    while (true) {
        wfi();
    }
}


/**
 *  Interrupt.
 */

version(LDC) {
    void disableInterrupt()
    {
        pragma(LDC_allow_inline);
        cpsid();
    }

    void enableInterrupt()
    {
        pragma(LDC_allow_inline);
        cpsie();
    }
}

/**
 * Instructions.
 */

version(LDC) {
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

    void cpsid()
    {
        pragma(LDC_allow_inline);
        __asm("cpsid i", "");
    }

    void cpsie()
    {
        pragma(LDC_allow_inline);
        __asm("cpsie i", "");
    }
}
