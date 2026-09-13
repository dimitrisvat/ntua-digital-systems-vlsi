#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xparameters_ps.h"
#include "xaxidma.h"
#include "xtime_l.h"

#define TX_DMA_ID                 XPAR_PS2PL_DMA_DEVICE_ID
#define TX_DMA_MM2S_LENGTH_ADDR  (XPAR_PS2PL_DMA_BASEADDR + 0x28) // Reports actual number of bytes transferred from PS->PL (use Xil_In32 for report)

#define RX_DMA_ID                 XPAR_PL2PS_DMA_DEVICE_ID
#define RX_DMA_S2MM_LENGTH_ADDR  (XPAR_PL2PS_DMA_BASEADDR + 0x58) // Reports actual number of bytes transferred from PL->PS (use Xil_In32 for report)

#define TX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x08000000) // 0 + 128MByte
#define RX_BUFFER (XPAR_DDR_MEM_BASEADDR + 0x10000000) // 0 + 256MByte

#define N           1024
#define MAX_PKT_LEN (N * N)

/* ------------------------------------------------------------------ */
/* Input image & SW output buffers                                     */
/* ------------------------------------------------------------------ */
u8 pixels_in[N * N] = {
    #include "in_data_N1024.txt"
};

u8 out_sw[N * N * 3]; // N*N pixels * 3 colour channels (R, G, B)

/* ------------------------------------------------------------------ */
/* DMA instances                                                       */
/* ------------------------------------------------------------------ */
XAxiDma RxAxiDma, TxAxiDma;

/* ------------------------------------------------------------------ */
/* Helper: boundary-safe pixel access                                  */
/* ------------------------------------------------------------------ */
u8 get_pixel(s16 row, s16 col)
{
    return (row < 0 || row > N-1 || col < 0 || col > N-1)
           ? 0
           : pixels_in[row * N + col];
}

/* ------------------------------------------------------------------ */
/* Software debayering reference implementation                        */
/* ------------------------------------------------------------------ */
void debayer_sw(void)
{
    u8  rgb_r, rgb_g, rgb_b;
    s32 index = 0;

    for (s16 row = 0; row < N; ++row)
    {
        for (s16 col = 0; col < N; ++col)
        {
            // Fetch 3x3 neighbourhood
            u8 up_left   = get_pixel(row-1, col-1);
            u8 up_mid    = get_pixel(row-1, col);
            u8 up_right  = get_pixel(row-1, col+1);

            u8 mid_left  = get_pixel(row,   col-1);
            u8 mid_mid   = get_pixel(row,   col);
            u8 mid_right = get_pixel(row,   col+1);

            u8 down_left  = get_pixel(row+1, col-1);
            u8 down_mid   = get_pixel(row+1, col);
            u8 down_right = get_pixel(row+1, col+1);

            if (row % 2 == 1)
            {
                // Green pixel (case i)
                if (col % 2 == 1)
                {
                    rgb_r = (mid_left  + mid_right) >> 1;
                    rgb_g = mid_mid;
                    rgb_b = (up_mid    + down_mid)  >> 1;
                }
                // Red pixel
                else
                {
                    rgb_r = mid_mid;
                    rgb_g = (up_mid + down_mid + mid_left + mid_right)           >> 2;
                    rgb_b = (up_left + up_right + down_left + down_right)        >> 2;
                }
            }
            else
            {
                // Green pixel (case ii)
                if (col % 2 == 0)
                {
                    rgb_r = (up_mid   + down_mid)  >> 1;
                    rgb_g = mid_mid;
                    rgb_b = (mid_left + mid_right) >> 1;
                }
                // Blue pixel
                else
                {
                    rgb_r = (up_left + up_right + down_left + down_right)        >> 2;
                    rgb_g = (up_mid  + down_mid + mid_left  + mid_right)         >> 2;
                    rgb_b = mid_mid;
                }
            }

            out_sw[index++] = rgb_r;
            out_sw[index++] = rgb_g;
            out_sw[index++] = rgb_b;
        }
    }
}

/* ------------------------------------------------------------------ */
/* Main                                                                */
/* ------------------------------------------------------------------ */
int main()
{
//    Xil_DCacheDisable();

    XTime preExecCyclesFPGA  = 0;
    XTime postExecCyclesFPGA = 0;
    XTime preExecCyclesSW    = 0;
    XTime postExecCyclesSW   = 0;

    print("HELLO 1\r\n");

    // User application local variables
    XAxiDma_Config *RxCfgPtr, *TxCfgPtr;
    int   status;
    int   sent, received;
    u32   errors           = 0;
    u64   error_percentage = 0;
    int   poll_timeout     = 1000000;
    u8    r_hw, g_hw, b_hw;

    init_platform();

    /* -------------------------------------------------------------- */
    /* Step 1: Initialize TX-DMA Device (PS->PL)                      */
    /* -------------------------------------------------------------- */
    u8 *TxBufferPtr = (u8 *)TX_BUFFER;

    TxCfgPtr = XAxiDma_LookupConfig(TX_DMA_ID);
    if (!TxCfgPtr)
    {
        xil_printf("Error: No config found for TX-DMA device.\r\n");
        return XST_FAILURE;
    }

    status = XAxiDma_CfgInitialize(&TxAxiDma, TxCfgPtr);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: TX-DMA initialization failed. Status: %d\r\n", status);
        return XST_FAILURE;
    }

    // Disable interrupts � polling mode
    XAxiDma_IntrDisable(&TxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&TxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    /* -------------------------------------------------------------- */
    /* Step 2: Initialize RX-DMA Device (PL->PS)                      */
    /* -------------------------------------------------------------- */
    u32 *RxBufferPtr = (u32 *)RX_BUFFER;

    RxCfgPtr = XAxiDma_LookupConfig(RX_DMA_ID);
    if (!RxCfgPtr)
    {
        xil_printf("Error: No config found for RX-DMA device.\r\n");
        return XST_FAILURE;
    }

    status = XAxiDma_CfgInitialize(&RxAxiDma, RxCfgPtr);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: RX-DMA initialization failed. Status: %d\r\n", status);
        return XST_FAILURE;
    }

    // Disable interrupts � polling mode
    XAxiDma_IntrDisable(&RxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&RxAxiDma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);

    /* -------------------------------------------------------------- */
    /* Fill TX buffer with raw Bayer pixels and flush D-cache          */
    /* -------------------------------------------------------------- */
    for (u32 i = 0; i < MAX_PKT_LEN; ++i)
        TxBufferPtr[i] = pixels_in[i];

    Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);

    /* -------------------------------------------------------------- */
    /* Step 3: Perform FPGA processing                                 */
    /* -------------------------------------------------------------- */
    xil_printf("Starting FPGA processing...\r\n");
    XTime_GetTime(&preExecCyclesFPGA);

    /* 3a: Setup RX-DMA transaction (PL->PS)
           Each pixel comes back as a 32-bit word (00 | R | G | B),
           so we request MAX_PKT_LEN * 4 bytes.                       */
    status = XAxiDma_SimpleTransfer(&RxAxiDma, (UINTPTR)RxBufferPtr,
                                    MAX_PKT_LEN * 4, XAXIDMA_DEVICE_TO_DMA);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: RX-DMA transfer failed.\r\n");
        return XST_FAILURE;
    }

    /* 3b: Setup TX-DMA transaction (PS->PL) */
    status = XAxiDma_SimpleTransfer(&TxAxiDma, (UINTPTR)TxBufferPtr,
                                    MAX_PKT_LEN, XAXIDMA_DMA_TO_DEVICE);
    if (status != XST_SUCCESS)
    {
        xil_printf("Error: TX-DMA transfer failed.\r\n");
        return XST_FAILURE;
    }

    /* 3c: Wait for TX-DMA & RX-DMA to finish */
    while (poll_timeout)
    {
        if (!(XAxiDma_Busy(&TxAxiDma, XAXIDMA_DMA_TO_DEVICE)) &&
            !(XAxiDma_Busy(&RxAxiDma, XAXIDMA_DEVICE_TO_DMA)))
            break;
        poll_timeout--;
        usleep(1U);
    }

    // Invalidate D-cache so we see the DMA-written data
    Xil_DCacheInvalidateRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN * 4);

    XTime_GetTime(&postExecCyclesFPGA);

    // Report bytes actually transferred
    sent     = Xil_In32(TX_DMA_MM2S_LENGTH_ADDR);
    received = Xil_In32(RX_DMA_S2MM_LENGTH_ADDR);
    xil_printf("FPGA processing over. Sent: %d, Received: %d\r\n\r\n", sent, received);

    /* -------------------------------------------------------------- */
    /* Step 5: Perform SW processing                                   */
    /* -------------------------------------------------------------- */
    xil_printf("Begin SW processing...\r\n");
    XTime_GetTime(&preExecCyclesSW);
    debayer_sw();
    XTime_GetTime(&postExecCyclesSW);
    xil_printf("SW processing over.\r\n\r\n");

    /* -------------------------------------------------------------- */
    /* Step 6: Compare FPGA and SW results                             */
    /* -------------------------------------------------------------- */

    /* Hardware packs results as: bits[31:24]=0x00, [23:16]=R, [15:8]=G, [7:0]=B
       matching the VHDL:  rgb_data <= "00000000" & R & G & B           */
    for (u32 i = 0; i < N * N; ++i)
    {
        r_hw = (RxBufferPtr[i] >> 16) & 0xFF;
        g_hw = (RxBufferPtr[i] >>  8) & 0xFF;
        b_hw = (RxBufferPtr[i] >>  0) & 0xFF;

        if (r_hw != out_sw[i*3 + 0] ||
            g_hw != out_sw[i*3 + 1] ||
            b_hw != out_sw[i*3 + 2])
        {
            xil_printf("pixel %lu � expected R=%u G=%u B=%u, got R=%u G=%u B=%u\r\n",
                       i,
                       out_sw[i*3+0], out_sw[i*3+1], out_sw[i*3+2],
                       r_hw, g_hw, b_hw);
            errors++;
        }
    }

    /* 6a: Report total percentage error */
    error_percentage = errors ? ((u64)errors * 100ULL) / (N * N) : 0ULL;
    printf("Total errors:              %lu\r\n",   errors);
    printf("Total errors (percentage): %llu%%\r\n", error_percentage);

    /* 6b & 6c: Report execution times in cycles */
    XTime exectime_FPGA = postExecCyclesFPGA - preExecCyclesFPGA;
    XTime exectime_SW   = postExecCyclesSW   - preExecCyclesSW;

    printf("FPGA execution time (cycles): %llu\r\n", exectime_FPGA);
    printf("SW   execution time (cycles): %llu\r\n", exectime_SW);

    /* 6d: Report speedup */
    printf("Speedup (SW / FPGA): %llu\r\n",
           exectime_FPGA ? (exectime_SW / exectime_FPGA) : 0ULL);

    cleanup_platform();
    return 0;
}
