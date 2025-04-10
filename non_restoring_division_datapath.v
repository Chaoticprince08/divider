
`include "mux_2x1.v"
`include "register_a.v"
`include "register_q.v"
`include "shift_register.v"
`include "adder.v"
`include "subtractor.v"
`include "counter.v"
`include "comparator.v"
`timescale 1ns/1ps


module non_restoring_division_datapath (
    input clk,
    input rst,
    input [15:0] dividend,
    input [15:0] divisor,
    input select_A,
    input ld_A,
    input ld_Q,
    input shift_left_enable,
    input count_enable,
    output reg [15:0] quotient,
    output reg [15:0] remainder,
    output reg done
);

// Internal signals
wire [16:0] A; // 17 bits to accommodate the sign bit
wire [15:0] Q;
//reg [15:0] M;
wire [16:0] mux_out_1;
wire [16:0] shift_register_out;
wire [16:0] adder_out;
wire [16:0] subtractor_out;
wire [16:0] mux_out_2;
wire [3:0] count;
wire complete;

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
    .input_data(dividend),
    .ld_register(ld_Q),
    .output_data(Q)
);

//shift register
shift_register shift_A_left(
    .rst(rst),
    .clk(clk),
    .A(A),
    .dividend(Q),
    .shift_left_enable(shift_left_enable),
    .shift_out(shift_register_out)
);

//Addition
adder adder1(
    .A(shift_register_out),
    .B({1'b0,divisor}),
    .sum(adder_out)
);

//Subtraction
subtractor aubtractor1(
    .A(shift_register_out),
    .B({1'b0,divisor}),
    .difference(subtractor_out)
);

//Multiplexer for the second stage
mux_2x1 mux2(
    .select(A[16]),
    .A(adder_out),
    .B(subtractor_out),
    .out(mux_out_2)
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



    
endmodule