// SPDX-License-Identifier: GPL-3.0-or-later
unsigned powmod(unsigned base, unsigned exp, unsigned modulo)
{
	unsigned ret = 1;
	base %= modulo;
	while (exp) {
		if ((exp % 2) == 1) {
			ret = (ret * base) % modulo;
		}
		exp >>= 1;
		base = (base * base) % modulo;
	}
	return ret;
}
