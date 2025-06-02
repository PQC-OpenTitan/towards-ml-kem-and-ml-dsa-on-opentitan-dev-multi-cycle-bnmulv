#! /bin/bash

set -e;

TMPDIR="tmp-kybertest"
mkdir $TMPDIR

# Run the assembler on each file
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber512_mlkem_keypair_test.o sw/otbn/crypto/tests/kyber512_mlkem_keypair_test.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_packing.o sw/otbn/crypto/kyber-handwritten/kyber_packing.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_poly_gen_matrix.o sw/otbn/crypto/kyber-handwritten/kyber_poly_gen_matrix.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_poly.o sw/otbn/crypto/kyber-handwritten/kyber_poly.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_cbd_isaext.o sw/otbn/crypto/kyber-handwritten/kyber_cbd_isaext.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_basemul.o sw/otbn/crypto/kyber-handwritten/kyber_basemul.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_ntt.o sw/otbn/crypto/kyber-handwritten/kyber_ntt_trn.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_intt.o sw/otbn/crypto/kyber-handwritten/kyber_intt_trn.s
hw/ip/otbn/util/otbn_as.py -DKYBER_K=2 -o $TMPDIR/kyber_mlkem.o sw/otbn/crypto/kyber-handwritten/kyber_mlkem.s

# Run the linker to generate a .elf file
hw/ip/otbn/util/otbn_ld.py -o $TMPDIR/kyber512_mklem_keypair_test.elf $TMPDIR/kyber512_mlkem_keypair_test.o $TMPDIR/kyber_packing.o $TMPDIR/kyber_poly_gen_matrix.o $TMPDIR/kyber_poly.o $TMPDIR/kyber_cbd_isaext.o $TMPDIR/kyber_basemul.o $TMPDIR/kyber_ntt.o $TMPDIR/kyber_intt.o $TMPDIR/kyber_mlkem.o

# Run the test
./hw/ip/otbn/util/otbn_sim_test.py -v hw/ip/otbn/dv/otbnsim/standalone.py sw/otbn/crypto/tests/kyber512_mlkem_keypair_test.exp $TMPDIR/kyber512_mklem_keypair_test.elf

# Clean up
rm $TMPDIR/*
rmdir $TMPDIR
