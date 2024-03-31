as -o gen-primes.o gen-primes.s
as -o lib.o lib.s
ld -o gen-primes gen-primes.o lib.o -nostdlib
