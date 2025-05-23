#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

static char *code[] = {
 "module sid_buffer #( "
,"    parameter NUM = 3 // 参数化写缓冲区接口个数 "
,")( "
,"    input            clk          , "
,"    input            rstn         , "
," "
,"    // 写缓冲区接口 "
,"    input [12-1:0]   s_axid      [NUM-1:0], // 输入AXI ID "
,"    input            s_axid_vld  [NUM-1:0], // 输入AXI ID有效信号 "
,"    input            s_fifo_rdy  [NUM-1:0], // FIFO就绪信号 "
,"    output           s_push_rdy  [NUM-1:0], // 允许写入信号 "
," "
,"    // 清理缓冲区和调整位置接口 "
,"    input            last        [NUM-1:0], // 清理信号 "
,"    input [12-1:0]   sid         [NUM-1:0], // 输入SID "
,"    input            sid_vld     [NUM-1:0], // 输入SID有效信号 "
,"    output           sid_clr_rdy [NUM-1:0], // 允许清理信号 "
," "
,"    output reg [12-1:0] sid_buffer  [0:3]      // SID缓冲区 "
,"); "
," "
,"reg  [NUM-1:0] push_select; "
,"wire [NUM-1:0] push_grant; "
,"wire           full; "
," "
,"wire [NUM-1:0] clr_select; "
,"wire [NUM-1:0] clr_grant; "
,"wire [3:0]     clr_idx; "
,"wire           clr_rdy; "
," "
,"// 写缓冲区逻辑 "
,"integer i; "
,"always @(*) begin "
,"    if (!rstn) begin "
,"        push_select = 'd0; "
,"    end else begin "
,"        for (i = 0; i < NUM; i = i + 1) begin "
,"            push_select[i] = s_axid_vld[i] & s_fifo_rdy[i]; "
,"        end "
,"    end "
,"end "
," "
,"assign push_grant = priority_sel(push_select); "
," "
,"assign clr_rdy = (~|clr_grant) && (~full); "
," "
,"generate "
,"    for (i = 0; i < NUM; i = i + 1) begin : push_ready_gen "
,"        assign s_push_rdy[i] = ~(push_select[i] ^ push_grant[i]) && clr_rdy; "
,"    end "
,"endgenerate "
," "
,"always @(posedge clk) begin "
,"    if (!rstn) begin "
,"        sid_buffer[0] <= 1'b0; "
,"        sid_buffer[1] <= 1'b0; "
,"        sid_buffer[2] <= 1'b0; "
,"        sid_buffer[3] <= 1'b0; "
,"    end else begin "
,"        for (i = 0; i < NUM; i = i + 1) begin "
,"            if (push_grant[i] && s_push_rdy[i]) begin "
,"                if (sid_buffer[0] == 1'b0) begin "
,"                    sid_buffer[0] <= s_axid[i]; "
,"                end else if (sid_buffer[1] == 1'b0) begin "
,"                    sid_buffer[1] <= s_axid[i]; "
,"                end else if (sid_buffer[2] == 1'b0) begin "
,"                    sid_buffer[2] <= s_axid[i]; "
,"                end else if (sid_buffer[3] == 1'b0) begin "
,"                    sid_buffer[3] <= s_axid[i]; "
,"                end "
,"            end "
,"        end "
,"    end "
,"end "
," "
,"assign full = (sid_buffer[3] == 1'b0) ? 0 : 1; "
," "
,"// 清理缓冲区和调整位置逻辑 "
,"generate "
,"    for (i = 0; i < NUM; i = i + 1) begin : clr_select_gen "
,"        assign clr_select[i] = last[i] & sid_vld[i]; "
,"    end "
,"endgenerate "
," "
,"assign clr_grant = priority_sel(clr_select); "
," "
,"generate "
,"    for (i = 0; i < NUM; i = i + 1) begin : clr_ready_gen "
,"        assign sid_clr_rdy[i] = ~(clr_select[i] ^ clr_grant[i]); "
,"    end "
,"endgenerate "
," "
,"generate "
,"    for (i = 0; i < 4; i = i + 1) begin : idx_loop "
,"        assign clr_idx[i] = (clr_grant[0] && (sid[0] == sid_buffer[i])) ? 1'b1 : "
,"                            (clr_grant[1] && (sid[1] == sid_buffer[i])) ? 1'b1 : "
,"                            (clr_grant[2] && (sid[2] == sid_buffer[i])) ? 1'b1 : "
,"                            (clr_grant[NUM-1] && (sid[NUM-1] == sid_buffer[i])) ? 1'b1 : 1'b0; "
,"    end "
,"endgenerate "
," "
,"always @(posedge clk) begin "
,"    if (clr_idx[0]) begin "
,"        sid_buffer[0] <= sid_buffer[1]; "
,"        sid_buffer[1] <= sid_buffer[2]; "
,"        sid_buffer[2] <= sid_buffer[3]; "
,"        sid_buffer[3] <= 1'b0; "
,"    end else if (clr_idx[1]) begin "
,"        sid_buffer[1] <= sid_buffer[2]; "
,"        sid_buffer[2] <= sid_buffer[3]; "
,"        sid_buffer[3] <= 1'b0; "
,"    end else if (clr_idx[2]) begin "
,"        sid_buffer[2] <= sid_buffer[3]; "
,"        sid_buffer[3] <= 1'b0; "
,"    end else if (clr_idx[3]) begin "
,"        sid_buffer[3] <= 1'b0; "
,"    end "
,"end "
," "
,"// 优先级选择函数 "
,"function [NUM-1:0] priority_sel; "
,"    input [NUM-1:0] request; "
,"    integer j; "
,"    begin "
,"        priority_sel = 'd0; "
,"        for (j = NUM-1; j >= 0; j = j - 1) begin "
,"            if (request[j]) begin "
,"                priority_sel = (1 << j); "
,"                break; "
,"            end "
,"        end "
,"    end "
,"endfunction "
," "
,"endmodule "
, NULL
};

int gen_sid_buffer( char* prefix, FILE* fo )
{
    int i=0;

    if (prefix==NULL) return 1;

    while (code[i] != NULL) {
         fprintf(fo, "%s\n", code[i]);
         i++;
    }
fprintf(fo, "\n");
    return 0;
}
