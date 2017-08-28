module cortexm;

version(LDC)
{
    import ldc.attributes;
    import ldc.llvmasm;
}

version(ARM_Thumb):
@nogc:
nothrow:

version(LDC)
{
    pragma(LDC_no_moduleinfo);
    pragma(LDC_no_typeinfo);
}

/**
 *  Entorypont.
 */

// User must define `main()` function.
extern (C) void main();
extern (C) static typeof(&reset_handler) _reset = &reset_handler;

@section(".text.reset_handler")
extern (C) void reset_handler()
{
    pragma(LDC_never_inline);
    main();
    while (true) {
        wfi();
    }
}

/**
 *  Peripherals.
 */

// Instrumentation Trace Macrocell
__gshared Itm* ITM = cast(Itm*) 0xE0000000;

struct Itm
{
    Stim[256] stim;
    uint[640] __reserved0;
    uint[8] ter;
    uint [8] __reserved1;
    uint tpr;
    uint[15] __reserved2;
    uint tcr;
    uint[75] __reserved3;
    uint lar;
    uint lsr;
}

align (4) struct Stim
{
    uint register;
}

bool isFIFOReady(Stim* stim)
{
    return volatileLoad(&stim.register) == 1;
}

// Nested Vector Interrupt Controller
__gshared Nvic* NVIC = cast(Nvic*) 0xE000E100;

struct Nvic
{
    uint[8] iser;
    uint[24] __reserved0;
    uint[8] icer;
    uint[24] __reserved1;
    uint[8] ispr;
    uint[24] __reserved2;
    uint[8] icpr;
    uint[24] __reserved3;
    uint[8] iabr;
    uint[56] __reserved4;
    uint[240] ip;
    uint[644] __reserved5;
    uint stir;
}

// Enable interrupt.
void enable(Nvic* _, uint nr)
{
    auto iser = &NVIC.iser[nr / 32];
    volatileStore(iser, 1 << nr);
}


/**
 *  Exceptions.
 */

extern (C) {
    void NMIExceptionHandler();
    void HardFaultExceptionHandler();
    void MemmanageFaultExceptionHandler();
    void BusFaultExceptionHandler();
    void UsageFaultExceptionHandler();
    void SVCallExceptionHandler();
    void PendSVExceptionHandler();
    void SystickExceptionHandler();
}

@section(".rodata.exceptions")
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


extern (C) void defaultExceptionHandler()
{
    pragma(LDC_never_inline);
    bkpt();
    while (true) {
        wfi();
    }
}


/**
 *  Interrupts.
 */

extern (C) {
    void WWDG_IRQInterruptHandler();  // Window WatchDog
    void PVD_IRQInterruptHandler();   // PVD through EXTI Line detection
    void TAMP_STAMP_IRQInterruptHandler();    // Tamper and TimeStamps through the EXTI line
    void RTC_WKUP_IRQInterruptHandler();      // RTC Wakeup through the EXTI line
    void FLASH_IRQInterruptHandler(); // FLASH
    void RCC_IRQInterruptHandler();   // RCC
    void EXTI0_IRQInterruptHandler(); // EXTI Line0
    void EXTI1_IRQInterruptHandler(); // EXTI Line1
    void EXTI2_IRQInterruptHandler(); // EXTI Line2
    void EXTI3_IRQInterruptHandler(); // EXTI Line3
    void EXTI4_IRQInterruptHandler(); // EXTI Line4
    void DMA1_Stream0_IRQInterruptHandler();  // DMA1 Stream 0
    void DMA1_Stream1_IRQInterruptHandler();  // DMA1 Stream 1
    void DMA1_Stream2_IRQInterruptHandler();  // DMA1 Stream 2
    void DMA1_Stream3_IRQInterruptHandler();  // DMA1 Stream 3
    void DMA1_Stream4_IRQInterruptHandler();  // DMA1 Stream 4
    void DMA1_Stream5_IRQInterruptHandler();  // DMA1 Stream 5
    void DMA1_Stream6_IRQInterruptHandler();  // DMA1 Stream 6
    void ADC_IRQInterruptHandler();   // ADC1; ADC2 and ADC3s
    void CAN1_TX_IRQInterruptHandler();       // CAN1 TX
    void CAN1_RX0_IRQInterruptHandler();      // CAN1 RX0
    void CAN1_RX1_IRQInterruptHandler();      // CAN1 RX1
    void CAN1_SCE_IRQInterruptHandler();      // CAN1 SCE
    void EXTI9_5_IRQInterruptHandler();       // External Line[9:5]s
    void TIM1_BRK_TIM9_IRQInterruptHandler(); // TIM1 Break and TIM9
    void TIM1_UP_TIM10_IRQInterruptHandler(); // TIM1 Update and TIM10
    void TIM1_TRG_COM_TIM11_IRQInterruptHandler();     // TIM1 Trigger and Commutation and TIM11
    void TIM1_CC_IRQInterruptHandler();       // TIM1 Capture Compare
    void TIM2_IRQInterruptHandler();  // TIM2
    void TIM3_IRQInterruptHandler();  // TIM3
    void TIM4_IRQInterruptHandler();  // TIM4
    void I2C1_EV_IRQInterruptHandler();       // I2C1 Event
    void I2C1_ER_IRQInterruptHandler();       // I2C1 Error
    void I2C2_EV_IRQInterruptHandler();       // I2C2 Event
    void I2C2_ER_IRQInterruptHandler();       // I2C2 Error
    void SPI1_IRQInterruptHandler();  // SPI1
    void SPI2_IRQInterruptHandler();  // SPI2
    void USART1_IRQInterruptHandler();// USART1
    void USART2_IRQInterruptHandler();// USART2
    void USART3_IRQInterruptHandler();// USART3
    void EXTI15_10_IRQInterruptHandler();     // External Line[15:10]s
    void RTC_Alarm_IRQInterruptHandler();     // RTC Alarm (A and B() through EXTI Line
    void OTG_FS_WKUP_IRQInterruptHandler();   // USB OTG FS Wakeup through EXTI line
    void TIM8_BRK_TIM12_IRQInterruptHandler();// TIM8 Break and TIM12
    void TIM8_UP_TIM13_IRQInterruptHandler(); // TIM8 Update and TIM13
    void TIM8_TRG_COM_TIM14_IRQInterruptHandler();     // TIM8 Trigger and Commutation and TIM14
    void TIM8_CC_IRQInterruptHandler();       // TIM8 Capture Compare
    void DMA1_Stream7_IRQInterruptHandler();  // DMA1 Stream7
    void FSMC_IRQInterruptHandler();  // FSMC
    void SDIO_IRQInterruptHandler();  // SDIO
    void TIM5_IRQInterruptHandler();  // TIM5
    void SPI3_IRQInterruptHandler();  // SPI3
    void UART4_IRQInterruptHandler(); // UART4
    void UART5_IRQInterruptHandler(); // UART5
    void TIM6_DAC_IRQInterruptHandler();      // TIM6 and DAC1&2 underrun errors
    void TIM7_IRQInterruptHandler();  // TIM7
    void DMA2_Stream0_IRQInterruptHandler();  // DMA2 Stream 0
    void DMA2_Stream1_IRQInterruptHandler();  // DMA2 Stream 1
    void DMA2_Stream2_IRQInterruptHandler();  // DMA2 Stream 2
    void DMA2_Stream3_IRQInterruptHandler();  // DMA2 Stream 3
    void DMA2_Stream4_IRQInterruptHandler();  // DMA2 Stream 4
    void ETH_IRQInterruptHandler();   // Ethernet
    void ETH_WKUP_IRQInterruptHandler();      // Ethernet Wakeup through EXTI line
    void CAN2_TX_IRQInterruptHandler();       // CAN2 TX
    void CAN2_RX0_IRQInterruptHandler();      // CAN2 RX0
    void CAN2_RX1_IRQInterruptHandler();      // CAN2 RX1
    void CAN2_SCE_IRQInterruptHandler();      // CAN2 SCE
    void OTG_FS_IRQInterruptHandler();// USB OTG FS
    void DMA2_Stream5_IRQInterruptHandler();  // DMA2 Stream 5
    void DMA2_Stream6_IRQInterruptHandler();  // DMA2 Stream 6
    void DMA2_Stream7_IRQInterruptHandler();  // DMA2 Stream 7
    void USART6_IRQInterruptHandler();// USART6
    void I2C3_EV_IRQInterruptHandler();       // I2C3 event
    void I2C3_ER_IRQInterruptHandler();       // I2C3 error
    void OTG_HS_EP1_OUT_IRQInterruptHandler();// USB OTG HS End Point 1 Out
    void OTG_HS_EP1_IN_IRQInterruptHandler(); // USB OTG HS End Point 1 In
    void OTG_HS_WKUP_IRQInterruptHandler();   // USB OTG HS Wakeup through EXTI
    void OTG_HS_IRQInterruptHandler();// USB OTG HS
    void DCMI_IRQInterruptHandler();  // DCMI
    void CRYP_IRQInterruptHandler();  // CRYP crypto
    void HASH_RNG_IRQInterruptHandler();      // Hash and Rng
    void FPU_IRQInterruptHandler();    // FPU
}

@section(".rodata.interrupts")
typeof(&defaultInterruptHandler)[82] INTERRUPTS = [
    &WWDG_IRQInterruptHandler,
    &PVD_IRQInterruptHandler,
    &TAMP_STAMP_IRQInterruptHandler,
    &RTC_WKUP_IRQInterruptHandler,
    &FLASH_IRQInterruptHandler,
    &RCC_IRQInterruptHandler,
    &EXTI0_IRQInterruptHandler,
    &EXTI1_IRQInterruptHandler,
    &EXTI2_IRQInterruptHandler,
    &EXTI3_IRQInterruptHandler,
    &EXTI4_IRQInterruptHandler,
    &DMA1_Stream0_IRQInterruptHandler,
    &DMA1_Stream1_IRQInterruptHandler,
    &DMA1_Stream2_IRQInterruptHandler,
    &DMA1_Stream3_IRQInterruptHandler,
    &DMA1_Stream4_IRQInterruptHandler,
    &DMA1_Stream5_IRQInterruptHandler,
    &DMA1_Stream6_IRQInterruptHandler,
    &ADC_IRQInterruptHandler,
    &CAN1_TX_IRQInterruptHandler,
    &CAN1_RX0_IRQInterruptHandler,
    &CAN1_RX1_IRQInterruptHandler,
    &CAN1_SCE_IRQInterruptHandler,
    &EXTI9_5_IRQInterruptHandler,
    &TIM1_BRK_TIM9_IRQInterruptHandler,
    &TIM1_UP_TIM10_IRQInterruptHandler,
    &TIM1_TRG_COM_TIM11_IRQInterruptHandler,
    &TIM1_CC_IRQInterruptHandler,
    &TIM2_IRQInterruptHandler,
    &TIM3_IRQInterruptHandler,
    &TIM4_IRQInterruptHandler,
    &I2C1_EV_IRQInterruptHandler,
    &I2C1_ER_IRQInterruptHandler,
    &I2C2_EV_IRQInterruptHandler,
    &I2C2_ER_IRQInterruptHandler,
    &SPI1_IRQInterruptHandler,
    &SPI2_IRQInterruptHandler,
    &USART1_IRQInterruptHandler,
    &USART2_IRQInterruptHandler,
    &USART3_IRQInterruptHandler,
    &EXTI15_10_IRQInterruptHandler,
    &RTC_Alarm_IRQInterruptHandler,
    &OTG_FS_WKUP_IRQInterruptHandler,
    &TIM8_BRK_TIM12_IRQInterruptHandler,
    &TIM8_UP_TIM13_IRQInterruptHandler,
    &TIM8_TRG_COM_TIM14_IRQInterruptHandler,
    &TIM8_CC_IRQInterruptHandler,
    &DMA1_Stream7_IRQInterruptHandler,
    &FSMC_IRQInterruptHandler,
    &SDIO_IRQInterruptHandler,
    &TIM5_IRQInterruptHandler,
    &SPI3_IRQInterruptHandler,
    &UART4_IRQInterruptHandler,
    &UART5_IRQInterruptHandler,
    &TIM6_DAC_IRQInterruptHandler,
    &TIM7_IRQInterruptHandler,
    &DMA2_Stream0_IRQInterruptHandler,
    &DMA2_Stream1_IRQInterruptHandler,
    &DMA2_Stream2_IRQInterruptHandler,
    &DMA2_Stream3_IRQInterruptHandler,
    &DMA2_Stream4_IRQInterruptHandler,
    &ETH_IRQInterruptHandler,
    &ETH_WKUP_IRQInterruptHandler,
    &CAN2_TX_IRQInterruptHandler,
    &CAN2_RX0_IRQInterruptHandler,
    &CAN2_RX1_IRQInterruptHandler,
    &CAN2_SCE_IRQInterruptHandler,
    &OTG_FS_IRQInterruptHandler,
    &DMA2_Stream5_IRQInterruptHandler,
    &DMA2_Stream6_IRQInterruptHandler,
    &DMA2_Stream7_IRQInterruptHandler,
    &USART6_IRQInterruptHandler,
    &I2C3_EV_IRQInterruptHandler,
    &I2C3_ER_IRQInterruptHandler,
    &OTG_HS_EP1_OUT_IRQInterruptHandler,
    &OTG_HS_EP1_IN_IRQInterruptHandler,
    &OTG_HS_WKUP_IRQInterruptHandler,
    &OTG_HS_IRQInterruptHandler,
    &DCMI_IRQInterruptHandler,
    &CRYP_IRQInterruptHandler,
    &HASH_RNG_IRQInterruptHandler,
    &FPU_IRQInterruptHandler];


extern (C) void defaultInterruptHandler()
{
    pragma(LDC_never_inline);
    bkpt();
    while (true) {
        wfi();
    }
}

version(LDC)
{
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

version(LDC)
{
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


/**
 *  bitop
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
