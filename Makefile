default: build

build:
	dune build

test:
	dune runtest

all: build

clean:
	dune clean

.PHONY: build doc test all clean