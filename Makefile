all: scheme2llvm.llvm

clean:
	-rm core *.llvm *.bc *.s test/*.llvm test/*.bc test/*.s test/*.ll

TEST_SRC := $(wildcard test/*.scm) 

compile: scheme2llvm.llvm $(TEST_SRC:.scm=.llvm)

tests: test/semantics.llvm
	./$^

%.ll: %.scm scheme2llvm.llvm
	ulimit -v 50000; cat $< | ./scheme2llvm.llvm > $@

scheme2llvm.ll: scheme2llvm.scm
	ulimit -v 50000; cat $< | ./scheme2llvm.llvm > $@
	
scheme2llvm.csi.ll: scheme2llvm.scm
	cat $^ | csi -q $^ > $@

scheme2llvm.csi: scheme2llvm.scm
	csc -O5 scheme2llvm.scm -o $@

%.bc: %.ll
	opt -O3 $^ -o $@

%.s: %.bc
	llc -O3 $^

%.ll: %.c
	clang -S -emit-llvm $^ -o $@

%.llvm: %.s
	clang $^ -o $@ -lgc

bootstrap:
	make scheme2llvm.llvm
	touch scheme2llvm.scm
	make scheme2llvm.llvm

benchmark:
	-rm scheme2llvm.ll
	/usr/bin/time -v make scheme2llvm.ll

size:
	 cat scheme2llvm.scm| sed 's/\(.\)/\1\n/g' | sort | uniq -c | sort -n | grep "("
