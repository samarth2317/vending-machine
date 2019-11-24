`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:01:12 05/04/2019 
// Design Name: 
// Module Name:    vm2 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vm2(out_led, out_lcd, clk, cancel, nickel, dime, quater, dollar, selectProduct, LED_button0, LED_button1, LED_button2, LED_button3, LED_button4, LED_button5);
	
	output out_led;			// Output LED to indicate dispense of Item after successful transaction.
	output [2:0] out_lcd;		// Output for LCD display interface.

			input clk;
       	input cancel;			// Push Button for Cancel Request
       	input nickel;			// Push Button for Nickel Coin Entering
       	input dime;			// Push Button for Dime Coin Entering
       	input quater;			// Push Button for Quater Coin Entering
       	input dollar;			// Push Button for Dollar Entering
	input [3:0] selectProduct;	// Keypad Interfacing pins for Product Selection
	output LED_button0, LED_button1, LED_button2, LED_button3, LED_button4, LED_button5;
	
	reg out_led = 0;		// Initially LED off as there is no dispense of Item.
	reg [2:0] out_lcd = 0;		
	reg LED_button0=0, LED_button1=0, LED_button2=0, LED_button3=0, LED_button4=0, LED_button5=0;
	wire cancel, nickel, dime, quater, dollar;
	integer timeControl;



//-------------------------------------- Initialization of basic variables  ---------------------------------------------//
parameter amountProduct0 = 50;
parameter amountProduct1 = 100;
parameter amountProduct2 = 125;
parameter amountProduct3 = 150;
/*
parameter [31:0] t_40ns 	= 1;		//40ns 		== ~1clk
parameter [31:0] t_250ns 	= 6;		//250ns 	== ~6clks
parameter [31:0] t_15000us	= 360000;	//15ms 		== ~360000clks
*/

integer requiredAmount;
integer enteredAmount;
//reg [8*100:1] lcdString;
reg [3:0] state = 0;
reg [0:1] subState = 0;	

//-------------------------------------- Clock ------------------------------------------------------------//
integer counter_sec = 0;
reg clk_sec = 0;

always @(posedge clk) begin
	if (counter_sec == 5000000)
	begin
		clk_sec <= ~clk_sec;
		counter_sec <= 0;
	end
	else
		counter_sec <= counter_sec + 1;
end



//-------------------------------------- Initial Flag Polling ---------------------------------------------//

wire [3:0] selectProduct;
reg flag_rst;											// Initially in Reset Mode
reg [3:0] flag_product = 0;
reg flag_selectProduct = 0;								// Initially No Product Selected
reg flag_productAvailable;							// Initailly Product Available
reg flag_changeCollect;								// Change Collect
reg flag_productDispense;							// Initially No Product Dispense
reg flag_busy = 0;
reg flagDime = 0;
reg flagQuater = 0;
reg flagDollar = 0;
reg flagNickel = 0;

/*
always @(posedge clk_sec) begin
	
	if( |selectProduct && !flag_busy) begin
		
		// Check for keypress on keypad
		// If any key pressed then flag_selectProduct = 1
		// flag_busy = 1;
		flag_product <= selectProduct;
		flag_selectProduct <= 1;
		flag_busy <= 1;

	end


	if(nickel || dime || quater || dollar) begin
		
		case ({nickel,dime,quater,dollar})
		4'b0001 : flagDollar = 1;
		4'b0010 : flagQuater = 1;
		4'b0100 : flagDime = 1;
		4'b1000 : flagNickel = 1;
		default : flagNickel = 1;
		endcase
		
	end


end
*/

//-------------------------------------- Timer Counting ---------------------------------------------//



//-------------------------------------- State Machine ---------------------------------------------//

				


/*
* State 0 : Select Product State ( Reset State )
* State 1 : Product Specific State
* State 2 : Waiting for Amount State
* State 3 : Amount checking State
* State 4 : Product dispense State
* State 5 : 
* State 6 :
* State 7 :
*/

always @(posedge clk_sec) begin
	
	case (state)
		
		
		0 : begin

						LED_button0 <= 1'b1;
				
						out_led <= 1'b0;
						out_lcd <= 0;
						//if(timeControl == 150)
					//	begin
								if( |selectProduct && !flag_busy) 
								begin
						
								// Check for keypress on keypad
								// If any key pressed then flag_selectProduct = 1
								// flag_busy = 1;
							
								flag_product <= selectProduct;
								flag_selectProduct <= 1;
								flag_busy <= 1;
								state <= state + 1;

								end
								else	
								begin
									state <= state;
									//timeControl <= 150;
								end
							//end
							//else
							//	timeControl <= timeControl + 1;
			end		
		
		1 : begin							//Select Product State : LCD - Select Product, Keypad - wait for input
			
			LED_button0 <= 1'b0;LED_button1 <= 1'b1;
			requiredAmount <= 0;
			enteredAmount <= 0;
			flag_changeCollect <= 0;								// Change Collect
			flag_productDispense <=0;

			
			if (!flag_selectProduct) begin				//flag_selectProduct = 0 , No product selected
				state <= state;					//Stay in same state
				flag_rst <= 1;					//Stay in reset state
			end	
			
			else begin						//flag_selectProduct = 1 , Any product selected
				state <= state + 1;				//Move to next state
				flag_rst <= 0;					//Not in reset state anymore :)
				flag_productAvailable <= 1;
				case (flag_product)
					4'b0001 : out_lcd <= 001;
					4'b0010 : out_lcd <= 010;
					4'b0100 : out_lcd <= 011;
					4'b1000 : out_lcd <= 100;
				endcase
			end
		end

		2 : begin							//Any product selected
			LED_button0 <= 1'b0;LED_button1 <= 1'b0;LED_button2<=1'b1;
			if (!flag_productAvailable) begin			//Product Not Available
				state <= 0;					//Go to State 0
				flag_rst <=1;					//Go to State 0
			end

			else begin
			//	LED_button2 = 1'b1;
				state <= state + 1;
				flag_rst <= 0;
				if (flag_product == 4'b0001) begin
					requiredAmount <= amountProduct0;
				end
				else if (flag_product == 4'b0010) begin
					requiredAmount <= amountProduct1;
				end
				else if (flag_product == 4'b0100) begin
					requiredAmount <= amountProduct2;
				end
				else if (flag_product == 4'b1000) begin
					requiredAmount <= amountProduct3;
				end
				//lcdString <= "Insert Amount : ";
				//lcdString <= requiredAmount;
				// Display on LCD : Insert Amount of Product 0
				// requiredAmount = amountOfProduct(0)
			end

		end

		3 : begin							//Wait for Amount to be entered : Check for which push button entered
			
			LED_button3 <= 1'b1;LED_button2<=1'b0;
			// Create a loop for 3 mins for entering required
			// amount, after that reset it.
			//
			 if(nickel || dime || quater || dollar) begin
				
			//	LED_button3 = 1'b1;
			
				if(nickel) flagNickel <= 1;
				if(dime) flagDime <= 1;
				if(quater) flagQuater <= 1;
				if(dollar) flagDollar <= 1;
			/*
				case ({nickel,dime,quater,dollar})
					4'b0001 : flagDollar = 1;
					4'b0010 : flagQuater = 1;
					4'b0100 : flagDime = 1;
					4'b1000 : flagNickel = 1;
					default : flagNickel = 1;
				endcase
			*/
			end
	
			if (enteredAmount < requiredAmount) begin ///* Condition for 3 min /or /wait for enteredAmount <= requiredAmount */
				
				if (flagNickel) begin				//Nickel entered
					enteredAmount <= enteredAmount + 5;			// enteredAmount = enteredAmount + 5 cents
					flagNickel <= 0;
				end

				else if (flagDime) begin			//Dime entered
					enteredAmount <= enteredAmount + 10;			// enteredAmount = enteredAmount + 10 cents
					flagDime <= 0;
					end
			
				else if (flagQuater) begin			//Quater entered
					enteredAmount <= enteredAmount + 25;			// enteredAmount = enteredAmount + 25 cents
					flagQuater <= 0;
				end

				else if (flagDollar) begin			//Dollar entered
					enteredAmount <= enteredAmount + 100;			// enteredAmount = enteredAmount + 1 $
					flagDollar <= 0;
				end
				
				state <= state;

			end
			
			else begin
				state <= state + 1;
				flag_rst <= 0;
			end

		end

		4 : begin						//Check for right amount : Less, Equal or Greater

			LED_button4 <= 1'b1; LED_button3 <= 1'b0;
			if (enteredAmount < requiredAmount) begin
				state <= state + 1;			//Go to next state
			   flag_rst <= 0;
				flag_changeCollect <= 1;		//Change to be collected
				flag_productDispense <= 0;		//No Product Dispense due to less amount
			end
			
			else if (enteredAmount == requiredAmount) begin
				state <= state + 1;			//Go to next state
				flag_rst <= 0;
				flag_changeCollect <= 0;		//No change at end of transaction
				flag_productDispense <= 1;		//Product Dispense
			end
	
			else if (enteredAmount > requiredAmount) begin
				state <= state + 1;			//Go to next state
				flag_rst <= 0;
				flag_changeCollect <= 1;		//Change to be collected
				flag_productDispense <= 1;		//Product Dispense
			end

		end

		5 : begin
						
						LED_button5 <= 1'b1; LED_button4 <= 1'b0;
						//timeControl <= timeControl + 1;
						if (!flag_productDispense && flag_changeCollect) begin				//No product dispense due to less amount
							out_led <= 0;								//Product dispense LED Off
							//out_lcd <= "Please collect your change and try with right amount";	//Display message on LCD
							out_lcd <= 101;
							//state <= 0;								//Go to initial state
							flag_rst <= 1;								//Set Reset flag 
						end

						else if (flag_productDispense && !flag_changeCollect) begin			//Product dispense with no change
							out_led <= 1;								//Product dispense LED On
							//out_lcd <= "Please collect your product";				//Display message on LCD
							out_lcd <= 110;
							//state <= 0;								//Go to initial State
							flag_rst <= 1;								//Set Reset flag
						end

						else if (flag_productDispense && flag_changeCollect) begin			//Product dispense with remaining change
							out_led <= 1;								//Product dispense LED On
							//remainingChange = enteredAmount - requiredAmount			//Remaining Amount after transaction
							//out_lcd <= "Please collect your product and remaining change";	//Display message on LCD
							out_lcd <= 111;
							//state <= 0;								//Go to initial State
							flag_rst <= 1;								//Set Reset flag
						end

					//if(timeControl == 250)
					//begin
						//out_lcd <= 0;
						timeControl <= 0;
						state <= 0;
						flag_busy <= 0;
						flag_selectProduct <= 0;
						flag_product <= 0;
						flag_productAvailable <= 0;
						flag_productDispense <= 0;
						flag_changeCollect <= 0;	
					//end
					
					//else
						//timeControl <= timeControl + 1;

		end

	endcase

end
endmodule 