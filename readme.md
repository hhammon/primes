# Description

This is an implementation of the Sieve of Eratosthenes in x86-64 assembly. The program takes a single command line argument to specify an upper bound and prints all primes up to it.

I decided to take this on without any linking to stdlib, so I first needed to write a simple library of functions to do basic tasks like printing, allocating memory and parsing using Linux syscalls and raw assembly.

This is the largest assembly project I've taken on before having only used it prior to learn about computers at a low level. I'm happy with how it turned out and the amount I learned doing it, despite the frustrations of debugging it. I took the better part of a day to get it working correctly.

It gets all of the performance a sieve should get. It uses standard optimiztions like only checking up to the square root of the number, checking divisibility only by known primes, and skipping even numbers. It also uses a bit array to store the sieve lessening the memory requirements. The sieve, of all major prime generation algorithms, is the most time efficient but least memory efficient, so indexing into a bit array is a good compromise.

# Concerns

-   I'm definitely not following calling conventions. I considered doing it, but I'm not writing a library that any other code will use, so I didn't want to deal with it too much. As a result, only one function makes any use of the stack for its variables, which is the one to print numbers. The rest use registers or allocated memory for everything.

-   I'm sure there are optimizations that could be made. I'm always amazed by how esoteric compiler output tends to be to get the best performance. Most of what I did was relatively straightforward... except the division by 10 in the print_num function. I got a little crazy with that one.

# Usage

I ran it on an older laptop with an Intel i7-8550U CPU running Windows with WSL.

There's a build script included using `as` to assemble and `ld` to link.

```bash
./build.sh
```

Then it can be run:

```bash
./gen-primes <upper_bound>
```

This repo includes the output of:

```bash
./gen-primes 1000000 > primes.txt
```
