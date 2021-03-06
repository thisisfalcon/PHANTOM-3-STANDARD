all_elfs = decode capture scan_phantom calc_hopping
all_objects = bk5811_demodu.o parse_opt.o decode.o capture.o scan_phantom.o calc_hopping.o
all: $(all_elfs)
.PHONY : all

CFLAGS += -g -Wall -std=c99
bk5811_demodu_objects = bk5811_demodu.o
parse_opt_objects = parse_opt.o
decode_objects = decode.o
capture_objects = capture.o
scan_phantom_objects = scan_phantom.o
calc_hopping_objects = calc_hopping.o

# should be modify when it's change
ifeq ($(shell uname), Linux)
HACKRF_INCLUDE := -I/usr/local/include/libhackrf
HACKRF_LIB := -L/usr/local/lib -lhackrf 
else ifeq ($(shell uname), Darwin)
HACKRF_INCLUDE := -I/usr/local/include/libhackrf
HACKRF_LIB := -L/usr/local/lib -lhackrf
endif

# if the .h has been modified, should be recompile.
# compile
# no need hackrf header
#$(bk5811_demodu_objects) $(decode_objects) : bk5811_demodu.h packet_common.h
#$(bk5811_demodu_objects) $(decode_objects) : %.o : %.c
#	$(CC) $(CFLAGS) -c $< -o $@
# need hackrf header
#$(capture_objects) $(scan_phantom_objects) $(calc_hopping_objects) : rf_common.h bk5811_demodu.h
#$(capture_objects) $(scan_phantom_objects) $(calc_hopping_objects) : %.o : %.c
#	$(CC) $(CFLAGS) $(HACKRF_INCLUDE) -c $< -o $@
$(all_objects) : bk5811_demodu.h packet_common.h rf_common.h parse_opt.h
$(all_objects) : %.o : %.c
	$(CC) $(CFLAGS) $(HACKRF_INCLUDE) -c $< -o $@
	
# link
# decode no need hackrf libs
decode : $(bk5811_demodu_objects) $(parse_opt_objects) $(decode_objects) 
	$(CC) -o decode $(CFLAGS) $(bk5811_demodu_objects) $(parse_opt_objects) $(decode_objects)
# capture nedd hackrf libs
capture : $(parse_opt_objects) $(capture_objects) 
	$(CC) -o capture $(CFLAGS) $(parse_opt_objects) $(capture_objects) $(HACKRF_LIB) 
# scan_phantom need hackrf libs
scan_phantom : $(parse_opt_objects) $(scan_phantom_objects) $(bk5811_demodu_objects) 
	$(CC) -o scan_phantom $(CFLAGS) $(parse_opt_objects) $(scan_phantom_objects) $(HACKRF_LIB) $(bk5811_demodu_objects) 
# calc_hopping need hackrf libs
calc_hopping : $(calc_hopping_objects) $(bk5811_demodu_objects) 
	$(CC) -o calc_hopping $(CFLAGS) $(parse_opt_objects) $(calc_hopping_objects) $(HACKRF_LIB) $(bk5811_demodu_objects) 

.PHONY : clean
clean :
	-rm -f $(all_objects) 
	-rm -f $(all_elfs) 
