#include <stdio.h>

int main(void) {
    long long N = 5277616985;
    int sum = 0;

    while (N > 0) {
        sum += N % 10;
        N /= 10;
    }

    printf("%d\n", sum);
    return 0;
}
