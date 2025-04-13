`include "non_restoring_division_controlpath.v"
`include "non_restoring_division_datapath.v"
`timescale 1ns / 1ps
module non_restoring_division_topmodule (
    input clk,
    input [15:0] dividend,
    input [15:0] divisor,
    input start,
    input rst,
    output [15:0] quotient,
    output [16:0] remainder,
    output done
);

wire select_A;
wire select_Q;
wire ld_A;
wire ld_Q;
wire shift_left_enable_a;
wire shift_left_enable_q;
wire count_enable;

// Instantiation of Datapath and Controlpath modules

non_restoring_division_datapath datapath (
    .clk(clk),
    .rst(rst),
    .dividend(dividend),
    .divisor(divisor),
    .select_A(select_A),
    .select_Q(select_Q),
    .ld_A(ld_A),
    .ld_Q(ld_Q),
    .shift_left_enable_a(shift_left_enable_a),
    .shift_left_enable_q(shift_left_enable_q),
    .count_enable(count_enable),
    .quotient(quotient),
    .remainder(remainder),
    .done(done)
);

non_restoring_division_control_path controlpath (
    .clk(clk),
    .rst(rst),
    .start(start),
    .done(done),
    .count_enable(count_enable),
    .select_A(select_A),
    .select_Q(select_Q),
    .ld_A(ld_A),
    .ld_Q(ld_Q),
    .shift_left_enable_a(shift_left_enable_a),
    .shift_left_enable_q(shift_left_enable_q)
);


    
endmodule