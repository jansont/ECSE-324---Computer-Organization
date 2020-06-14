extern int MAX_2(int x, int y);

int main() {	

	// int a, b, c;
	// a = 1;
	// b = 2;
	// c = MAX_2(a,b);
	// return c;

	int a[5] = {1,20,3,4,5};
	int max_val = a[0];
	int i;

	for (i = 0; i < sizeof(a)/sizeof(max_val); i++) {
		max_val = MAX_2(a[i], max_val);
	}

	return max_val;
}
