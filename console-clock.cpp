/*
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <http://unlicense.org/>
 *
 * Contributors:
 *   2017 djcj <djcj@gmx.de>
 */
 
 /* prints and updates the current system time */

#include <iostream>
#include <iomanip>

#include <sys/timeb.h>
#include <time.h>

void console_clock()
{
  while (true)
  {
    time_t t = time(0);
    struct tm *time = localtime(&t);
    timeb tb;
    ftime(&tb);

    std::cout
      << std::setfill('0') << std::setw(2) << time->tm_hour << ":"
      << std::setfill('0') << std::setw(2) << time->tm_min << ":"
      << std::setfill('0') << std::setw(2) << time->tm_sec << "."
      << std::setfill('0') << std::setw(1) << tb.millitm/100  /* 1/10th of a second */
      << std::flush << "\r";  /* flush screen and jump to begin of line */

    nanosleep((const struct timespec[]) {{ 0, 50000000L }}, NULL);  /* sleep for 0.05 seconds */
  }
}

int main()
{
  console_clock();
  return 0;
}
