----------------------------------------------------------------------------------
-- Company:       
-- Engineer:      
-- 
-- Create Date:   12.11.2025 16:51:33
-- Design Name:   SPI Master Testbench
-- Module Name:   spi_tb - Behavioral
-- Project Name:  lab2_spi
-- Target Devices: 
-- Tool Versions: Vivado 2025.1
-- Description:   Етап 3. Тестбенч для верифікації модуля spi_master.
--                Імітує відправку двох байтів (xA5, x12)
--                та імітує відповідь Slave-пристрою (x"F0").
--
-- Dependencies:  spi_master.vhd
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.ALL; -- Додано для виводу повідомлень (report)

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL; -- НАМ ЦЕ ПОТРІБНО

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity spi_tb is
--  Port ( ); -- Тестбенч не має портів
end spi_tb;

architecture Behavioral of spi_tb is

    -- --- Константи ---
    CONSTANT c_CLK_PERIOD : TIME := 20 ns; -- Період CLK (для 50 МГц)

    -- --- Сигнали для підключення до нашого модуля ---
    SIGNAL s_clk       : STD_LOGIC := '0';
    SIGNAL s_reset     : STD_LOGIC := '0';
    SIGNAL s_start_tx  : STD_LOGIC := '0';
    SIGNAL s_data_tx   : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_data_rx   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_done_flag : STD_LOGIC;
    SIGNAL s_sck       : STD_LOGIC;
    SIGNAL s_ss        : STD_LOGIC;
    SIGNAL s_mosi      : STD_LOGIC;
    SIGNAL s_miso      : STD_LOGIC := '0'; -- Імітуємо відповідь Slave

begin

    -- ------------------------------------------------------------------------
    -- 1. Підключення нашого модуля (DUT - Device Under Test)
    -- ------------------------------------------------------------------------
    dut_spi_master : ENTITY work.spi_master
        PORT MAP (
            i_clk       => s_clk,
            i_reset     => s_reset,
            i_start_tx  => s_start_tx,
            i_data_tx   => s_data_tx,
            o_data_rx   => s_data_rx,
            o_done_flag => s_done_flag,
            o_sck       => s_sck,
            o_ss        => s_ss,
            o_mosi      => s_mosi,
            i_miso      => s_miso
        );

    -- ------------------------------------------------------------------------
    -- 2. Генератор тактового сигналу (CLK)
    -- ------------------------------------------------------------------------
    s_clk <= NOT s_clk AFTER c_CLK_PERIOD / 2;

    -- ------------------------------------------------------------------------
    -- 3. Імітація Slave-пристрою (відповідь на MISO)
    -- Імітуємо Slave, який завжди повертає байт x"F0" (11110000)
    -- ------------------------------------------------------------------------
    PROCESS (s_sck, s_ss)
        -- Використовуємо зсувний регістр, щоб імітувати відповідь
        VARIABLE v_slave_data : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"F0";
    BEGIN
        -- Відповідь по задньому фронту SCK (для Режиму 0)
        IF falling_edge(s_sck) THEN
            IF s_ss = '0' THEN
                -- Slave відповідає: виставляє старший біт і зсувається
                s_miso <= v_slave_data(7);
                v_slave_data := v_slave_data(6 DOWNTO 0) & '0';
            END IF;
        END IF;
        
        -- Коли SS неактивний, перезавантажуємо регістр Slave
        IF s_ss = '1' THEN 
             v_slave_data := x"F0";
             s_miso <= 'Z'; -- Імітуємо, що MISO у Z-стані
        END IF;
    END PROCESS;

    -- ------------------------------------------------------------------------
    -- 4. Стимули (Сценарій тестування)
    -- ------------------------------------------------------------------------
    stimulus_proc : PROCESS
    BEGIN
        -- --- Скидання (RESET) ---
        report "Starting simulation... Applying RESET.";
        s_reset <= '1';
        WAIT FOR 100 ns;
        s_reset <= '0';
        WAIT FOR c_CLK_PERIOD;

        -- --- Тест 1: Відправка x"A5" (10100101) ---
        report "TEST 1: Sending xA5...";
        s_data_tx <= x"A5";
        s_start_tx <= '1';
        WAIT FOR c_CLK_PERIOD;
        s_start_tx <= '0';
        
        -- Чекаємо на завершення
        WAIT UNTIL s_done_flag = '1';
        report "TEST 1: Done.";
        WAIT FOR 100 ns;

        -- --- Тест 2: Відправка x"12" (00010010) ---
        report "TEST 2: Sending x12...";
        s_data_tx <= x"12";
        s_start_tx <= '1';
        WAIT FOR c_CLK_PERIOD;
        s_start_tx <= '0';
        
        -- Чекаємо на завершення
        WAIT UNTIL s_done_flag = '1';
        report "TEST 2: Done." ;
        WAIT FOR 100 ns;

        report "SIMULATION FINISHED. Stopping simulation.";
        std.env.stop; -- Коректна зупинка симуляції
    END PROCESS;

end Behavioral;