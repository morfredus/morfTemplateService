find_package(Qt6 REQUIRED COMPONENTS Core)

add_executable(morftemplate_demo main.cpp)
target_link_libraries(morftemplate_demo PRIVATE morfTemplateService::morfTemplateService Qt6::Core)

if(MSVC)
    target_compile_options(morftemplate_demo PRIVATE /utf-8)
endif()
