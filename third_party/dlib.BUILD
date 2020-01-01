cc_library(
    name = "dlib",
    hdrs = glob(["dlib-*/dlib/**/*.h"]),
    linkstatic = 1,
    strip_include_prefix = glob(["dlib-*/.gitignore"])[0].split("/", 1)[0],
    visibility = ["//visibility:public"],
)
