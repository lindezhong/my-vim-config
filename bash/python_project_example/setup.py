import setuptools

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
    install_requires=get_install_requires()
)
