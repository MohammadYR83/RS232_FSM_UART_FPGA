----------------------------------------------------------------------------------
-- Engineer      : Mohammad Goodarzi
-- Module Name   : RS232_Receiver
-- Project Name  : RS232_FSM_UART
-- Target Device : Generic FPGA
-- Tool Version  : Tested on Xilinx ISE
--
-- Description   :
-- This module implements an RS232 UART receiver using a finite state machine (FSM).
-- The design includes:
--   - Serial input signal sampling and synchronization
--   - Start-bit detection
--   - 8-bit data reception (LSB first)
--   - Parity bit checking (even parity)
--   - Stop-bit validation
--   - Output flag to indicate valid received data
--
-- Baud rate example:
--   For 50 MHz clock, BAUD_TICKS = 5207 → ~9600 baud rate.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

----------------------------------------------------------------------------------
-- ENTITY DECLARATION
-- Defines the I/O ports of the RS232 Receiver module.
----------------------------------------------------------------------------------
ENTITY RS232_Receiver IS
    PORT (
        clock_in  : IN  STD_LOGIC;                      -- System clock input
        serial_in : IN  STD_LOGIC;                      -- Serial data input (RX)
        valid_out : OUT STD_LOGIC;                      -- Indicates received data is valid
        data_out  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)    -- 8-bit parallel data output
    );
END RS232_Receiver;

----------------------------------------------------------------------------------
-- ARCHITECTURE DEFINITION
-- FSM-based implementation of UART receiver logic.
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF RS232_Receiver IS

    -------------------------------------------------------------------------------
    -- Constant Definitions
    -------------------------------------------------------------------------------
    CONSTANT BAUD_TICKS       : unsigned(12 DOWNTO 0) := to_unsigned(5207, 13); -- Full bit period
    CONSTANT HALF_BAUD_TICKS  : unsigned(12 DOWNTO 0) := to_unsigned(2603, 13); -- Half bit period (mid-bit sampling)

    -------------------------------------------------------------------------------
    -- State Machine Definition
    -------------------------------------------------------------------------------
    TYPE state_type IS (IDLE, START_BIT, RECEIVE_BITS, PARITY_CHECK, STOP_BIT, DONE);
    SIGNAL current_state, next_state : state_type := IDLE;

    -------------------------------------------------------------------------------
    -- Internal Signal Declarations
    -------------------------------------------------------------------------------
    SIGNAL valid_flag       : STD_LOGIC := '0';                           -- Data valid flag
    SIGNAL data_reg         : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); -- Received data register

    SIGNAL serial_sync0     : STD_LOGIC := '1';                           -- Synchronization stage 1
    SIGNAL serial_sync1     : STD_LOGIC := '1';                           -- Synchronization stage 2

    SIGNAL baud_tick_count  : unsigned(12 DOWNTO 0) := (OTHERS => '0');   -- Baud timing counter
    SIGNAL bit_index        : unsigned(3 DOWNTO 0)  := (OTHERS => '0');   -- Bit index during reception

    SIGNAL parity_txd_bit   : STD_LOGIC := '0';                           -- Received parity bit
    SIGNAL parity_rxd_bit   : STD_LOGIC := '0';                           -- Calculated parity from received bits

    SIGNAL stop_bit_flag    : STD_LOGIC := '0';                           -- Internal stop-bit check flag

BEGIN
    -------------------------------------------------------------------------------
    -- Output Assignments
    -------------------------------------------------------------------------------
    valid_out <= valid_flag;
    data_out  <= data_reg;

    -------------------------------------------------------------------------------
    -- Main FSM Process
    -- Handles sampling, state transitions, and data reconstruction
    -------------------------------------------------------------------------------
    PROCESS (clock_in)
    BEGIN
        IF (rising_edge(clock_in)) THEN

            -----------------------------------------------------------------------
            -- Input Synchronization
            -- Prevents metastability from asynchronous serial input
            -----------------------------------------------------------------------
            serial_sync0 <= serial_in;
            serial_sync1 <= serial_sync0;

            -----------------------------------------------------------------------
            -- FSM State Transitions
            -----------------------------------------------------------------------
            CASE current_state IS

                -------------------------------------------------------------------
                -- IDLE: Wait for start bit detection (falling edge on RX line)
                -------------------------------------------------------------------
                WHEN IDLE =>
                    valid_flag <= '0';
                    IF (serial_sync1 = '0') THEN
                        next_state <= START_BIT;
                    END IF;

                -------------------------------------------------------------------
                -- START_BIT: Wait for half bit period before sampling data bits
                -------------------------------------------------------------------
                WHEN START_BIT =>
                    baud_tick_count <= baud_tick_count + 1;
                    IF (baud_tick_count = HALF_BAUD_TICKS) THEN
                        next_state <= RECEIVE_BITS;
                        baud_tick_count <= (OTHERS => '0');
                    END IF;

                -------------------------------------------------------------------
                -- RECEIVE_BITS: Sample and store 8 data bits (LSB first)
                -- Also compute running parity for even parity verification
                -------------------------------------------------------------------
                WHEN RECEIVE_BITS =>
                    baud_tick_count <= baud_tick_count + 1;
                    IF (baud_tick_count = BAUD_TICKS) THEN
                        data_reg(to_integer(bit_index)) <= serial_sync1;
                        parity_rxd_bit <= parity_rxd_bit XOR serial_sync1; -- Incremental parity calculation
                        baud_tick_count <= (OTHERS => '0');
                        bit_index <= bit_index + 1;

                        IF (bit_index = 7) THEN
                            bit_index <= (OTHERS => '0');
                            next_state <= PARITY_CHECK;
                        END IF;
                    END IF;

                -------------------------------------------------------------------
                -- PARITY_CHECK: Sample and store parity bit
                -------------------------------------------------------------------
                WHEN PARITY_CHECK =>
                    baud_tick_count <= baud_tick_count + 1;
                    IF (baud_tick_count = BAUD_TICKS) THEN
                        parity_txd_bit <= serial_sync1;
                        baud_tick_count <= (OTHERS => '0');
                        next_state <= STOP_BIT;
                    END IF;

                -------------------------------------------------------------------
                -- STOP_BIT: Validate stop bit(s) before completing reception
                -------------------------------------------------------------------
                WHEN STOP_BIT =>
                    baud_tick_count <= baud_tick_count + 1;
                    IF (baud_tick_count = BAUD_TICKS) THEN
                        IF (serial_sync1 = '1' AND stop_bit_flag = '0') THEN
                            stop_bit_flag <= '1';
                            baud_tick_count <= (OTHERS => '0');
                        ELSIF (serial_sync1 = '1' AND stop_bit_flag = '1') THEN
                            stop_bit_flag <= '0';
                            baud_tick_count <= (OTHERS => '0');
                            next_state <= DONE;
                        END IF;
                    END IF;

                -------------------------------------------------------------------
                -- DONE: Verify parity and set valid flag if data is correct
                -------------------------------------------------------------------
                WHEN DONE =>
                    IF (parity_txd_bit = parity_rxd_bit) THEN
                        valid_flag <= '1';
                    END IF;
                    next_state <= IDLE;

                -------------------------------------------------------------------
                -- Default safety case
                -------------------------------------------------------------------
                WHEN OTHERS =>
                    next_state <= IDLE;
            END CASE;

            -----------------------------------------------------------------------
            -- Update FSM Current State
            -----------------------------------------------------------------------
            current_state <= next_state;
        END IF;
    END PROCESS;

END Behavioral;
