#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include "simon.h"

#define OPTION		"vhs"

typedef void (*enc_t)(uint64_t *, uint64_t *, uint64_t *);
typedef void (*dec_t)(uint64_t *, uint64_t *, uint64_t *);

int main(int argc, char **argv)
{
	int opt;

	enc_t enc = &simon_enc;
	dec_t dec = &simon_dec;

	uint64_t key[4] = {0x0, 0x0, 0x0, 0x0};
	uint64_t ct[2] = {0};
	uint64_t pt[2] = {0x6d69732061207369, 0x74206e69206d6f6f};
	uint64_t pt_1[2] = {0};
	uint64_t ct_1[2] = {0x3bf72a87efe7b868, 0x8d2b5579afc8a3a0};

	while ((opt = getopt(argc, argv, OPTION)) != -1) {
		switch(opt) {
		case 'v':
			set_verbose();
			break;
		case 's':
			enc = &ssimon_enc;
			dec = &ssimon_dec;

			key[0] = 0; key[1] = 0; key[2] = 0; key[3] = 0;
			pt[0] = 4; pt[1] = 0;
			ct_1[1] = 0x5443df36fb0a7d4a; ct[0] = 0x6a160cadce4b21e6; 
			break;
		case 'h':
		default:
			printf("Usage: ./simon-test [-h] [-s] [-v]\n");
			printf("-h: print usage information\n");
			printf("-s: Use the SimpleSimon cipher. Default is Simon.\n");
			printf("-v: Verbose mode. Prints the key schedule and values during each round.\n");
			exit(1);
			break;
		}
	}

	enc(pt, ct, key);
	dec(pt_1, ct, key);

	printf("Key:\t\t\t%016lX %016lX %016lX %016lX\n", key[3], key[2], key[1], key[0]);
	printf("Plaint text:\t\t%016lX %016lX\n", pt[1], pt[0]);
	printf("Cipher text:\t\t%016lX %016lX\n", ct[1], ct[0]);
	printf("Decrypted Plaint text:\t%016lX %016lX\n", pt_1[1], pt_1[0]);

	return 0;
}
