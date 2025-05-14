# Test OTBN PQ Extensions

Script to run assembly tests with the verilator model against the python instruction set simulator (ISS).

```bash
./run_smoke_pq.sh                           # run all assembly tests in /hw/ip/otbn/sw
./run_smoke_pq.sh -s                        # skip building verilator model (must be built already)
./run_smoke_pq.sh -t ../smoke/smoke_test.s  # test only the specified assembly file
```
NOTE: You will only see missmatches between the ISS and the verilator model.
This does not mean that the ISS behaves correctly.

