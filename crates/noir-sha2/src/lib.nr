pub fn sha2<M>(input: [u8; M], input_len: u16) -> [u8; 32] {
    let k: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ];
    let mut h0: u32 = 0x6A09E667;
    let mut h1: u32 = 0xBB67AE85;
    let mut h2: u32 = 0x3C6EF372;
    let mut h3: u32 = 0xA54FF53A;
    let mut h4: u32 = 0x510E527F;
    let mut h5: u32 = 0x9B05688C;
    let mut h6: u32 = 0x1F83D9AB;
    let mut h7: u32 = 0x5BE0CD19;

    let mut msg: [u8; M] = [0; M];
    for i in 0..M { msg[i] = input[i]; }
    msg[input_len] = 0x80;

    let msg_length_in_bits_as_be_bytes: [u8; 8] = u64_to_u8(input_len as u64 * 8);
    let mut rem: u16 = fast_div_mod_rem(input_len + 1, 64);
    rem = if rem <= 56 {
        56 as u16 - rem
    } else {
        56 as u16 + (64 as u16 - rem)
    };
    let msg_padding_end: u16 = input_len + 1 + rem;
    for i in 0..8 {
        msg[msg_padding_end+i as u16] = msg_length_in_bits_as_be_bytes[i];
    }
    
    let num_chunks: u16 = (msg_padding_end / 64) + 1;
    let num_chunks_max: Field = (M/64);
    for chunk_idx in 0..num_chunks_max {
        if chunk_idx as u16 < num_chunks as u16 {
            let start_idx = chunk_idx * 64;
            let mut chunk: [u8; 64] = [0; 64];
            for j in 0..64 {
                chunk[j] = msg[start_idx as Field + j as Field];
            }
            let mut w: [u32; 64] = [0; 64];
            for i in 0..16 {
                w[i] = bytes_to_u32([
                    chunk[ i * 4],
                    chunk[(i * 4) + 1],
                    chunk[(i * 4) + 2],
                    chunk[(i * 4) + 3]]);
            }
            for i in 16..64 {
                w[i] = sigma1(w[i - 2]) + w[i - 7] + sigma0(w[i - 15]) + w[i - 16];
            }
            
            let (mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut h) = (h0, h1, h2, h3, h4, h5, h6, h7);
            for t in 0..64 {
                let temp1: u32 = h + big_sigma1(e) + ch(e, f, g) + k[t] + w[t];
                let temp2: u32 = big_sigma0(a) + maj(a, b, c);
                h = g;
                g = f;
                f = e;
                e = d + temp1;
                d = c;
                c = b;
                b = a;
                a = temp1 + temp2;
            }
            h0 += a;
            h1 += b;
            h2 += c;
            h3 += d;
            h4 += e;
            h5 += f;
            h6 += g;
            h7 += h;
        }
    }
    
    let h0_bytes = u32_to_u8(h0);
    let h1_bytes = u32_to_u8(h1);
    let h2_bytes = u32_to_u8(h2);
    let h3_bytes = u32_to_u8(h3);
    let h4_bytes = u32_to_u8(h4);
    let h5_bytes = u32_to_u8(h5);
    let h6_bytes = u32_to_u8(h6);
    let h7_bytes = u32_to_u8(h7);

    let mut result: [u8; 32] = [0; 32];
    for i in 0..4 { result[i]     = h0_bytes[i]; }
    for i in 0..4 { result[4+i]   = h1_bytes[i]; }
    for i in 0..4 { result[8+i]   = h2_bytes[i]; }
    for i in 0..4 { result[12+i]  = h3_bytes[i]; }
    for i in 0..4 { result[16+i]  = h4_bytes[i]; }
    for i in 0..4 { result[20+i]  = h5_bytes[i]; }
    for i in 0..4 { result[24+i]  = h6_bytes[i]; }
    for i in 0..4 { result[28+i]  = h7_bytes[i]; }

    result
}

fn fast_div_mod_rem(dividend: u16, divisor: u16) -> u16 {
    if dividend == divisor { 0 }
    else if dividend < divisor { dividend }
    else {
        let quot: u16 = dividend / divisor;
        let rem: u16 = dividend - (divisor * quot);
        rem
    }
}

fn bytes_to_u32(bytes: [u8; 4]) -> u32 {
    bytes[0] as u32 << 24 | bytes[1] as u32 << 16 | bytes[2] as u32 << 8 | bytes[3] as u32
}

fn u32_to_u8(num: u32) -> [u8; 4] {
    let mut result: [u8; 4] = [0; 4];
    for i in 0..4 {
        result[i] = (num >> (24 - (i * 8))) as u8;
    }
    result
}

fn u64_to_u8(num: u64) -> [u8; 8] {
    let mut result: [u8; 8] = [0; 8];
    for i in 0..8 {
        result[i] = (num >> (56 - (i * 8))) as u8;
    }
    result
}

fn sigma0(x: u32) -> u32 {
    right_rotate(x, 7) ^ right_rotate(x, 18) ^ (x >> 3)
}

fn sigma1(x: u32) -> u32 {
    right_rotate(x, 17) ^ right_rotate(x, 19) ^ (x >> 10)
}

fn big_sigma0(x: u32) -> u32 {
    right_rotate(x, 2) ^ right_rotate(x, 13) ^ right_rotate(x, 22)
}

fn big_sigma1(x: u32) -> u32 {
    right_rotate(x, 6) ^ right_rotate(x, 11) ^ right_rotate(x, 25)
}

fn right_rotate(n: u32, d: u32) -> u32 {
    (n >> d) | (n << (32 - d)) & 0xFFFFFFFF
}

fn maj(a: u32, b: u32, c: u32) -> u32 {
    (a & b) ^ (a & c) ^ (b & c)
}

fn ch(a: u32, b: u32, c: u32) -> u32 {
    (a & b) ^ ((!a) & c)
}

#[test]
fn test_sha2() {
    // Hal Finney was a cypherpunk pioneer
    let test_msg: [u8; 64] = [
        0x48, 0x61, 0x6c, 0x20, 0x46, 0x69, 0x6e, 0x6e,
        0x65, 0x79, 0x20, 0x77, 0x61, 0x73, 0x20, 0x61,
        0x20, 0x63, 0x79, 0x70, 0x68, 0x65, 0x72, 0x70,
        0x75, 0x6e, 0x6b, 0x20, 0x70, 0x69, 0x6f, 0x6e,
        0x65, 0x65, 0x72, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
    let test_hash: [u8; 32] =  [
        0xd4, 0x5d, 0xa9, 0xcf, 0x6f, 0xc0, 0xe0, 0x56, 0x7e, 0xa2, 0x7d, 0xf1, 0xbb, 0x17, 0xfb, 0x0a,
        0x28, 0x10, 0x29, 0xca, 0x23, 0x17, 0x4f, 0xd0, 0x64, 0xad, 0xc4, 0x9a, 0x98, 0x7f, 0xd9, 0xff];

    let hash = sha2(test_msg, 35);
    assert(hash == test_hash);
}
