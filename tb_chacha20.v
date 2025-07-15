`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.07.2025 12:24:47
// Design Name: 
// Module Name: tb_chacha20
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_chacha20();

parameter  DEBUG = 1;

parameter HALF_CLK = 1;
parameter FULL_CLK = 2*HALF_CLK;

parameter ADDR_control = 8'h0a;
parameter ADDR_status = 8'h0b;
parameter ADDR_keylen = 8'h0c;
parameter ADDR_rounds = 8'h0d;

parameter ADDR_KEY0 = 8'h30;
parameter ADDR_KEY1 = 8'h31;
parameter ADDR_KEY2 = 8'h32;
parameter ADDR_KEY3 = 8'h33;
parameter ADDR_KEY4 = 8'h34;
parameter ADDR_KEY5 = 8'h35;
parameter ADDR_KEY6 = 8'h36;
parameter ADDR_KEY7 = 8'h37;

parameter ADDR_NONCE0 = 8'h38;
parameter ADDR_NONCE1 = 8'h39;
parameter ADDR_NONCE2 = 8'h3a;

parameter ADDR_INPUT0 = 8'h50;
parameter ADDR_INPUT1 = 8'h51;
parameter ADDR_INPUT2 = 8'h52;
parameter ADDR_INPUT3 = 8'h53;
parameter ADDR_INPUT4 = 8'h54;
parameter ADDR_INPUT5 = 8'h55;
parameter ADDR_INPUT6 = 8'h56;
parameter ADDR_INPUT7 = 8'h57;
parameter ADDR_INPUT8 = 8'h58;
parameter ADDR_INPUT9 = 8'h59;
parameter ADDR_INPUT10 = 8'h5a;
parameter ADDR_INPUT11 = 8'h5b;
parameter ADDR_INPUT12 = 8'h5c;
parameter ADDR_INPUT13 = 8'h5d;
parameter ADDR_INPUT14 = 8'h5e;
parameter ADDR_INPUT15 = 8'h5f;

parameter ADDR_OUTPUT0 = 8'h70;
parameter ADDR_OUTPUT1 = 8'h71;
parameter ADDR_OUTPUT2 = 8'h72;
parameter ADDR_OUTPUT3 = 8'h73;
parameter ADDR_OUTPUT4 = 8'h74;
parameter ADDR_OUTPUT5 = 8'h75;
parameter ADDR_OUTPUT6 = 8'h76;
parameter ADDR_OUTPUT7 = 8'h77;
parameter ADDR_OUTPUT8 = 8'h78;
parameter ADDR_OUTPUT9 = 8'h79;
parameter ADDR_OUTPUT10 = 8'h7a;
parameter ADDR_OUTPUT11 = 8'h7b;
parameter ADDR_OUTPUT12 = 8'h7c;
parameter ADDR_OUTPUT13 = 8'h7d;
parameter ADDR_OUTPUT14 = 8'h7e;
parameter ADDR_OUTPUT15 = 8'h7f;

parameter STATUS_ready_bit = 0;

parameter KEY_256_BITS = 1;

parameter EIGHT_ROUNDS  = 8;
parameter TEN_ROUNDS = 10;
parameter TWELWE_ROUNDS = 12;
parameter TWENTY_ROUNDS = 20;    
// WIRES AND REGISTER

reg tb_clk;
reg tb_reset_nl;

reg tb_cs;
reg tb_read_write;

reg [7:0] tb_addr;
reg [31:0] tb_data_in;
reg [31:0] tb_data_out;
wire        tb_error;

reg [63:0] cycle_ctr;
reg [31:0] error_ctr;
reg [31:0] tc_ctr;

reg error_found;
reg [31:0] read_data;

reg [511:0] extracted_data;

reg display_cycle_ctr;
reg display_read_write;
reg display_core_state;


chacha dut(
    .clk(tb_clk),
    .reset_n(tb_reset_nl),
    .cs(tb_cs),
    .we(tb_read_write),
    .addr(tb_addr),
    .write_data(tb_data_in),
    .read_data(tb_data_out)
    
    );


// Clock Generation   
always 
    begin: clk_gen
    #(FULL_CLK) tb_clk = !tb_clk;
    end


//dut monitor

always @(posedge tb_clk)
    begin : dut_monitor

    cycle_ctr = cycle_ctr+1;
    
    if(display_cycle_ctr)
    begin
        $display("Cycle :%016x", cycle_ctr);
        end 
        
     if(display_core_state)
     begin
        $display("core_state0 :0x%08x,core_state1 :0x%08x,core_state2 :0x%08x,core_state3 :0x%08x", 
        dut.core.state_reg[00],dut.core.state_reg[01],dut.core.state_reg[02],dut.core.state_reg[03]);
        $display("core_state4 :0x%08x,core_state5 :0x%08x,core_state6 :0x%08x,core_state7 :0x%08x", 
        dut.core.state_reg[04],dut.core.state_reg[05],dut.core.state_reg[06],dut.core.state_reg[07]);
        $display("core_state8 :0x%08x,core_state9 :0x%08x,core_state10 :0x%08x,core_state11 :0x%08x", 
        dut.core.state_reg[08],dut.core.state_reg[09],dut.core.state_reg[10],dut.core.state_reg[11]);
        $display("core_state12 :0x%08x,core_state13 :0x%08x,core_state14 :0x%08x,core_state15 :0x%08x", 
        dut.core.state_reg[12],dut.core.state_reg[13],dut.core.state_reg[14],dut.core.state_reg[15]); // included state of register only, no ctr etc. details 
        end    
    
    if(display_read_write)
    begin 
        if(dut.cs)
        begin
            if(dut.we)
            begin
            $display("data_to_be_written :0x%08x, address :0x%08x",dut.write_data,dut.addr );// actual variable to show value
            end
            else 
            begin 
            $display("data_to_be_read :0x%08x, address :0x%08x",dut.read_data, dut.addr);
            end
        end
    end    
end

//reset
task reset_dut;
    begin
        tb_reset_nl = 0;
        #(2*FULL_CLK);
        tb_reset_nl = 1;
    end   
endtask 


//initial state
task init_dut;
    begin
    tb_clk = 0;
    tb_reset_nl = 0;
    tb_cs = 0;
    tb_read_write = 0;
    tb_addr = 8'h0;
    tb_data_in = 32'h0;
    
    cycle_ctr = 0;
    error_ctr = 0;
    tc_ctr = 0;
    
    display_cycle_ctr = 0;
    display_read_write = 0;
    display_core_state = 0;
    end
endtask 


//read
task read_dut(input [7:0] addr);
    begin
    tb_cs = 1;
    tb_read_write = 0;
    tb_addr = addr;
    #(FULL_CLK);
    tb_cs = 0;
    tb_read_write = 0;
    tb_addr = 8'h0;
    tb_data_in = 32'h0;
    end
endtask  

//write
task write_dut(input [7:0] addr,input [31:0]data);
    begin 
    tb_cs = 1;
    tb_read_write = 1;
    tb_addr = addr;
    tb_data_in = data;
    #(FULL_CLK);
    tb_cs = 0;
    tb_read_write = 0;
    tb_addr = 8'h0;
    tb_data_in = 32'h0; 
    end   
endtask    


task show_top_state();
    begin 
    $display("");
    $display("TOP STATE");
    $display("-------------------");
    
    
   $display("key0 :%08x, key1 :%08x, key2 :%08x, key3 :%08x",
   dut.key_reg[0], dut.key_reg[1], dut.key_reg[2], dut.key_reg[3]);
   $display("key4 :%08x, key5 :%08x, key6 :%08x, key7 :%08x",
   dut.key_reg[4], dut.key_reg[5], dut.key_reg[6], dut.key_reg[7]);
   
   $display("Nonce0 :%08x, Nonce1 :%08x, Nonce3 :%08x",
   dut.iv_reg[0],dut.iv_reg[1],dut.iv_reg[2]);
   
   $display("Data0 :%08x, Data1 :%08x, Data2 :%08x, Data3 :%08x",
   dut.data_in_reg[00],dut.data_in_reg[01],dut.data_in_reg[02],dut.data_in_reg[03]);
    $display("Data0 :%08x, Data1 :%08x, Data2 :%08x, Data3 :%08x",
   dut.data_in_reg[04],dut.data_in_reg[05],dut.data_in_reg[06],dut.data_in_reg[07]);
    $display("Data0 :%08x, Data1 :%08x, Data2 :%08x, Data3 :%08x",
   dut.data_in_reg[08],dut.data_in_reg[09],dut.data_in_reg[10],dut.data_in_reg[11]);
    $display("Data0 :%08x, Data1 :%08x, Data2 :%08x, Data3 :%08x",
   dut.data_in_reg[12],dut.data_in_reg[13],dut.data_in_reg[14],dut.data_in_reg[15]);
   
   $display("core_ready :%08x, data_valid :%08x",dut.core_ready,dut.core_data_out_valid);
    
    $display("Data_out0 :%08x, Data_out1 :%08x, Data_out2 :%08x, Data_out3 :%08x",
    dut.core_data_out[511:480],dut.core_data_out[479:448],dut.core_data_out[447:416],dut.core_data_out[415:384]);
    $display("Data_out4 :%08x, Data_out5 :%08x, Data_out6 :%08x, Data_out7 :%08x",
    dut.core_data_out[383 : 352],dut.core_data_out[351 : 320],dut.core_data_out[319 : 288],dut.core_data_out[287 : 256]);
    $display("Data_out8 :%08x, Data_out9 :%08x, Data_out10 :%08x, Data_out11 :%08x",
    dut.core_data_out[255 : 224],dut.core_data_out[223 : 192],dut.core_data_out[191 : 160],dut.core_data_out[159 : 128]);
    $display("Data_out12 :%08x, Data_out13 :%08x, Data_out14 :%08x, Data_out15 :%08x",
    dut.core_data_out[127:96],dut.core_data_out[95:64],dut.core_data_out[63:32],dut.core_data_out[31:0]);  
    end 
endtask 


//used only when two blocks of data in given simultaneously
task show_core_state;
    begin
    $display("");
    $display("CORE STATE");
    $display("-------------------");
    $display("Round State:");
    $display("state0_reg  = 0x%08x, state1_reg  = 0x%08x, state2_reg  = 0x%08x, state3_reg  = 0x%08x",
              dut.core.state_reg[00], dut.core.state_reg[01], dut.core.state_reg[02], dut.core.state_reg[03]);
    $display("state4_reg  = 0x%08x, state5_reg  = 0x%08x, state6_reg  = 0x%08x, state7_reg  = 0x%08x",
              dut.core.state_reg[04], dut.core.state_reg[05], dut.core.state_reg[06], dut.core.state_reg[07]);
    $display("state8_reg  = 0x%08x, state9_reg  = 0x%08x, state10_reg = 0x%08x, state11_reg = 0x%08x",
              dut.core.state_reg[08], dut.core.state_reg[09], dut.core.state_reg[10], dut.core.state_reg[11]);
    $display("state12_reg = 0x%08x, state13_reg = 0x%08x, state14_reg = 0x%08x, state15_reg = 0x%08x",
              dut.core.state_reg[12], dut.core.state_reg[13], dut.core.state_reg[14], dut.core.state_reg[15]);
              
              
    $display("Round :%01x",dut.core.rounds);  
    $display("QR :%04x, DR :%04x",dut.core.qr_ctr_reg,dut.core.dr_ctr_reg);  
    
    $display("Data_in :%064x",dut.core.data_in);
    
    $display("QR0_a_out :%08x, QR0_b_out :%08x, QR0_c_out :%08x, QR0_d_out :%08x", 
                dut.qr0_a_out,dut.qr0_b_out,dut.qr0_c_out,dut.qr0_d_out);          
    end 
endtask 

//display results
task display_results;
    begin
        if(error_ctr == 0)
        begin 
        $display("Successfull in all %04x cases", tc_ctr);
        end 
        else
        begin
        $display("Error while processing all %04x cases", error_ctr);
        end
    end 
endtask 

//not that much applicable, may be helpful while debugging
task read_write_test;
    begin
      tc_ctr = tc_ctr + 1;

      write_reg(ADDR_KEY0, 32'h55555555);
      read_reg(ADDR_KEY0);
      write_reg(ADDR_KEY1, 32'haaaaaaaa);
      read_reg(ADDR_KEY1);
      read_reg(ADDR_control);
      read_reg(ADDR_status);
      read_reg(ADDR_keylen);
      read_reg(ADDR_rounds);

      read_reg(ADDR_KEY0);
      read_reg(ADDR_KEY1);
      read_reg(ADDR_KEY2);
      read_reg(ADDR_KEY3);
      read_reg(ADDR_KEY4);
      read_reg(ADDR_KEY5);
      read_reg(ADDR_KEY6);
      read_reg(ADDR_KEY7);
    end
  endtask 


//to write to the parameters

task write_parameters( input [511:0]data_in, 
                        input [255:0]key, //a 256 bit space for key
                        input [4:0]rounds, 
                        input [95:0]nonce, 
                        input keylen);
                        
       begin
       write_dut(ADDR_KEY0,key[255:224]);
       write_dut(ADDR_KEY1,key[223:192]);
       write_dut(ADDR_KEY2,key[191:160]);
       write_dut(ADDR_KEY3,key[159:128]);
       write_dut(ADDR_KEY4,key[127:96]);
       write_dut(ADDR_KEY5,key[95:64]);
       write_dut(ADDR_KEY6,key[63:32]);
       write_dut(ADDR_KEY7,key[31:0]);
       
       write_dut(ADDR_NONCE0,nonce[95:64]);
       write_dut(ADDR_NONCE1,nonce[63:32]);
       write_dut(ADDR_NONCE2,nonce[31:0]);
       
       write_dut(ADDR_rounds,{{27'h0},rounds});
       write_dut(ADDR_keylen,{{27'h0},keylen});
       
       write_dut(ADDR_INPUT0,data_in[511:480]);
       write_dut(ADDR_INPUT0,data_in[479:448]);
       write_dut(ADDR_INPUT0,data_in[447:416]);
       write_dut(ADDR_INPUT0,data_in[415:384]);
       write_dut(ADDR_INPUT0,data_in[383 : 352]);
       write_dut(ADDR_INPUT0,data_in[351 : 320]);
       write_dut(ADDR_INPUT0,data_in[319 : 288]);
       write_dut(ADDR_INPUT0,data_in[287 : 256]);
       write_dut(ADDR_INPUT0,data_in[255 : 224]);
       write_dut(ADDR_INPUT0,data_in[223 : 192]);
       write_dut(ADDR_INPUT0,data_in[191 : 160]);
       write_dut(ADDR_INPUT0,data_in[159 : 128]);
       write_dut(ADDR_INPUT0,data_in[127:96]);
       write_dut(ADDR_INPUT0,data_in[95:64]);
       write_dut(ADDR_INPUT0,data_in[63:32]);
       write_dut(ADDR_INPUT0,data_in[31:0]); 
       end       
                                
endtask  


//start initial block
task start_init;
    begin
    write_reg(ADDR_control, 32'h00000001);
      #(2 * FULL_CLK);
      write_reg(ADDR_control, 32'h00000000);
    end
endtask                       


//next block
task start_next;
   begin
    begin
    write_reg(ADDR_control, 32'h00000001);
      #(2 * FULL_CLK);
      write_reg(ADDR_control, 32'h00000000);
    end
    begin 
    if(DEBUG)
        $display("Core State");
        show_core_state();
        #(2 * FULL_CLK);
        show_core_state();
     end
  end
endtask

// used in double round only
task wait_ready;
    begin
        while(!tb_data_out[STATUS_ready_bit])
            begin
                read_dut(ADDR_status);
             end   
    end 
endtask 


//extract data
task extract_data;
    begin
      read_dut(ADDR_OUTPUT0);
      extracted_data[511 : 480] = tb_data_out;
      read_dut(ADDR_OUTPUT1);
      extracted_data[479 : 448] = tb_data_out;
      read_dut(ADDR_OUTPUT2);
      extracted_data[447 : 416] = tb_data_out;
      read_dut(ADDR_OUTPUT3);
      extracted_data[415 : 384] = tb_data_out;
      read_dut(ADDR_OUTPUT4);
      extracted_data[383 : 352] = tb_data_out;
      read_dut(ADDR_OUTPUT5);
      extracted_data[351 : 320] = tb_data_out;
      read_dut(ADDR_OUTPUT6);
      extracted_data[319 : 288] = tb_data_out;
      read_dut(ADDR_OUTPUT7);
      extracted_data[287 : 256] = tb_data_out;
      read_dut(ADDR_OUTPUT8);
      extracted_data[255 : 224] = tb_data_out;
      read_dut(ADDR_OUTPUT9);
      extracted_data[223 : 192] = tb_data_out;
      read_dut(ADDR_OUTPUT10);
      extracted_data[191 : 160] = tb_data_out;
      read_dut(ADDR_OUTPUT11);
      extracted_data[159 : 128] = tb_data_out;
      read_dut(ADDR_OUTPUT12);
      extracted_data[127 :  96] = tb_data_out;
      read_dut(ADDR_OUTPUT13);
      extracted_data[95  :  64] = tb_data_out;
      read_dut(ADDR_OUTPUT14);
      extracted_data[63  :  32] = tb_data_out;
      read_dut(ADDR_OUTPUT15);
      extracted_data[31  :   0] = tb_data_out;
    end
  endtask 


task single_block_run(input [255:0]key, input keylen, input [95:0]nonce, input [4:0]rounds, input [511:0]expected, input [511:0]data_in);
    begin
        tc_ctr = tc_ctr + 1;
        write_parameters(.key(key),.nonce(nonce),.keylen(keylen),.rounds(rounds),.data_in(data_in));
        start_init();
        $display("Starting");
        wait_ready();
        $display("Getting Ready");
        show_top_state();
        extract_data();
        
        if(extracted_data != expected)
            begin
                error_ctr = error_ctr + 1;
                $display("error while performing");
                $display("expected data : %064x",expected);
                $display("obtained data : %064x",extracted_data);
            end
         else   
            begin
            $display("----------");
            end
    end
endtask


//Actual testing calling tasks

initial 
    begin
    $display("Test Bench Starting");
    init_dut();
    reset_dut();
    
    $display("State just after reset");
    show_top_state();
    
    $display("Entering Parameters given in Test Bench");
    single_block_run(256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f,
                    KEY_256_BITS,
                    96'h000000090000004a00000000,
                    TWENTY_ROUNDS,
                    512'h60fdedbd1a280cb741d0593b6ea0309010acf18e1471f68968f4c9e311dca149b8e027b47c81e0353db013891aa5f68ea3b13dd2f3b8dd0873bf3746e7d6c567,
                    512'h4c616469657320616e642047656e746c656d656e206f662074686520636c617373206f66202739393a204966204920636f756c64206f6666657220796f75206f);
    
    //Parameters yet to be entered
    display_results();
    $display("ChaCha Simulation Done");
    end 


endmodule
//increase delay if not working properly
