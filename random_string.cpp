#include <iostream>

#include <sstream>
#include <time.h>

std::string random_string(size_t length)
{
  struct timespec ts;
  char ch;
  std::stringstream ss;
  const char charset[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
  const size_t max_index = (sizeof(charset) - 1);

  for (size_t i = 0; i <= length; ++i)
  {
    timespec_get(&ts, TIME_UTC);
    ch = charset[ts.tv_nsec % max_index];
    ss << ch;
  }
  return ss.str();
}

int main(void)
{
  std::cout << "random: " << random_string(8) << std::endl;
  return 0;
}

