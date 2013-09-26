#
#	Makefile for this SNAP example
#	- modify Makefile.ex when creating a new SNAP example
#
#	implements:
#		all (default), clean
#
 
include ../../Makefile.config
include Makefile.ex
CXXFLAGS += -g

all: $(MAIN)

# COMPILE
$(MAIN): $(MAIN).cpp $(DEPH) $(DEPCPP) $(EXSNAP)/Snap.o 
#	MAKEFLAGS="PKG_CPPFLAGS=-I../../snap-core\ -I../../snap-adv\ -I../../glib-core\ -lrt" R CMD SHLIB $(MAIN).cpp $(DEPCPP) $(EXSNAP)/Snap.o -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB) $(LDFLAGS) $(LIBS)
	$(CC)  $(CXXFLAGS) -c $(MAIN).cpp -o $(MAIN).o  -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB)
	$(CC)  $(CXXFLAGS) -o $(MAIN) $(MAIN).o $(DEPCPP) $(EXSNAP)/Snap.o -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB) $(LDFLAGS) $(LIBS)
	$(CC)  $(CXXFLAGS) -shared -o rdssim.so -fPIC rdssim.cpp -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB) $(LDFLAGS) $(LIBS)

$(EXSNAP)/Snap.o: 
	make -C $(EXSNAP)


clean:
	rm -f *.o  $(MAIN)  $(MAIN).exe *.user
	rm -rf Debug Release
