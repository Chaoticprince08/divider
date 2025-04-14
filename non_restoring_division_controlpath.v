`timescale 1ns/1ps
module non_restoring_division_control_path (
    input clk,
    input rst,
    input start,
    input status_correctness_check,
    input done,
    output reg count_enable,
    output reg select_A,
    output reg select_Q,
    output reg ld_A,
    output reg ld_Q,
    output reg select_add,
    output reg shift_left_enable_a,
    output reg shift_left_enable_q,
    output reg ld_rem_quotient
    
);

//FSM states using parameters
parameter [3:0] idle = 4'b0000;
parameter [3:0] load = 4'b0001;
parameter [3:0] load_wait = 4'b0010;
parameter [3:0] shift_a = 4'b0011;
parameter [3:0] wait_a = 4'b0100;
parameter [3:0] add_sub_wait = 4'b0101;
parameter [3:0] shift_q = 4'b0110;
parameter [3:0] wait_q = 4'b0111;
parameter [3:0] correctness_check = 4'b1000;
parameter [3:0] correct_add_state = 4'b1001;
parameter [3:0] correct_add_wait_state = 4'b1010;
parameter [3:0] display = 4'b1011;

reg  [3:0] present_state, next_state; // 3-bit state register

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
            next_state = load_wait; // Transition to shift_a state after loading
        end
        load_wait: begin
            next_state = shift_a; // Transition to shift_a state after loading
        end
        
        shift_a: begin
            next_state = wait_a; // Transition to wait_a state after shifting A
        end
        wait_a: begin
            next_state = add_sub_wait; // Transition to add_sub_wait state after waiting for A
        end
        
        add_sub_wait: begin
            next_state = shift_q; // Transition to shift_q state after waiting for A
        end
        
        shift_q: begin
            next_state = wait_q; // Transition to wait_q state after shifting Q
        end
        
        wait_q: begin
            if (done) begin
                next_state = correctness_check; // Transition back to idle state when done signal is high
            end 
            else begin
                next_state = load_wait; // Move to load wait state
            end
        end
        correctness_check: begin
            if(status_correctness_check == 1'b1) begin
                next_state = correct_add_state; // Transition to idle state if correctness check is successful
            end 
            else begin
                next_state = display; // Stay in correctness check state if not successful
            end
        end
        correct_add_state: begin
            next_state = display; // Transition to wait state
        end
    
        display: begin
            next_state = idle; // Transition to idle state after displaying result
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
            select_add = 1'b0; 
            shift_left_enable_q = 1'b0; // Disable left shift for Q in idle state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient in idle state
        end
        
        load: begin
            count_enable = 1'b0; // Disable counter during load state
            select_A = 1'b1; // Select A register during load state
            select_Q = 1'b1; // Select Q register during load state
            ld_A = 1'b1; // Load A register during load state
            ld_Q = 1'b1; // Load Q register during load state
            shift_left_enable_a = 1'b0; // Disable left shift for A during load state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during load state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during load state
        end

        load_wait: begin
            count_enable = 1'b0; // Disable counter during load_wait state
            select_A = 1'b0; // Select A register during load_wait state
            select_Q = 1'b0; // Select Q register during load_wait state
            ld_A = 1'b0; // Load A register during load_wait state
            ld_Q = 1'b0; // Load Q register during load_wait state
            shift_left_enable_a = 1'b0; // Disable left shift for A during load_wait state
            select_add = 1'b0; 
            shift_left_enable_q = 1'b0; // Disable left shift for Q during load_wait state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during load_wait state
        end

        
        shift_a: begin
            count_enable = 1'b0; // Disable counter during shift_a state
            select_A = 1'b0; // Select A register during shift_a state
            select_Q = 1'b0; // Select Q register during shift_a state
            ld_A = 1'b0; // Load A register during shift_a state
            ld_Q = 1'b0; // Load Q register during shift_a state
            shift_left_enable_a = 1'b1; // Enable left shift for A during shift_a state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during shift_a state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during shift_a state
        end

        wait_a: begin
            count_enable = 1'b0; // Disable counter during wait_a state
            select_A = 1'b0; // Select A register during wait_a state
            select_Q = 1'b0; // Select Q register during wait_a state
            ld_A = 1'b0; // Load A register during wait_a state
            ld_Q = 1'b0; // Load Q register during wait_a state
            shift_left_enable_a = 1'b0; // Disable left shift for A during wait_a state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during wait_a state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during wait_a state
        end

        add_sub_wait : begin
            count_enable = 1'b0; // Disable counter during add_sub_wait state
            select_A = 1'b0; // Select A register during add_sub_wait state
            select_Q = 1'b0; // Select Q register during add_sub_wait state
            ld_A = 1'b0; // Load A register during add_sub_wait state
            ld_Q = 1'b0; // Load Q register during add_sub_wait state
            shift_left_enable_a = 1'b0; // Disable left shift for A during add_sub_wait state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during add_sub_wait state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during add_sub_wait state
        end
        
        shift_q: begin
            count_enable = 1'b0; // Disable counter during shift_q state
            select_A = 1'b0; // Select A register during shift_q state
            select_Q = 1'b0; // Select Q register during shift_q state
            ld_A = 1'b0; // Load A register during shift_q state
            ld_Q = 1'b0; // Load Q register during shift_q state
            shift_left_enable_a = 1'b0; // Disable left shift for A during shift_q state
            select_add = 1'b0;
            shift_left_enable_q = 1'b1; // Enable left shift for Q during shift_q state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during shift_q state
        end
        wait_q: begin
            count_enable = 1'b1; // Disable counter during wait_q state
            select_A = 1'b0; // Select A register during wait_q state
            select_Q = 1'b0; // Select Q register during wait_q state
            ld_A = 1'b1; // Load A register during wait_q state
            ld_Q = 1'b1; // Load Q register during wait_q state
            shift_left_enable_a = 1'b0; // Disable left shift for A during wait_q state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during wait_q state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during wait_q state
        end
        correctness_check: begin
            count_enable = 1'b0; // Disable counter during correctness_check state
            select_A = 1'b1; // Select A register during correctness_check state
            select_Q = 1'b0; // Select Q register during correctness_check state
            ld_A = 1'b0; // Load A register during correctness_check state
            ld_Q = 1'b0; // Load Q register during correctness_check state
            shift_left_enable_a = 1'b0; // Disable left shift for A during correctness_check state
            select_add = 1'b1;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during correctness_check state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during correctness_check state
        end
        correct_add_state: begin
           count_enable = 1'b0; // Disable counter during correctness_check state
            select_A = 1'b1; // Select A register during correctness_check state
            select_Q = 1'b0; // Select Q register during correctness_check state
            ld_A = 1'b1; // Load A register during correctness_check state
            ld_Q = 1'b0; // Load Q register during correctness_check state
            shift_left_enable_a = 1'b0; // Disable left shift for A during correctness_check state
            select_add = 1'b1;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during correctness_check state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient during correctness_check state
        end
        display: begin 
            count_enable = 1'b0; // Disable counter during correctness_check state
            select_A = 1'b0; // Select A register during correctness_check state
            select_Q = 1'b0; // Select Q register during correctness_check state
            ld_A = 1'b0; // Load A register during correctness_check state
            ld_Q = 1'b0; // Load Q register during correctness_check state
            shift_left_enable_a = 1'b0; // Disable left shift for A during correctness_check state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q during correctness_check state
            ld_rem_quotient = 1'b1; // Disable loading of remainder and quotient during correctness_check state       
        end

        default : begin
            count_enable = 1'b0; // Disable counter in default state
            select_A = 1'b0; // Select A register in default state
            select_Q = 1'b0; // Select Q register in default state
            ld_A = 1'b0; // Load A register in default state
            ld_Q = 1'b0; // Load Q register in default state
            shift_left_enable_a = 1'b0; // Disable left shift for A in default state
            select_add = 1'b0;
            shift_left_enable_q = 1'b0; // Disable left shift for Q in default state
            ld_rem_quotient = 1'b0; // Disable loading of remainder and quotient in default state
        end
    endcase
end

endmodule