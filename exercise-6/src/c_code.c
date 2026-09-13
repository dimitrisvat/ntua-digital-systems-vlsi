#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xaxidma.h"
#include "xtime_l.h"

#define TX_DMA_ID                 XPAR_PS2PL_DMA_DEVICE_ID
#define TX_DMA_MM2S_LENGTH_ADDR  (XPAR_PS2PL_DMA_BASEADDR + 0x28)

#define RX_DMA_ID                 XPAR_PL2PS_DMA_DEVICE_ID
#define RX_DMA_S2MM_LENGTH_ADDR  (XPAR_PL2PS_DMA_BASEADDR + 0x58)

#define TX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x08000000)
#define RX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x10000000)

#define DEBAYER_BASEADDR   XPAR_DEBAYARING_0_S00_AXI_BASEADDR
#define REG_IMAGE_DIM      0x0

#define SLCR_UNLOCK_ADDR       0xF8000008
#define SLCR_LOCK_ADDR         0xF8000004
#define SLCR_UNLOCK_KEY        0xDF0D
#define SLCR_LOCK_KEY          0x767B
#define FPGA_RST_CTRL_ADDR     0xF8000240


u8 pixels_in_1024[1024 * 1024] = {
    #include "in_data_N1024.txt"
};

u8 pixels_in_32[32 * 32] = {
    #include "in_data_N32.txt"
};

u8 out_sw[1024 * 1024 * 3];


XAxiDma RxAxiDma, TxAxiDma;


static void accelerator_reset(void)
{
    Xil_Out32(SLCR_UNLOCK_ADDR, SLCR_UNLOCK_KEY);
    u32 cur = Xil_In32(FPGA_RST_CTRL_ADDR);
    Xil_Out32(FPGA_RST_CTRL_ADDR, cur | 0x1);
    usleep(100);
    Xil_Out32(FPGA_RST_CTRL_ADDR, cur & ~0x1);
    Xil_Out32(SLCR_LOCK_ADDR, SLCR_LOCK_KEY);
    usleep(1000);
}


u8 get_pixel(s16 row, s16 col, u16 n, u8 *pixels_in)
{
    return (row < 0 || row > n-1 || col < 0 || col > n-1)
           ? 0
           : pixels_in[row * n + col];
}


void debayer_sw(u16 n, u8 *pixels_in)
{
    u8  rgb_r, rgb_g, rgb_b;
    s32 index = 0;

    for (s16 row = 0; row < n; ++row)
    {
        for (s16 col = 0; col < n; ++col)
        {
            u8 up_left    = get_pixel(row-1, col-1, n, pixels_in);
            u8 up_mid     = get_pixel(row-1, col,   n, pixels_in);
            u8 up_right   = get_pixel(row-1, col+1, n, pixels_in);

            u8 mid_left   = get_pixel(row,   col-1, n, pixels_in);
            u8 mid_mid    = get_pixel(row,   col,   n, pixels_in);
            u8 mid_right  = get_pixel(row,   col+1, n, pixels_in);

            u8 down_left  = get_pixel(row+1, col-1, n, pixels_in);
            u8 down_mid   = get_pixel(row+1, col,   n, pixels_in);
            u8 down_right = get_pixel(row+1, col+1, n, pixels_in);

            if (row % 2 == 1)
            {
                if (col % 2 == 1)
                {
                    rgb_r = (mid_left  + mid_right) >> 1;
                    rgb_g = mid_mid;
                    rgb_b = (up_mid    + down_mid)  >> 1;
                }
                else
                {
                    rgb_r = mid_mid;
                    rgb_g = (up_mid + down_mid + mid_left + mid_right)    >> 2;
                    rgb_b = (up_left + up_right + down_left + down_right) >> 2;
                }
            }
            else
            {
                if (col % 2 == 0)
                {
                    rgb_r = (up_mid   + down_mid)  >> 1;
                    rgb_g = mid_mid;
                    rgb_b = (mid_left + mid_right) >> 1;
                }
                else
                {
                    rgb_r = (up_left + up_right + down_left + down_right) >> 2;
                    rgb_g = (up_mid  + down_mid + mid_left  + mid_right)  >> 2;
                    rgb_b = mid_mid;
                }
            }

            out_sw[index++] = rgb_r;
            out_sw[index++] = rgb_g;
            out_sw[index++] = rgb_b;
        }
    }
}


void run_test(u16 n, u8 *pixels_in, u8 *TxBufferPtr, u32 *RxBufferPtr)
{
    accelerator_reset();  // reset the accelerator before each test

    u32 pkt_len = (u32)n * n;

    XTime preExecCyclesFPGA  = 0, postExecCyclesFPGA = 0;
    XTime preExecCyclesSW    = 0, postExecCyclesSW   = 0;

    int  status;
    int  sent, received;
    u32  errors           = 0;
    u64  error_percentage = 0;
    int  poll_timeout     = 1000000;
    u8   r_hw, g_hw, b_hw;

    xil_printf("\r\n========================================\r\n");
    xil_printf("  Running test for N = %u\r\n", n);
    xil_printf("========================================\r\n");

    for (u32 i = 0; i < pkt_len; ++i)
        TxBufferPtr[i] = pixels_in[i];

    Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, pkt_len);

    xil_printf("Starting FPGA processing...\r\n");
    XTime_GetTime(&preExecCyclesFPGA);

    u32 config_word = (1 << 31) | (n & 0xFFFF);
    Xil_Out32(DEBAYER_BASEADDR + REG_IMAGE_DIM, config_word);
    xil_printf("Image dimension sent: %u\r\n", n);

    status = XAxiDma_SimpleTransfer(&RxAxiDma, (UINTPTR)RxBufferPtr,
                                    pkt_len * 4, XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: RX-DMA transfer failed.\r\n");
        return;
    }

    status = XAxiDma_SimpleTransfer(&TxAxiDma, (UINTPTR)TxBufferPtr,
                                    pkt_len, XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: TX-DMA transfer failed.\r\n");
        return;
    }

    poll_timeout = 1000000;
    while (poll_timeout)
    {
        if (!(XAxiDma_Busy(&TxAxiDma, XAXIDMA_DMA_TO_DEVICE)) &&
            !(XAxiDma_Busy(&RxAxiDma, XAXIDMA_DEVICE_TO_DMA)))
            break;
        poll_timeout--;
        usleep(1U);
    }

    Xil_DCacheInvalidateRange((UINTPTR)RxBufferPtr, pkt_len * 4);
    XTime_GetTime(&postExecCyclesFPGA);

    xil_printf("Begin SW processing...\r\n");
    XTime_GetTime(&preExecCyclesSW);
    debayer_sw(n, pixels_in);
    XTime_GetTime(&postExecCyclesSW);
    xil_printf("SW processing over.\r\n\r\n");

    for (u32 i = 0; i < pkt_len; ++i)
    {
        r_hw = (RxBufferPtr[i] >> 16) & 0xFF;
        g_hw = (RxBufferPtr[i] >>  8) & 0xFF;
        b_hw = (RxBufferPtr[i] >>  0) & 0xFF;

        if (r_hw != out_sw[i*3 + 0] ||
            g_hw != out_sw[i*3 + 1] ||
            b_hw != out_sw[i*3 + 2])
        {
            xil_printf("pixel %lu   expected R=%u G=%u B=%u, got R=%u G=%u B=%u\r\n",
                       i,
                       out_sw[i*3+0], out_sw[i*3+1], out_sw[i*3+2],
                       r_hw, g_hw, b_hw);
            errors++;
        }
    }

    error_percentage = errors ? ((u64)errors * 100ULL) / pkt_len : 0ULL;
    printf("Total errors:              %lu\r\n",   errors);
    printf("Total errors (percentage): %llu%%\r\n", error_percentage);

    XTime exectime_FPGA = postExecCyclesFPGA - preExecCyclesFPGA;
    XTime exectime_SW   = postExecCyclesSW   - preExecCyclesSW;

    printf("FPGA execution time (cycles): %llu\r\n", exectime_FPGA);
    printf("SW   execution time (cycles): %llu\r\n", exectime_SW);
    printf("Speedup (SW / FPGA): %llu\r\n",
           exectime_FPGA ? (exectime_SW / exectime_FPGA) : 0ULL);
}


int main()
{
    print("HELLO 1\r\n");

    XAxiDma_Config *RxCfgPtr, *TxCfgPtr;
    int status;

    init_platform();

    u8  *TxBufferPtr = (u8  *)TX_BUFFER;
    u32 *RxBufferPtr = (u32 *)RX_BUFFER;

    TxCfgPtr = XAxiDma_LookupConfig(TX_DMA_ID);
    if (!TxCfgPtr) { xil_printf("Error: No config found for TX-DMA.\r\n"); return XST_FAILURE; }

    status = XAxiDma_CfgInitialize(&TxAxiDma, TxCfgPtr);
    if (status != XST_SUCCESS) { xil_printf("Error: TX-DMA init failed.\r\n"); return XST_FAILURE; }

    XAxiDma_IntrDisable(&TxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&TxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    RxCfgPtr = XAxiDma_LookupConfig(RX_DMA_ID);
    if (!RxCfgPtr) { xil_printf("Error: No config found for RX-DMA.\r\n"); return XST_FAILURE; }

    status = XAxiDma_CfgInitialize(&RxAxiDma, RxCfgPtr);
    if (status != XST_SUCCESS) { xil_printf("Error: RX-DMA init failed.\r\n"); return XST_FAILURE; }

    XAxiDma_IntrDisable(&RxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&RxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    run_test(  32, pixels_in_32,   TxBufferPtr, RxBufferPtr);
    run_test(1024, pixels_in_1024, TxBufferPtr, RxBufferPtr);


    cleanup_platform();
    return 0;
}
