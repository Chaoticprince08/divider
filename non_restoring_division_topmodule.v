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
wire select_add;
wire shift_left_enable_q;
wire count_enable;
wire ld_rem_quotient;
wire status_correctness_check;

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
    .select_add(select_add),
    .shift_left_enable_q(shift_left_enable_q),
    .count_enable(count_enable),
    .ld_rem_quotient(ld_rem_quotient),
    .status_correctness_check(status_correctness_check),
    .quotient(quotient),
    .remainder(remainder),
    .done(done)
);

non_restoring_division_control_path controlpath (
    .clk(clk),
    .rst(rst),
    .start(start),
    .status_correctness_check(status_correctness_check),
    .done(done),
    .count_enable(count_enable),
    .select_A(select_A),
    .select_Q(select_Q),
    .ld_A(ld_A),
    .ld_Q(ld_Q),
    .select_add(select_add),
    .shift_left_enable_a(shift_left_enable_a),
    .shift_left_enable_q(shift_left_enable_q),
    .ld_rem_quotient(ld_rem_quotient)
);


    
endmodule