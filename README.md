# Noir SHA-2

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Nargo Test 🌌](https://github.com/michaelelliot/noir-sha2/actions/workflows/test.yml/badge.svg)](https://github.com/michaelelliot/noir-sha2/actions/workflows/test.yml)

This library contains a Noir implementation of the SHA-2 hashing algorithm.

## Usage

In your `Nargo.toml` file, add the following dependency:

```toml
[dependencies]
sha2 = { tag = "v0.0.1", git = "https://github.com/michaelelliot/noir-sha2", directory = "crates/noir-sha2" }
```

Then use it in your Noir project like this:

```rust
use dep::sha2::{sha2};

fn main(input: [u8; 64], input_len: u16, hash: pub [u8; 32]) {
    // Generate SHA-2 hash digest of input
    let compare_hash = sha2(input, input_len);
    assert(hash == compare_hash);
}
```

*NOTE:* The `input` parameter must be a `u8` byte array with a length that's a multiple of 64, such as 64, 128, 192, or 256 etc.
The rest of the byte array can be zero-padded (`0x00`) as shown in the example below, with the `input_len` parameter specifying the number of initial bytes from the `input` to be used for calculating the digest.

Here's an example unit test for the `main` entrypoint above:

```rust
#[test]
fn test_main() {
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
    main(test_msg, 35, test_hash);
}
```

## Example

Noir example source code: [`./example/src/main.nr`](./example/src/main.nr)

## License

MIT License

Copyright (c) 2023 Michael Elliot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
