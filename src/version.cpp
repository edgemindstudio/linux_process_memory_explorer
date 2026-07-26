#include "proclens/version.hpp"

namespace proclens {

auto product_name() noexcept -> std::string_view {
    return "ProcLens";
}

auto platform_name() noexcept -> std::string_view {
#ifdef __linux__
    return "Linux";
#else
    return "Unsupported platform";
#endif
}

} // namespace proclens
