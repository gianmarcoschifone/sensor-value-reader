library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


------------------------------ struttura ------------------------------

entity project_reti_logiche is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_start : in std_logic;
		i_add : in std_logic_vector(15 downto 0);
		i_k : in std_logic_vector(9 downto 0);
		
		o_done : out std_logic;
		
		o_mem_addr : out std_logic_vector(15 downto 0);
		i_mem_data : in std_logic_vector(7 downto 0);
		o_mem_data : out std_logic_vector(7 downto 0);
		o_mem_we : out std_logic;
		o_mem_en : out std_logic
	);
end project_reti_logiche;

architecture struttura_arch of project_reti_logiche is

component k_counter is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		i_k : in std_logic_vector(9 downto 0);
		current_k : out std_logic_vector(10 downto 0);
		done : out std_logic
	);
end component k_counter;

component adder is
	port(
		i_add : in std_logic_vector(15 downto 0);
		current_k : in std_logic_vector(10 downto 0);
        enable : in std_logic;
		o_mem_addr : out std_logic_vector(15 downto 0)
	);
end component adder;

component modified_mux is
    port (
        i_mem_data : in std_logic_vector(7 downto 0);
		current_k : in std_logic_vector (10 downto 0);
        enable :  in std_logic;
		need_to_write_c : out std_logic;
		need_to_write_w : out std_logic;
		rst_c : out std_logic;
		c_to_zero : out std_logic;
        word_in : out std_logic_vector(7 downto 0);
        sel : out std_logic
    );
end component modified_mux;

component w_register is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		done : in std_logic;
		word_in : in std_logic_vector(7 downto 0);
		word_out : out std_logic_vector(7 downto 0)
	);
end component w_register;

component c_register is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		done : in std_logic;
		rst_c : in std_logic;
		c_to_zero : in std_logic;
		credibility : out std_logic_vector(4 downto 0)
	);
end component c_register;

component mux is
    port (
        word_out : in std_logic_vector(7 downto 0);
		credibility : in std_logic_vector(4 downto 0);
        enable : in std_logic;
        sel : in std_logic;
        o_mem_data : out std_logic_vector(7 downto 0)
    );
end component mux;

component fsm is
    port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
		
		o_done : out std_logic;
		o_mem_en : out std_logic;
		o_mem_we : out std_logic;
		
		need_to_write_c : in std_logic;
		need_to_write_w : in std_logic;
		done : in std_logic;
		
        en_counter : out std_logic;
        en_adder : out std_logic;
        en_w_register : out std_logic;
        en_c_register : out std_logic;
		en_m_mux : out std_logic;
		en_mux : out std_logic
    );
end component fsm;


signal sig_en_counter : std_logic;
signal sig_en_adder : std_logic;
signal sig_en_m_mux : std_logic;
signal sig_en_w_register : std_logic;
signal sig_en_c_register : std_logic;
signal sig_en_mux : std_logic;
signal sig_current_k : std_logic_vector(10 downto 0);
signal sig_done : std_logic;
signal sig_sel : std_logic;
signal sig_need_to_write_c : std_logic;
signal sig_need_to_write_w : std_logic;
signal sig_word_in : std_logic_vector(7 downto 0);
signal sig_rst_c : std_logic;
signal sig_c_to_zero : std_logic;
signal sig_word_out : std_logic_vector(7 downto 0);
signal sig_credibility : std_logic_vector(4 downto 0);


begin

	kc : k_counter port map(
		i_clk => i_clk,
		i_rst => i_rst,
		enable => sig_en_counter,
		i_k => i_k,
		current_k => sig_current_k,
		done => sig_done
	);

	add : adder port map(
		i_add => i_add,
		current_k => sig_current_k,
        enable => sig_en_adder,
		o_mem_addr => o_mem_addr
	);

	mmux : modified_mux port map (
        i_mem_data => i_mem_data,
		current_k => sig_current_k,
        enable => sig_en_m_mux,
		need_to_write_c => sig_need_to_write_c,
		need_to_write_w => sig_need_to_write_w,
		rst_c => sig_rst_c,
		c_to_zero => sig_c_to_zero,
        word_in => sig_word_in,
        sel => sig_sel
    );

	wr : w_register port map (
		i_clk => i_clk,
		i_rst => i_rst,
		enable => sig_en_w_register,
		done => sig_done,
		word_in => sig_word_in,
		word_out => sig_word_out
	);

	cr : c_register port map (
		i_clk => i_clk,
		i_rst => i_rst,
		enable => sig_en_c_register,
		done => sig_done,
		rst_c => sig_rst_c,
		c_to_zero => sig_c_to_zero,
		credibility => sig_credibility
	);

	m : mux port map (
        word_out => sig_word_out,
		credibility => sig_credibility,
        enable => sig_en_mux,
        sel => sig_sel,
        o_mem_data => o_mem_data
    );

	f : fsm port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
		o_done => o_done,
		o_mem_en => o_mem_en,
		o_mem_we => o_mem_we,
		need_to_write_c => sig_need_to_write_c,
		need_to_write_w => sig_need_to_write_w,
		done => sig_done,
        en_counter => sig_en_counter,
        en_adder => sig_en_adder,
        en_w_register => sig_en_w_register,
        en_c_register => sig_en_c_register,
		en_m_mux => sig_en_m_mux,
		en_mux => sig_en_mux
    );

end struttura_arch;














------------------------------ fsm ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fsm is
    port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
		
		o_done : out std_logic;
		o_mem_en : out std_logic;
		o_mem_we : out std_logic;
		
		need_to_write_c : in std_logic;
		need_to_write_w : in std_logic;
		done : in std_logic;
		
        en_counter : out std_logic;
        en_adder : out std_logic;
        en_w_register : out std_logic;
        en_c_register : out std_logic;
		en_m_mux : out std_logic;
		en_mux : out std_logic
    );
end fsm;

architecture fsm_arch of fsm is
type S is (INIT, CURRENT_K, CURRENT_ADDRESS, READ_W, SAVE_W, WRITE_W, WRITE_C, DONE_STATE);
signal curr_state : S;
begin

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            curr_state <= INIT;
        elsif rising_edge(i_clk) then
            case curr_state is
                when INIT =>
                    if i_start = '1' then
                        curr_state <= CURRENT_K;
                    end if;
                when CURRENT_K =>
				    curr_state <= CURRENT_ADDRESS;
                when CURRENT_ADDRESS =>
                    if done = '0' then
                        curr_state <= READ_W;
                    else
                        curr_state <= DONE_STATE;
                    end if;
                when READ_W =>
					if need_to_write_c = '0' and need_to_write_w = '0' then
						curr_state <= SAVE_W;
					elsif need_to_write_c = '1' then
						curr_state <= WRITE_C;
				    else
				        curr_state <= WRITE_W;
					end if;
				when SAVE_W =>
					curr_state <= CURRENT_K;
				when WRITE_W =>
					curr_state <= CURRENT_K;
				when WRITE_C =>
                    curr_state <= CURRENT_K;
				when DONE_STATE =>
					if i_start = '0' then
						curr_state <= INIT;
					end if;
            end case;
        end if;
    end process;
    
    process(curr_state)
    begin
        o_done <= '0';
		o_mem_en <= '0';
		o_mem_we <= '0';
		en_counter <= '0';
        en_adder <= '0';
        en_w_register <= '0';
        en_c_register <= '0';
		en_m_mux <= '0';
		en_mux <= '0';

        if curr_state = CURRENT_K then
            en_counter <= '1';
        elsif curr_state = CURRENT_ADDRESS then
            en_adder <= '1';
			o_mem_en <= '1';
        elsif curr_state = READ_W then
			en_adder <= '1';
			o_mem_en <= '1';
            en_m_mux <= '1';
		elsif curr_state = SAVE_W then
			en_adder <= '1';
			o_mem_en <= '1';
            en_m_mux <= '1';
            en_w_register <= '1';
            en_c_register <= '1';
		elsif curr_state = WRITE_W then
			en_adder <= '1';
			o_mem_en <= '1';
            en_m_mux <= '1';
            en_mux <= '1';
			o_mem_we <= '1';
		elsif curr_state = WRITE_C then
		    en_c_register <= '1';
            en_adder <= '1';
            o_mem_en <= '1';
            en_m_mux <= '1';
            en_mux <= '1';
            o_mem_we <= '1';
		elsif curr_state = DONE_STATE then
			o_done <= '1';
        end if;
    end process;
	
end fsm_arch;














------------------------------ k_counter ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity k_counter is
   port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		i_k : in std_logic_vector(9 downto 0);
		current_k : out std_logic_vector(10 downto 0);
		done : out std_logic
	);
end k_counter;

architecture k_counter_arch of k_counter is
signal count : std_logic_vector(10 downto 0);
	begin
		process (i_clk, i_rst)
		begin
			if (i_rst = '1') then
				count <= "00000000000";
				current_k <= "00000000000";
				done <= '0';
			elsif rising_edge(i_clk) and enable = '1' then
			    if count <= std_logic_vector(signed(i_k(9 downto 0) & '0')-1) and i_k > "0000000000" then
					current_k <= count;
					count <= std_logic_vector(signed(count) + 1);
                    done <= '0';
				else
				    done <= '1';
                    count <= "00000000000";
                    current_k <= "00000000000";
                end if;
			end if;
		end process;
end k_counter_arch;














------------------------------ adder ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
	port(
		i_add : in std_logic_vector(15 downto 0);
		current_k : in std_logic_vector(10 downto 0);
        enable : in std_logic;
		o_mem_addr : out std_logic_vector(15 downto 0)
	);
end adder;

architecture adder_arch of adder is
begin
	process(enable, i_add, current_k)
	variable ext_current_k : std_logic_vector(15 downto 0) := (others => '0');
	variable sum : unsigned(15 downto 0) := (others => '0');
	begin
	    o_mem_addr <= (others => '0');
	    if (enable = '1') then
			ext_current_k := "00000" & current_k;
            sum := unsigned(i_add) + unsigned(ext_current_k);
            o_mem_addr <= std_logic_vector(sum);
        end if;
	end process;
end adder_arch;














------------------------------ modified_mux ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity modified_mux is
    port (
        i_mem_data : in std_logic_vector(7 downto 0);
		current_k : in std_logic_vector (10 downto 0);
        enable :  in std_logic;
		need_to_write_c : out std_logic;
		need_to_write_w : out std_logic;
		rst_c : out std_logic;
        word_in : out std_logic_vector(7 downto 0);
        sel : out std_logic;
		c_to_zero : out std_logic
    );
end modified_mux;

architecture modified_mux_arch of modified_mux is
begin
	process(enable, i_mem_data, current_k)
	begin
		need_to_write_c <= '0';
		need_to_write_w <= '0';
		rst_c <= '0';
		word_in <= (others => '0');
		sel <= '0';
		c_to_zero <= '0';
		if enable = '1' then
			--current_k dispari (credibilità)
			if current_k(0) = '1' then
				need_to_write_c <= '1';
				sel <= '1';
			else
				--current_k pari (parola)
				if i_mem_data > "00000000" then
					word_in <= i_mem_data;
					rst_c <= '1';
				elsif i_mem_data = "00000000" then
					need_to_write_w <= '1';
					sel <= '0';
					if current_k = "00000000000" then
						c_to_zero <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;
end modified_mux_arch;













------------------------------ w_register ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity w_register is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		done : in std_logic;
		word_in : in std_logic_vector(7 downto 0);
		word_out : out std_logic_vector(7 downto 0)
	);
end w_register;

architecture w_register_arch of w_register is
begin
	process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			word_out <= (others => '0');
		elsif rising_edge(i_clk) then
			if enable = '1' then
				word_out <= word_in;
			end if;
			if done = '1' then
				word_out <= (others => '0');
			end if;
		end if;
	end process;
end w_register_arch;













------------------------------ c_register ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity c_register is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
		enable : in std_logic;
		done : in std_logic;
		rst_c : in std_logic;
		c_to_zero : in std_logic;
		credibility : out std_logic_vector(4 downto 0)
	);
end c_register;

architecture c_register_arch of c_register is
signal count : std_logic_vector(4 downto 0);
begin
	process(i_clk, i_rst)
	begin
		if i_rst = '1' then
			credibility <= (others => '1');
			count <= (others => '1');
		elsif rising_edge(i_clk) then
			if enable = '1' then
				credibility <= count;
				if count > "00000" then
					count <= std_logic_vector(signed(count) - 1);
				end if;
			elsif c_to_zero = '1' then
				credibility <= (others => '0');
				count <= (others => '0');
			elsif rst_c = '1' then
				credibility <= (others => '1');
				count <= (others => '1');
			elsif done = '1' then
				credibility <= (others => '1');
				count <= (others => '1');
			end if;
		end if;
	end process;
end c_register_arch;














------------------------------ mux ------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux is
    port (
        word_out : in std_logic_vector(7 downto 0);
		credibility : in std_logic_vector(4 downto 0);
        enable : in std_logic;
        sel : in std_logic;
        o_mem_data : out std_logic_vector(7 downto 0)
    );
end mux;

architecture mux_arch of mux is
begin
	process(enable, sel, word_out, credibility)
	begin
		o_mem_data <= (others => '0');
		if enable = '1' then
			case sel is
				when '0' =>
					o_mem_data <= word_out;
				when '1' =>
					o_mem_data <= "000" & credibility;
				when others =>
			end case;
		end if;
	end process;
end architecture;