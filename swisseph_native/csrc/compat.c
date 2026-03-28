/* Provide sincos() for platforms that lack it (Android Bionic). */
#include <math.h>

#if defined(__ANDROID__)
void sincos(double x, double *sinp, double *cosp) {
  *sinp = sin(x);
  *cosp = cos(x);
}
#endif
