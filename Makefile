#
#	Makefile for this SNAP example
#	- modify Makefile.ex when creating a new SNAP example
#
#	implements:
#		all (default), clean
#
 
include ../../Makefile.config
include Makefile.ex
CXXFLAGS += -g -fPIC 

all: $(MAIN)

# COMPILE
$(MAIN): $(MAIN).cpp $(DEPH) $(DEPCPP) $(EXSNAP)/Snap.o 
	MAKEFLAGS="PKG_CPPFLAGS=-I../../snap-core\ -I../../snap-adv\ -I../../glib-core\ -lrt\ -fPIC" R CMD SHLIB $(MAIN).cpp $(DEPCPP) $(EXSNAP)/Snap.o -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB) $(LDFLAGS) $(LIBS) 
	$(CC) $(CXXFLAGS) -o $(MAIN) $(MAIN).cpp $(DEPCPP) $(EXSNAP)/Snap.o -I /usr/share/R/include -I$(EXSNAP) -I$(EXSNAPADV) -I$(EXGLIB) $(LDFLAGS) $(LIBS)

$(EXSNAP)/Snap.o: 
	make -C $(EXSNAP)


clean:
	rm -f *.o  $(MAIN)  $(MAIN).exe *.user
	rm -rf Debug Release
