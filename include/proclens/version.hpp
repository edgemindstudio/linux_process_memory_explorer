#ifndef PROCLENS_VERSION_HPP
#define PROCLENS_VERSION_HPP

#include <string_view>

namespace proclens {

inline constexpr int VERSION_MAJOR = 0;
inline constexpr int VERSION_MINOR = 1;
inline constexpr int VERSION_PATCH = 0;

[[nodiscard]] constexpr auto version_string() noexcept -> std::string_view {
    return "0.1.0";
}

static_assert(VERSION_MAJOR == 0);
static_assert(VERSION_MINOR == 1);
static_assert(VERSION_PATCH == 0);
static_assert(version_string() == "0.1.0");

[[nodiscard]] auto product_name() noexcept -> std::string_view;

[[nodiscard]] auto platform_name() noexcept -> std::string_view;

} // namespace proclens

#endif
