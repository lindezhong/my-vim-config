#include <pybind11/pybind11.h>
#include <iostream>
 
using namespace std;
 
class Box
{
   public:
      double length;   // 长度
      double breadth;  // 宽度
      double height;   // 高度
      // 成员函数声明
      double get(void);
      void set( double len, double bre, double hei );
};
// 成员函数定义
double Box::get(void)
{
    return length * breadth * height;
}
 
void Box::set( double len, double bre, double hei)
{
    length = len;
    breadth = bre;
    height = hei;
}

int add(int i, int j) {
    return i + j;
}

// 需要安装 pybind11 , pip3 install pybind11 & sudo apt install -y python3-pybind11 
namespace py = pybind11;

PYBIND11_MODULE(pybind11, m) {
    m.doc() = R\"pbdoc(
        文档说明
        -----------------------

        .. currentmodule:: cClass

        .. autosummary::
           :toctree: _generate

           add
           subtract
    )pbdoc\";

    // 方法定义
    m.def(\"add\", &add, R\"pbdoc(
        文档说明
    )pbdoc\");

    // 使用表达式定义方法
    m.def(\"subtract\", [](int i, int j) { return i - j; }, R\"pbdoc(
        文档说明
    )pbdoc\");

    // 定义类
    py::class_<Box>(m, \"Box\")
        .def(py::init<>())
        .def(\"set\", &Box::set)
        .def(\"get\", &Box::get);


// #ifdef VERSION_INO
//     m.attr(\"__version__\") = MACRO_STRINGIFY(VERSION_INFO);
// #else
//     m.attr(\"__version__\") = \"dev\";
// #endif

}
