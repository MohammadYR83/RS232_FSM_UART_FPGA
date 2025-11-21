----------------------------------------------------------------------------------
-- Engineer      : Mohammad Goodarzi
-- Module Name   : RS232_Transmitter
-- Project Name  : RS232_FSM_UART
-- Target Device : Generic FPGA
-- Tool Version  : Tested on Xilinx ISE
--
-- Description   :
-- This module implements an RS232 UART transmitter using a finite state machine (FSM).
-- The design includes:
--   - Data input (8 bits)
--   - Parity bit generation (even parity)
--   - Packet formation (Start, Data, Parity, Stop bits)
--   - Bit-by-bit serial transmission at a fixed baud rate
--   - Busy flag output to indicate ongoing transmission
--
--
-- Baud rate example:
--   For 50 MHz clock, BAUD_TICKS = 5207 → ~9600 baud rate.
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

----------------------------------------------------------------------------------
-- ENTITY DECLARATION
-- Defines the I/O ports of the RS232 Transmitter module.
----------------------------------------------------------------------------------
ENTITY RS232_Transmitter IS
    PORT (
        clock_in : IN STD_LOGIC; -- System clock input
        send_in : IN STD_LOGIC; -- Send trigger signal
        busy_out : OUT STD_LOGIC; -- Indicates transmitter is busy
        serial_out : OUT STD_LOGIC; -- Serial output line (TX)
        data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0) -- 8-bit data input
    );
END RS232_Transmitter;

----------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
-- Main FSM-based implementation of UART transmitter logic.
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF RS232_Transmitter IS

    -------------------------------------------------------------------------------
    -- Constant Definitions
    -------------------------------------------------------------------------------
    CONSTANT BAUD_TICKS : unsigned(12 DOWNTO 0) := to_unsigned(5207, 13);
    -- Number of clock ticks per bit (for ~9600 baud @ 50 MHz)

    -------------------------------------------------------------------------------
    -- State Machine Definition
    -------------------------------------------------------------------------------
    TYPE state_type IS (IDLE, PARITY_GEN, PACKET_BUILD, SEND_BITS, DONE);
    SIGNAL current_state, next_state : state_type := IDLE;

    -------------------------------------------------------------------------------
    -- Internal Signal Declarations
    -------------------------------------------------------------------------------
    SIGNAL tx_busy : STD_LOGIC := '0'; -- Busy flag
    SIGNAL serial_bit : STD_LOGIC := '1'; -- Serial output bit
    SIGNAL send_sync0 : STD_LOGIC := '0'; -- Send signal sync stage 1
    SIGNAL send_sync1 : STD_LOGIC := '0'; -- Send signal sync stage 2
    SIGNAL parity_bit : STD_LOGIC := '0'; -- Generated parity bit
    SIGNAL data_reg : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Latched input data
    SIGNAL tx_packet : STD_LOGIC_VECTOR(11 DOWNTO 0) := (OTHERS => '0');-- Full transmission packet
    SIGNAL bit_index : unsigned(3 DOWNTO 0) := (OTHERS => '0'); -- Current bit being transmitted
    SIGNAL baud_tick_count : unsigned(12 DOWNTO 0) := (OTHERS => '0'); -- Baud rate counter

BEGIN
    -------------------------------------------------------------------------------
    -- Output Assignments
    -------------------------------------------------------------------------------
    busy_out <= tx_busy;
    serial_out <= serial_bit;

    -------------------------------------------------------------------------------
    -- Main FSM Process
    -- Triggered on rising edge of the system clock
    -------------------------------------------------------------------------------
    PROCESS (clock_in)
    BEGIN
        IF (rising_edge(clock_in)) THEN

            -- Synchronize send_in signal (to avoid metastability)
            send_sync0 <= send_in;
            send_sync1 <= send_sync0;

            -----------------------------------------------------------------------
            -- FSM State Transitions
            -----------------------------------------------------------------------
            CASE current_state IS

                    -------------------------------------------------------------------
                    -- IDLE: Wait for send trigger
                    -------------------------------------------------------------------
                WHEN IDLE =>
                    IF (send_sync0 = '0' AND send_sync1 = '1') THEN
                        next_state <= PARITY_GEN;
                        tx_busy <= '1';
                        data_reg <= data_in;
                    END IF;

                    -------------------------------------------------------------------
                    -- PARITY_GEN: Compute parity for data_reg
                    -------------------------------------------------------------------
                WHEN PARITY_GEN =>
                    parity_bit <= data_reg(0) XOR data_reg(1) XOR data_reg(2) XOR data_reg(3)
                        XOR data_reg(4) XOR data_reg(5) XOR data_reg(6) XOR data_reg(7);
                    next_state <= PACKET_BUILD;

                    -------------------------------------------------------------------
                    -- PACKET_BUILD: Construct transmission packet
                    -- Format: Stop(1), Stop(1), Parity, Data(7:0), Start(0)
                    -------------------------------------------------------------------
                WHEN PACKET_BUILD =>
                    tx_packet <= '1' & '1' & parity_bit & data_reg & '0';
                    bit_index <= (OTHERS => '0');
                    baud_tick_count <= (OTHERS => '0');
                    next_state <= SEND_BITS;

                    -------------------------------------------------------------------
                    -- SEND_BITS: Send packet bit-by-bit at the baud rate
                    -------------------------------------------------------------------
                WHEN SEND_BITS =>
                    IF (bit_index < 11) THEN
                        serial_bit <= tx_packet(to_integer(bit_index));
                        baud_tick_count <= baud_tick_count + 1;

                        IF (baud_tick_count = BAUD_TICKS) THEN
                            bit_index <= bit_index + 1;
                            baud_tick_count <= (OTHERS => '0');
                        END IF;
                    END IF;

                    -- Last bit transmission
                    IF (bit_index = 11) THEN
                        serial_bit <= tx_packet(to_integer(bit_index));
                        baud_tick_count <= baud_tick_count + 1;

                        IF (baud_tick_count = BAUD_TICKS) THEN
                            next_state <= DONE;
                        END IF;
                    END IF;

                    -------------------------------------------------------------------
                    -- DONE: Transmission complete, return to IDLE
                    -------------------------------------------------------------------
                WHEN DONE =>
                    tx_busy <= '0';
                    serial_bit <= '1';
                    next_state <= IDLE;

                    -------------------------------------------------------------------
                    -- Default safety case
                    -------------------------------------------------------------------
                WHEN OTHERS =>
                    next_state <= IDLE;
            END CASE;

            -- Update FSM current state
            current_state <= next_state;
        END IF;
    END PROCESS;

END Behavioral;