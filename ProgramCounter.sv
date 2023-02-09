// Program Counter
//
// The CounterValue increment by 1 every clock cycle when no condition is true
//
module ProgramCounter
(
	input Clock, Reset,
	input [15:0] LoadValue,
	input LoadEnable,
	input signed [8:0] Offset,
	input OffsetEnable,
	output logic signed [15:0]CounterValue
);
	logic [15:0] nextCounterValue; // Create a 16 bit variable nextCounterValue to update CounterValue
	
	always_ff @(posedge Clock)
	begin
		CounterValue <= nextCounterValue; // Update CounterValue with nextCounterValue on positive edge of the clock
	end
	
	always_comb
	begin
		if (Reset)
			nextCounterValue = '0; // set nextCounterValue to 0 when Reset is High
			
			else if (LoadEnable)
				nextCounterValue = LoadValue; // Set nextCounterValue to LoadValue when LoadEnable is High
				
				else if (OffsetEnable)
					nextCounterValue = CounterValue + Offset; // Add offset to CounterValue and set it to nextCounterValue when Offset Enable is High
					
					else
						nextCounterValue = CounterValue + 1; // Increment CounterValue and set it to nextCounterValue
	end
endmodule