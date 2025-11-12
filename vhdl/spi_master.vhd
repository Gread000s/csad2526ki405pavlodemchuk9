----------------------------------------------------------------------------------
-- Company:       
-- Engineer:      
-- 
-- Create Date:   09.11.2025 18:18:43
-- Design Name:   SPI Master Controller
-- Module Name:   spi_master - Behavioral
-- Project Name:  lab2_spi
-- Target Devices: Artix-7
-- Tool Versions: Vivado 2025.1
-- Description:   Лабораторна робота №2. Реалізація SPI Master (Варіант 9).
--                Модуль реалізує FSM для передачі 8 біт даних.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL; -- НАМ ЦЕ ПОТРІБНО для лічильника

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

----------------------------------------------------------------------------
-- ENTITY: "Чорна скринька" або "піни" нашого модуля
-- Описує всі входи та виходи
----------------------------------------------------------------------------
entity spi_master is
    Port ( 
        -- --- Системні сигнали ---
        i_clk       : IN  STD_LOGIC; -- Вхідний тактовий сигнал (наприклад, 50 МГц)
        i_reset     : IN  STD_LOGIC; -- Сигнал скидання (активний - '1')

        -- --- Керуючі сигнали (від CPU або іншої логіки) ---
        i_start_tx  : IN  STD_LOGIC; -- '1' для старту однієї транзакції
        i_data_tx   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- 8-бітні дані для відправки
        
        o_data_rx   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- 8-бітні дані, що ми отримали
        o_done_flag : OUT STD_LOGIC; -- '1' коли транзакція завершена

        -- --- Фізичні лінії SPI-шини ---
        o_sck       : OUT STD_LOGIC; -- SPI Тактовий сигнал (генерується нами)
        o_ss        : OUT STD_LOGIC; -- Slave Select (Active Low)
        o_mosi      : OUT STD_LOGIC; -- Master Out Slave In (дані від нас)
        i_miso      : IN  STD_LOGIC  -- Master In Slave Out (дані до нас)
    );
end entity spi_master;

----------------------------------------------------------------------------
-- ARCHITECTURE: "Мозок" модуля
-- Описує внутрішню логіку, що реалізує нашу FSM
----------------------------------------------------------------------------
architecture Behavioral of spi_master is

    -- --- Тип для наших станів FSM (згідно намальованої діаграми) ---
    TYPE t_state IS (
        IDLE,
        START_BUS,
        SCK_HIGH,
        SCK_LOW,
        CHECK_COUNT,
        STOP_BUS
    );

    -- --- Внутрішні сигнали ---
    SIGNAL s_state        : t_state := IDLE; -- Сигнал, що зберігає поточний стан FSM
    SIGNAL s_bit_counter  : UNSIGNED(2 DOWNTO 0); -- Лічильник бітів (3 біти для 0-7)
    
    -- Регістри зсуву: один для відправки, інший для прийому
    SIGNAL s_tx_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0); 
    SIGNAL s_rx_reg       : STD_LOGIC_VECTOR(7 DOWNTO 0);

begin

    -- ------------------------------------------------------------------------
    -- Головний процес: реалізує логіку FSM (керує станами та виходами)
    -- Це синхронний процес, він спрацьоє лише по тактовому сигналу i_clk
    -- ------------------------------------------------------------------------
    PROCESS (i_clk)
    BEGIN
        IF rising_edge(i_clk) THEN
            IF i_reset = '1' THEN
                -- --- Логіка скидання (повертаємо все у початковий стан) ---
                s_state       <= IDLE;
                s_bit_counter <= (OTHERS => '0');
                s_tx_reg      <= (OTHERS => '0');
                s_rx_reg      <= (OTHERS => '0');
                o_sck         <= '0';
                o_ss          <= '1'; -- Неактивний
                o_mosi        <= '0';
                o_done_flag   <= '0';
                o_data_rx     <= (OTHERS => '0');

            ELSE
                -- --- Основна логіка FSM (виконується на кожному такті) ---
                -- Цей CASE...END CASE є прямою реалізацією вашої діаграми
                CASE s_state IS

                    -- --- СТАН: IDLE (Очікування) ---
                    WHEN IDLE =>
                        o_ss        <= '1'; -- SS неактивний
                        o_sck       <= '0'; -- SCK в спокої
                        o_done_flag <= '0';
                        
                        IF i_start_tx = '1' THEN
                            -- Отримали команду, готуємось до передачі
                            s_tx_reg <= i_data_tx; -- Завантажуємо дані для відправки
                            s_state  <= START_BUS; -- Перехід на наступний стан
                        END IF;

                    -- --- СТАН: START_BUS (Захоплення шини) ---
                    WHEN START_BUS =>
                        o_ss          <= '0'; -- Активуємо SS
                        s_bit_counter <= (OTHERS => '0'); -- Скидаємо лічильник бітів
                        s_state       <= SCK_HIGH; -- Перехід

                    -- --- СТАН: SCK_HIGH (SCK = '1') ---
                    WHEN SCK_HIGH =>
                        o_sck   <= '1';
                        -- Виставляємо старший біт s_tx_reg на лінію MOSI
                        o_mosi  <= s_tx_reg(7); 
                        s_state <= SCK_LOW; -- Перехід

                    -- --- СТАН: SCK_LOW (SCK = '0') ---
                    WHEN SCK_LOW =>
                        o_sck   <= '0';
                        -- Зчитування біта буде в наступному стані CHECK_COUNT
                        s_state     <= CHECK_COUNT; -- Перехід

                    -- --- СТАН: CHECK_COUNT (Перевірка лічильника) ---
                    WHEN CHECK_COUNT =>
                        -- Зсуваємо обидва регістри на 1 біт
                        s_tx_reg <= s_tx_reg(6 DOWNTO 0) & '0';
                        s_rx_reg <= s_rx_reg(6 DOWNTO 0) & i_miso;
                        
                        IF s_bit_counter = 7 THEN
                            -- Вже відправили 8 біт (від 0 до 7)
                            s_state <= STOP_BUS; -- Перехід
                        ELSE
                            -- Ще є біти, збільшуємо лічильник
                            s_bit_counter <= s_bit_counter + 1;
                            s_state       <= SCK_HIGH; -- Повертаємось на SCK_HIGH
                        END IF;

                    -- --- СТАН: STOP_BUS (Звільнення шини) ---
                    WHEN STOP_BUS =>
                        o_ss        <= '1'; -- Деактивуємо SS
                        o_done_flag <= '1'; -- Сигналізуємо про завершення
                        o_data_rx   <= s_rx_reg; -- Виставляємо прийняті дані на вихід
                        s_state     <= IDLE; -- Повертаємось в очікування
                
                END CASE;
            END IF;
        END IF;
    END PROCESS;

end Behavioral;
