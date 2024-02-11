#include <Python.h>

static unsigned int _c_fun(unsigned int n)
{
  unsigned int sum = 0;
  unsigned int i = 0;

  for(; i <= n; i++)
    sum += i;

  return sum;
}

static PyObject *c_fun(PyObject* self, PyObject* args)
{
  unsigned int n = 0;

  // 类型解析参考 https://docs.python.org/3/c-api/arg.html#c.PyArg_ParseTuple
  if(!PyArg_ParseTuple(args, \"i\", &n))
    return NULL;

  return Py_BuildValue(\"i\",_c_fun(n));
}

static PyMethodDef cFunMethods[] =
{
  {\"c_fun\", c_fun, METH_VARARGS, \"Python 封装C语言函数\"},
  {NULL, NULL, 0, NULL}

};

static PyModuleDef cFunModule =
{
  PyModuleDef_HEAD_INIT,
  \"cfun\",                   // module name
  \"Python封装C语言模块\",// module description
  -1,
  cFunMethods
};


// 仅有的非 static 函数，对外暴露模块接口，PyInit_name 必须和模块名相同
// only one non-static function
PyMODINIT_FUNC PyInit_cfun(void)
{
  return PyModule_Create(&cFunModule);
}
