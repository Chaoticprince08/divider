module mux_2x1 (
    input select,
    input [16:0] A,
    input [16:0] B,
    output reg [16:0] out
);

    always @(select or A or B) begin
        if (select) begin
            out = A; // Select input A
        end else begin
            out = B; // Select input B
        end
    end
    
endmodule