# Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

def rev_end(input, chunksize):
    BYTE_LEN = 2
    chunksize *= 2  # bytes -> chars
    chunks = [input[i:i+chunksize] for i in range(0, len(input), chunksize)]
    new_chunks = []
    for chunk in chunks:
        sc = [chunk[i:i+BYTE_LEN] for i in range(0, len(chunk), BYTE_LEN)]
        new_chunks.append("".join(reversed(sc)))
    return new_chunks

def print_asm(chunks):
    for chunk in chunks:
        print(f".dword 0x{chunk}")


def print_exp(chunks):
    print(f"0x{''.join([c.lower() for c in chunks])}")


chunks = rev_end("3A3A819C48EFDE2AD914FBF00E18AB6BC4F14513AB27D0C178A188B61431E7F5623CB66B23346775D386B50E982C493ADBBFC54B9A3CD383382336A1A0B2150A15358F336D03AE18F666C7573D55C4FD181C29E6CCFDE63EA35F0ADF5885CFC0A3D84A2B2E4DD24496DB789E663170CEF74798AA1BBCD4574EA0BBA40489D764B2F83AADC66B148B4A0CD95246C127D5871C4F11418690A5DDF01246A0C80A43C70088B6183639DCFDA4125BD113A8F49EE23ED306FAAC576C3FB0C1E256671D817FC2534A52F5B439F72E424DE376F4C565CCA82307DD9EF76DA5B7C4EB7E085172E328807C02D011FFBF33785378D79DC266F6A5BE6BB0E4A92ECEEBAEB1", 8)
print_asm(chunks)
chunks = rev_end("6E8B8BD195BDD560689AF2348BDC74AB7CD05ED8B9A57711E9BE71E9726FDA4591FEE12205EDACAF82FFBBAF16DFF9E702A708862080166C2FF6BA379BC7FFC2", 4)
print_exp(chunks)