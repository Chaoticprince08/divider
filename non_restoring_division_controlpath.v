`timescale 1ns/1ps
module non_restoring_division_control_path (
    input clk,
    input rst,
    input start,
    input done,
    output reg count_enable,
    output reg select_A,
    output reg select_Q,
    output reg ld_A,
    output reg ld_Q,
    output reg shift_left_enable_a,
    output reg shift_left_enable_q
    
);

//FSM states using parameters
parameter [2:0] idle = 3'b000;
parameter [2:0] load = 3'b001;
parameter [2:0] load_wait = 3'b010;
parameter [2:0] shift_a = 3'b011;
parameter [2:0] wait_a = 3'b100;
parameter [2:0] shift_q = 3'b101;
parameter [2:0] wait_q = 3'b110;
parameter [2:0] correctnes_check = 3'b111;

reg  [2:0] present_state, next_state; // 3-bit state register

//State Updation Logic
always @(posedge(clk) or posedge(rst)) begin
    if(rst) begin
        present_state <= idle; // Reset to idle state
    end 
    else begin
        present_state <= next_state; // Update state on clock edge
    end
end

//Next State Logic
always @(present_state or start) begin
    case (present_state)
        idle: begin
            if (start) begin
                next_state = load; // Transition to load state on start signal
            end 
            else begin
                next_state = idle; // Stay in idle state otherwise
            end
        end
        
        load: begin
            next_state = shift_a; // Transition to shift_a state after loading
        end
        
        shift_a: begin
            next_state = wait_a; // Transition to wait_a state after shifting A
        end
        
        wait_a: begin
            next_state = shift_q; // Transition to shift_q state after waiting for A
        end
        
        shift_q: begin
            next_state = wait_q; // Transition to wait_q state after shifting Q
        end
        
        wait_q: begin
            if (done) begin
                next_state = correctnes_check; // Transition back to idle state when done signal is high
            end 
            else begin
                next_state = wait_a; // Stay in wait_q state otherwise
            end
        end
        
        default: begin
            next_state = idle; // Default case to avoid latches, go back to idle state
        end
        
    endcase
end

//Control Outputs based on the states
always @(present_state) begin
    case (present_state)
        idle: begin
            count_enable = 1'b0; // Disable counter in idle state
            select_A = 1'b0; // Select A register in idle state
            select_Q = 1'b0; // Select Q register in idle state
            ld_A = 1'b0; // Load A register in idle state
            ld_Q = 1'b0; // Load Q register in idle state
            shift_left_enable_a = 1'b0; // Disable left shift for A in idle state
            shift_left_enable_q = 1'b0; // Disable left shift for Q in idle state
        end
        
        load: begin
            count_enable = 1'b0; // Disable counter during load state
            select_A = 1'b1; // Select A register during load state
            select_Q = 1'b1; // Select Q register during load state
            ld_A = 1'b1; // Load A register during load state
            ld_Q = 1'b1; // Load Q register during load state
            shift_left_enable_a = 1'b0; // Disable left shift for A during load state
            shift_left_enable_q = 1'b0; // Disable left shift for Q during load state
        end
        wait_a: begin
            count_enable = 1'b0; // Disable counter during wait_a state
            select_A = 1'b0; // Select A register during wait_a state
            select_Q = 1'b0; // Select Q register during wait_a state
            ld_A = 1'b0; // Load A register during wait_a state
            ld_Q = 1'b0; // Load Q register during wait_a state
            shift_left_enable_a = 1'b0; // Disable left shift for A during wait_a state
            shift_left_enable_q = 1'b0; // Disable left shift for Q during wait_a state
        end
        
        shift_a: begin
            count_enable = 1'b0; // Disable counter during shift_a state
            select_A = 1'b0; // Select A register during shift_a state
            select_Q = 1'b0; // Select Q register during shift_a state
            ld_A = 1'b0; // Load A register during shift_a state
            ld_Q = 1'b0; // Load Q register during shift_a state
            shift_left_enable_a = 1'b1; // Enable left shift for A during shift_a state
            shift_left_enable_q = 1'b0; // Disable left shift for Q during shift_a state
        end
        
        wait_a: begin
            count_enable = 1'b0; // Disable counter during wait_a state
            select_A = 1'b0; // Select A register during wait_a state
            select_Q = 1'b0; // Select Q register during wait_a state
            ld_A = 1'b0; // Load A register during wait_a state
            ld_Q = 1'b0;
            shift_left_enable_a = 1'b0; // Disable left shift for A during wait_a state
            shift_left_enable_q = 1'b0; // Disable left shift for Q during wait_a state
        end
        shift_q: begin
            count_enable = 1'b0; // Disable counter during shift_q state
            select_A = 1'b0; // Select A register during shift_q state
            select_Q = 1'b0; // Select Q register during shift_q state
            ld_A = 1'b0; // Load A register during shift_q state
            ld_Q = 1'b0; // Load Q register during shift_q state
            shift_left_enable_a = 1'b0; // Disable left shift for A during shift_q state
            shift_left_enable_q = 1'b1; // Enable left shift for Q during shift_q state
        end
        wait_q: begin
            count_enable = 1'b1; // Disable counter during wait_q state
            select_A = 1'b0; // Select A register during wait_q state
            select_Q = 1'b0; // Select Q register during wait_q state
            ld_A = 1'b1; // Load A register during wait_q state
            ld_Q = 1'b1; // Load Q register during wait_q state
            shift_left_enable_a = 1'b0; // Disable left shift for A during wait_q state
            shift_left_enable_q = 1'b0; // Disable left shift for Q during wait_q state
        end
        default : begin
            count_enable = 1'b0; // Disable counter in default state
            select_A = 1'b0; // Select A register in default state
            select_Q = 1'b0; // Select Q register in default state
            ld_A = 1'b0; // Load A register in default state
            ld_Q = 1'b0; // Load Q register in default state
            shift_left_enable_a = 1'b0; // Disable left shift for A in default state
            shift_left_enable_q = 1'b0; // Disable left shift for Q in default state
        end
    endcase
end

endmodule