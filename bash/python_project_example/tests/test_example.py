#!/usr/bin/env python
import unittest
from unittest import suite
from unittest import runner
from ${project_name} import example
`    
if [[ $is_c_project == "y" ]]; then
echo 'from '${project_name}'.api import cfun, pybind11'
fi
`

class TestExample(unittest.TestCase):

    def setUp(self) -> None:
        print(\"测试每个方法前都会调用\")
    def tearDown(self) -> None:
        print(\"测试每个方法后都会调用\")

    @classmethod
    def setUpClass(cls) -> None:
        print(\"整个测试类测试前调用,只是调用一次\")
    @classmethod
    def tearDownClass(cls) -> None:
        print(\"整个测试类测试后调用,只是调用一次\")
    
    # 测试方法,以方法名为\"test_\" 开头的都是测试方法,会执行
    def test_fun(self) -> None:
        print(\"test_fun\")
`    
if [[ $is_c_project == \"y\" ]]; then
echo '
    def test_c_moduel(self):
        \"\"\"测试C语言封装
        :returns: 

        \"\"\"
        print(f\"C API封装, c_fun: {cfun.c_fun(50)}\")
        print(f\"pybind11 封装方法  c_class.add : {pybind11.add(1, 2)}\")
        
        box = pybind11.Box()
        box.set(1, 2, 3)
        print(f\"pybind11 封装类 Box.get() : {box.get()}\")


'
fi
`

    def test_fun_fail(self) -> None:
        self.fail(\"调用失败\")
    
    @unittest.skip(\"跳过测试(可以写在类和方法上,写类上跳过整个类的测试),使用注解 @unittest.skip(无条件) @unittest.skipUnless(需要条件) @unittest.skipIf(需要条件)\")
    # @unittest.skipIf(True, \"\")
    # @unittest.skipUnless(True, \"\")
    def test_skip(self) -> None:
        self.fail(\"跳过测试,这失败记录不会出现\")

if __name__ == \"__main__\" :
    unittest.main() # 运行全部

    # 分组测试,只是测试添加的 test_fun 方法
    # suite = unittest.TestSuite()
    # suite.addTest(TestExample(\"test_fun\"))
    # runner = unittest.TextTestRunner()
    # runner.run(suite)

