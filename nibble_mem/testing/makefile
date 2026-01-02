TOP = nibble_mem
RTL = ../rtl/$(TOP).v
CPP = sim_main.cpp

all: sim

sim:
	verilator -Wall --cc $(RTL) --exe $(CPP) --top-module $(TOP)
	$(MAKE) -C obj_dir -f V$(TOP).mk
	cp obj_dir/V$(TOP) ./sim

clean:
	rm -rf obj_dir sim
