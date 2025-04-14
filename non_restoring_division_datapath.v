`include "mux_2x1.v"
`include "mux_2x1_16bit.v"
`include "register_a.v"
`include "register_q.v"
`include "shift_register_a.v"
`include "shift_register_q.v"
`include "adder.v"
`include "subtractor.v"
`include "counter.v"
`include "comparator.v"
`include "comparator_1bit.v"
`timescale 1ns/1ps


module non_restoring_division_datapath (
    input clk,
    input rst,
    input [15:0] dividend,
    input [15:0] divisor,
    input select_A,
    input select_Q,
    input ld_A,
    input ld_Q,
    input shift_left_enable_a,
    input select_add,
    input shift_left_enable_q,
    input count_enable,
    input ld_rem_quotient,
    output [15:0] quotient,
    output [16:0] remainder,
    output reg status_correctness_check,
    output reg done
);

// Internal signals
wire [16:0] A; // 17 bits to accommodate the sign bit
wire [15:0] Q;
//reg [15:0] M;
wire [16:0] mux_out_1;
wire [16:0] shift_register_out_a;
wire [15:0] shift_register_out_q;
wire [16:0] adder_out;
wire [16:0] subtractor_out;
wire [16:0] mux_out_2;
wire [15:0] mux_out_3;
wire [16:0] mux_out_4;
wire [3:0] count;
wire complete;

//Select the A register or the output of the second mux for the first stage
//.B(2nd mux_output)
mux_2x1 mux1(
    .select(select_A),
    .A(17'b0),
    .B(mux_out_2),
    .out(mux_out_1)
);

//load the A register
register_a A_reg(
    .rst(rst),
    .clk(clk),
    .input_data(mux_out_1),
    .ld_register(ld_A),
    .output_data(A)
);

//load the Q register
register_q Q_reg(
    .rst(rst),
    .clk(clk),
    .input_data(mux_out_3),
    .ld_register(ld_Q),
    .output_data(Q)
);

//shift register for A
shift_register_a shift_A_left(
    .rst(rst),
    .clk(clk),
    .A(A),
    .Q(Q),
    .shift_left_enable_a(shift_left_enable_a),
    .shift_out(shift_register_out_a)
);

mux_2x1 mux4(
    .select(select_add), //Give the proper Value here
    .A(A),
    .B(shift_register_out_a),
    .out(mux_out_4)
);


//Addition
adder adder1(
    .A(mux_out_4),
    .B({1'b0,divisor}),
    .sum(adder_out)
);

//Subtraction
subtractor subtractor1(
    .A(shift_register_out_a),
    .B({1'b0,divisor}),
    .difference(subtractor_out)
);

//Multiplexer for the second stage
mux_2x1 mux2(
    .select(shift_register_out_a[16]), //Give the proper Value here
    .A(adder_out),
    .B(subtractor_out),
    .out(mux_out_2)
);

//Multiplexer for the third stage
mux_2x1_16bit mux3(
    .select(select_Q),
    .A(dividend),
    .B(shift_register_out_q),
    .out(mux_out_3)
);


//shift register for Q
shift_register_q shift_Q_left(
    .rst(rst),
    .clk(clk),
    .shift_left_enable_q(shift_left_enable_q),
    .Q(Q),
    .A(mux_out_2),
    .shift_out(shift_register_out_q)
);

//Counter for the number of iterations
counter incrementer(
    .clk(clk),
    .rst(rst),
    .count_enable(count_enable),
    .count(count)
);

//Comparator to check whether counter has reached 16 iterations
comparator cmp(
    .A(count),
    .B(4'b1111),
    .equal(complete)
);

//Output register for remainder and quotient
register_a remainder_reg(
    .rst(rst),
    .clk(clk),
    .input_data(A),
    .ld_register(ld_rem_quotient),
    .output_data(remainder)
);

//Output register for quotient
register_q quotient_reg(
    .rst(rst),
    .clk(clk),
    .input_data(Q),
    .ld_register(ld_rem_quotient),
    .output_data(quotient)
);

//Comaring A[16] for correctness check
comparator_1bit cmp1(
    .A(shift_register_out_a[16]),
    .B(1'b1),
    .equal(status_correctness_check)
);



    
endmodule