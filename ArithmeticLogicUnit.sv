// ArithmeticLogicUnit
// This is a basic implementation of the essential operations needed
// in the ALU. Adding futher instructions to this file will increase 
// your marks.

// Load information about the instruction set. 
import InstructionSetPkg::*;

// Define the connections into and out of the ALU.
module ArithmeticLogicUnit
(
	// The Operation variable is an example of an enumerated type and
	// is defined in InstructionSetPkg.
	input eOperation Operation,
	
	// The InFlags and OutFlags variables are examples of structures
	// which have been defined in InstructionSetPkg. They group together
	// all the single bit flags described by the Instruction set.
	input  sFlags    InFlags,
	output sFlags    OutFlags,
	
	// All the input and output busses have widths determined by the 
	// parameters defined in InstructionSetPkg.
	input  signed [ImmediateWidth-1:0] InImm,
	
	// InSrc and InDest are the values in the source and destination
	// registers at the start of the instruction.
	input  signed [DataWidth-1:0] InSrc,
	input  signed [DataWidth-1:0]	InDest,
	
	// OutDest is the result of the ALU operation that is written 
	// into the destination register at the end of the operation.
	output logic signed [DataWidth-1:0] OutDest
);

	// This block allows each OpCode to be defined. Any opcode not
	// defined outputs a zero. The names of the operation are defined 
	// in the InstructionSetPkg. 
	always_comb
	begin
	
		// By default the flags are unchanged. Individual operations
		// can override this to change any relevant flags.
		OutFlags  = InFlags;
		
		// The basic implementation of the ALU only has the NAND and
		// ROL operations as examples of how to set ALU outputs 
		// based on the operation and the register / flag inputs.
		case(Operation)	
	
	
		   //Sets register Dest to the contents of register Src having
         //first shifted the value left by 1 bit and sets the least
         //significant bit of Dest to the value in the C flag.
         //Following this operation, the C flag contains the most
         //significant bit of SRC.
			ROL:     {OutFlags.Carry,OutDest} = {InSrc,InFlags.Carry};	
			
			
			//Sets register Dest to the bitwise logical NAND of the
         //contents of registers Dest and Src
			NAND:    OutDest = ~(InSrc & InDest);
			
         //Sets the upper bits of register Dest based upon the
         //immediate value
			LIU:
				begin
					if (InImm[ImmediateWidth - 1] ==  1)
						OutDest = {InImm[ImmediateWidth - 2:0], InDest[ImmediateHighStart - 1:0]};
					else if  (InImm[ImmediateWidth - 1] ==  0)	
						OutDest = $signed({InImm[ImmediateWidth - 2:0], InDest[ImmediateMidStart - 1:0]});
					else
						OutDest = InDest;	
				end


			// ***** ONLY CHANGES BELOW THIS LINE ARE ASSESSED *****
			// Put your instruction implementations here.
			
			//Copies the content of register Src to register Dest
			MOVE:		OutDest = InSrc;
			
			//Sets register Dest to the bitwise logical NOR of the
         //contents of registers Dest and Src
			NOR:		OutDest = ~(InSrc | InDest);
			
			//Sets register Dest to the contents of register Src having
         //first shifted the value right by 1 bit and sets the most
         //significant bit of Dest to the value in the C flag.
         //Following this operation, the C flag contains the least
         //significant bit of SRC
			ROR:     {OutDest,OutFlags.Carry} = {InFlags.Carry,InSrc};
			
			//Sets the contents of register Dest to a sign extended
         //copy of the immediate value
			LIL:		OutDest = $signed(InImm);
			
			//Sets the value of register Dest to be the sum of Src
         //Dest and the C flag. All flags are set according to the
         //result
			ADC:
				begin
					{OutFlags.Carry,OutDest} = InSrc + InDest + InFlags.Carry;
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
					// Overflow Flag
					case ({InDest[DataWidth-1],InSrc[DataWidth-1],OutDest[DataWidth-1]})
						3'b001: OutFlags.Overflow = 1;
						3'b110: OutFlags.Overflow = 1;
						default: OutFlags.Overflow = 0;
					endcase
					
					// Parity Flag
					OutFlags.Parity = ~^OutDest;
					
				end
			
		   //Sets the value of register Dest to Dest – (Src + C) flag.
         //All flags are set according to the result	
			SUB:
				begin
					{OutFlags.Carry,OutDest} = InDest - (InSrc + InFlags.Carry);
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
					// Overflow Flag
					case ({InDest[DataWidth-1],InSrc[DataWidth-1],OutDest[DataWidth-1]})
						3'b011: OutFlags.Overflow = 1;
						3'b100: OutFlags.Overflow = 1;
						default: OutFlags.Overflow = 0;
					endcase
					
					// Parity Flag
					OutFlags.Parity = ~^OutDest;
					
				end
			
			//Sets the value of register Dest to the result of a signed
         //integer division Dest / Src
			DIV:
				begin
					OutDest = $signed (InDest) / $signed (InSrc);
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
					// Parity Flag
					OutFlags.Parity = ~^OutDest;
					
				end
			
		   //Sets the value of register Dest to the remainder of the
         //signed integer division Dest / Src	
			MOD:
				begin
					OutDest = $signed (InDest) % $signed (InSrc);
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
					// Parity Flag
					OutFlags.Parity = ~^OutDest;
					
				end
			//Sets the value of register Dest to the low half of the
         //signed integer product Dest x Src	
			MUL:
				begin
					logic signed [(2*DataWidth)-1:0] Product;
					
					Product = $signed (InDest) * $signed (InSrc);
					
					OutDest = Product[DataWidth-1:0];
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
			      // Parity Flag		
					OutFlags.Parity = ~^OutDest;
					
				end
			
	      //Sets the value of register Dest to the high half of the
         //signed integer product Dest x Src	
			MUH:
				begin
					logic signed [(2*DataWidth)-1:0] Product;
					
					Product = $signed (InDest) * $signed (InSrc);
					
					OutDest = Product[(2*DataWidth)-1:DataWidth];
					
					// Zero Flag
					if (OutDest == 0)
						OutFlags.Zero = 1;
						else
							OutFlags.Zero = 0;
					
					// Negative Flag
					if (OutDest[DataWidth-1] == 1)
						OutFlags.Negative = 1;
						else
							OutFlags.Negative = 0;
					
			      // Parity Flag		
					OutFlags.Parity = ~^OutDest;
					
				end
			
			// ***** ONLY CHANGES ABOVE THIS LINE ARE ASSESSED	*****		
			
			default:	OutDest = '0;
			
		endcase;
	end

endmodule
