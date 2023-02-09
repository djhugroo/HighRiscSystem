//Register File
//
// The register file has 64 registers that are 16 bits long and two ports; A and B
//	The operations are performed synchronously
// The value of the registers depends on the Address given as an input
// 
module RegisterFile
(
	input Clock,
	input [5:0] AddressA,
	output logic [15:0] ReadDataA,
	input [15:0] WriteData,
	input WriteEnable,
	input [5:0] AddressB,
	output logic [15:0] ReadDataB
);
	logic [15:0] Registers [64]; // Create an array of registers
	
	always_ff @(posedge Clock)
	begin
		if (WriteEnable)
			Registers [AddressA] <= WriteData; //The register at the AddressA is given the value of WriteData when WriteEnable is high
	end
	
	always_comb
	begin
	
	ReadDataA = Registers [AddressA]; // The value of the registers at AddressA is written to the ReadDataA
	ReadDataB = Registers [AddressB]; // The value of the registers at AddressB is written to the ReadDataB
	
	end
endmodule