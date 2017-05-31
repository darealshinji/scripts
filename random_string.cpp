/**
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
 */

#include <iostream>
#include <sstream>

#include <time.h>
#include <stdlib.h>
#include <string.h>


std::string random_string(size_t length)
{
  struct timespec ts;
  char ch;
  std::stringstream ss;
  const char charset[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  const size_t max_index = (sizeof(charset) - 1);

  for (size_t i = 0; i < length; ++i)
  {
    timespec_get(&ts, TIME_UTC);
    ch = charset[ts.tv_nsec % max_index];
    ss << ch;
  }
  return ss.str();
}

int main(int argc, char **argv)
{
  int n = 16;

  if (argc == 2)
  {
    if (strcmp("--help", argv[1]) == 0)
    {
      std::cout << "usage: " << argv[0] << " [LENGTH<0..2048>]" << std::endl;
      return 0;
    }

    n = atoi(argv[1]);

    if (n < 1)
    {
      n = 16;
    }
    else if (n > 2048)
    {
      n = 2048;
    }
  }

  std::cout << random_string(n) << std::endl;
  return 0;
}

