# Demon de service morfTemplateService : execute la bibliotheque en tache de fond.
# Le binaire s'appelle « morftemplate » (comme l'unite systemd et /opt/morftemplate).
add_executable(morftemplate main.cpp)

target_link_libraries(morftemplate PRIVATE morfTemplateService::morfTemplateService Qt6::Core)

if(MSVC)
    target_compile_options(morftemplate PRIVATE /utf-8)
endif()

install(TARGETS morftemplate RUNTIME DESTINATION bin)
