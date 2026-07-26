#include "proclens/version.hpp"

#include <iostream>

auto main() -> int {
    std::cout << proclens::product_name() << ' ' << proclens::version_string() << '\n';
    std::cout << "Platform: " << proclens::platform_name() << '\n';
    std::cout << "Milestone 0 foundation build\n";

    return 0;
}
