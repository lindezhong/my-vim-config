import setuptools
`
if [[ $is_c_project == "y" ]]; then
    echo "import platform"
    echo '
def get_ext_modules() -> list:
    """
    获取三方模块
    Linux和Windows需要编译封装接口
    Mac由于缺乏二进制库支持无法使用
    """
    if platform.system() == "Linux":
        extra_compile_flags = [
            "-std=c++17",
            "-O3",
            "-Wno-delete-incomplete",
            "-Wno-sign-compare",
        ]
        extra_link_args = ["-lstdc++"]
        runtime_library_dirs = ["$ORIGIN"]

    elif platform.system() == "Windows":
        extra_compile_flags = ["-O2", "-MT"]
        extra_link_args = []
        runtime_library_dirs = []

    else:
        return []

    # module = setuptools.Extension(
    #     "'${project_name}'.accumulate",
    #     [
    #         "api/accumulate.c",
    #     ],
    #     # include_dirs=["'${project_name}'/api/include","'${project_name}'/api/vnctp"],
    #     define_macros=[],
    #     undef_macros=[],
    #     # library_dirs=["'${project_name}'/api/libs", "'${project_name}'/api"],
    #     # libraries=["thostmduserapi_se", "thosttraderapi_se"],
    #     extra_compile_args=extra_compile_flags,
    #     extra_link_args=extra_link_args,
    #     runtime_library_dirs=runtime_library_dirs,
    #     depends=[],
    #     language="cpp",
    # )
    c_module = setuptools.Extension(
        "'${project_name}'.api.example.cfun",
        [
          "'${project_name}'/api/example/c_fun.c",
        ],
        # include_dirs=["'${project_name}'/api/include","'${project_name}'/api/vnctp"],
        define_macros=[],
        undef_macros=[],
        # library_dirs=["'${project_name}'/api/libs", "'${project_name}'/api"],
        # libraries=["thostmduserapi_se", "thosttraderapi_se"],
        extra_compile_args=extra_compile_flags,
        extra_link_args=extra_link_args,
        runtime_library_dirs=runtime_library_dirs,
        depends=[],
        language="cpp",
    )
    # 使用pybind11_module需要安装 pybind11 , pip3 install pybind11 & sudo apt install -y python3-pybind11
    pybind11_module = setuptools.Extension(
        "'${project_name}'.api.example.pybind11",
        [
          "'${project_name}'/api/example/pybind11.cpp",
        ],
        # include_dirs=["'${project_name}'/api/include","'${project_name}'/api/vnctp"],
        define_macros=[],
        undef_macros=[],
        # library_dirs=["'${project_name}'/api/libs", "'${project_name}'/api"],
        # libraries=["thostmduserapi_se", "thosttraderapi_se"],
        extra_compile_args=extra_compile_flags,
        extra_link_args=extra_link_args,
        runtime_library_dirs=runtime_library_dirs,
        depends=[],
        language="cpp",
    )


    return [c_module, pybind11_module]
    '
fi
`

def get_install_requires():
    with open('requirements.txt', 'r', encoding='utf-8') as fh:
        return fh.readlines()

with open('README.md', 'r', encoding='utf-8') as fh:
    long_description = fh.read()

setuptools.setup(
    name='$project_name',
    version='`
    read -p "请输入项目版本默认 [${version}] : " use_version
    test -z $use_version && use_version=${version}
    echo $use_version
    `',
    author='$author',
    author_email='$author_email',
    description='`
    read -p "请输入项目说明: " use_description
    test -z "$use_description" && use_description=${description}
    echo $use_description
    `',
    long_description=long_description,
    long_description_content_type='text/markdown',
    url='$url/$project_name',
    project_urls={
        'Bug Tracker': '$url/$project_name/issues',
    },
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: $license',
        'Operating System :: OS Independent',
    ],
    test_suite='tests',
    python_requires='>=$python_version',
    install_requires=get_install_requires(),
`    
if [[ $is_c_project == "y" ]]; then
echo '    ext_modules = get_ext_modules(),'
fi
`
)
