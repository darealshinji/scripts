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

#include <iostream>
#include <iomanip>

#include <stdio.h>
#include <stdlib.h>
#include <sys/timeb.h>
#include <time.h>

#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

/* https://gist.github.com/vsajip/1864660 */
int kbhit()
{
  struct termios oldt, newt;
  int ch;
  int oldf;

  tcgetattr(STDIN_FILENO, &oldt);
  newt = oldt;
  newt.c_lflag &= ~(ICANON | ECHO);
  tcsetattr(STDIN_FILENO, TCSANOW, &newt);
  oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
  fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);

  ch = getchar();

  tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
  fcntl(STDIN_FILENO, F_SETFL, oldf);

  if(ch != EOF)
  {
    ungetc(ch, stdin);
    return 1;
  }

  return 0;
}

void stopwatch()
{
  timeb tb;
  int time_start, time;

  std::cout << "Press any key to start the timer" << std::flush;
  while (!kbhit());
  std::cout << "\r                                " << std::flush;

  ftime(&tb);
  time_start = (int)tb.time * 1000 + (int)tb.millitm;

  while (true)
  {
    ftime(&tb);
    time = (int)tb.time * 1000 + (int)tb.millitm - time_start;

    std::cout << "\r"
      << std::setfill('0') << std::setw(2) << time / 3600000 << ":"
      << std::setfill('0') << std::setw(2) << (time / 60000) % 60 << ":"
      << std::setfill('0') << std::setw(2) << (time / 1000) % 60 << "."
      << std::setfill('0') << std::setw(2) << (time % 1000) / 10
      << std::flush;

    /* sleep for 0.009 seconds */
    nanosleep((const struct timespec[]) {{ 0, 9000000L }}, NULL);
  }
}

int main()
{
  stopwatch();
  return 0;
}
