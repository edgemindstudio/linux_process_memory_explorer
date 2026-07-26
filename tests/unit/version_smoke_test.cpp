#include "proclens/version.hpp"

#include <cstdlib>
#include <iostream>
#include <string_view>

namespace {

[[nodiscard]] auto check(bool condition, std::string_view message) -> bool {
    if (!condition) {
        std::cerr << "FAILED: " << message << '\n';
        return false;
    }

    return true;
}

} // namespace

auto main() -> int {
    bool passed = true;

    passed &= check(proclens::product_name() == "ProcLens", "product_name must be ProcLens");
    passed &= check(!proclens::platform_name().empty(), "platform_name must not be empty");

    if (!passed) {
        return EXIT_FAILURE;
    }

    std::cout << "ProcLens version smoke test passed\n";
    return EXIT_SUCCESS;
}
